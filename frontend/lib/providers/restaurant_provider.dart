// lib/providers/restaurant_provider.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/menu_section.dart';
import '../services/restaurant_service.dart';
import 'auth_provider.dart'; // for AuthState, AuthStatus, authNotifierProvider

/// 1) Service provider
final restaurantServiceProvider = Provider<RestaurantService>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(tokenStorageProvider);
  return RestaurantService(dio, storage);
});

/// 2) Notifier that holds the restaurant’s menu sections + items
class RestaurantMenuNotifier
    extends StateNotifier<AsyncValue<List<MenuSection>>> {
  final RestaurantService _service;
  final Ref _ref;

  RestaurantMenuNotifier(this._service, this._ref)
    : super(const AsyncValue.loading()) {
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    final authState = _ref.read(authNotifierProvider);
    if (authState.status != AuthStatus.authenticated) {
      state = const AsyncValue.error('غير مسجل دخول', StackTrace.empty);
      return;
    }

    final vendorId = authState.user!.id;
    try {
      final list = await _service.listMenu(vendorId: vendorId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async => _loadMenu();

  Future<void> addSection({required String name}) async {
    final authState = _ref.read(authNotifierProvider);
    if (authState.status != AuthStatus.authenticated) return;
    final vendorId = authState.user!.id;

    state = const AsyncValue.loading();
    try {
      final newSec = await _service.createMenuSection(
        vendorId: vendorId,
        sectionName: name,
      );
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data([...current, newSec]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSection({
    required String sectionId,
    required newName,
  }) async {
    final authState = _ref.read(authNotifierProvider);
    if (authState.status != AuthStatus.authenticated) return;
    final vendorId = authState.user!.id;

    state = const AsyncValue.loading();
    try {
      final updated = await _service.updateMenuSection(
        vendorId: vendorId,
        sectionId: sectionId,
        newName: newName,
      );
      final current = state.valueOrNull ?? [];
      final idx = current.indexWhere((s) => s.id == sectionId);
      if (idx != -1) {
        current[idx] = updated;
      }
      state = AsyncValue.data([...current]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteSection({required String sectionId}) async {
    final authState = _ref.read(authNotifierProvider);
    if (authState.status != AuthStatus.authenticated) return;
    final vendorId = authState.user!.id;

    state = const AsyncValue.loading();
    try {
      await _service.deleteMenuSection(
        vendorId: vendorId,
        sectionId: sectionId,
      );
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data(current.where((s) => s.id != sectionId).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addDish({
    required String sectionId,
    required String dishName,
    required String dishPrice,
    File? imageFile,
  }) async {
    final authState = _ref.read(authNotifierProvider);
    if (authState.status != AuthStatus.authenticated) return;
    final vendorId = authState.user!.id;

    state = const AsyncValue.loading();
    try {
      final newDish = await _service.addDish(
        vendorId: vendorId,
        sectionId: sectionId,
        dishName: dishName,
        dishPrice: dishPrice,
        dishImage: imageFile,
      );

      final current = state.valueOrNull ?? [];
      final idx = current.indexWhere((s) => s.id == sectionId);
      if (idx != -1) {
        final section = current[idx];
        final updatedItems = [...section.items, newDish];
        final updatedSection = MenuSection(
          id: section.id,
          name: section.name,
          items: updatedItems,
        );
        final newSections = List<MenuSection>.from(current);
        newSections[idx] = updatedSection;
        state = AsyncValue.data(newSections);
        return;
      }

      // If section not found, reload entire menu
      await _loadMenu();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateDish({
    required String sectionId,
    required String dishId,
    String? newName,
    String? newPrice,
    File? newImage,
  }) async {
    final authState = _ref.read(authNotifierProvider);
    if (authState.status != AuthStatus.authenticated) return;
    final vendorId = authState.user!.id;

    state = const AsyncValue.loading();
    try {
      final updated = await _service.updateDish(
        vendorId: vendorId,
        sectionId: sectionId,
        dishId: dishId,
        newName: newName,
        newPrice: newPrice,
        newImage: newImage,
      );

      final current = state.valueOrNull ?? [];
      final sIdx = current.indexWhere((s) => s.id == sectionId);
      if (sIdx != -1) {
        final section = current[sIdx];
        final dIdx = section.items.indexWhere((d) => d.id == dishId);
        if (dIdx != -1) {
          final updatedItems = List<Dish>.from(section.items);
          updatedItems[dIdx] = updated;
          final updatedSection = MenuSection(
            id: section.id,
            name: section.name,
            items: updatedItems,
          );
          final newSections = List<MenuSection>.from(current);
          newSections[sIdx] = updatedSection;
          state = AsyncValue.data(newSections);
          return;
        }
      }

      // Fallback: reload
      await _loadMenu();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteDish({
    required String sectionId,
    required String dishId,
  }) async {
    final authState = _ref.read(authNotifierProvider);
    if (authState.status != AuthStatus.authenticated) return;
    final vendorId = authState.user!.id;

    state = const AsyncValue.loading();
    try {
      await _service.deleteDish(
        vendorId: vendorId,
        sectionId: sectionId,
        dishId: dishId,
      );

      final current = state.valueOrNull ?? [];
      final sIdx = current.indexWhere((s) => s.id == sectionId);
      if (sIdx != -1) {
        final section = current[sIdx];
        final updatedItems =
            section.items.where((d) => d.id != dishId).toList();
        final updatedSection = MenuSection(
          id: section.id,
          name: section.name,
          items: updatedItems,
        );
        final newSections = List<MenuSection>.from(current);
        newSections[sIdx] = updatedSection;
        state = AsyncValue.data(newSections);
        return;
      }

      // Fallback: reload
      await _loadMenu();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// 3) Expose as a global provider
final restaurantMenuProvider = StateNotifierProvider<
  RestaurantMenuNotifier,
  AsyncValue<List<MenuSection>>
>((ref) {
  final service = ref.watch(restaurantServiceProvider);
  return RestaurantMenuNotifier(service, ref);
});
