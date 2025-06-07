import 'dart:convert';
import 'package:dio/dio.dart';
import '../services/token_storage.dart';

class MenuService {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  MenuService(this._dio, this._tokenStorage);

  /// 1) Fetch all sections for a given vendor:
  Future<List<Map<String, dynamic>>> getSections(String vendorId) async {
    // ← must hit “/menu/sections”, not “/menu”
    final response = await _dio.get('/vendors/$vendorId/menu/sections');
    return List<Map<String, dynamic>>.from(response.data as List);
  }

  /// 2) Create a new section:
  Future<Map<String, dynamic>> createSection(
    String vendorId,
    String name,
  ) async {
    // ← POST to “/menu/sections”
    final response = await _dio.post(
      '/vendors/$vendorId/menu/sections',
      data: {'name': name},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// 3) Update a section’s name:
  Future<Map<String, dynamic>> updateSection(
    String vendorId,
    String sectionId,
    String newName,
  ) async {
    // ← PUT to “/menu/sections/:sectionId”
    final response = await _dio.put(
      '/vendors/$vendorId/menu/sections/$sectionId',
      data: {'name': newName},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// 4) Delete a section:
  Future<void> deleteSection(String vendorId, String sectionId) async {
    // ← DELETE “/menu/sections/:sectionId”
    await _dio.delete('/vendors/$vendorId/menu/sections/$sectionId');
  }

  /// 5) Fetch all items in a given section:
  Future<List<Map<String, dynamic>>> getItems(
    String vendorId,
    String sectionId,
  ) async {
    // ← GET “/menu/sections/:sectionId/items”
    final response = await _dio.get(
      '/vendors/$vendorId/menu/sections/$sectionId/items',
    );
    return List<Map<String, dynamic>>.from(response.data as List);
  }

  /// 6) Create a new item (“dish”) inside a section:
  Future<Map<String, dynamic>> createItem(
    String vendorId,
    String sectionId, {
    required String name,
    String? description,
    required double price,
    String? imageUrl,
  }) async {
    // ← POST to “/menu/sections/:sectionId/items”
    final response = await _dio.post(
      '/vendors/$vendorId/menu/sections/$sectionId/items',
      data: {
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// 7) Update an existing item:
  Future<Map<String, dynamic>> updateItem(
    String vendorId,
    String sectionId,
    String itemId, {
    String? name,
    String? description,
    double? price,
    String? imageUrl,
  }) async {
    // ← PUT “/menu/sections/:sectionId/items/:itemId”
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (price != null) data['price'] = price;
    if (imageUrl != null) data['imageUrl'] = imageUrl;

    final response = await _dio.put(
      '/vendors/$vendorId/menu/sections/$sectionId/items/$itemId',
      data: data,
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// 8) Delete an item:
  Future<void> deleteItem(
    String vendorId,
    String sectionId,
    String itemId,
  ) async {
    // ← DELETE “/menu/sections/:sectionId/items/:itemId”
    await _dio.delete(
      '/vendors/$vendorId/menu/sections/$sectionId/items/$itemId',
    );
  }
}
