// lib/services/booking_service.dart

import 'package:dio/dio.dart';
import 'package:masterevent/models/booking_detail.dart';
import '../models/booking.dart';

class BookingService {
  final Dio _dio;
  BookingService(this._dio);

  /// Organizer creates a booking, now requires scheduledAt + optional note
  Future<Booking> createBooking({
    required String eventId,
    required String offeringId,
    required DateTime scheduledAt,
    String? note,
    int quantity = 1,
  }) async {
    final data = {
      'event': eventId,
      'offering': offeringId,
      'quantity': quantity,
      'scheduledAt': scheduledAt.toIso8601String(),
      if (note != null) 'note': note,
    };
    final resp = await _dio.post('/bookings', data: data);
    return Booking.fromJson(resp.data as Map<String, dynamic>);
  }

  /// Organizer fetches all bookings for a given event
  Future<List<BookingDetail>> fetchBookingDetails({
    required String eventId,
  }) async {
    final resp = await _dio.get(
      '/bookings',
      queryParameters: {'event': eventId},
    );
    final data = resp.data as List<dynamic>;
    return data
        .map((e) => BookingDetail.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Booking>> listVendorBookings() async {
    final resp = await _dio.get('/bookings/vendor');
    final data = resp.data as List<dynamic>;
    return data
        .map((e) => Booking.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Vendor updates a booking’s status
  Future<Booking> updateBookingStatus({
    required String bookingId,
    required String status, // “confirmed” or “declined”
  }) async {
    final resp = await _dio.put(
      '/bookings/$bookingId/status',
      data: {'status': status},
    );
    return Booking.fromJson(resp.data as Map<String, dynamic>);
  }
}
  /// Vendor updates status (“confirmed” or “declined”)

