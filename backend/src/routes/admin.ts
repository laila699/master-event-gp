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

const router = express.Router();

// simple disk storage – you can swap for Cloudinary, S3, etc.

// all admin routes should require the admin role

// ---- User management ----
router.get("/users", getAllUsers);

router.delete("/users/:id", deleteUser);

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
