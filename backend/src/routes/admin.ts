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

const router = express.Router();

// simple disk storage – you can swap for Cloudinary, S3, etc.
const upload = multer({ dest: "uploads/invitation-themes/" });

// all admin routes should require the admin role
router.use(requireRole("admin"));

// ---- User management ----
router.get("/users", getAllUsers);
router.delete("/users/:id", deleteUser);

// ---- Invitation themes ----
router.post(
  "/invitation-themes",
  upload.single("image"),
  createInvitationTheme
);
router.get("/invitation-themes", getInvitationThemes);
router.put(
  "/invitation-themes/:id",
  upload.single("image"),
  updateInvitationTheme
);
router.delete("/invitation-themes/:id", deleteInvitationTheme);

export default router;
