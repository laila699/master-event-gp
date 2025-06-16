import mongoose, { Schema, Document } from "mongoose";

export interface IRating extends Document {
  organizerId: mongoose.Types.ObjectId; // who rated
  bookingId: mongoose.Types.ObjectId; // which booking unlocked the rating
  value: number; // 1–5
  review?: string; // optional comment
  ratedAt: Date;
}

export const RatingSchema = new Schema<IRating>(
  {
    organizerId: { type: Schema.Types.ObjectId, ref: "User", required: true },
    bookingId: { type: Schema.Types.ObjectId, ref: "Booking", required: true },
    value: { type: Number, min: 1, max: 5, required: true },
    review: { type: String, trim: true },
    ratedAt: { type: Date, default: Date.now },
  },
  { _id: false } // embedded, no own _id
);
