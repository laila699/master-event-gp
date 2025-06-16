class Rating {
  final String organizerId;
  final String bookingId;
  final int value; // 1-5
  final String? review;
  final DateTime ratedAt;

  Rating({
    required this.organizerId,
    required this.bookingId,
    required this.value,
    this.review,
    required this.ratedAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
    organizerId: json['organizerId'] as String,
    bookingId: json['bookingId'] as String,
    value: (json['value'] as num).toInt(),
    review: json['review'] as String?,
    ratedAt: DateTime.parse(json['ratedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'organizerId': organizerId,
    'bookingId': bookingId,
    'value': value,
    if (review != null) 'review': review,
    'ratedAt': ratedAt.toIso8601String(),
  };
}
