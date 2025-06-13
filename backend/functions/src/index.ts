// functions/src/index.ts
import {
  onDocumentCreated,
  FirestoreEvent,
} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

export const onMessageCreated = onDocumentCreated(
  "chats/{chatId}/messages/{msgId}",
  async (event: FirestoreEvent<any>) => {
    const { chatId } = event.params;
    const msg = event.data.data(); // FirestoreSnapshot
    const text = msg.text as string;
    const sender = msg.senderId as string;

    // 1) Update metadata
    await db.doc(`chats/${chatId}`).update({
      lastMessage: text,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 2) Load the conversation to get other participant
    const chatSnap = await db.doc(`chats/${chatId}`).get();
    const participants = chatSnap.data()?.participants as string[];
    const recipients = participants.filter((uid) => uid !== sender);

    // 3) Gather FCM tokens from Firestore (assumes you mirror tokens there)
    const tokens: string[] = [];
    for (const uid of recipients) {
      const userSnap = await db.doc(`users/${uid}`).get();
      const userTokens = (userSnap.data()?.fcmTokens as string) || [];
      tokens.push(...userTokens);
    }

    if (tokens.length === 0) return;

    // 4) Send the push
    const payload = {
      notification: {
        title: "New message",
        body: text.length > 50 ? text.substring(0, 47) + "…" : text,
      },
      data: { chatId, sender },
    };
    await admin.messaging().sendToDevice(tokens, payload);
  }
);
