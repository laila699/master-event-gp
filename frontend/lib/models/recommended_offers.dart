// lib/models/recommended_offers.dart
class RecOffer {
  final String id;
  final String title;
  final double price;
  final String vendorId;
  final String vendorName;
  final double? vendorRating;

  RecOffer({
    required this.id,
    required this.title,
    required this.price,
    required this.vendorId,
    required this.vendorName,
    this.vendorRating,
  });

  factory RecOffer.fromJson(Map<String, dynamic> j) => RecOffer(
    id: j['id'],
    title: j['title'],
    price: (j['price'] as num).toDouble(),
    vendorId: j['vendor']['id'],
    vendorName: j['vendor']['name'],
    vendorRating: (j['vendor']['averageRating'] as num?)?.toDouble(),
  );
}

class RecBucket {
  final String category;
  final double remaining;
  final List<RecOffer> offers;

  RecBucket({
    required this.category,
    required this.remaining,
    required this.offers,
  });

  factory RecBucket.fromJson(Map<String, dynamic> j) => RecBucket(
    category: j['category'],
    remaining: (j['remaining'] as num).toDouble(),
    offers: (j['offers'] as List).map((e) => RecOffer.fromJson(e)).toList(),
  );
}
