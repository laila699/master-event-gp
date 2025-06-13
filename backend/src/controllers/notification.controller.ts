// src/controllers/notification.controller.ts

import { Request, Response } from "express";
import admin from "firebase-admin"; // default import, not * as
import PushToken from "../models/PushToken";
import User, { IUser } from "../models/User";

// Initialize Firebase Admin once (in your app’s entrypoint)
import { asyncHandler } from "../utils/asyncHandler";
import "../utils/firebase";
import { sendNotificationToUser } from "../utils/notify";
/**
 * Send a push notification to all of a user’s devices.
 * Uses sendMulticast, which is on admin.messaging().sendMulticast
 */

export const sendChatNotification = asyncHandler(
  async (req: Request, res: Response) => {
    const { chatId, senderId, text, recipients } = req.body as {
      chatId: string;
      senderId: string;
      text: string;
      recipients: string[];
    };
    if (!Array.isArray(recipients) || recipients.length === 0) {
      return res.status(400).json({ message: "No recipients provided." });
    }

    // Build a payload for FCM:
    const payload = {
      notification: {
        title: "رسالة جديدة",
        body: text.length > 50 ? text.substring(0, 47) + "…" : text,
      },
      data: { chatId, senderId },
    };

    // Fan-out to each user
    await Promise.all(
      recipients.map((uid) => sendNotificationToUser(uid, payload))
    );

    res.json({ success: true });
  }
);

// Save an FCM token on login
export const saveFcmToken = asyncHandler(
  async (req: Request, res: Response) => {
    const user = req.user as IUser;
    const { token } = req.body;
    if (!token) return res.status(400).json({ message: "Token is required" });

    // 1) Save in the User model
    if (!user.fcmTokens.includes(token)) {
      user.fcmTokens.push(token);
      await user.save();
    }

    // 2) Mirror to PushToken collection (optional)
    await PushToken.updateOne(
      { token },
      { token, user: user._id },
      { upsert: true }
    );

    res.json({ message: "FCM token saved" });
  }
);

// Remove an FCM token on logout
export const removeFcmToken = asyncHandler(
  async (req: Request, res: Response) => {
    const user = req.user as IUser;
    const { token } = req.body;
    if (!token) return res.status(400).json({ message: "Token is required" });

    user.fcmTokens = user.fcmTokens.filter((t) => t !== token);
    await user.save();
    await PushToken.deleteOne({ token });

    res.json({ message: "FCM token removed" });
  }
);
