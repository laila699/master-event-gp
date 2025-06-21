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
  [VendorServiceType.Decorator]: [
    { key: "name", label: "الاسم", type: "string", required: true },
    { key: "bio", label: "نبذة عن الخدمة", type: "string", value: "" },
    {
      key: "styles",
      label: "أساليب التصميم",
      type: "multiSelect",
      options: ["كلاسيكي", "حديث", "ريفي", "صناعي", "مزيج"],
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
      key: "eventTypes",
      label: "أنواع المناسبات",
      type: "multiSelect",
      options: ["زفاف", "خطوبة", "تخرج", "عيد ميلاد", "حفل عمل"],
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

  [VendorServiceType.FurnitureStore]: [
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
      options: ["كلاسيكي", "سينمائي", "استوديو", "خارجي"],
      value: [],
    },
    {
      key: "eventTypes",
      label: "أنواع المناسبات",
      type: "multiSelect",
      options: ["زفاف", "خطوبة", "تخرج", "أطفال", "عيد ميلاد", "افتتاح مشروع"],
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

  [VendorServiceType.GiftShop]: [
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
    { key: "priceRange", label: "نطاق السعر", type: "string", value: "" },
  ],

  [VendorServiceType.Entertainer]: [
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
      label: "أنواع الفعاليات",
      type: "multiSelect",
      options: ["دي جي", "مغني", "فرقة موسيقية", "ساحر", "مهرج"],
      value: [],
    },
    {
      key: "availability",
      label: "تواريخ التوفر",
      type: "array",
      itemType: "date",
      value: [],
    },
    { key: "priceRange", label: "نطاق السعر", type: "string", value: "" },
    {
      key: "entertainerImages",
      label: "صور العرض",
      type: "array",
      itemType: "string",
      value: [],
    },

    { key: "city", label: "المدينة", type: "string", value: "" },
  ],

  [VendorServiceType.UNKNOWN]: [],
};
