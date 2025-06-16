// src/utils/devMailer.ts
import nodemailer from "nodemailer";

declare global {
  // eslint-disable-next-line no-var
  var __devTransport: ReturnType<typeof nodemailer.createTransport> | undefined;
}

/**
 * For local/dev only: uses Ethereal test accounts.
 * Each time you run the app a fresh inbox is created.
 */
export async function getDevTransport() {
  // Only create once (singleton).
  if (globalThis.__devTransport) return globalThis.__devTransport;

  const testAcc = await nodemailer.createTestAccount(); // ← magic line
  const transport = nodemailer.createTransport({
    host: testAcc.smtp.host,
    port: testAcc.smtp.port,
    secure: testAcc.smtp.secure, // false for 587
    auth: {
      user: testAcc.user,
      pass: testAcc.pass,
    },
  });

  console.log("📧  Ethereal account created for dev mail:");
  console.log(`   Login: ${testAcc.user}`);
  console.log(`   Pass : ${testAcc.pass}`);
  console.log("   View any sent mail in the link printed after send()");

  globalThis.__devTransport = transport;
  return transport;
}
