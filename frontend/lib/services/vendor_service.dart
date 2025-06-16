// lib/services/vendor_service.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masterevent/models/provider_attribute.dart';
import 'package:masterevent/models/service_type.dart';
import 'package:masterevent/models/user.dart';
import '../models/provider_model.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:http_parser/http_parser.dart'; // for MediaType

class VendorService {
  final Dio _dio;
  VendorService(this._dio);
  Future<List<User>> listVendors({
    required VendorServiceType type,
    String? city,
    double? lat,
    double? lng,
    double? radiusKm,
    Map<String, String>? attrs,
  }) async {
    final qp = <String, dynamic>{
      'serviceType': type.value,
      if (city != null) 'city': city,
      if (lat != null && lng != null) ...{
        'lat': lat.toString(),
        'lng': lng.toString(),
        'radius': radiusKm?.toString() ?? '10',
      },
      if (attrs != null)
        for (final e in attrs.entries) e.key: e.value,
    };

    final resp = await _dio.get('/vendors', queryParameters: qp);
    return (resp.data as List).map((json) => User.fromJson(json)).toList();
  }

  /// Rate a vendor **once** per booking.
  ///
  /// Returns `{averageRating, ratingsCount}` from the API.
  Future<Map<String, dynamic>> rateVendor({
    required String vendorId,
    required String bookingId,
    required int value, // 1–5
    String? review,
    required String eventId,
  }) async {
    assert(value >= 1 && value <= 5);
    final resp = await _dio.post<Map<String, dynamic>>(
      '/vendors/$vendorId/ratings',
      data: {
        'bookingId': bookingId,
        'value': value,
        'eventId': eventId,
        if (review != null) 'review': review,
      },
    );
    return resp.data!;
  }

  Future<ProviderModel> fetchProviderModel(String vendorId) async {
    final resp = await _dio.get('/vendors/$vendorId');
    return ProviderModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> updateProviderAttributes(
    String vendorId,
    List<ProviderAttribute> attrs,
  ) async {
    await _dio.put(
      '/vendors/$vendorId',
      data: {'attributes': attrs.map((a) => a.toJson()).toList()},
    );
  }

  Future<String> uploadAttributeImage(
    String vendorId,
    String key,
    dynamic file, // can be File or XFile
  ) async {
    MultipartFile multipart;

    if (kIsWeb && file is XFile) {
      // Web: read bytes
      final bytes = await file.readAsBytes();
      multipart = MultipartFile.fromBytes(
        bytes,
        filename: file.name,
        contentType: MediaType(
          'image',
          p.extension(file.name).replaceFirst('.', ''),
        ),
      );
    } else if (file is File) {
      // Mobile/desktop: normal File
      final filename = p.basename(file.path);
      multipart = await MultipartFile.fromFile(file.path, filename: filename);
    } else {
      throw ArgumentError('Unsupported file type');
    }

    final formData = FormData.fromMap({'file': multipart});

    final resp = await _dio.post<Map<String, dynamic>>(
      '/vendors/$vendorId/attributes/$key/image',
      data: formData,
      // Let Dio set the content-type boundary header automatically
    );

    if (resp.statusCode == 200 && resp.data?['url'] != null) {
      return resp.data!['url'] as String;
    }
    throw Exception('Upload failed');
  }

  Future<void> updateLocation(String vendorId, double lat, double lng) async {
    await _dio.put(
      '/vendors/$vendorId/location',
      data: {
        "location": {'lat': lat.toString(), 'lng': lng.toString()},
      },
    );
  }

  Future<List<dynamic>> listBookings(String vendorId) async {
    final resp = await _dio.get('/vendors/$vendorId/bookings');
    return resp.data as List<dynamic>;
  }

  Future<List<dynamic>> listOfferings(String vendorId) async {
    final resp = await _dio.get('/vendors/$vendorId/offerings');
    return resp.data as List<dynamic>;
  }

  // offering create/update/delete with multipart…
  Future<Map<String, dynamic>> createOffering(
    String vendorId,
    FormData data,
  ) async {
    final resp = await _dio.post('/vendors/$vendorId/offerings', data: data);
    return resp.data as Map<String, dynamic>;
  }

  // similarly updateOffering, deleteOffering…
}
