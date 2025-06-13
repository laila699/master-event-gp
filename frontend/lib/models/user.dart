// lib/models/user.dart

import 'provider_attribute.dart';

class VendorProfile {
  final String serviceType; // e.g. "decorator"
  final String? bio;
  final List<double>? location; // [lng, lat]
  final List<ProviderAttribute>? attributes;

  VendorProfile({
    required this.serviceType,
    this.bio,
    this.location,
    this.attributes,
  });

  factory VendorProfile.fromJson(Map<String, dynamic> json) {
    // location comes as { type: "Point", coordinates: [lng,lat] } or as just [lng,lat]
    List<double>? loc;
    if (json['location'] is Map) {
      final coords = (json['location']['coordinates'] as List).cast<num>();
      loc = coords.map((n) => n.toDouble()).toList();
    } else if (json['location'] is List) {
      loc =
          (json['location'] as List)
              .cast<num>()
              .map((n) => n.toDouble())
              .toList();
    }

    // attributes array
    List<ProviderAttribute>? attrs;
    if (json['attributes'] is List) {
      attrs =
          (json['attributes'] as List)
              .map((e) => ProviderAttribute.fromJson(e as Map<String, dynamic>))
              .toList();
    }

    return VendorProfile(
      serviceType: json['serviceType'] as String,
      bio: json['bio'] as String?,
      location: loc,
      attributes: attrs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceType': serviceType,
      if (bio != null) 'bio': bio,
      if (location != null) 'location': location,
      if (attributes != null)
        'attributes': attributes!.map((a) => a.toJson()).toList(),
    };
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String? avatarUrl;
  final VendorProfile? vendorProfile;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    this.avatarUrl,
    this.vendorProfile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      vendorProfile:
          json['vendorProfile'] != null
              ? VendorProfile.fromJson(
                json['vendorProfile'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
    };
    if (avatarUrl != null) m['avatarUrl'] = avatarUrl;
    if (vendorProfile != null) {
      // assign the Map directly, don't cast to String
      m['vendorProfile'] = vendorProfile!.toJson();
    }
    return m;
  }
}
