import { Request, Response } from "express";
import Offering from "../models/Offering";
import { asyncHandler } from "../utils/asyncHandler";
import mongoose from "mongoose";

// GET /api/offerings?serviceType=accommodation
export const listOfferings = asyncHandler( 
  async (req: Request, res: Response) => {
    const { serviceType } = req.query as { serviceType?: string };

    // Build a query on Offering
    let query = Offering.find(); // Find all offerings

    // If they passed ?serviceType=…, only return offerings whose vendor has that serviceType
    if (serviceType && mongoose.Types.ObjectId.isValid(serviceType) === false) {
      // serviceType is a string like "accommodation", so we match on the populated vendorProfile
      query = query.populate({
        path: "vendor",
        match: { "vendorProfile.serviceType": serviceType }, // Filter offerings by vendor's serviceType
        select: "name vendorProfile.serviceType", // اسم ونوع الخدمة
      });
    } else {
      // no filter or invalid filter: still populate vendor name so the frontend can show it
      query = query.populate({
        path: "vendor",
        select: "name vendorProfile.serviceType",
      });
    }

    const offerings = await query.exec(); // يعني كل الـ offerings اللي طابقت الشروط
  
    // If we filtered by serviceType, some docs may have vendor=null → drop them
    const filtered = offerings.filter((off) => off.vendor !== null); // Remove offerings with no vendor (due to serviceType filter)

    res.json(filtered);
  }
);
