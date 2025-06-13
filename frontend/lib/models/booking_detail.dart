import 'event.dart';
import 'offering.dart';

class BookingDetail {
  final String id;
  final Event event;
  final String vendorId;
  final String vendorName;
  final String offeringId;
  final String offeringTitle;
  final String? offeringDescription;
  final List<String> offeringImages;
  final double offeringPrice;
  final int quantity;
  final DateTime scheduledAt;
  final String? note;
  final String status;

  BookingDetail({
    required this.id,
    required this.event,
    required this.vendorId,
    required this.vendorName,
    required this.offeringId,
    required this.offeringTitle,
    this.offeringDescription,
    required this.offeringImages,
    required this.offeringPrice,
    required this.quantity,
    required this.scheduledAt,
    this.note,
    required this.status,
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    // parse nested event
    final ev = Event.fromJson(json['event'] as Map<String, dynamic>);
    // offering + vendor
    final offJson = json['offering'] as Map<String, dynamic>;
    final vendJson = offJson['vendor'] as Map<String, dynamic>;

    return BookingDetail(
      id: json['_id'] as String,
      event: ev,
      vendorId: vendJson['_id'] as String,
      vendorName: vendJson['name'] as String,
      offeringId: offJson['_id'] as String,
      offeringTitle: offJson['title'] as String,
      offeringDescription: offJson['description'] as String?,
      offeringImages: List<String>.from(offJson['images'] ?? []),
      offeringPrice: (offJson['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      scheduledAt:
          json['scheduledAt'] != null
              ? DateTime.parse(json['scheduledAt'] as String)
              : DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String?,
      status: json['status'] as String,
    );
  }
}
