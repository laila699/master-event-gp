// lib/models/provider_model.dart
import 'provider_attribute.dart';

class ProviderModel {
  final String id;
  final String serviceType;
  final List<ProviderAttribute> attributes;
  final double? averageRating; // ⭐ NEW
  final int? ratingsCount;

  ProviderModel({
    required this.id,
    required this.serviceType,
    required this.attributes,
    required this.averageRating,
    required this.ratingsCount,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> j) => ProviderModel(
    id: j['id'] as String,
    serviceType: j['serviceType'] as String,
    averageRating: (j['averageRating'] as num?)?.toDouble(),
    ratingsCount: (j['ratingsCount'] as num?)?.toInt(),
    attributes:
        (j['attributes'] as List)
            .map((a) => ProviderAttribute.fromJson(a as Map<String, dynamic>))
            .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'serviceType': serviceType,
    'attributes': attributes.map((a) => a.toJson()).toList(),
  };
}
