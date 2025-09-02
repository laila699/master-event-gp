import mongoose, { Document, Schema } from "mongoose";

export interface IBooking extends Document {
  event: mongoose.Types.ObjectId;
  offering: mongoose.Types.ObjectId;
  quantity: number;
  // ← new fields
  scheduledAt: Date; // ← scheduled date/time
  note?: string;
  rated: Boolean;

  status: "pending" | "confirmed" | "declined";
  createdAt: Date; // ← created date/time
  updatedAt: Date; 
}

const BookingSchema = new Schema<IBooking>(
  {
    event: { type: Schema.Types.ObjectId, ref: "Trip", required: true },//ref: "Trip" يسمح باستخدام populate لاسترجاع بيانات الحدث بسهولة.
    offering: { type: Schema.Types.ObjectId, ref: "Offering", required: true },
    quantity: { type: Number, default: 1 },
    rated: { type: Boolean, default: false }, 
    scheduledAt: { type: Date, required: true },// ← scheduled date/time
    // ← optional organizer note
    note: { type: String },
    status: {
      type: String,
      enum: ["pending", "confirmed", "declined"],
      default: "pending",
    },
  },
  { timestamps: true }
);

export default mongoose.model<IBooking>("Booking", BookingSchema);
