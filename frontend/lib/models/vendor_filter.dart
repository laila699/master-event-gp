// lib/models/vendor_filter.dart
import 'package:flutter/foundation.dart';
import 'package:softwareGP/models/service_type.dart';

class VendorFilter {
  final VendorServiceType type;
  final String? city;
  final double? lat, lng, radiusKm; // e.g. 10.0 for 10 km radius
  final Map<String, String> attrs; // key-value pairs for attributes

  const VendorFilter({
    required this.type,
    this.city,
    this.lat,
    this.lng,
    this.radiusKm, // e.g. 10.0 for 10 km radius
    this.attrs = const {},
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;  // check if same instance
    if (other is! VendorFilter) return false; // check if other is VendorFilter
    return other.type == type &&
        other.city == city &&
        other.lat == lat &&
        other.lng == lng &&
        other.radiusKm == radiusKm &&
        mapEquals(other.attrs, attrs);
  }

  @override
  int get hashCode => Object.hash(
    type,
    city,
    lat,
    lng,
    radiusKm,
    Object.hashAll(attrs.entries.map((e) => Object.hash(e.key, e.value))),
  );
}
