// src/routes/vendors.ts
import { Router } from "express";
import {
  createOffering,
  listOfferingsByVendor,
  updateOffering,
  deleteOffering,
  listVendors,
  updateVendorLocation,
  listVendorBookings,
  getVendorDetails,
  updateVendorAttributes,
  uploadAttributeImage,
  getOfferingById,
  createVendorRating,
} from "../controllers/vendor.controller";
import { requireAuth, requireRole } from "../middleware/auth";
import {
  uploadAttributeImages,
  uploadOfferingImages,
} from "../middleware/multer";

const router = Router();

// Public or authenticated listing w/ optional geo-filter
router.get("/", requireAuth, listVendors);
router.get("/:vendorId", requireAuth, getVendorDetails);

// PUT /api/vendors/:vendorId → update the attributes array
router.put(
  "/:vendorId",
  requireAuth,
  requireRole("vendor"),
  updateVendorAttributes
);
router.post(
  "/:vendorId/attributes/:key/image",
  requireAuth,
  requireRole("vendor"),
  uploadAttributeImages.single("file"),
  uploadAttributeImage
);
router.post("/:vendorId/ratings", requireAuth, createVendorRating);

router.get("/:vendorId/bookings", requireRole("vendor"), listVendorBookings);

// Vendor updates their location
router.put("/:vendorId/location", requireRole("vendor"), updateVendorLocation);

// Create a new offering (vendor only)
router.post(
  "/:vendorId/offerings",
  requireAuth,
  requireRole("vendor"),
  uploadOfferingImages.array("images", 5), // now Multer runs here
  createOffering
);
// List offerings for a vendor (authenticated users)
router.get("/:vendorId/offerings", listOfferingsByVendor);
router.get(
  "/:vendorId/offerings/:offeringId",
  requireAuth,
  getOfferingById // new: single
);
// Update an offering (vendor only
router.put(
  "/:vendorId/offerings/:offeringId",
  requireAuth,
  requireRole("vendor"),
  uploadOfferingImages.array("images", 5), // now Multer runs here
  updateOffering
);

// Delete an offering (vendor only)
router.delete(
  "/:vendorId/offerings/:offeringId",
  requireRole("vendor"),
  deleteOffering
);

export default router;
