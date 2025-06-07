// lib/models/event.dart

class Event {
  final String id;
  final String title;
  final DateTime date;
  final String venue;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.venue,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: (json['_id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      date: DateTime.parse(
        (json['date'] as String?) ?? DateTime.now().toIso8601String(),
      ),
      venue: (json['venue'] as String?) ?? '',
    );
  }
}
