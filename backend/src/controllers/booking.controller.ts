import { Request, Response } from "express";
import Booking from "../models/Booking";
import { asyncHandler } from "../utils/asyncHandler";
import Offering from "../models/Offering";
import Event from "../models/Event";
import { Types } from "mongoose";
import { FcmPayload, sendNotificationToUser } from "../utils/notify";

// POST /api/bookings

export const createBooking = asyncHandler(
  async (req: Request, res: Response) => {
    const organizer = req.user!;
    const { event, offering, quantity, scheduledAt, note } = req.body;

    if (!scheduledAt) {
      return res.status(400).json({ message: "scheduledAt is required" });
    }

    // 1) create the booking
    const booking = await Booking.create({
      event,
      offering,
      quantity,
      scheduledAt: new Date(scheduledAt),
      note,
      user: organizer._id,
    });

    // 2) lookup offering to get vendor
    const off = await Offering.findById(offering);
    if (off) {
      const vendorId = off.vendor.toString();

      // 3) build your FCM payload
      const title = "📅 طلب حجز جديد";
      const body = `${organizer.name} طلب ${off.title} بتاريخ ${new Date(
        scheduledAt
      ).toLocaleDateString("ar-EG")}`;

      const payload: FcmPayload = {
        notification: { title, body },
        data: {
          type: "NEW_BOOKING",
          bookingId: booking.id.toString(),
          offeringId: offering.toString(),
          eventId: event.toString(),
        },
        androidChannelId: "BOOKING_CHANNEL",
      };

      // 4) fire‐and‐forget
      sendNotificationToUser(vendorId, payload).catch((err) =>
        console.error("FCM error (new booking):", err)
      );
    }

    // 5) respond
    res.status(201).json(booking);
  }
);

// GET /api/bookings?event=...
export const listBookings = asyncHandler(
  async (req: Request, res: Response) => {
    const { event } = req.query;
    if (!event) {
      return res.status(400).json({ message: "Event ID is required" });
    }

    // Fetch bookings for that event, and populate both
    //   - 'offering' (and its vendor name)
    //   - 'event' (so you have title/date/venue)
    const bookings = await Booking.find({ event })
      .populate({
        path: "offering",
        populate: { path: "vendor", select: "name" },
      })
      .populate({
        path: "event",
      });

    res.json(bookings);
  }
);

// GET /api/bookings/vendor
export const listVendorBookings = asyncHandler(
  async (req: Request, res: Response) => {
    const vendorId = req.user!._id;

    // populate offering → vendor and event
    const bookings = await Booking.find()
      .populate({
        path: "offering",
        populate: { path: "vendor", select: "name" },
      })
      .populate("event");
    // filter only those where offering.vendor === current vendor
    const filtered = bookings.filter((b) => {
      const off = b.offering as any; // populated

      return (
        off.vendor &&
        (off.vendor._id as Types.ObjectId).toString() === vendorId.toString()
      );
    });

    res.json(filtered);
  }
);

// PUT /api/bookings/:id/status
export const updateBookingStatus = asyncHandler(
  async (req: Request, res: Response) => {
    const bookingId = req.params.id;
    const { status } = req.body as { status: "confirmed" | "declined" };

    // 1) find booking + offering
    const booking = await Booking.findById(bookingId).populate<{
      offering: any;
    }>("offering");
    if (!booking) return res.status(404).json({ message: "Booking not found" });

    const offering = await Offering.findById(booking.offering._id);
    if (!offering)
      return res.status(404).json({ message: "Offering not found" });

    // 2) auth check: only vendor can update
    if (offering.vendor.toString() !== req.user!._id.toString()) {
      return res.status(403).json({ message: "Forbidden" });
    }

    // 3) update status
    booking.status = status;
    await booking.save();

    // 4) send push to the user who made the booking
    const title =
      status === "confirmed" ? "✅ تم تأكيد حجزك" : "❌ عذراً، تم رفض حجزك";
    const body =
      status === "confirmed"
        ? `حجز ${offering.title} الخاص بك قُبل بنجاح!`
        : `حجز ${offering.title} الخاص بك لم يتم قبوله.`;

    const payload: FcmPayload = {
      notification: { title, body },
      data: {
        type: "BOOKING_STATUS_CHANGED",
        bookingId: booking.id.toString(),
        status,
      },
      androidChannelId: "BOOKING_CHANNEL",
    };
    // find the user from the event
    const event = await Event.findById(booking.event);
    if (!event) return res.status(404).json({ message: "Event not found" });
    const user = event.organizer;
    // fire and forget
    sendNotificationToUser(user.toString(), payload).catch((err) =>
      console.error("FCM error:", err)
    );

    // 5) return updated booking
    res.json(booking);
  }
);
