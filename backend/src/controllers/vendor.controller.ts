// src/controllers/offering.controller.ts
import { Request, Response } from "express";
import Offering from "../models/Offering";
import { asyncHandler } from "../utils/asyncHandler";
import User, { IUser, VendorServiceType } from "../models/User";
import Booking from "../models/Booking";

export const listVendorBookings = asyncHandler(
  async (req: Request, res: Response) => {
    const vendorId = req.params.vendorId;
    // ensure vendor or admin
    const user = req.user as { _id: { toString(): string }; role: string };
    if (user._id.toString() !== vendorId && user.role !== "admin") {
      return res.status(403).json({ message: "Forbidden" });
    }
    // find offerings by this vendor
    const offerings = await Offering.find({ vendor: vendorId }).select("_id");
    const offeringIds = offerings.map((o) => o._id);

    // find bookings for those offerings
    const bookings = await Booking.find({ offering: { $in: offeringIds } })
      .populate("event", "title date")
      .populate("offering", "title price");

    res.json(bookings);
  }
);
export const createVendorRating = asyncHandler(
  async (req: Request, res: Response) => {
    const vendorId = req.params.vendorId;
    const { bookingId, value, review, eventId } = req.body;
    console.log("user", req.user);
    console.log("eventId", eventId);
    // ── 1. quick sanity ───────────────────────────────────────────────
    if (!value || value < 1 || value > 5) {
      return res.status(400).json({ message: "value must be 1-5" });
    }

    // ── 2. booking must exist, belong to this organizer, match vendor & be over ──
    const booking = await Booking.findOne({
      _id: bookingId,
      event: eventId,
      rated: false,
    }).populate("offering", "vendor scheduledAt");
    console.log("offering in booking", booking);
    if (!booking || booking.scheduledAt > new Date()) {
      return res.status(403).json({ message: "Booking not eligible" });
    }

    // ── 3. push rating into vendor user doc ───────────────────────────
    const vendor = await User.findOne({ _id: vendorId, role: "vendor" });
    if (!vendor) return res.status(404).json({ message: "Vendor not found" });

    await (vendor as any).addRating({
      organizerId: (req.user as any)._id, // ← add this line

      eventId,
      bookingId,
      value,
      review,
      ratedAt: new Date(),
    });

    // ── 4. mark booking as rated ──────────────────────────────────────
    booking.rated = true;
    await booking.save();

    // ── 5. send back fresh aggregates ─────────────────────────────────
    res.json({
      averageRating: vendor.averageRating,
      ratingsCount: vendor.ratingsCount,
    });
  }
);
// GET /api/vendors?lat=<>&lng=<>&radius=<km>
export const listVendors = asyncHandler(async (req: Request, res: Response) => {
  const { serviceType, city, lat, lng, radius, ...rest } = req.query;
  const filter: any = { role: "vendor" };

  // 1) serviceType filter
  if (serviceType) {
    filter["vendorProfile.serviceType"] = serviceType;
  }

  // 2) city filter (stored as an attribute)
  if (city) {
    filter["vendorProfile.attributes"] = {
      $elemMatch: { key: "city", value: city },
    };
  }

  // 3) geolocation
  if (lat && lng) {
    const latitude = parseFloat(lat as string);
    const longitude = parseFloat(lng as string);
    const km = radius ? parseFloat(radius as string) : 10;
    filter["vendorProfile.location"] = {
      $near: {
        $geometry: { type: "Point", coordinates: [longitude, latitude] },
        $maxDistance: km * 1000,
      },
    };
  }

  // 4) any other query‐param → attribute filter
  //    e.g. /vendors?performanceTypes=دي%20جي
  const extraAttrFilters = Object.entries(rest).map(([key, value]) => ({
    "vendorProfile.attributes": {
      // if you want to match any of many values: use $in
      $elemMatch: {
        key,
        value: { $in: Array.isArray(value) ? value : [value] },
      },
    },
  }));
  if (extraAttrFilters.length) {
    filter.$and = extraAttrFilters;
  }
  // lets return the id of the vendor as id not _id

  const vendors = await User.find(filter)
    .select(
      [
        "_id",
        "name",
        "email",
        "role",
        "location",
        "phone",
        "avatarUrl",
        "vendorProfile.serviceType",
        "vendorProfile.attributes",
        "averageRating",
        "ratingsCount",
      ].join(" ")
    )
    .lean();

  const withId = vendors.map((v) => {
    const { _id, __v, ...keep } = v;
    return {
      id: _id.toString(), // <-- rename
      ...keep,
    };
  });

  res.json(withId);
});
export const getVendorDetails = asyncHandler(async (req, res) => {
  const { vendorId } = req.params;
  const vendor = await User.findById(vendorId).select(
    "name vendorProfile.attributes role vendorProfile.serviceType averageRating ratingsCount"
  );
  console.log("vendor:", vendor);

  if (!vendor || vendor.role !== "vendor") {
    return res.status(404).json({ message: "Vendor not found" });
  }
  res.json({
    id: vendor._id,
    serviceType: vendor.vendorProfile!.serviceType,
    attributes: vendor.vendorProfile!.attributes,
  });
});

// PUT /api/vendors/:vendorId
export const updateVendorAttributes = asyncHandler(async (req, res) => {
  const { vendorId } = req.params;
  const user = req.user as IUser;
  if (user._id.toString() !== vendorId) {
    return res.status(403).json({ message: "Forbidden" });
  }
  const { attributes } = req.body;
  if (!Array.isArray(attributes)) {
    return res.status(400).json({ message: "Invalid attributes payload" });
  }
  user.vendorProfile!.attributes = attributes;
  await user.save();
  res.json(user.vendorProfile!.attributes);
});

export const uploadAttributeImage = asyncHandler(
  async (req: Request, res: Response) => {
    const { vendorId, key } = req.params;
    const user = req.user as IUser;

    // 1) Ownership check
    if (user._id.toString() !== vendorId) {
      return res.status(403).json({ message: "Forbidden" });
    }

    // 2) File presence
    if (!req.file) {
      return res.status(400).json({ message: "No file uploaded" });
    }

    // 3) Build accessible URL (ensure your Express serves /uploads/attributes statically)
    const url = `/uploads/attributes/${req.file.filename}`;

    // 4) Find the matching attribute
    const attrs = user.vendorProfile?.attributes;
    if (!attrs) {
      return res
        .status(400)
        .json({ message: "Vendor does not have any attributes configured." });
    }
    const attr = attrs.find((a) => a.key === key);
    if (!attr) {
      return res.status(400).json({ message: `Attribute '${key}' not found.` });
    }

    // 5) Append URL to the attribute's value array
    const list = Array.isArray(attr.value) ? [...attr.value] : [];
    list.push(url);
    attr.value = list;

    // 6) Persist the change
    await user.save();

    // 7) Return the new URL to the client
    res.json({ url });
  }
);

// Note: make sure this route is protected by requireRole('vendor')
export const updateVendorLocation = asyncHandler(
  async (req: Request, res: Response) => {
    const vendorId = req.params.vendorId;
    const user = req.user as IUser;

    // 1) Check ownership
    if (user._id.toString() !== vendorId) {
      return res.status(403).json({ message: "Forbidden" });
    }

    // 2) Parse & validate
    const { lat, lng } = req.body;
    const latitude = parseFloat(lat as string);
    const longitude = parseFloat(lng as string);
    if (isNaN(latitude) || isNaN(longitude)) {
      return res.status(400).json({ message: "Invalid coordinates" });
    }

    // 3) Ensure vendorProfile exists
    if (!user.vendorProfile) {
      user.vendorProfile = {
        // we know this is a vendor, so serviceType must be defined
        serviceType: VendorServiceType.Decorator,
        bio: "",
        location: { type: "Point", coordinates: [longitude, latitude] },
      };
    } else {
      user.vendorProfile.location = {
        type: "Point",
        coordinates: [longitude, latitude],
      };
    }

    // 4) Save and respond
    await user.save();
    return res.json({ message: "Location updated" });
  }
);

// POST /api/vendors/:vendorId/offerings
export const createOffering = asyncHandler(
  async (req: Request, res: Response) => {
    const vendorId = req.params.vendorId;
    const user = req.user as IUser;
    console.log("user", user);
    console.log("vendorId", vendorId);
    if (user._id.toString() !== vendorId) {
      return res.status(403).json({ message: "Forbidden" });
    }

    // Multer has already run, so:
    //   - req.body.title, req.body.description, req.body.price are available as strings
    //   - req.files is an array of uploaded files
    console.log("body:", req.body);
    console.log("files:", req.files);

    const { title, description, price } = req.body;
    if (!title || !price) {
      return res.status(400).json({ message: "عنوان وسعر مطلوبان" });
    }

    // Convert req.files → array of URL paths
    let images: string[] = [];
    console.log("req.files:", req.files);
    if (Array.isArray(req.files) && req.files.length > 0) {
      images = (req.files as Express.Multer.File[]).map((file) => {
        return `/uploads/offerings/${file.filename}`;
      });
    }

    const offering = await Offering.create({
      vendor: vendorId,
      title,
      description: description || "",
      images: images,
      price: parseFloat(price),
    });

    res.status(201).json(offering);
  }
);

// GET /api/vendors/:vendorId/offerings
export const listOfferingsByVendor = asyncHandler(
  async (req: Request, res: Response) => {
    const vendorId = req.params.vendorId;
    const offerings = await Offering.find({ vendor: vendorId });
    res.json(offerings);
  }
);

// PUT /api/vendors/:vendorId/offerings/:offeringId
export const updateOffering = asyncHandler(
  async (req: Request, res: Response) => {
    const { vendorId, offeringId } = req.params;
    const user = req.user as IUser;
    if (user._id.toString() !== vendorId) {
      return res.status(403).json({ message: "Forbidden" });
    }

    // If images are included in this PUT, multer has already put them into req.files
    const updateData: Partial<any> = {};
    if (req.body.title) updateData.title = req.body.title;
    if (req.body.description) updateData.description = req.body.description;
    if (req.body.price) updateData.price = parseFloat(req.body.price);
    console.log("req.files:", req.files);

    // If new images were uploaded, build an array of paths:
    if (Array.isArray(req.files) && req.files.length > 0) {
      updateData.images = (req.files as Express.Multer.File[]).map((file) => {
        return `/uploads/offerings/${file.filename}`;
      });
    }

    const updated = await Offering.findOneAndUpdate(
      { _id: offeringId, vendor: vendorId },
      updateData,
      { new: true }
    );
    if (!updated) {
      return res.status(404).json({ message: "Offering not found" });
    }
    res.json(updated);
  }
);

export const getOfferingById = asyncHandler(
  async (req: Request, res: Response) => {
    const { vendorId, offeringId } = req.params;

    // If you want to restrict to the owning vendor (or leave public)
    const offering = await Offering.findOne({
      _id: offeringId,
      vendor: vendorId,
    });
    if (!offering) {
      return res.status(404).json({ message: "Offering not found" });
    }
    res.json(offering);
  }
);
// DELETE /api/vendors/:vendorId/offerings/:offeringId
export const deleteOffering = asyncHandler(
  async (req: Request, res: Response) => {
    const { vendorId, offeringId } = req.params;
    const user = req.user as { _id: { toString(): string } };
    if (user._id.toString() !== vendorId) {
      return res.status(403).json({ message: "Forbidden" });
    }
    await Offering.findOneAndDelete({ _id: offeringId, vendor: vendorId });
    res.sendStatus(204);
  }
);
