import { Router } from "express";
import {
  saveFcmToken,
  removeFcmToken,
  sendChatNotification,
} from "../controllers/notification.controller";
import { requireAuth } from "../middleware/auth";

const router = Router();

// Save a device's FCM token
router.post("/token", requireAuth, saveFcmToken); // حفظ توكن fcm لجهاز المستخدم
router.post("/chat", sendChatNotification); //ارسال اشعار fcm عند مستخدم يرسل رسالة لمستخدم اخر

// Remove a token
router.delete("/token", requireAuth, removeFcmToken);

export default router;
