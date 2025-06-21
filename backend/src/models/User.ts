// src/models/User.ts
import mongoose, { Document, Schema } from "mongoose";
import { IRating, RatingSchema } from "./Rating";

export enum VendorServiceType {
  Decorator = "decorator",
  FurnitureStore = "furniture_store",
  Photographer = "photographer",
  Restaurant = "restaurant",
  GiftShop = "gift_shop",
  Entertainer = "entertainer",
  UNKNOWN = "unknown",
}

// 1) Define the TS type for an attribute
export interface IVendorAttribute {
  key: string;
  label?: string;
  type:
    | "string"
    | "number"
    | "boolean"
    | "select"
    | "multiSelect"
    | "date"
    | "array"
    | "object";
  value?: any;
  options?: any[];
  required?: boolean;
  // only for array/object
  itemType?: "string" | "number" | "object" | "array" | "boolean" | "date";
  fields?: IVendorAttribute[]; // sub-fields for object or array-of-objects
}

// 2) Extend your IUser interface
export interface IUser extends Document {
  _id: mongoose.Types.ObjectId;
  name: string;
  email: string;
  passwordHash: string;
  role: "organizer" | "vendor" | "admin";
  phone: string;
  avatarUrl?: string;
  ratings?: IRating[]; // only populated for vendors
  averageRating?: number;
  ratingsCount?: number;
  vendorProfile?: {
    serviceType: VendorServiceType;
    bio?: string;
    location?: {
      type: "Point";
      coordinates: [number, number]; // [lng, lat]
    };
    attributes?: IVendorAttribute[];
  };
  fcmTokens: string[];
  active: boolean;
}

// 3) Create a recursive sub‐schema for VendorAttribute
const VendorAttributeSchema = new Schema<IVendorAttribute>(
  {
    key: { type: String, required: true },
    label: { type: String },
    type: {
      type: String,
      enum: [
        "string",
        "number",
        "boolean",
        "select",
        "multiSelect",
        "date",
        "array",
        "object",
      ],
      required: true,
    },
    value: Schema.Types.Mixed,
    options: [Schema.Types.Mixed],
    required: { type: Boolean, default: false },

    // Only used when type==="array" or "object":
    itemType: { type: String, enum: ["string", "number", "object"] },
    fields: [
      /* recursive: VendorAttributeSchema */
    ],
  },
  { _id: false }
);
// workaround to let fields refer to itself
VendorAttributeSchema.add({ fields: [VendorAttributeSchema] });

const VendorProfileSchema = new Schema(
  {
    serviceType: {
      type: String,
      enum: Object.values(VendorServiceType),
      required: true,
    },
    bio: { type: String },
    location: {
      type: {
        type: String,
        enum: ["Point"],
      },
      coordinates: {
        type: [Number],
        index: "2dsphere",
      },
    },

    // ← Now fully recursive attributes:
    attributes: { type: [VendorAttributeSchema], default: [] },
  },
  { _id: false }
);

const UserSchema = new Schema<IUser>(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    passwordHash: { type: String, required: true },
    ratings: { type: [RatingSchema], default: [] },
    averageRating: { type: Number, default: 0 },
    ratingsCount: { type: Number, default: 0 },
    role: {
      type: String,
      enum: ["organizer", "vendor", "admin"],
      required: true,
    },
    phone: { type: String, required: true },
    avatarUrl: { type: String },
    vendorProfile: VendorProfileSchema,
    fcmTokens: { type: [String], default: [] },
    active: { type: Boolean, default: false },
  },
  { timestamps: true }
);
UserSchema.methods.recalculateRating = function () {
  if (!this.ratings?.length) {
    this.averageRating = 0;
    this.ratingsCount = 0;
    return;
  }
  this.ratingsCount = this.ratings.length;
  this.averageRating =
    this.ratings.reduce((s: number, r: IRating) => s + r.value, 0) /
    this.ratingsCount;
};
UserSchema.methods.addRating = function (rating: Partial<IRating>) {
  this.ratings.push(rating);
  this.recalculateRating();
  return this.save();
};

UserSchema.index({ "vendorProfile.location": "2dsphere" });

export default mongoose.model<IUser>("User", UserSchema);
