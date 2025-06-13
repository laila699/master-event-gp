// src/controllers/event.controller.ts
import { Request, Response, NextFunction } from "express";
import Event from "../models/Event";
import { asyncHandler } from "../utils/asyncHandler";
import mongoose from "mongoose";

// POST /api/events
export const createEvent = asyncHandler(async (req: Request, res: Response) => {
  const organizerId = req.user!._id;
  const { title, date, venue, venueLocation } = req.body;

  // Build a payload object, only including venueLocation if it's valid
  const payload: any = {
    organizer: organizerId,
    title,
    date: new Date(date),
    venue,
  };

  // venueLocation should be { type: 'Point', coordinates: [lng, lat] }
  if (
    venueLocation &&
    Array.isArray(venueLocation.coordinates) &&
    venueLocation.coordinates.length === 2
  ) {
    payload.venueLocation = venueLocation;
  }

  const event = await Event.create(payload);

  // Return the full document, including the newly‐written venueLocation
  res.status(201).json(event);
});

// GET /api/events
export const listMyEvents = asyncHandler(
  async (req: Request, res: Response) => {
    const organizerId = req.user!._id;
    const events = await Event.find({ organizer: organizerId });
    res.json(events);
  }
);

// GET /api/events/:id
export const getEventById = asyncHandler(
  async (req: Request, res: Response) => {
    const { id } = req.params;
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ message: "Invalid event ID" });
    }
    const event = await Event.findById(id);
    if (!event) return res.status(404).json({ message: "Event not found" });
    res.json(event);
  }
);

// PUT /api/events/:id
export const updateEvent = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const organizerId = req.user!._id;

  // Extract settings if present, and everything else
  const { settings, ...rest } = req.body;

  // Build a $set object:
  const setOps: Record<string, any> = { ...rest };

  if (settings && typeof settings === "object") {
    // For each field in settings, dot‐set it
    for (const [key, val] of Object.entries(settings)) {
      setOps[`settings.${key}`] = val;
    }
  }

  // Now perform an atomic update
  const updated = await Event.findOneAndUpdate(
    { _id: id, organizer: organizerId },
    { $set: setOps },
    { new: true }
  );

  if (!updated) {
    return res
      .status(404)
      .json({ message: "Event not found or you are not the organizer" });
  }

  res.json(updated);
});

// DELETE /api/events/:id
export const deleteEvent = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const organizerId = req.user!._id;
  const deleted = await Event.findOneAndDelete({
    _id: id,
    organizer: organizerId,
  });
  if (!deleted)
    return res.status(404).json({ message: "Event not found or forbidden" });
  res.sendStatus(204);
});

// POST /api/events/:id/guests
export const addGuest = asyncHandler(async (req: Request, res: Response) => {
  const { id } = req.params;
  const { name, email } = req.body;
  const event = await Event.findById(id);
  if (!event) return res.status(404).json({ message: "Event not found" });
  event.guests.push({ name, email, status: "pending" } as any);
  await event.save();
  res.status(201).json(event);
});

// PUT /api/events/:id/guests/:guestId
export const updateGuestStatus = asyncHandler(
  async (req: Request, res: Response) => {
    const { id, guestId } = req.params;
    const { status } = req.body as { status: "pending" | "yes" | "no" };
    const event = await Event.findById(id);
    if (!event) return res.status(404).json({ message: "Event not found" });
    const guest = event.guests.find((g: any) => g._id?.toString() === guestId);
    if (!guest) return res.status(404).json({ message: "Guest not found" });
    guest.status = status;
    await event.save();
    res.json(event);
  }
);
