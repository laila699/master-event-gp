// scripts/createAdmin.js
import mongoose from "mongoose";
// ✅ Use bcryptjs, which you already have:
import bcrypt from "bcryptjs";
import User from "../models/User"; // adjust path if needed

async function run() {
  await mongoose.connect("mongodb://localhost:27017/eventmgmt");

  const email = "admin@example.com";
  const existing = await User.findOne({ email });
  if (existing) {
    console.log("Admin user already exists");
    process.exit(0);
  }

  const passwordHash = await bcrypt.hash("pass123", 12);
  const admin = await User.create({
    name: "Super Admin",
    email,
    passwordHash,
    role: "admin",
    phone: "0000000000",
    fcmTokens: [],
  });

  console.log("Created admin:", admin);
  process.exit(0);
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
