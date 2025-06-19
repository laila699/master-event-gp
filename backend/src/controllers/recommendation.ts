import { Request, Response } from "express";
import { asyncHandler } from "../utils/asyncHandler";
import Event from "../models/Event";
import Offering from "../models/Offering";
import { VendorServiceType } from "../models/User"; // <-- new

/* Arabic category → serviceType slug */
const arToService: Record<string, VendorServiceType> = {
  التصوير: VendorServiceType.Photographer,
  الترفيه: VendorServiceType.Entertainer,
  الطعام: VendorServiceType.Restaurant,
  الأثاث: VendorServiceType.FurnitureStore,
  الديكور: VendorServiceType.Decorator,
  // أضف أي أقسام أخرى تحتاجها…
};

/**
 * GET /api/events/:eventId/recommended-offerings?limit=5
 * Response:  [{ category, remaining, offers:[…] }, … ]
 */
export const recommendedOfferings = asyncHandler(
  async (req: Request, res: Response) => {
    const eventId = req.params.eventId;
    const limit = parseInt((req.query.limit as string) || "5", 10);

    // 1) fetch event & ownership
    const ev = await Event.findById(eventId);
    if (!ev) return res.status(404).json({ message: "Event not found" });

    const user = req.user as { _id: any; role: string };
    if (
      user.role !== "admin" &&
      user._id.toString() !== ev.organizer.toString()
    )
      return res.status(403).json({ message: "Forbidden" });

    // 2) cash remaining by category
    const remaining: Record<string, number> = await (ev as any).remainingBudget;

    // 3) for each category get offers ≤ cash
    const out: any[] = [];
    for (const [catAr, cash] of Object.entries(remaining)) {
      if (cash <= 0) continue;

      const svcSlug = arToService[catAr] || catAr; // map Arabic → slug

      const offers = await Offering.aggregate([
        // join vendor & filter by serviceType
        {
          $lookup: {
            from: "users",
            localField: "vendor",
            foreignField: "_id",
            pipeline: [
              {
                $match: {
                  role: "vendor",
                  "vendorProfile.serviceType": svcSlug,
                },
              },
              { $project: { averageRating: 1, name: 1 } },
            ],
            as: "vendor",
          },
        },
        { $unwind: "$vendor" },
        { $match: { price: { $lte: cash } } },
        {
          $addFields: { sortKey: { $subtract: [10, "$vendor.averageRating"] } },
        },
        { $sort: { sortKey: 1, price: 1 } },
        { $limit: limit },
        {
          $project: {
            id: "$_id",
            title: 1,
            price: 1,
            "vendor.id": "$vendor._id",
            "vendor.name": "$vendor.name",
            "vendor.averageRating": "$vendor.averageRating",
          },
        },
      ]);

      out.push({ category: catAr, remaining: cash, offers });
    }

    res.json(out);
  }
);
