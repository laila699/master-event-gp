import 'dart:io';
import 'package:dio/dio.dart';
import '../models/menu_section.dart';
import 'token_storage.dart';

class RestaurantService {
  final Dio _dio;
  final TokenStorage _tokenStorage; // Token storage for authentication

  RestaurantService(this._dio, this._tokenStorage);

  /// 1) List all menu‐sections  (no “/menu” by itself—must be “/menu/sections”)
  Future<List<MenuSection>> listMenu({required String vendorId}) async {
    final response = await _dio.get('/vendors/$vendorId/menu');
    final data = response.data as List<dynamic>; // استخراج البيانات من الرد
    return data
        .map((json) => MenuSection.fromJson(json as Map<String, dynamic>)) // convert each section to MenuSection object
        .toList();
  }

  /// 2) Create a new section: SO SENT DATA
  Future<MenuSection> createMenuSection({
    required String vendorId,
    required String sectionName,
  }) async {
    // ← must hit “/menu/sections”
    final response = await _dio.post( // إرسال طلب لإنشاء قسم جديد
      '/vendors/$vendorId/menu/sections',
      data: {'name': sectionName},
    );
    return MenuSection.fromJson(response.data as Map<String, dynamic>);
  }

  /// 3) Update a section’s name:
  Future<MenuSection> updateMenuSection({
    required String vendorId,
    required String sectionId,
    required String newName,
  }) async {
    final response = await _dio.put(
      '/vendors/$vendorId/menu/sections/$sectionId',
      data: {'name': newName},
    );
    return MenuSection.fromJson(response.data as Map<String, dynamic>);
  }

  /// 4) Delete a section:
  Future<void> deleteMenuSection({
    required String vendorId,
    required String sectionId,
  }) async {
    await _dio.delete('/vendors/$vendorId/menu/sections/$sectionId');
  }

  /// 5) Add a new dish (item) under a section:
  Future<Dish> addDish({
    required String vendorId,
    required String sectionId,
    required String dishName,
    required String dishPrice,
    File? dishImage,
  }) async {
    final formMap = <String, dynamic>{'name': dishName, 'price': dishPrice};
    if (dishImage != null) {
      final filename = dishImage.path.split('/').last; //  JUST Extract filename from path
      formMap['image'] = await MultipartFile.fromFile(
        dishImage.path,
        filename: filename,
      );
    } // Convert the map to FormData for sending
    final formData = FormData.fromMap(formMap);

    // ← POST to “/menu/sections/:sectionId/items”
    final response = await _dio.post( // Send a request to create a new dish
      '/vendors/$vendorId/menu/sections/$sectionId/items',
      data: formData, // send form data with dish details name and price
      options: Options(contentType: 'multipart/form-data'),
    );
    return Dish.fromJson(response.data as Map<String, dynamic>); // Convert response data to Dish object
  }

  /// 6) Update a dish:
  Future<Dish> updateDish({
    required String vendorId,
    required String sectionId,
    required String dishId,
    String? newName,
    String? newPrice,
    File? newImage,
  }) async { 
    final formMap = <String, dynamic>{};
    if (newName != null) formMap['name'] = newName;
    if (newPrice != null) formMap['price'] = newPrice;
    if (newImage != null) {
      final filename = newImage.path.split('/').last; // th image is file 
      formMap['image'] = await MultipartFile.fromFile( // convert image to MultipartFile
        newImage.path,
        filename: filename,
      );
    }
    final formData = FormData.fromMap(formMap);

    // ← PUT to “/menu/sections/:sectionId/items/:dishId”
    final response = await _dio.put(
      '/vendors/$vendorId/menu/sections/$sectionId/items/$dishId',
      data: formData,
      options: Options(contentType: 'multipart/form-data'), // set content type for multipart/form-data
    );
    return Dish.fromJson(response.data as Map<String, dynamic>);
  }

  /// 7) Delete a dish:
  Future<void> deleteDish({
    required String vendorId,
    required String sectionId,
    required String dishId,
  }) async {
    // ← DELETE “/menu/sections/:sectionId/items/:dishId”
    await _dio.delete(
      '/vendors/$vendorId/menu/sections/$sectionId/items/$dishId',
    );
  }
}
