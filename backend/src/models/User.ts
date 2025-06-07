// src/models/User.ts
import mongoose, { Document, Schema } from "mongoose";

export enum VendorServiceType {
  Decorator = "decorator",
  InteriorDesigner = "interior_designer",
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
  itemType?: "string" | "number" | "object";
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
    role: {
      type: String,
      enum: ["organizer", "vendor", "admin"],
      required: true,
    },
    phone: { type: String, required: true },
    avatarUrl: { type: String },
    vendorProfile: VendorProfileSchema,
    fcmTokens: { type: [String], default: [] },
  },
  { timestamps: true }
);

UserSchema.index({ "vendorProfile.location": "2dsphere" });

export default mongoose.model<IUser>("User", UserSchema);
