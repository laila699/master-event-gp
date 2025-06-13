import { Router } from "express";
import {
  saveFcmToken,
  removeFcmToken,
  sendChatNotification,
} from "../controllers/notification.controller";
import { requireAuth } from "../middleware/auth";

const router = Router();

// Save a device's FCM token
router.post("/token", requireAuth, saveFcmToken);
router.post("/chat", sendChatNotification);

// Remove a token
router.delete("/token", requireAuth, removeFcmToken);

export default router;
