// lib/models/provider_model.dart
import 'provider_attribute.dart';

class ProviderModel {
  final String id;
  final String serviceType;
  final List<ProviderAttribute> attributes;

  ProviderModel({
    required this.id,
    required this.serviceType,
    required this.attributes,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> j) => ProviderModel(
    id: j['id'] as String,
    serviceType: j['serviceType'] as String,
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
