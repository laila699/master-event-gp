// server/src/routes/chat.ts
import dotenv from "dotenv";
dotenv.config();

import express, { Request, Response } from "express";
import OpenAI from "openai";
import axios, { Method } from "axios";

const router = express.Router();
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
const API_BASE = process.env.API_BASE_URL || "http://localhost:5000/api";

router.post("/", async (req: Request, res: Response): Promise<any> => {
  const userMsg = String(req.body.message);
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ reply: "مطلوب تسجيل الدخول." });
  }

  try {
    // Ask GPT for plan: either NO_CALL or JSON { call, body }
    const plan = await openai.chat.completions.create({
      model: "gpt-3.5-turbo",
      messages: [
        {
          role: "system",
          content: `
أنت EventBot، مساعد عربي متخصص في تنظيم المناسبات باستخدام خدمات تطبيقنا فقط.
يمكنك استدعاء أي نقطة نهاية ضمن مسارات API الخاصة بنا فقط:
- /api/events
- /api/bookings
- /api/vendors
- /api/vendors/:vendorId/menu
- /api/vendors/:vendorId/offerings
- /api/vendors/:vendorId/offerings/:offeringId

عندما يطلب المستخدم بيانات من هذه الخدمات (مثل قائمة الأحداث أو قائمة المزودين حسب النوع أو قائمة العروض أو قائمة المأكولات من قائمة المطعم)،
أجب أولاً بإخراج JSON مختصر يصف:
  { "call": "<METHOD> <PATH>", "body": {…} }
حيث <PATH> هو المسار النسبي بدون /api، وbody هو جسم الطلب.

على سبيل المثال:
- للحصول على عروض مزود محدد:
  { "call": "GET /vendors/:vendorId/offerings", "body": { "vendorId": "abc123" } }
- للحصول على عرض مفرد:
  { "call": "GET /vendors/:vendorId/offerings/:offeringId", "body": { "vendorId": "abc123", "offeringId": "off456" } }
- للحصول على قائمة المطعم من القائمة:
  { "call": "GET /vendors/:vendorId/menu", "body": { "vendorId": "abc123" } }

وإذا كانت الأسئلة عامة (مثل نصائح حول الميزانية أو أفكار ديكور)،
فلا تستدعي أي نقطة نهاية وارجع ببساطة إجابة عربية مفصلة.

لا تخرج عن هذه المسارات ولا تذكر صيغ JSON في الرد النهائي، بل استخدم JSON فقط لتخطيط الاستدعاء.
لا تخرج عن سياق التطبيق، ولا تتناول مواضيع عامة أو خارجية.

`,
        },
        { role: "user", content: userMsg },
      ],
    });

    const rawPlan = plan.choices[0].message?.content?.trim() || "";

    // If no call is needed
    if (rawPlan === "NO_CALL") {
      const replyOnly = await openai.chat.completions.create({
        model: "gpt-3.5-turbo",
        messages: [
          { role: "system", content: "أجب بالعربية وبأسلوب مهني وودود." },
          { role: "user", content: userMsg },
        ],
      });
      return res.json({ reply: replyOnly.choices[0].message?.content?.trim() });
    }

    // Parse JSON plan
    let payload: { call: string; body?: any };
    try {
      payload = JSON.parse(rawPlan);
    } catch {
      const fallback = await openai.chat.completions.create({
        model: "gpt-3.5-turbo",
        messages: [
          { role: "system", content: "أجب بالعربية وبأسلوب مهني وودود." },
          { role: "user", content: userMsg },
        ],
      });
      return res.json({ reply: fallback.choices[0].message?.content?.trim() });
    }

    // Resolve vendorId placeholder if present
    const [methodRaw, ...pathParts] = payload.call.split(" ");
    const method = methodRaw.toUpperCase() as Method;
    let path = pathParts.join(" ");
    // If path contains :vendorId, replace from body
    // inside your route handler, before building `url`:
    if (path.includes(":vendorId")) {
      let vid = payload.body?.vendorId;

      // 1) No vendorId → list vendors for organizer to choose
      if (!vid) {
        const vendorsResp = await axios.get(`${API_BASE}/vendors`, {
          headers: { Authorization: authHeader },
        });
        const listText = vendorsResp.data
          .map((v: any, i: number) => `${i + 1}. ${v.name} (ID: ${v.id})`)
          .join("\n");
        return res.json({
          reply: `يرجى اختيار المزود من القائمة التالية:\n${listText}`,
        });
      }

      // 2) If the user sent a number, map to index
      if (/^\d+$/.test(vid)) {
        const idx = parseInt(vid, 10) - 1;
        const vendorsResp = await axios.get(`${API_BASE}/vendors`, {
          headers: { Authorization: authHeader },
        });
        const vendors = vendorsResp.data;
        if (idx < 0 || idx >= vendors.length) {
          return res.json({
            reply: `الرقم غير صالح، يرجى اختيار رقم بين 1 و ${vendors.length}`,
          });
        }
        vid = vendors[idx].id;
      }
      // 3) If it’s not a 24-hex ObjectId, look up by name
      else if (!/^[0-9a-fA-F]{24}$/.test(vid)) {
        const vendorsResp = await axios.get(`${API_BASE}/vendors`, {
          headers: { Authorization: authHeader },
        });
        const found = vendorsResp.data.find((v: any) => v.name === vid);
        if (!found) {
          return res.json({ reply: `لم يتم العثور على المزود بالاسم: ${vid}` });
        }
        vid = found.id;
      }

      // 4) Substitute into path
      path = path.replace(/:vendorId/g, vid);
    }

    // If path contains :id for events
    if (path.match(/^\/events\/:id(?:$|\/)/)) {
      const eid = payload.body?.id;
      if (!eid) {
        const eventsResp = await axios({
          method: "get",
          url: `${API_BASE}/events`,
          headers: { Authorization: authHeader },
        });
        const events = eventsResp.data;
        const listText = events
          .map(
            (e: any, i: number) =>
              `${i + 1}. ${e.title} بتاريخ ${new Date(
                e.date
              ).toLocaleDateString("ar-EG")} (ID: ${e.id})`
          )
          .join("");
        return res.json({
          reply: `يرجى اختيار المناسبة من القائمة التالية:
${listText}`,
        });
      }
      path = path.replace(/:id/g, eid);
    }

    // If path contains :guestId, ensure we have event ID
    if (path.includes(":guestId")) {
      const eid = payload.body?.id || payload.body?.eventId;
      if (!eid) {
        const eventsResp = await axios({
          method: "get",
          url: `${API_BASE}/events`,
          headers: { Authorization: authHeader },
        });
        const events = eventsResp.data;
        const listText = events
          .map((e: any, i: number) => `${i + 1}. ${e.title} (ID: ${e.id})`)
          .join("");
        return res.json({
          reply: `يرجى اختيار المناسبة أولًا من القائمة التالية:
${listText}`,
        });
      }
      // fetch guests list for that event
      const guestsResp = await axios({
        method: "get",
        url: `${API_BASE}/events/${eid}/guests`,
        headers: { Authorization: authHeader },
      });
      const guests = guestsResp.data;
      const listText = guests
        .map(
          (g: any, i: number) =>
            `${i + 1}. ${g.name} (${g.email}) (ID: ${g.id})`
        )
        .join("");
      return res.json({
        reply: `يرجى اختيار الضيف من القائمة التالية:
${listText}`,
      });
    }

    const url = `${API_BASE}${path.startsWith("/") ? path : `/${path}`}`;
    `${API_BASE}${path.startsWith("/") ? path : `/${path}`}`;
    `${API_BASE}${path.startsWith("/") ? path : `/${path}`}`;

    const axiosCfg: any = {
      method,
      url,
      headers: { Authorization: authHeader },
    };

    if (payload.body && Object.keys(payload.body).length) {
      axiosCfg.data = payload.body;
    }
    const apiResp = await axios(axiosCfg);
    const apiData = apiResp.data;

    // Final Arabic reply based on real data
    const final = await openai.chat.completions.create({
      model: "gpt-3.5-turbo",
      messages: [
        {
          role: "system",
          content: `
لقد حصلت على هذه البيانات من خادمك:
${JSON.stringify(apiData)}

أجب الآن بالعربية فقط، دون ذكر JSON أو تفاصيل تقنية، وسردٌ واضح يلبي طلب المستخدم:
"${userMsg}"
          `,
        },
      ],
    });

    return res.json({ reply: final.choices[0].message?.content?.trim() });
  } catch (err: any) {
    console.error("Chat error:", err);
    if (err.code === "insufficient_quota" || err.status === 429) {
      return res
        .status(429)
        .json({ reply: "آسف، الخدمة غير متاحة الآن؛ حاول لاحقًا." });
    }
    return res
      .status(500)
      .json({ reply: "حدث خطأ في الخادم أثناء الاتصال بالبوت." });
  }
});

export default router;
