class Rating {
  final String organizerId;
  final String bookingId; // ID of the booking being rated
  final int value; // 1-5
  final String? review; // optional review text
  final DateTime ratedAt; // when the rating was given

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
    value: (json['value'] as num).toInt(), // ensure value is an int
    review: json['review'] as String?,
    ratedAt: DateTime.parse(json['ratedAt'] as String), // parse date string
  );

  Map<String, dynamic> toJson() => {
    'organizerId': organizerId,
    'bookingId': bookingId,
    'value': value,
    if (review != null) 'review': review,
    'ratedAt': ratedAt.toIso8601String(),
  };
}
