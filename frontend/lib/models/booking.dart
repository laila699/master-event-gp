// lib/models/booking.dart

class Booking {
  final String id;
  final String eventId;
  final String offeringId;
  final int quantity;
  final DateTime scheduledAt;
  final String? note;
  final bool rated;
  final String status; // “pending” | “confirmed” | “declined”
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.eventId,
    required this.offeringId,
    required this.quantity,
    required this.scheduledAt,
    required this.rated,
    this.note,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // helper to pull out ID whether it's a string or a nested {_id: ...} map
    String extractId(dynamic field) {
      if (field is String) return field;
      if (field is Map<String, dynamic> && field['_id'] is String) {
        return field['_id'] as String;
      }
      return '';
    }

    // helper to parse a date field that may be a String or {"$date":String}
    String _extractIso(dynamic raw) {
      if (raw is String) return raw;
      if (raw is Map<String, dynamic>) {
        // MongoDB extended JSON might use $date
        if (raw.containsKey(r'$date') && raw[r'$date'] is String) {
          return raw[r'$date'] as String;
        }
        // fallback to a "date" key
        if (raw.containsKey('date') && raw['date'] is String) {
          return raw['date'] as String;
        }
      }
      // last resort: toString (should be an ISO)
      return raw.toString();
    }

    return Booking(
      id: json['_id'] as String,
      eventId: extractId(json['event']),
      offeringId: extractId(json['offering']),
      quantity: (json['quantity'] as num).toInt(),
      scheduledAt: DateTime.parse(_extractIso(json['scheduledAt'])),
      note: json['note'] as String?,
      rated: (json['rated'] as bool?) ?? false,

      status: json['status'] as String,
      createdAt: DateTime.parse(_extractIso(json['createdAt'])),
      updatedAt: DateTime.parse(_extractIso(json['updatedAt'])),
    );
  }

  Map<String, dynamic> toJsonForCreate() {
    return {
      'event': eventId,
      'offering': offeringId,
      'quantity': quantity,
      'scheduledAt': scheduledAt.toIso8601String(),
      if (note != null) 'note': note,
    };
  }
}
