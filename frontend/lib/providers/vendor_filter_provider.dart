// lib/providers/vendor_filter_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masterevent/models/service_type.dart';
import 'package:masterevent/models/user.dart';
import 'package:masterevent/models/vendor_filter.dart';
import 'package:masterevent/providers/vendor_provider.dart';

class VendorFilterNotifier extends StateNotifier<VendorFilter> {
  VendorFilterNotifier()
    : super(const VendorFilter(type: VendorServiceType.decorator));

  void changeType(VendorServiceType t) => state = VendorFilter(type: t);
  void setAttr(String key, String? value) {
    final m = Map<String, String>.from(state.attrs);
    if (value == null)
      m.remove(key);
    else
      m[key] = value;
    state = VendorFilter(
      type: state.type,
      city: state.city,
      lat: state.lat,
      lng: state.lng,
      radiusKm: state.radiusKm,
      attrs: m,
    );
  }
}

final vendorFilterProvider =
    StateNotifierProvider<VendorFilterNotifier, VendorFilter>(
      (_) => VendorFilterNotifier(),
    );

final vendorListProvider = FutureProvider<List<User>>((ref) {
  final filter = ref.watch(vendorFilterProvider);
  return ref
      .watch(vendorServiceProvider)
      .listVendors(
        type: filter.type,
        city: filter.city,
        lat: filter.lat,
        lng: filter.lng,
        radiusKm: filter.radiusKm,
        attrs: filter.attrs,
      );
});
