import dotenv from "dotenv";
dotenv.config();


//تهيئة api 
import sgMail from "@sendgrid/mail";
sgMail.setApiKey(process.env.SENDGRID_KEY!);

export async function sendInvitationEmail(
  to: string,
  eventTitle: string,
  date: Date
) {
  // إعداد البريد الإلكتروني
  await sgMail.send({
    to,
    from: process.env.SENDGRID_FROM!,
    subject: `دعوة إلى ${eventTitle}`,
    html: `
      <div style="background-color:#f9f9f9; padding:30px; font-family:'Tahoma', sans-serif; color:#333;">
        <div style="max-width:600px; margin:auto; background:white; border-radius:8px; overflow:hidden; box-shadow:0 0 10px rgba(0,0,0,0.05);">
          <div style="background-color:#6200ee; color:white; padding:20px; text-align:center;">
            <h1 style="margin:0;">🎉 دعوة للمشاركة بالرحلة</h1>
          </div>
          <div style="padding:30px;">
            <p style="font-size:18px;">مرحباً،</p>
            <p style="font-size:16px;">
              تمت دعوتك لحضور <strong>${eventTitle}</strong> بتاريخ 
              <strong>${date.toLocaleDateString("ar-SA")}</strong>.
            </p>
            <p style="font-size:16px;">
              نتحمس لرؤيتك في هذه الرحلة  المميزة. 🎊
            </p>
            <hr style="border:none; border-top:1px solid #eee; margin:20px 0;">
            <p style="font-size:14px; color:#888;">يرجى عدم الرد على هذا البريد. لمزيد من التفاصيل، تواصل معنا عبر التطبيق.</p>
          </div>
          <div style="background-color:#f1f1f1; text-align:center; padding:15px; font-size:12px; color:#999;">
            ©️ ${new Date().getFullYear()} Master Trip — جميع الحقوق محفوظة.
          </div>
        </div>
      </div>
    `,
  });
}
export async function sendApprovalEmail(to: string, name: string) {
  await sgMail.send({
    to,
    from: process.env.SENDGRID_FROM!,
    subject: `تمت الموافقة على حسابك في Master Trip`,
    html: `
      <div style="background-color:#f9f9f9; padding:30px; font-family:'Tahoma', sans-serif; color:#333;">
        <div style="max-width:600px; margin:auto; background:white; border-radius:8px; overflow:hidden; box-shadow:0 0 10px rgba(0,0,0,0.05);">
          <div style="background-color:#4CAF50; color:white; padding:20px; text-align:center;">
            <h1 style="margin:0;">✔ تم تفعيل حسابك</h1>
          </div>
          <div style="padding:30px;">
            <p style="font-size:18px;">مرحباً ${name || "المستخدم"},</p>
            <p style="font-size:16px;">
              تمت الموافقة على حسابك بنجاح! يمكنك الآن الدخول إلى تطبيق Master Trip والاستفادة من جميع الميزات.
            </p>
            <p style="font-size:16px;">
              نحن سعداء بانضمامك إلينا. 🎉
            </p>
            <hr style="border:none; border-top:1px solid #eee; margin:20px 0;">
            <p style="font-size:14px; color:#888;">يرجى عدم الرد على هذا البريد. لأي استفسار، تواصل معنا عبر التطبيق.</p>
          </div>
          <div style="background-color:#f1f1f1; text-align:center; padding:15px; font-size:12px; color:#999;">
            ©️ ${new Date().getFullYear()} Master Trip — جميع الحقوق محفوظة.
          </div>
        </div>
      </div>
    `,
  });
}