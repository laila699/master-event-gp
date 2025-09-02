// src/routes/events.ts
import { Router } from "express";
import * as ctrl from "../controllers/trip.controller";
import { requireRole } from "../middleware/auth";
import { recommendedOfferings } from "../controllers/recommendation";

const router = Router();

router.post("/", ctrl.createTrip);
router.get("/", ctrl.listMyTrips);

router.get("/:id", ctrl.getTripById);
router.put("/:id", ctrl.updateTrip);
router.delete("/:id", ctrl.deleteTrip);
router.get("/:eventId/recommended-offerings", recommendedOfferings); // Get recommended offerings for an event

router.post("/:id/guests", ctrl.addMember); // Add a guest to an event
router.put(
  "/:id/guests/:guestId",

  ctrl.updateMemberStatus // Update the status of a guest in an event
);

export default router;
