// lib/models/offering.dart

class Offering {
  final String id;
  final String title;
  final String? description;
  final String vendorId; // ← new field so we know the owner

  final List<String> images; // list of image URLs
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;

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
    return Offering(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      vendorId: (json['vendor'] as String), // assume backend populates “vendor”

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
  }
}
