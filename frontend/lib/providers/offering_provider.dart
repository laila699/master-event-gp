// lib/providers/offering_provider.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masterevent/models/service_type.dart';
import '../models/offering.dart';
import '../services/offering_service.dart';
import 'auth_provider.dart';

/// StateNotifier that holds offerings for a specific vendor.
class VendorOfferingsNotifier
    extends StateNotifier<AsyncValue<List<Offering>>> {
  final OfferingService _service;
  final Ref _ref;
  final String vendorId;

  VendorOfferingsNotifier(this._service, this._ref, this.vendorId)
    : super(const AsyncValue.loading()) {
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    // Fetch offerings using the passed-in vendorId, not auth user
    try {
      final list = await _service.listOfferings(vendorId: vendorId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Public method to refresh from UI:
  Future<void> refresh() async => _loadOfferings();

  /// Add a new offering for this vendor
  Future<void> addOffering({
    required String title,
    String? description,
    required double price,
    List<File>? images,
  }) async {
    final previous = state.valueOrNull ?? <Offering>[];
    state = const AsyncValue.loading();
    try {
      final newOff = await _service.createOffering(
        vendorId: vendorId,
        title: title,
        description: description,
        price: price,
        imageFiles: images,
      );
      state = AsyncValue.data([...previous, newOff]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update an existing offering for this vendor
  Future<void> updateExisting({
    required String offeringId,
    String? title,
    String? description,
    double? price,
    List<File>? newImages,
  }) async {
    final prev = state.valueOrNull;
    if (prev == null) return;
    try {
      final updated = await _service.updateOffering(
        vendorId: vendorId,
        offeringId: offeringId,
        title: title,
        description: description,
        price: price,
        newImageFiles: newImages,
      );
      state = AsyncValue.data(
        prev.map((off) => off.id == offeringId ? updated : off).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // get offer by id
  Future<Offering> getOfferingById(String offeringId) async {
    try {
      return await _service.fetchOfferingById(
        vendorId: vendorId,
        offeringId: offeringId,
      );
    } catch (e) {
      throw Exception('Failed to fetch offering: $e');
    }
  }

  /// Delete an offering for this vendor
  Future<void> deleteExisting({required String offeringId}) async {
    final prev = state.valueOrNull;
    if (prev == null) return;
    try {
      await _service.deleteOffering(vendorId: vendorId, offeringId: offeringId);
      state = AsyncValue.data(
        prev.where((off) => off.id != offeringId).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final offeringDetailProvider = FutureProvider.family<Offering, String>((
  ref,
  offeringId,
) {
  final auth = ref.watch(authNotifierProvider);
  final vendorId = auth.user!.id;
  return ref
      .read(vendorOfferingsProvider(vendorId).notifier)
      .getOfferingById(offeringId);
});

/// Expose as a family provider keyed by vendorId
final vendorOfferingsProvider = StateNotifierProvider.family<
  VendorOfferingsNotifier,
  AsyncValue<List<Offering>>,
  String
>((ref, vendorId) {
  final service = ref.watch(offeringServiceProvider);
  return VendorOfferingsNotifier(service, ref, vendorId);
});

/// OfferingService provider
final offeringServiceProvider = Provider<OfferingService>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(tokenStorageProvider);
  return OfferingService(dio, storage);
});
final allOfferingsProvider =
    FutureProvider.family<List<Offering>, VendorServiceType?>((
      ref,
      serviceType,
    ) {
      final svc = ref.watch(offeringServiceProvider);
      return svc.fetchAllOfferings(serviceType: serviceType);
    });
