// lib/providers/menu_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masterevent/providers/auth_provider.dart';
import '../services/menu_service.dart';

/// A “menu section” simplified model. You can replace with a proper Dart class.
class MenuSection {
  final String id;
  final String name;
  MenuSection({required this.id, required this.name});

  factory MenuSection.fromJson(Map<String, dynamic> json) {
    return MenuSection(id: json['_id'] as String, name: json['name'] as String);
  }
}

/// A “menu item” simplified model.
class MenuItem {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;

  MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

/// StateNotifier to hold the list of sections for the currently‐logged‐in vendor.
class MenuSectionsNotifier
    extends StateNotifier<AsyncValue<List<MenuSection>>> {
  final MenuService _menuService;
  final String vendorId;

  MenuSectionsNotifier(this._menuService, this.vendorId)
    : super(const AsyncValue.loading()) {
    _fetchSections();
  }

  Future<void> _fetchSections() async {
    try {
      final data = await _menuService.getSections(vendorId);
      state = AsyncValue.data(
        data.map((e) => MenuSection.fromJson(e)).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addSection(String name) async {
    state = const AsyncValue.loading();
    try {
      final newJson = await _menuService.createSection(vendorId, name);
      final newSection = MenuSection.fromJson(newJson);
      state = state.whenData((list) => [...list, newSection]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSection(String sectionId, String newName) async {
    state = const AsyncValue.loading();
    try {
      final updatedJson = await _menuService.updateSection(
        vendorId,
        sectionId,
        newName,
      );
      final updatedSection = MenuSection.fromJson(updatedJson);
      state = state.whenData((list) {
        return list
            .map((sec) => sec.id == sectionId ? updatedSection : sec)
            .toList();
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteSection(String sectionId) async {
    state = const AsyncValue.loading();
    try {
      await _menuService.deleteSection(vendorId, sectionId);
      state = state.whenData((list) {
        return list.where((sec) => sec.id != sectionId).toList();
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for vendor’s menu sections. Replace “currentVendorId” with your logic to fetch it.
final menuSectionsProvider = StateNotifierProvider.family<
  MenuSectionsNotifier,
  AsyncValue<List<MenuSection>>,
  String
>((ref, vendorId) {
  final svc = ref.watch(menuServiceProvider);
  return MenuSectionsNotifier(svc, vendorId);
});

/// StateNotifier for a single section’s list of items
class MenuItemsNotifier extends StateNotifier<AsyncValue<List<MenuItem>>> {
  final MenuService _menuService;
  final String vendorId;
  final String sectionId;

  MenuItemsNotifier(this._menuService, this.vendorId, this.sectionId)
    : super(const AsyncValue.loading()) {
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    try {
      final data = await _menuService.getItems(vendorId, sectionId);
      state = AsyncValue.data(data.map((e) => MenuItem.fromJson(e)).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addItem({
    required String name,
    String? description,
    required double price,
    String? imageUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      final newJson = await _menuService.createItem(
        vendorId,
        sectionId,
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
      );
      final newItem = MenuItem.fromJson(newJson);
      state = state.whenData((list) => [...list, newItem]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateItem(
    String itemId, {
    String? name,
    String? description,
    double? price,
    String? imageUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      final updatedJson = await _menuService.updateItem(
        vendorId,
        sectionId,
        itemId,
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
      );
      final updatedItem = MenuItem.fromJson(updatedJson);
      state = state.whenData(
        (list) => list.map((it) => it.id == itemId ? updatedItem : it).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteItem(String itemId) async {
    state = const AsyncValue.loading();
    try {
      await _menuService.deleteItem(vendorId, sectionId, itemId);
      state = state.whenData(
        (list) => list.where((it) => it.id != itemId).toList(),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider family: each section has its own items
final menuItemsProvider = StateNotifierProvider.family<
  MenuItemsNotifier,
  AsyncValue<List<MenuItem>>,
  Map<String, String>
>((ref, params) {
  // params should contain { vendorId, sectionId }
  final svc = ref.watch(menuServiceProvider);
  return MenuItemsNotifier(svc, params['vendorId']!, params['sectionId']!);
});
final menuServiceProvider = Provider<MenuService>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(tokenStorageProvider);
  return MenuService(dio, storage);
});
