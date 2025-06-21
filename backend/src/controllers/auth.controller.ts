// src/controllers/auth.controller.ts

import { Request, Response, NextFunction } from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import User, { IUser, VendorServiceType } from "../models/User";
import { asyncHandler } from "../utils/asyncHandler";
import { uploadAvatar } from "../middleware/multer";
import { defaultVendorAttributes } from "../utils/defaultVendorAttributes";
import { sendNotificationToUser } from "../utils/notify";
import admin from "../utils/firebase";
const JWT_EXPIRES_IN = "7d";

// ─── Multer setup (same as before) ───────────────────────────────────────────────

// ─── Existing register, login, getMe (unchanged) ────────────────────────────────
// (As in your previous code)
export const register = [
  uploadAvatar.single("profileImage"),
  asyncHandler(async (req: Request, res: Response) => {
    const { name, email, password, role, phone, vendorProfile } = req.body;
    if (!name || !email || !password || !role || !phone) {
      return res.status(400).json({ message: "جميع الحقول مطلوبة." });
    }

    // Prevent duplicate emails
    if (await User.exists({ email })) {
      return res
        .status(409)
        .json({ message: "هذا البريد الإلكتروني مستخدم بالفعل." });
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // Handle avatar upload
    let avatarUrl: string | undefined;
    if (req.file) {
      avatarUrl = `/uploads/avatars/${req.file.filename}`;
    }

    // Base fields
    const userFields: Partial<IUser> = {
      name,
      email,
      passwordHash,
      role,
      phone,
      avatarUrl,
    };

    // If vendor, build vendorProfile with seeded attributes
    if (role === "vendor") {
      if (!vendorProfile) {
        return res
          .status(400)
          .json({ message: "vendorProfile مطلوب للبائعين." });
      }

      let parsed: any;
      try {
        parsed =
          typeof vendorProfile === "string"
            ? JSON.parse(vendorProfile)
            : vendorProfile;
      } catch {
        return res
          .status(400)
          .json({ message: "تنسيق vendorProfile غير صحيح." });
      }

      const { serviceType, bio, location } = parsed as {
        serviceType: VendorServiceType;
        bio?: string;
        location?: { type: "Point"; coordinates: [number, number] };
      };

      if (!serviceType) {
        return res
          .status(400)
          .json({ message: "serviceType مطلوب في vendorProfile." });
      }

      // Seed attributes based on serviceType
      const attrs = defaultVendorAttributes[serviceType] || [];
      const attributes = attrs.map((a) => ({
        ...a,
        value: a.value ?? (a.type === "array" ? [] : null),
      }));

      userFields.vendorProfile = {
        serviceType,
        bio,
        location,
        attributes,
      };
    }

    // Save user
    const user = new User(userFields);
    await user.save();
    if (role === "vendor") {
      const admins = await User.find({ role: "admin" }).select("_id name");
      const payload = {
        notification: {
          title: "🧾 مقدم خدمة جديد",
          body: `${name} قام بالتسجيل كمقدم خدمة جديد.`,
        },
      };
      for (const admin of admins) {
        await sendNotificationToUser(admin._id.toString(), payload);
      }
    }
    // Generate JWT
    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET!, {
      expiresIn: JWT_EXPIRES_IN,
    });

    // Return user + token (including vendorProfile!)
    res.status(201).json({
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        phone: user.phone,
        avatarUrl: user.avatarUrl || null,
        vendorProfile: user.vendorProfile || null,
      },
    });
  }),
];
export const login = asyncHandler(async (req: Request, res: Response) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res
      .status(400)
      .json({ message: "الرجاء إدخال البريد وكلمة المرور." });
  }

  // 1) Find user by email
  const user = await User.findOne({ email });
  console.log("user", user);
  if (!user) {
    return res.status(401).json({ message: "بيانات الاعتماد غير صحيحة." });
  }

  // 2) Compare password
  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) {
    return res.status(401).json({ message: "بيانات الاعتماد غير صحيحة." });
  }
  if (user.role === "vendor" && !user.active) {
    return res
      .status(403)
      .json({ message: "حسابك قيد المراجعة حالياً، سيتم تفعيله قريباً." });
  }

  // 3) Generate JWT
  const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET!, {
    expiresIn: JWT_EXPIRES_IN,
  });

  const firebaseToken = await admin
    .auth()
    .createCustomToken(user._id.toString());

  // 4) Return token + user info (including phone + avatarUrl + vendorProfile)
  res.json({
    token,
    user: {
      id: user._id,
      name: user.name,
      email: user.email,
      role: user.role,
      phone: user.phone,
      avatarUrl: user.avatarUrl || null,
      vendorProfile: user.vendorProfile || null,
    },
    firebaseToken,
  });
});

export const getUserById = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const user = await User.findById(id).select("name"); // only need name
  if (!user) {
    return res.status(404).json({ message: "User not found." });
  }
  res.json({ id: user._id, name: user.name });
});
export const getMe = asyncHandler(async (req: Request, res: Response) => {
  const user = req.user as IUser;
  if (!user) {
    return res.status(401).json({ message: "غير مسجل الدخول." });
  }

  // Return all relevant fields, exactly as Flutter’s `User.fromJson` expects:
  res.json({
    id: user._id,
    name: user.name,
    email: user.email,
    role: user.role,
    phone: user.phone,
    avatarUrl: user.avatarUrl || null,
    vendorProfile: user.vendorProfile || null,
  });
});

// ─── 3.5 New: updateMe Controller ───────────────────────────────────────────────

/**
 * PUT /api/auth/me
 * Protected. Accepts multipart/form-data with optional `profileImage`.
 * Body can include: { name, email, phone } to update. If `role` should not be editable, omit it.
 */
export const updateMe = [
  uploadAvatar.single("profileImage"),
  asyncHandler(async (req: Request, res: Response) => {
    const userId = (req.user as IUser).id; // typed as IUser

    // Build an update object (Partial<IUser>)
    const updates: Partial<IUser> = {};

    if (req.body.name) updates.name = req.body.name;
    if (req.body.email) updates.email = req.body.email;
    if (req.body.phone) updates.phone = req.body.phone;
    // We do NOT allow role changes here for security.

    if (req.file) {
      updates.avatarUrl = `/uploads/avatars/${req.file.filename}`;
    }

    // 1) If email is changing, ensure uniqueness
    if (updates.email) {
      const existing = await User.findOne({
        email: updates.email,
        _id: { $ne: userId },
      });
      if (existing) {
        return res
          .status(409)
          .json({ message: "هذا البريد الإلكتروني مستخدم بالفعل." });
      }
    }

    // 2) Perform the update
    const user = await User.findByIdAndUpdate(userId, updates, {
      new: true,
      runValidators: true,
    });

    if (!user) {
      return res.status(404).json({ message: "المستخدم غير موجود." });
    }
    // let test notfiaction here

    // 3) Send back the updated user (same shape as getMe)
    res.json({
      id: user._id,
      name: user.name,
      email: user.email,
      role: user.role,
      phone: user.phone,
      avatarUrl: user.avatarUrl || null,
      vendorProfile: user.vendorProfile || null,
    });
  }),
];
