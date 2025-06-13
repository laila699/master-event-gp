// lib/services/event_service.dart

import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import '../models/event.dart';
import '../models/guest.dart';

class EventService {
  final Dio _dio;
  EventService(this._dio);

  Future<List<Event>> fetchEvents(String organizerId) async {
    final resp = await _dio.get(
      '/events',
      queryParameters: {'organizerId': organizerId},
    );
    final data = resp.data;
    if (data is List) {
      return data
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (data is Map<String, dynamic> && data['events'] is List) {
      return (data['events'] as List)
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Unexpected /events response: $data');
  }

  Future<Event> fetchEventById(String eventId) async {
    final resp = await _dio.get('/events/$eventId');
    return Event.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<Event> createEvent({
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
    return Event.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<Event> updateEvent({
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
    return Event.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> deleteEvent(String eventId) async {
    await _dio.delete('/events/$eventId');
  }

  Future<void> registerPushToken(String token) =>
      _dio.post('/notifications/token', data: {'token': token});

  Future<void> deletePushToken(String token) =>
      _dio.delete('/notifications/token', data: {'token': token});
  Future<Guest> addGuest({
    required String eventId,
    required String name,
    required String email,
  }) async {
    final resp = await _dio.post(
      '/events/$eventId/guests',
      data: {'name': name, 'email': email},
    );
    return Guest.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<Guest> updateGuestStatus({
    required String eventId,
    required String guestId,
    required String status,
  }) async {
    final resp = await _dio.put(
      '/events/$eventId/guests/$guestId',
      data: {'status': status},
    );
    return Guest.fromJson(resp.data as Map<String, dynamic>);
  }
}
