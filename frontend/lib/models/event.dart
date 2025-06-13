// lib/models/event.dart
import 'package:latlong2/latlong.dart';
import 'task.dart';
import 'guest.dart';

class EventSettings {
  final Map<String, dynamic>? budget;
  final Map<String, dynamic>? logistics;
  final List<Task>? tasks;

  EventSettings({this.budget, this.logistics, this.tasks});

  factory EventSettings.fromJson(Map<String, dynamic> json) {
    return EventSettings(
      budget:
          json['budget'] != null
              ? Map<String, dynamic>.from(json['budget'] as Map)
              : null,
      logistics:
          json['logistics'] != null
              ? Map<String, dynamic>.from(json['logistics'] as Map)
              : null,
      tasks:
          (json['tasks'] as List<dynamic>?)
              ?.map((e) => Task.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{};
    if (budget != null) m['budget'] = budget;
    if (logistics != null) m['logistics'] = logistics;
    if (tasks != null) m['tasks'] = tasks!.map((t) => t.toJson()).toList();
    return m;
  }
}

class Event {
  final String id;
  final String title;
  final DateTime date;
  final String venue;
  final LatLng? venueLocation;
  final String? description;
  final EventSettings? settings;
  final List<Guest>? guests;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.venue,
    this.venueLocation,
    this.settings,
    this.guests,
    this.description,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    LatLng? loc;
    if (json['venueLocation'] != null) {
      final coords = json['venueLocation']['coordinates'] as List<dynamic>;
      loc = LatLng(
        (coords[1] as num).toDouble(),
        (coords[0] as num).toDouble(),
      );
    }

    return Event(
      id: (json['_id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      date: DateTime.parse(
        (json['date'] as String?) ?? DateTime.now().toIso8601String(),
      ),
      venue: (json['venue'] as String?) ?? '',
      description: (json['description'] as String?),
      venueLocation: loc,
      settings:
          json['settings'] != null
              ? EventSettings.fromJson(json['settings'] as Map<String, dynamic>)
              : null,
      guests:
          (json['guests'] as List<dynamic>?)
              ?.map((e) => Guest.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  /// For creating a new event or sending full payload
  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'title': title,
      'date': date.toIso8601String(),
      'venue': venue,
      if (description != null) 'description': description,
    };
    if (venueLocation != null) {
      m['venueLocation'] = {
        'type': 'Point',
        'coordinates': [venueLocation!.longitude, venueLocation!.latitude],
      };
    }
    if (settings != null) {
      m['settings'] = settings!.toJson();
    }
    if (guests != null) {
      m['guests'] = guests!.map((g) => g.toJson()).toList();
    }
    return m;
  }

  /// For partial updates
  Map<String, dynamic> toUpdateJson({
    String? title,
    DateTime? date,
    String? venue,
    LatLng? venueLocation,
    EventSettings? settings,
    List<Guest>? guests,
    String? description,
  }) {
    final m = <String, dynamic>{};
    if (title != null) m['title'] = title;
    if (date != null) m['date'] = date.toIso8601String();
    if (venue != null) m['venue'] = venue;
    if (description != null) m['description'] = description;
    if (venueLocation != null) {
      m['venueLocation'] = {
        'type': 'Point',
        'coordinates': [venueLocation.longitude, venueLocation.latitude],
      };
    }
    if (settings != null) m['settings'] = settings.toJson();
    if (guests != null) {
      m['guests'] = guests.map((g) => g.toJson()).toList();
    }
    return m;
  }
}
