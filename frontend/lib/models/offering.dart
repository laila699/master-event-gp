class Offering {
  final String id;
  final String title;
  final String? description;
  final String vendorId;
  final List<String> images;
  final double price;
  final DateTime createdAt; // when the offering was created
  final DateTime updatedAt; // when the offering was last updated

  Offering({
    required this.id,
    required this.title,
    required this.vendorId,
    this.description,
    required this.images,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Offering.fromJson(Map<String, dynamic> json) {
    // vendor can be a string ID or a populated object (map)
    final vendorRaw = json['vendor'];
    final vendorId =
        vendorRaw is String
            ? vendorRaw // If vendor is a string, use it directly
            : vendorRaw is Map<String, dynamic> // If vendor is a map, extract the ID
            ? (vendorRaw['_id'] as String)
            : ''; // Default to empty string if vendor is not provided

    return Offering(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      vendorId: vendorId,
      images:
          ((json['images'] as List<dynamic>?) ?? [])
              .map((e) => e as String)
              .toList(),
      price: (json['price'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'images': images,
      'price': price,
    };
  } // مابرجع id لانه بحدده السيرفر
}
