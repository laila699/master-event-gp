import mongoose, { Document, Schema } from "mongoose";

export interface IInvitationTheme extends Document {
  name: string;
  imageUrl: string; // URL or path to the uploaded image
  createdAt: Date;
  updatedAt: Date;
}

const InvitationThemeSchema = new Schema<IInvitationTheme>(
  {
    name: { type: String, required: true },
    imageUrl: { type: String, required: true },
  },
  { timestamps: true }
);

export default mongoose.model<IInvitationTheme>(
  "InvitationTheme",
  InvitationThemeSchema
);
