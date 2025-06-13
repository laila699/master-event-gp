// lib/models/vendor_filter.dart
import 'package:flutter/foundation.dart';
import 'package:masterevent/models/service_type.dart';

class VendorFilter {
  final VendorServiceType type;
  final String? city;
  final double? lat, lng, radiusKm;
  final Map<String, String> attrs;

  const VendorFilter({
    required this.type,
    this.city,
    this.lat,
    this.lng,
    this.radiusKm,
    this.attrs = const {},
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VendorFilter) return false;
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
