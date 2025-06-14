import { Request, Response } from "express";
import Offering from "../models/Offering";
import { asyncHandler } from "../utils/asyncHandler";
import mongoose from "mongoose";

// GET /api/offerings?serviceType=decorator
export const listOfferings = asyncHandler(
  async (req: Request, res: Response) => {
    const { serviceType } = req.query as { serviceType?: string };

    // Build a query on Offering
    let query = Offering.find();

    // If they passed ?serviceType=…, only return offerings whose vendor has that serviceType
    if (serviceType && mongoose.Types.ObjectId.isValid(serviceType) === false) {
      // serviceType is a string like "decorator", so we match on the populated vendorProfile
      query = query.populate({
        path: "vendor",
        match: { "vendorProfile.serviceType": serviceType },
        select: "name vendorProfile.serviceType",
      });
    } else {
      // no filter or invalid filter: still populate vendor name so the frontend can show it
      query = query.populate({
        path: "vendor",
        select: "name vendorProfile.serviceType",
      });
    }

    const offerings = await query.exec();

    // If we filtered by serviceType, some docs may have vendor=null → drop them
    const filtered = offerings.filter((off) => off.vendor !== null);

    res.json(filtered);
  }
);
