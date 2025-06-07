// lib/providers/offering_provider.dart

/// ... (other imports remain unchanged)
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/offering.dart';
import '../services/offering_service.dart';
import 'auth_provider.dart';

/// StateNotifier that holds this vendor’s offerings.
class VendorOfferingsNotifier
    extends StateNotifier<AsyncValue<List<Offering>>> {
  final OfferingService _service;
  final Ref _ref; // store Ref so we can read authState

  VendorOfferingsNotifier(this._service, this._ref)
    : super(const AsyncValue.loading()) {
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    final authState = _ref.read(authNotifierProvider);
    if (authState.status != AuthStatus.authenticated) {
      state = const AsyncValue.error('غير مسجل دخول', StackTrace.empty);
      return;
    }

    final vendorId = authState.user!.id;
    try {
      final list = await _service.listOfferings(vendorId: vendorId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Public method to refresh from UI:
  Future<void> refresh() async => _loadOfferings();

  /// Add a new offering (unchanged)
  Future<void> addOffering({
    required String title,
    String? description,
    required double price,
    List<File>? images,
  }) async {
    final authState = _ref.read(authNotifierProvider);
    if (authState.status != AuthStatus.authenticated) return;
    final vendorId = authState.user!.id;

    // We do show a loading state here because it's a full refresh
    // 1) remember the old list (if any) before we switch to loading:
    final previousList = state.valueOrNull ?? <Offering>[];

    // 2) show loading indicator (optional—remove if you don't want to flash)
    state = const AsyncValue.loading();

    try {
      final newOff = await _service.createOffering(
        vendorId: vendorId,
        title: title,
        description: description,
        price: price,
        imageFiles: images,
      );

      // 3) merge the newly created offering with the old ones
      state = AsyncValue.data([...previousList, newOff]);
    } catch (e, st) {
      // Restore old list in case of error, or show error state:
      state = AsyncValue.error(e, st);
    }
  }

  /// UPDATE: change to avoid flipping to a loading spinner
  Future<void> updateExisting({
    required String offeringId,
    String? title,
    String? description,
    double? price,
    List<File>? newImages,
  }) async {
    final authState = _ref.read(authNotifierProvider);
    if (authState.status != AuthStatus.authenticated) return;
    final vendorId = authState.user!.id;

    // Instead of setting a loading state, keep the old list visible:
    final previousValue = state.valueOrNull;
    if (previousValue == null) {
      // If there was no data to begin with, bail out or reload:
      await _loadOfferings();
      return;
    }

    try {
      // Call backend to update
      final updatedOff = await _service.updateOffering(
        vendorId: vendorId,
        offeringId: offeringId,
        title: title,
        description: description,
        price: price,
        newImageFiles: newImages,
      );

      // Replace just that one item in our existing list:
      final newList =
          previousValue.map((off) {
            if (off.id == offeringId) {
              return updatedOff;
            }
            return off;
          }).toList();

      state = AsyncValue.data(newList);
    } catch (e, st) {
      // If something goes wrong, preserve old data but emit error
      state = AsyncValue.error(e, st);
    }
  }

  /// Delete an offering
  Future<void> deleteExisting({required String offeringId}) async {
    final authState = _ref.read(authNotifierProvider);
    if (authState.status != AuthStatus.authenticated) return;
    final vendorId = authState.user!.id;

    final previousValue = state.valueOrNull;
    if (previousValue == null) return;

    try {
      await _service.deleteOffering(vendorId: vendorId, offeringId: offeringId);

      // Remove it locally without flipping to loading
      final newList =
          previousValue.where((off) => off.id != offeringId).toList();
      state = AsyncValue.data(newList);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Expose as a global provider
final vendorOfferingsProvider =
    StateNotifierProvider<VendorOfferingsNotifier, AsyncValue<List<Offering>>>((
      ref,
    ) {
      final service = ref.watch(offeringServiceProvider);
      return VendorOfferingsNotifier(service, ref);
    });
final offeringServiceProvider = Provider<OfferingService>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(tokenStorageProvider);
  return OfferingService(dio, storage);
});
