// src/utils/notification.ts
import PushToken from "../models/PushToken";
import admin from "./firebase";

export interface FcmPayload {
  notification: {
    title: string;
    body: string;
    imageUrl?: string;
  };
  data?: admin.messaging.DataMessagePayload;
  androidChannelId?: string;
}

export async function sendNotificationToUser(
  userId: string,
  payload: FcmPayload
) {
  // 1) load tokens from DB
  const docs = await PushToken.find({ user: userId }).select("token -_id");
  const tokens = docs.map((d) => d.token);

  if (tokens.length === 0) {
    console.log(`[FCM] no tokens for user ${userId}`);
    return;
  }

  const messaging = admin.messaging();

  // 2) build the base of your message (we’ll add token per-send)
  const baseMessage: Omit<admin.messaging.Message, "token"> = {
    notification: {
      title: payload.notification.title,
      body: payload.notification.body,
      imageUrl: payload.notification.imageUrl,
    },
    data: {
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      ...payload.data,
    },
    android: {
      notification: {
        channelId: payload.androidChannelId ?? "DEFAULT_CHANNEL",
        sound: "default",
      },
    },
  };

  // 3) send one-by-one
  const results = await Promise.all(
    tokens.map((token) =>
      messaging
        .send({ ...baseMessage, token })
        .then((responseId) => ({ token, success: true, responseId }))
        .catch((error) => ({ token, success: false, error }))
    )
  );

  const successCount = results.filter((r) => r.success).length;
  console.log(`[FCM] sent to ${successCount}/${tokens.length} tokens`);

  results
    .filter((r) => !r.success)
    .forEach((r) =>
      console.warn(`[FCM] failed token=${r.token}`, (r as any).error)
    );
}
