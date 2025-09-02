// src/controllers/event.controller.ts
import { Request, Response, NextFunction } from "express";
import Trip from "../models/Event";
import { asyncHandler } from "../utils/asyncHandler";
import mongoose from "mongoose";
import { sendInvitationEmail } from "../utils/email";

// POST /api/events
export const createTrip = asyncHandler(async (req: Request, res: Response) => {
  const organizerId = req.user!._id;
  const { title, date, venue, venueLocation } = req.body; //destructure the request body

  // Build a payload object, only including venueLocation if it's valid
  const payload: any = {
    organizer: organizerId, // Set the organizer to the authenticated user
    title,
    date: new Date(date), // Ensure date is a Date object
    venue, //location can be a string or an object
  };

  // venueLocation should be { type: 'Point', coordinates: [lng, lat] }
  if (
    venueLocation &&
    Array.isArray(venueLocation.coordinates) &&
    venueLocation.coordinates.length === 2
  ) {
    payload.venueLocation = venueLocation; // Only set venueLocation if it's a valid GeoJSON Point
  }

  const event = await Trip.create(payload); // Create the event with the payload

  // Return the full document, including the newly‐written venueLocation
  res.status(201).json(event);
});

// GET /api/events
export const listMyTrips = asyncHandler(
  async (req: Request, res: Response) => {
    const organizerId = req.user!._id;
    const events = await Trip.find({ organizer: organizerId }); // Find all events for the authenticated organizer
    res.json(events);
  }
);

// GET /api/events/:id
export const getTripById = asyncHandler(
  async (req: Request, res: Response) => {
    const { id } = req.params; // Get the event ID from the request parameters
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ message: "Invalid event ID" });
    }
    const event = await Trip.findById(id); // Find the event by ID
    if (!event) return res.status(404).json({ message: "Trip not found" });
    res.json(event); // Return the event details if found
  }
);

// PUT /api/events/:id
export const updateTrip = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params; // Get the event ID from the request parameters 
  const organizerId = req.user!._id; // is not null

  // Extract settings if present, and everything else
  const { settings, ...rest } = req.body;

  // Build a $set object:
  const setOps: Record<string, any> = { ...rest };

  if (settings && typeof settings === "object") { // Check if settings is an object
    // For each field in settings, dot‐set it
    for (const [key, val] of Object.entries(settings)) { // loop through  key settings
      setOps[`settings.${key}`] = val; // add the settings fields to the $set object
    }
  }

  // Now perform an atomic update
  const updated = await Trip.findOneAndUpdate( // تحديث سجل واحد في قاعدة البيانات
    { _id: id, organizer: organizerId },
    { $set: setOps }, // Use $set to update only the specified fields
    { new: true } // Return the updated document
  );

  if (!updated) {
    return res
      .status(404)
      .json({ message: "Trip not found or you are not the organizer" });
  }

  res.json(updated);
});

// DELETE /api/events/:id
export const deleteTrip = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const organizerId = req.user!._id;
  const deleted = await Trip.findOneAndDelete({
    _id: id,
    organizer: organizerId,
  });
  if (!deleted)
    return res.status(404).json({ message: "Trip not found or forbidden" });
  res.sendStatus(204);
});

// POST /api/events/:id/members
export const addMember = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const { name, email } = req.body;

  const event = await Trip.findById(id); // find the event by ID
  if (!event) return res.status(404).json({ message: "Trip not found" });

  // Check if email already exists in guests
  const emailExists = event.guests.some(
    (g: any) => g.email.toLowerCase() === email.toLowerCase()
  );
  if (emailExists) {
    return res
      .status(400)
      .json({ message: "This email is already added as a guest." });
  }

  event.guests.push({ name, email, status: "pending" } as any); // Add the new guest with status "pending"
  await event.save();

  try {
    console.log(`Sending invitation email to ${email}...`);
    const mailSent = await sendInvitationEmail(email, event.title, event.date);
    console.log(
      `Email sent successfully to ${email}. Accepted count: ${mailSent}`
    );
  } catch (err) {
    console.error("E-mail sending error →", err);
  }

  res.status(201).json({ message: "Member added & email processed" }); // Return success response
});

// PUT /api/events/:id/guests/:guestId
export const updateMemberStatus = asyncHandler(
  async (req: Request, res: Response) => {
    const { id, guestId } = req.params;
    const { status } = req.body as { status: "pending" | "yes" | "no" };
    const event = await Trip.findById(id);
    if (!event) return res.status(404).json({ message: "Trip not found" });
    const guest = event.guests.find((g: any) => g._id?.toString() === guestId); // find the guest by ID
    if (!guest) return res.status(404).json({ message: "Member not found" });
    guest.status = status; // Update the guest's status
    await event.save();
    res.json(event);
  }
);
