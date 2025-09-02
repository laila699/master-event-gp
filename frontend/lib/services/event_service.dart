// lib/services/event_service.dart

import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:softwareGP/models/recommended_offers.dart';
import '../models/trip.dart';
import '../models/member.dart';

class TripService {
  final Dio _dio;
  TripService(this._dio);

  Future<List<Trip>> fetchTrips(String organizerId) async {
    final resp = await _dio.get(
      // Fetch events for a specific organizer
      '/events',
      queryParameters: {'organizerId': organizerId},
    );
    final data = resp.data; // Check if data is a List or Map
    if (data is List) {
      return data.map((e) => Trip.fromJson(e as Map<String, dynamic>)).toList();
    } else if (data is Map<String, dynamic> && data['events'] is List) {
      return (data['events'] as List)
          .map((e) => Trip.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Unexpected /events response: $data');
  }

  Future<List<RecBucket>> fetchRecommendedOffers(
    // Fetch recommended offers for a specific event
    String eventId, {
    int limit = 5, // Limit the number of recommendations
  }) async {
    final resp = await _dio.get(
      '/events/$eventId/recommended-offerings',
      queryParameters: {'limit': limit},
    );

    return (resp.data
            as List) // convert each recommended offer to RecBucket object
        .map((e) => RecBucket.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Trip> fetchTripById(String eventId) async {
    final resp = await _dio.get('/events/$eventId');
    return Trip.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<Trip> createTrip({
    required String title,
    required DateTime date,
    required String venue,
    LatLng? venueLocation,
  }) async {
    final resp = await _dio.post(
      '/events',
      data: {
        'title': title,
        'date': date.toIso8601String(),
        'venue': venue,
        if (venueLocation != null)
          'venueLocation': {
            'type': 'Point',
            'coordinates': [venueLocation.longitude, venueLocation.latitude],
          },
      },
    );
    return Trip.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<Trip> updateTrip({
    required String eventId,
    String? title,
    DateTime? date,
    String? venue,
    Map<String, dynamic>? settings,
    LatLng? venueLocation,
    String? description,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (date != null) data['date'] = date.toIso8601String();
    if (venue != null) data['venue'] = venue;
    if (settings != null) data['settings'] = settings;
    if (venueLocation != null) {
      data['venueLocation'] = {
        'type': 'Point',
        'coordinates': [venueLocation.longitude, venueLocation.latitude],
      };
    }
    if (description != null) data['description'] = description;

    final resp = await _dio.put('/events/$eventId', data: data);
    return Trip.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> deleteTrip(String eventId) async {
    await _dio.delete('/events/$eventId');
  }

  Future<void> registerPushToken(String token) => // Register push token
      _dio.post('/notifications/token', data: {'token': token});

  Future<void> deletePushToken(String token) =>
      _dio.delete('/notifications/token', data: {'token': token});
  Future<Member> addMember({
    required String eventId,
    required String name,
    required String email,
  }) async {
    final resp = await _dio.post(
      '/events/$eventId/guests',
      data: {'name': name, 'email': email},
    );
    return Member.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<Member> updateMemberStatus({
    required String eventId,
    required String guestId,
    required String status,
  }) async {
    final resp = await _dio.put(
      '/events/$eventId/guests/$guestId',
      data: {'status': status},
    );
    return Member.fromJson(resp.data as Map<String, dynamic>);
  }
}
