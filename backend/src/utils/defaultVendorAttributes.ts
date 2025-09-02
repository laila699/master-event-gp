// src/utils/defaultVendorAttributes.ts
import { VendorServiceType, IVendorAttribute } from "../models/User";

/**
 * Default attribute definitions for each VendorServiceType.
 * Vendors will receive these fields at registration and can later update them.
 */
export const defaultVendorAttributes: Record<
  VendorServiceType,
  IVendorAttribute[]
> = {
  [VendorServiceType.Accommodation]: [
    { key: "name", label: "الاسم", type: "string", required: true },
    { key: "bio", label: "نبذة عن الخدمة", type: "string", value: "" },
    {
      key: "styles",
      label: "أنواع الاقامة ",
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
    { key: "priceRange", label: "نطاق السعر", type: "string", value: "" },
    {
      key: "tripTypes",
      label: "أنواع الرحل",
      type: "multiSelect",
      options: ["رحلة مغامرات", "رحلة مسارات", "رحل دينية", "رحلات بحرية", "رحل ثقافية "],
      value: [],
    },

    { key: "city", label: "المدينة", type: "string", value: "" },
    // ← Added location object
    {
      key: "location",
      label: "الموقع",
      type: "object",
      value: {},
      required: true,
      fields: [
        {
          key: "lat",
          label: "خط العرض",
          type: "number",
          value: 0,
          required: true,
        },
        {
          key: "lng",
          label: "خط الطول",
          type: "number",
          value: 0,
          required: true,
        },
      ],
    },
  ],

  [VendorServiceType.Transportation]: [
    { key: "name", label: "اسم المتجر", type: "string", required: true },
    { key: "description", label: "الوصف", type: "string", value: "" },
    { key: "address", label: "العنوان", type: "string", value: "" },

    { key: "city", label: "المدينة", type: "string", value: "" },
    {
      key: "location",
      label: "الموقع",
      type: "object",
      value: {},
      required: true,
      fields: [
        {
          key: "lat",
          label: "خط العرض",
          type: "number",
          value: 0,
          required: true,
        },
        {
          key: "lng",
          label: "خط الطول",
          type: "number",
          value: 0,
          required: true,
        },
      ],
    },
    {
      key: "productCategories",
      label: "  فئات النقل ",
      type: "multiSelect",
      options: ["حافلات كبيرة", "حافلات صغيرة", "سيارات فردية ", "دراجات هوائية", "دراجات نارية"],
      value: [],
    },
    {
      key: "storeImages",
      label: "صور المتجر",
      type: "array",
      itemType: "string",
      value: [],
    },
    { key: "openingHours", label: "ساعات العمل", type: "string", value: "" },
    { key: "priceRange", label: "نطاق السعر", type: "string", value: "" },
  ],

  [VendorServiceType.Photographer]: [
    { key: "name", label: "الاسم", type: "string", required: true },
    { key: "city", label: "المدينة", type: "string", required: true },
    { key: "mobile", label: "متنقل", type: "boolean", value: false },
    {
      key: "location",
      label: "الموقع",
      type: "object",
      value: {},
      required: true,
      fields: [
        {
          key: "lat",
          label: "خط العرض",
          type: "number",
          value: 0,
          required: true,
        },
        {
          key: "lng",
          label: "خط الطول",
          type: "number",
          value: 0,
          required: true,
        },
      ],
    },
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
      options: ["سينمائي", "برومو رحل ", "وثائقي", "كلاسيكي"],
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
  ],

  [VendorServiceType.Restaurant]: [
    { key: "name", label: "اسم المطعم", type: "string", required: true },
    {
      key: "image",
      label: "صورة رئيسية",
      type: "array",
      itemType: "string",
      value: [],
      required: true,
    },
    {
      key: "location",
      label: "الموقع",
      type: "object",
      value: {},
      required: true,
      fields: [
        {
          key: "lat",
          label: "خط العرض",
          type: "number",
          value: 0,
          required: true,
        },
        {
          key: "lng",
          label: "خط الطول",
          type: "number",
          value: 0,
          required: true,
        },
      ],
    },
    {
      key: "foodImages",
      label: "صور الأطباق",
      type: "array",
      itemType: "string",
      value: [],
    },

    { key: "city", label: "المدينة", type: "string", value: "" },
  ],

  [VendorServiceType.Tools]: [
    { key: "name", label: "اسم المتجر", type: "string", required: true },
    { key: "description", label: "الوصف", type: "string", value: "" },
    { key: "address", label: "العنوان", type: "string", value: "" },

    { key: "city", label: "المدينة", type: "string", value: "" },
    {
      key: "location",
      label: "الموقع",
      type: "object",
      value: {},
      required: true,
      fields: [
        {
          key: "lat",
          label: "خط العرض",
          type: "number",
          value: 0,
          required: true,
        },
        {
          key: "lng",
          label: "خط الطول",
          type: "number",
          value: 0,
          required: true,
        },
      ],
    },
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
    { key: "priceRange", label: "نطاق السعر", type: "string", value: "" },
  ],

  [VendorServiceType.Guides]: [
    { key: "name", label: "الاسم", type: "string", required: true },
    { key: "description", label: "نبذة عن الخدمة", type: "string", value: "" },
    {
      key: "location",
      label: "الموقع",
      type: "object",
      value: {},
      required: true,
      fields: [
        {
          key: "lat",
          label: "خط العرض",
          type: "number",
          value: 0,
          required: true,
        },
        {
          key: "lng",
          label: "خط الطول",
          type: "number",
          value: 0,
          required: true,
        },
      ],
    },
    {
      key: "performanceTypes",
      label: "المرشدين ",
      type: "multiSelect",
      options: ["مرشدين لغويين  ", "مساارات ومغامرات  ", "  ثقافية وتاريخية", " تخييم ", "مرشدين دينيين "],
      value: [],
    },
  /*  {
     key: "availability",
      label: "تواريخ التوفر",
      type: "array",
      itemType: "string",
      value: [],
    }, */
    { key: "priceRange", label: "نطاق السعر", type: "string", value: "" },
    {
      key: "guidesImages",
      label: "صور العرض",
      type: "array",
      itemType: "string",
      value: [],
    },

    { key: "city", label: "المدينة", type: "string", value: "" },
  ],

  [VendorServiceType.UNKNOWN]: [],
};
