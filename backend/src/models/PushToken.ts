// src/models/PushToken.ts
import mongoose from "mongoose";

const PushTokenSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  token: { type: String, required: true },
});

// a user can store the same token only once, but different users
// may store the same token on the rare case they share a device
PushTokenSchema.index({ user: 1, token: 1 }, { unique: true });

export default mongoose.model("PushToken", PushTokenSchema);