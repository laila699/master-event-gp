// lib/services/event_service.dart

import 'package:dio/dio.dart';
import '../models/event.dart';

class EventService {
  final Dio _dio;

  EventService(this._dio);

  /// Fetch events for a given organizer (user) ID.
  Future<List<Event>> fetchEvents(String organizerId) async {
    final response = await _dio.get(
      '/events',
      queryParameters: {'organizerId': organizerId},
    );

    final data = response.data;
    if (data is List) {
      // If the endpoint returns a JSON array of events:
      return data
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (data is Map<String, dynamic> && data['events'] is List) {
      // If wrapped in an “events” field: { "events": [ ... ] }
      return (data['events'] as List)
          .map((e) => Event.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Unexpected response format from /events: $data');
    }
  }
}
