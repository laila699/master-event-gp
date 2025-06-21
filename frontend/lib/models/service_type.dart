// lib/models/service_type.dart

enum VendorServiceType {
  decorator,

  furnitureStore,
  photographer,
  restaurant,
  giftShop,
  entertainer,
  unknown,
}

extension VendorServiceTypeExt on VendorServiceType {
  String get value {
    switch (this) {
      case VendorServiceType.decorator:
        return 'decorator';

      case VendorServiceType.furnitureStore:
        return 'furniture_store';
      case VendorServiceType.photographer:
        return 'photographer';
      case VendorServiceType.restaurant:
        return 'restaurant';
      case VendorServiceType.giftShop:
        return 'gift_shop';
      case VendorServiceType.entertainer:
        return 'entertainer';
      case VendorServiceType.unknown:
        return '';
    }
  }

  /// **Never** returns null.
  String get label {
    switch (this) {
      case VendorServiceType.decorator:
        return 'الديكورات';

      case VendorServiceType.furnitureStore:
        return 'متجر أثاث';
      case VendorServiceType.photographer:
        return 'التصوير';
      case VendorServiceType.restaurant:
        return 'المطاعم';
      case VendorServiceType.giftShop:
        return 'متجر هدايا';
      case VendorServiceType.entertainer:
        return 'الترفيه والعروض';
      case VendorServiceType.unknown:
        return '';
    }
  }
}
