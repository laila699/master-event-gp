import { Router } from "express";
import {
  createBooking,
  listBookings,
  listVendorBookings,
  updateBookingStatus,
} from "../controllers/booking.controller";
import { requireRole } from "../middleware/auth";

const router = Router();

// Organizer books an offering
router.post("/", requireRole("organizer"), createBooking); //requireRole("organizer") يتحقق المستخدم هو منظم

// Organizer views all bookings 
router.get("/", listBookings);

router.get("/vendor", requireRole("vendor"), listVendorBookings); //حجوزات خاصة بالبائع

// Vendor updates booking status
router.put("/:id/status", requireRole("vendor"), updateBookingStatus);

export default router;
