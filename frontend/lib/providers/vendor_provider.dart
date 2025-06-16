// lib/providers/vendor_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masterevent/models/service_type.dart';
import 'package:masterevent/models/user.dart';
import 'package:masterevent/models/vendor_filter.dart';
import 'package:masterevent/providers/auth_provider.dart';
import '../services/vendor_service.dart';
import '../models/provider_model.dart';
import 'dart:io';

final vendorServiceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return VendorService(dio);
});

// “Family” for details tab
final providerModelFamily = FutureProvider.family<ProviderModel, String>((
  ref,
  vendorId,
) {
  return ref.watch(vendorServiceProvider).fetchProviderModel(vendorId);
});

// list of vendors (for directory)
// lib/providers/vendor_provider.dart
/// One-shot mutation provider – call inside a button handler.
final rateVendorProvider = Provider((ref) {
  final svc = ref.read(vendorServiceProvider);
  return ({
    required String vendorId,
    required String bookingId,
    required int value,
    required String eventId,
    String? review,
  }) => svc.rateVendor(
    vendorId: vendorId,
    bookingId: bookingId,
    value: value,
    eventId: eventId,
    review: review,
  );
});

final vendorListProvider = FutureProvider.family<List<User>, VendorFilter>(
  (ref, filter) => ref
      .watch(vendorServiceProvider)
      .listVendors(
        type: filter.type,
        city: filter.city,
        lat: filter.lat,
        lng: filter.lng,
        radiusKm: filter.radiusKm,
        attrs: filter.attrs,
      ),
);

final uploadAttributeImageFn = Provider((ref) {
  final svc = ref.read(vendorServiceProvider);
  return (String vendorId, String key, File file) =>
      svc.uploadAttributeImage(vendorId, key, file);
});

// bookings
final bookingListFamily = FutureProvider.family<List<dynamic>, String>((
  ref,
  vid,
) {
  return ref.watch(vendorServiceProvider).listBookings(vid);
});

// offerings
final offeringListFamily = FutureProvider.family<List<dynamic>, String>((
  ref,
  vid,
) {
  return ref.watch(vendorServiceProvider).listOfferings(vid);
});
