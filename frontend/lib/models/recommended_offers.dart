// lib/models/recommended_offers.dart
// Represents a  ONE recommended offer
class RecOffer { 
  final String id;
  final String title;
  final double price;
  final String vendorId; // ID of the vendor providing this offer
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

// Represents a group of recommended offers
class RecBucket {
  final String category; // category of the offers LIKE "food", "clothing", etc.
  final double remaining; // remaining budget for this category
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
