// lib/services/vendor_service.dart
import 'package:dio/dio.dart';
import 'package:masterevent/models/provider_attribute.dart';
import '../models/provider_model.dart';

class VendorService {
  final Dio _dio;
  VendorService(this._dio);

  Future<List<dynamic>> listVendors({
    double? lat,
    double? lng,
    double? radiusKm,
  }) async {
    final resp = await _dio.get(
      '/vendors',
      queryParameters: {
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (radiusKm != null) 'radius': radiusKm,
      },
    );
    return resp.data as List<dynamic>;
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

  Future<void> updateLocation(String vendorId, double lat, double lng) async {
    await _dio.put(
      '/vendors/$vendorId/location',
      data: {'lat': lat.toString(), 'lng': lng.toString()},
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
