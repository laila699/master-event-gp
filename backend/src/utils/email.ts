// choose ONE implementation (SMTP or SendGrid) ⬇ ⬇

/* ------------------------------------------------------------------
   Option A – Any SMTP account (Gmail, Mailtrap …)
------------------------------------------------------------------ */
import nodemailer from "nodemailer";
import dotenv from "dotenv";
dotenv.config();

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: Number(process.env.SMTP_PORT) || 587,
  secure: false, // true for 465
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

export async function sendInvitationEmail(
  to: string,
  eventTitle: string,
  hostName: string,
  date: Date
) {
  const mail = await transporter.sendMail({
    from: `"${hostName}" <${process.env.SMTP_FROM}>`,
    to,
    subject: `دعوة إلى ${eventTitle}`,
    html: `
      <h2 style="font-family:Tahoma">مرحبا!</h2>
      <p>تمت دعوتك إلى <strong>${eventTitle}</strong> بتاريخ
         <strong>${date.toLocaleDateString("ar-SA")}</strong>.</p>
      <p>نتطلع لرؤيتك 🎉</p>
    `,
  });
  return mail.accepted.length; // returns 1 on success
}

/* ------------------------------------------------------------------
   Option B – SendGrid (comment out Option A)
------------------------------------------------------------------ */
// import sgMail from "@sendgrid/mail";
// sgMail.setApiKey(process.env.SENDGRID_KEY!);

// export async function sendInvitationEmail(
//   to: string,
//   eventTitle: string,
//   hostName: string,
//   date: Date,
// ) {
//   await sgMail.send({
//     to,
//     from: process.env.SENDGRID_FROM!,        // verified sender
//     subject: `دعوة إلى ${eventTitle}`,
//     html: `… same body …`,
//   });
// }
