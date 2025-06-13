import mongoose from "mongoose";

const PushTokenSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  token: { type: String, required: true, unique: true },
});

export default mongoose.model("PushToken", PushTokenSchema);
