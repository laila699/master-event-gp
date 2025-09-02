// src/scripts/seedVendorAttributes.ts
import mongoose from "mongoose";
import dotenv from "dotenv";
import User, { VendorServiceType, IVendorAttribute } from "../models/User";

dotenv.config();

const defaultAttributes: Record<VendorServiceType, IVendorAttribute[]> = {
    [VendorServiceType.Accommodation]: [
    { key: "name", label: "الاسم", type: "string", required: true },
    { key: "bio", label: "انواع الورود", type: "string" },
    {
      key: "styles",
      label: "أنواع الاقامة  ",
      type: "multiSelect",
      options: ["شقق", "فنادق", "مخيمات", "شاليهات", "كرفان"],
      value: [],
    },
    {
      key: "portfolioImages",
      label: "صور الأعمال",
      type: "array",
      itemType: "string",
      value: [],
    },
    { key: "priceRange", label: "نطاق السعر", type: "string" },
    {
      key: "tripTypes",
      label: "أنواع الرحل",
      type: "multiSelect",
      options: ["رحلة مغامرات", "رحلة مسارات", "رحل دينية", "رحلات بحرية", "رحل ثقافية "],
      value: [],
    },
    { key: "phone", label: "الهاتف", type: "string", required: true },
    { key: "city", label: "المدينة", type: "string" },
  ],


  [VendorServiceType.Transportation]: [
    { key: "name", label: "اسم المتجر", type: "string", required: true },
    { key: "description", label: "الوصف", type: "string" },
    { key: "address", label: "العنوان", type: "string" },
    { key: "phone", label: "الهاتف", type: "string", required: true },
    { key: "city", label: "المدينة", type: "string" },
    {
      key: "productCategories",
      label: "فئات النقل",
      type: "multiSelect",
      options: [" حافلات كبيرة", "حافلات صغيرة ", " سيارات فردية", " دراجات هوائية", "درجات نارية"],
      value: [],
    },
    {
      key: "storeImages",
      label: "صور المتجر",
      type: "array",
      itemType: "string",
      value: [],
    },
    { key: "openingHours", label: "ساعات العمل", type: "string" },
    { key: "priceRange", label: "نطاق السعر", type: "string" },
  ],

  [VendorServiceType.Photographer]: [
    { key: "name", label: "الاسم", type: "string", required: true },
    { key: "city", label: "المدينة", type: "string", required: true },
    { key: "mobile", label: "متنقل", type: "boolean", value: false },
    {
      key: "portfolioImages",
      label: "صور البورتفوليو",
      type: "array",
      itemType: "string",
      value: [],
    },
    {
      key: "photographyTypes",
      label: "أنواع التصوير",
      type: "multiSelect",
      options: ["سينمائي", "برومو رحل", "وثائقي", "كلاسيكي"],
      value: [],
    },
    {
      key: "tripTypes",
      label: "أنواع الرحل",
      type: "multiSelect",
      options: ["رحلة مغامرات", "رحلة مسارات", "رحل دينية", "رحلات بحرية", "رحل ثقافية "],
      value: [],
    },
    { key: "priceRange", label: "نطاق السعر", type: "string", value: "" },
    { key: "phone", label: "الهاتف", type: "string", required: true },
  ],

  [VendorServiceType.Restaurant]: [
    { key: "name", label: "اسم المطعم", type: "string", required: true },
    { key: "image", label: "صورة رئيسية", type: "string", value: "" },
    { key: "location", label: "الموقع", type: "string", value: "" },
    {
      key: "foodImages",
      label: "صور الأطباق",
      type: "array",
      itemType: "string",
      value: [],
    },
    { key: "phone", label: "الهاتف", type: "string", required: true },
    { key: "city", label: "المدينة", type: "string" },
  ],

  [VendorServiceType.Tools]: [
    { key: "name", label: "اسم المتجر", type: "string", required: true },
    { key: "description", label: "الوصف", type: "string" },
    { key: "address", label: "العنوان", type: "string" },
    { key: "phone", label: "الهاتف", type: "string", required: true },
    { key: "city", label: "المدينة", type: "string" },
    {
      key: "productTypes",
      label: "اصناف المعدات ",
      type: "multiSelect",
      options: ["مستلزمات الرحل", "ملابس رحلات ", "معدات الحمل والتخزين", "العناية الشخصية ", "الكترونيات الرحلات "],
      value: [],
    },
    {
      key: "shopImages",
      label: "صور المتجر",
      type: "array",
      itemType: "string",
      value: [],
    },
    { key: "priceRange", label: "نطاق السعر", type: "string" },
  ],

  [VendorServiceType.Guides]: [
    { key: "name", label: "الاسم", type: "string", required: true },
    { key: "description", label: "نبذة عن الخدمة", type: "string" },
    {
      key: "performanceTypes",
      label: " المرشدين",
      type: "multiSelect",
      options: ["مرشدين لغويين  ", "مسارات ومغامرات", " ثقافية وتاريخية", "تخييم", "مرشدين دينيين"],
      value: [],
    },
   /* {
      key: "availability",
      label: "تواريخ التوفر",
      type: "array",
      itemType: "string",
      value: [],
    }, */ 
    { key: "priceRange", label: "نطاق السعر", type: "string" },
    {
      key: "guidesImages",
      label: "صور العرض",
      type: "array",
      itemType: "string",
      value: [],
    },
    { key: "phone", label: "الهاتف", type: "string", required: true },
    { key: "city", label: "المدينة", type: "string" },
  ],

  [VendorServiceType.UNKNOWN]: [],
};

async function seed() {
  await mongoose.connect("mongodb://localhost:27017/eventmgmt");

  console.log("✅ Connected to MongoDB");

  // 1) Clear out any existing attributes first
  await User.updateMany(
    { role: "vendor" },
    { $set: { "vendorProfile.attributes": [] } }
  );
  console.log("🗑️  Cleared old vendor attributes");

  // 2) Seed the new defaults per serviceType
  for (const [type, defaults] of Object.entries(defaultAttributes) as [
    VendorServiceType,
    IVendorAttribute[]
  ][]) {
    if (!defaults.length) continue;

    const toSet = defaults.map((attr) => ({
      ...attr,
      value: attr.value ?? (attr.type === "array" ? [] : null),
    }));

    const res = await User.updateMany(
      {
        role: "vendor",
        "vendorProfile.serviceType": type,
        "vendorProfile.attributes": { $size: 0 },
      },
      { $set: { "vendorProfile.attributes": toSet } }
    );

    console.log(
      `→ Seeded ${toSet.length} attrs for ${res.modifiedCount} "${type}" vendors`
    );
  }

  console.log("🎉 Seeding complete!");
  process.exit(0);
}

seed().catch((err) => {
  console.error(err);
  process.exit(1);
});
