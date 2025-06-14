// lib/services/offering_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:masterevent/models/service_type.dart';
import '../models/offering.dart';
import 'token_storage.dart';

class OfferingService {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  OfferingService(this._dio, this._tokenStorage);

  /// List all offerings for a given vendor:
  Future<List<Offering>> listOfferings({required String vendorId}) async {
    final response = await _dio.get('/vendors/$vendorId/offerings');
    final data = response.data as List<dynamic>;
    return data
        .map((json) => Offering.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Offering>> fetchAllOfferings({
    VendorServiceType? serviceType,
  }) async {
    // build query-params
    final qp = <String, dynamic>{};
    if (serviceType != null) {
      // our backend expects the enum key, not an ObjectId
      qp['serviceType'] = serviceType.value;
    }

    final resp = await _dio.get('/offerings', queryParameters: qp);

    final data = resp.data as List<dynamic>;
    return data
        .map((json) => Offering.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Offering> fetchOfferingById({
    required String vendorId,
    required String offeringId,
  }) async {
    final resp = await _dio.get('/vendors/$vendorId/offerings/$offeringId');
    return Offering.fromJson(resp.data as Map<String, dynamic>);
  }

  /// Create a new offering. `imageFiles` can be multiple local Files.
  Future<Offering> createOffering({
    required String vendorId,
    required String title,
    String? description,
    required double price,
    List<File>? imageFiles,
  }) async {
    final formDataMap = {
      'title': title,
      'price': price,
      if (description != null) 'description': description,
    };

    if (imageFiles != null && imageFiles.isNotEmpty) {
      final uploaded = <MultipartFile>[];
      for (var file in imageFiles) {
        final filename = file.path.split('/').last;
        uploaded.add(
          await MultipartFile.fromFile(file.path, filename: filename),
        );
      }
      formDataMap['images'] = uploaded;
    }

    final formData = FormData.fromMap(formDataMap);
    print('Creating offering with data: $formDataMap');
    final response = await _dio.post(
      '/vendors/$vendorId/offerings',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return Offering.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update an existing offering (title, description, price, optional new images):
  Future<Offering> updateOffering({
    required String vendorId,
    required String offeringId,
    String? title,
    String? description,
    double? price,
    List<File>? newImageFiles, // these replace or append, depending on backend
  }) async {
    final formDataMap = <String, dynamic>{};
    if (title != null) formDataMap['title'] = title;
    if (description != null) formDataMap['description'] = description;
    if (price != null) formDataMap['price'] = price;
    if (newImageFiles != null && newImageFiles.isNotEmpty) {
      final uploaded = <MultipartFile>[];
      for (var file in newImageFiles) {
        final filename = file.path.split('/').last;
        uploaded.add(
          await MultipartFile.fromFile(file.path, filename: filename),
        );
      }
      formDataMap['images'] = uploaded;
    }

    final formData = FormData.fromMap(formDataMap);
    final response = await _dio.put(
      '/vendors/$vendorId/offerings/$offeringId',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return Offering.fromJson(response.data as Map<String, dynamic>);
  }

  /// Delete an offering:
  Future<void> deleteOffering({
    required String vendorId,
    required String offeringId,
  }) async {
    await _dio.delete('/vendors/$vendorId/offerings/$offeringId');
  }
}
