// src/scripts/seedVendorAttributes.ts
import mongoose from "mongoose";
import dotenv from "dotenv";
import User, { VendorServiceType, IVendorAttribute } from "../models/User";

dotenv.config();

const defaultAttributes: Record<VendorServiceType, IVendorAttribute[]> = {
    [VendorServiceType.Decorator]: [
    { key: "name", label: "الاسم", type: "string", required: true },
    { key: "bio", label: "انواع الورود", type: "string" },
    {
      key: "styles",
      label: "أساليب التصميم",
      type: "multiSelect",
      options: ["كلاسيكي", "حديث", "ريفي", "جوري", "مزيج"],
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
      label: "أنواع المناسبات",
      type: "multiSelect",
      options: ["زفاف", "خطوبة", "تخرج", "عيد ميلاد", "حفل عمل"],
      value: [],
    },
    { key: "phone", label: "الهاتف", type: "string", required: true },
    { key: "city", label: "المدينة", type: "string" },
  ],


  [VendorServiceType.FurnitureStore]: [
    { key: "name", label: "اسم المتجر", type: "string", required: true },
    { key: "description", label: "الوصف", type: "string" },
    { key: "address", label: "العنوان", type: "string" },
    { key: "phone", label: "الهاتف", type: "string", required: true },
    { key: "city", label: "المدينة", type: "string" },
    {
      key: "productCategories",
      label: "فئات الأثاث",
      type: "multiSelect",
      options: ["كراسي", "طاولات", "كنب", "أسرة", "خزائن"],
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
      options: ["كلاسيكي", "سينمائي", "استوديو", "خارجي"],
      value: [],
    },
    {
      key: "tripTypes",
      label: "أنواع المناسبات",
      type: "multiSelect",
      options: ["زفاف", "خطوبة", "تخرج", "أطفال", "عيد ميلاد", "افتتاح مشروع"],
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

  [VendorServiceType.GiftShop]: [
    { key: "name", label: "اسم المتجر", type: "string", required: true },
    { key: "description", label: "الوصف", type: "string" },
    { key: "address", label: "العنوان", type: "string" },
    { key: "phone", label: "الهاتف", type: "string", required: true },
    { key: "city", label: "المدينة", type: "string" },
    {
      key: "productTypes",
      label: "نوعيات الهدايا",
      type: "multiSelect",
      options: ["ساعات", "عطور", "إكسسوارات", "شوكولاتة", "زهور"],
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

  [VendorServiceType.Entertainer]: [
    { key: "name", label: "الاسم", type: "string", required: true },
    { key: "description", label: "نبذة عن الخدمة", type: "string" },
    {
      key: "performanceTypes",
      label: "أنواع الفعاليات",
      type: "multiSelect",
      options: ["دي جي", "مغني", "فرقة موسيقية", "ساحر", "مهرج"],
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
