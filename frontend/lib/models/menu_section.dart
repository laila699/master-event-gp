// lib/models/menu_section.dart

class Dish {
  final String id;
  final String name;
  final double price; // ← numeric, not a String
  final String? imageUrl; // URL (e.g. "/uploads/offerings/…")
  final String? description;

  Dish({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.description,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['_id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{'name': name, 'price': price};
    if (description != null) m['description'] = description;
    if (imageUrl != null) m['imageUrl'] = imageUrl;
    return m;
  }
}

class MenuSection {
  final String id;
  final String name;
  final List<Dish> items; // ← now Dish.price is double, not String

  MenuSection({required this.id, required this.name, required this.items});

  factory MenuSection.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List<dynamic>?) ?? [];
    return MenuSection(
      id: json['_id'] as String,
      name: json['name'] as String,
      items:
          itemsJson
              .map((e) => Dish.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      // We generally don’t send `items` here, since items are created/edited through separate endpoints.
      'items': items.map((d) => d.toJson()).toList(),
    };
  }
}
