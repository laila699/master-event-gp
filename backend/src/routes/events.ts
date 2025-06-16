// src/routes/events.ts
import { Router } from "express";
import * as ctrl from "../controllers/event.controller";
import { requireRole } from "../middleware/auth";
import { recommendedOfferings } from "../controllers/recommendation";

const router = Router();

router.post("/", ctrl.createEvent);
router.get("/", ctrl.listMyEvents);

router.get("/:id", ctrl.getEventById);
router.put("/:id", ctrl.updateEvent);
router.delete("/:id", ctrl.deleteEvent);
router.get("/:eventId/recommended-offerings", recommendedOfferings);

router.post("/:id/guests", ctrl.addGuest);
router.put(
  "/:id/guests/:guestId",

  ctrl.updateGuestStatus
);

export default router;
