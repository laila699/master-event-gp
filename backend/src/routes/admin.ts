import express from "express";
import multer from "multer";
import { deleteUser, getAllUsers } from "../controllers/adminController";
import {
  createInvitationTheme,
  getInvitationThemes,
  updateInvitationTheme,
  deleteInvitationTheme,
} from "../controllers/invitationThemeController";
import { requireRole } from "../middleware/auth";
import { uploadThemeImages } from "../middleware/multer";
import User from "../models/User";
import { sendApprovalEmail } from "../utils/email";

const router = express.Router();

// simple disk storage – you can swap for Cloudinary, S3, etc.

// all admin routes should require the admin role

// ---- User management ----
router.get("/users", getAllUsers);

router.delete("/users/:id", deleteUser);

router.put("/users/:id/approve", async (req, res): Promise<any> => {
  try {
    const u = await User.findByIdAndUpdate(
      req.params.id,
      { active: true },
      { new: true }
    );
    if (!u) return res.status(404).send({ message: "User not found" });

    // Send approval email
    if (u.email) {
      sendApprovalEmail(u.email, u.name ?? "").catch((err) =>
        console.error("❌ Email error →", err)
      );
    }

    res.send(u);
  } catch (err: any) {
    res.status(500).send({ message: err.message });
  }
});

// ---- Invitation themes ----
router.post(
  "/invitation-themes",
  uploadThemeImages.single("image"),
  createInvitationTheme
);
router.get("/invitation-themes", getInvitationThemes);
router.put(
  "/invitation-themes/:id",
  uploadThemeImages.single("image"),
  updateInvitationTheme
);
router.delete("/invitation-themes/:id", deleteInvitationTheme);

export default router;
