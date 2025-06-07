// lib/providers/vendor_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masterevent/providers/auth_provider.dart';
import '../services/vendor_service.dart';
import '../models/provider_model.dart';

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
final vendorListProvider = FutureProvider<List<dynamic>>((ref) {
  return ref.watch(vendorServiceProvider).listVendors();
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
