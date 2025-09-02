// lib/models/service_type.dart

enum VendorServiceType {
  accommodation,

  transportation,
  photographer,
  restaurant,
  tools,
  guides,
  unknown,
}

extension VendorServiceTypeExt on VendorServiceType { // Extension for VendorServiceType
  String get value { // Returns the string representation of the enum in backend
    switch (this) {
      case VendorServiceType.accommodation:
        return 'accommodation';

      case VendorServiceType.transportation:
        return 'transportation';
      case VendorServiceType.photographer:
        return 'photographer';
      case VendorServiceType.restaurant:
        return 'restaurant';
      case VendorServiceType.tools:
        return 'tools';
      case VendorServiceType.guides:
        return 'guides';
      case VendorServiceType.unknown:
        return '';
    }
  }

  /// **Never** returns null.
  String get label {
    switch (this) {
      case VendorServiceType.accommodation:
        return 'الاقامة';

      case VendorServiceType.transportation:
        return 'النقل ';
      case VendorServiceType.photographer:
        return 'التصوير';
      case VendorServiceType.restaurant:
        return 'المطاعم';
      case VendorServiceType.tools:
        return 'معدات الرحل ';
      case VendorServiceType.guides:
        return 'المرشد ';
      case VendorServiceType.unknown:
        return '';
    }
  }
}
