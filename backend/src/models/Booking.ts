import mongoose, { Document, Schema } from "mongoose";

export interface IBooking extends Document {
  event: mongoose.Types.ObjectId;
  offering: mongoose.Types.ObjectId;
  quantity: number;
  // ← new fields
  scheduledAt: Date;
  note?: string;
  rated: Boolean;

  status: "pending" | "confirmed" | "declined";
  createdAt: Date;
  updatedAt: Date;
}

const BookingSchema = new Schema<IBooking>(
  {
    event: { type: Schema.Types.ObjectId, ref: "Event", required: true },
    offering: { type: Schema.Types.ObjectId, ref: "Offering", required: true },
    quantity: { type: Number, default: 1 },
    rated: { type: Boolean, default: false }, // ← scheduled date/time
    scheduledAt: { type: Date, required: true },
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
