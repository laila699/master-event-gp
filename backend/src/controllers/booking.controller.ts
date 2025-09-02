import { Request, Response } from "express";
import Booking from "../models/Booking";
import { asyncHandler } from "../utils/asyncHandler"; // Utility to handle async errors
import Offering from "../models/Offering";
import Trip from "../models/Event";
import { Types } from "mongoose";
import { FcmPayload, sendNotificationToUser } from "../utils/notify"; 

// POST /api/bookings

export const createBooking = asyncHandler(
  async (req: Request, res: Response) => {
    const organizer = req.user!; // USER WHO IS MAKING THE BOOKING
    const { event, offering, quantity, scheduledAt, note } = req.body;

    if (!scheduledAt) { // تحقق من وجود scheduledAt
      return res.status(400).json({ message: "scheduledAt is required" });
    }

    // 1) create the booking IN THE DB
    const booking = await Booking.create({
      event,
      offering,
      quantity,
      scheduledAt: new Date(scheduledAt),
      note,
      user: organizer._id, // link BOOKING to the organizer
    });

    // 2) lookup offering to get vendor
    const off = await Offering.findById(offering); // find the offering الذي تم حجزه
    if (off) { // offering exists
      const vendorId = off.vendor.toString(); // convert vendor ID to string لارسال الاشعار

      // 3) build your FCM payload
      const title = "📅 طلب حجز جديد";
      const body = `${organizer.name} طلب ${off.title} بتاريخ ${new Date(
        scheduledAt
      ).toLocaleDateString("ar-EG")}`;

      const payload: FcmPayload = {
        notification: { title, body },
        data: {
          type: "NEW_BOOKING",
          bookingId: booking.id.toString(), // تساعد  يفتح شاشة جديدة عند يضغط ع الاشعار
          offeringId: offering.toString(),
          eventId: event.toString(),
        },
        androidChannelId: "BOOKING_CHANNEL", // قناة الاشعارات
      };

      // 4) fire‐and‐forget SEND NOTIFICATION TO VENDOR
      sendNotificationToUser(vendorId, payload).catch((err) =>
        console.error("FCM error (new booking):", err)
      );
    }

    // 5) respond AFTER SUCCESS THE BOOKING
    res.status(201).json(booking); // Return the created booking
  }
);

// GET /api/bookings?event=...
export const listBookings = asyncHandler(
  async (req: Request, res: Response) => {
    const { event } = req.query; // get event ID from query params
    if (!event) {
      return res.status(400).json({ message: "Trip ID is required" });
    }

    // Fetch bookings for that event, and populate both
    //   - 'offering' (and its vendor name)
    //   - 'event' (so you have title/date/venue)
    const bookings = await Booking.find({ event }) // يبحث في مجمّع الحجوزات (bookings collection) عن كل الحجوزات التي تتبع الحدث event.
      .populate({ 
        path: "offering",
        populate: { path: "vendor", select: "name" },
      })
      .populate({
        path: "event",
      });

    res.json(bookings); // برجع الحجوزات مع التفاصيل المربوطة
  }
);
/*
// GET /api/bookings/vendor
export const listVendorBookings = asyncHandler(
  async (req: Request, res: Response) => {
    const vendorId = req.user!._id; // get the current vendor's ID

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
    }); // filter bookings to only those that belong to the current vendor

    res.json(filtered);
  }
);
*/

export const listVendorBookings = asyncHandler( // قائمة الحجوزات الخاصة بالبائع
  async (req: Request, res: Response) => {
    const vendorId = req.user!._id;

    // Fetch only bookings where the offering.vendor = current vendor
    const bookings = await Booking.find()
      .populate({
        path: "offering",
        match: { vendor: vendorId }, //  إذا كان  الOFFER vendor  تبعه هو نفس CURRENT vendorId.
        populate: { path: "vendor", select: "name" },
      })
      .populate("event");

    //, بعض الحجوزات ممكن تكون null
    const filtered = bookings.filter((b) => b.offering != null);

    res.json(filtered); //بيرجع فقط الحجوزات اللي إلها علاقة بالـ vendor الحالي.
  }
);

// PUT /api/bookings/:id/status
export const updateBookingStatus = asyncHandler(
  async (req: Request, res: Response) => {
    const bookingId = req.params.id; // get booking ID from URL params
    const { status } = req.body as { status: "confirmed" | "declined" };

    // 1) find booking + offering in db
    const booking = await Booking.findById(bookingId).populate<{  // populate يجلب البيانات المرتبطة بالعرض offering
      offering: any; 
    }>("offering");
    if (!booking) return res.status(404).json({ message: "Booking not found" });

    const offering = await Offering.findById(booking.offering._id); // جلب بيانات العرض offering من قاعدة البيانات
    if (!offering)
      return res.status(404).json({ message: "Offering not found" });

    // 2) auth check: only vendor can update booking status
    if (offering.vendor.toString() !== req.user!._id.toString()) {   // التحقق من أن المستخدم الحالي هو البائع المرتبط بالعرض
      return res.status(403).json({ message: "Forbidden" });
    }

    // 3) update status
    booking.status = status;
    await booking.save(); // save the updated booking

    // 4) send push to the user who made the booking
    const title =
      status === "confirmed" ? "✅ تم تأكيد حجزك" : "❌ عذراً، تم رفض حجزك";
    const body =
      status === "confirmed"
        ? `حجز ${offering.title} الخاص بك قُبل بنجاح!` // Booking confirmed
        : `حجز ${offering.title} الخاص بك لم يتم قبوله.`; // Booking declined

    const payload: FcmPayload = {
      notification: { title, body },
      data: {
        type: "BOOKING_STATUS_CHANGED", // نوع الإشعار
        bookingId: booking.id.toString(), // ID of the booking
        status, // new status
      },
      androidChannelId: "BOOKING_CHANNEL",
    };
    // find the user from the event
    const event = await Trip.findById(booking.event); // جلب بيانات الحدث من قاعدة البيانات 
    if (!event) return res.status(404).json({ message: "Trip not found" });
    const user = event.organizer; // get the organizer of the event
    // fire and forget send notification
    sendNotificationToUser(user.toString(), payload).catch((err) =>
      console.error("FCM error:", err)
    );

    // 5) return updated booking
    res.json(booking);
  }
);
