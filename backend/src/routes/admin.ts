import express from "express";
import multer from "multer";
import { deleteUser, getAllUsers } from "../controllers/adminController";
import {
  createInvitationTheme,
  getInvitationThemes,
  updateInvitationTheme,
  deleteInvitationTheme,
} from "../controllers/invitationThemeController";
import { requireRole } from "../middleware/auth"; // Middleware to check for admin role
import { uploadThemeImages } from "../middleware/multer"; // Middleware for handling theme image uploads
import User from "../models/User"; 
import { sendApprovalEmail } from "../utils/email"; // لتبعت ايميل موافقة

const router = express.Router(); //(sub-router) خاص بمسارات الأدمن.

// simple disk storage – you can swap for Cloudinary, S3, etc.

// all admin routes should require the admin role

// ---- User management ----
router.get("/users", getAllUsers);

router.delete("/users/:id", deleteUser);

router.put("/users/:id/approve", async (req, res): Promise<any> => {
  try {
    const u = await User.findByIdAndUpdate(
      req.params.id,// ال ID بتاع المستخدم
      { active: true }, // تفعيل المستخدم
      { new: true } // Return the updated user
    );
    if (!u) return res.status(404).send({ message: "User not found" });

    // Send approval email
    if (u.email) {
      sendApprovalEmail(u.email, u.name ?? "").catch((err) =>
        console.error("❌ Email error →", err)
      );
    }

    res.send(u); // Return the updated user as JSON
  } catch (err: any) {
    res.status(500).send({ message: err.message });
  }
});

// ---- Invitation themes ----
router.post(
  "/invitation-themes",
  uploadThemeImages.single("image"), // يرفع صورة 
  createInvitationTheme
);
router.get("/invitation-themes", getInvitationThemes);
router.put( // update an existing theme
  "/invitation-themes/:id",
  uploadThemeImages.single("image"),
  updateInvitationTheme
);
router.delete("/invitation-themes/:id", deleteInvitationTheme);

export default router;
