// lib/models/user.dart

import 'dart:convert';

class VendorProfile {
  final String serviceType; // e.g. "decorator", "restaurant", etc.
  final String? bio;
  final List<double>? location; // [lng, lat]

  VendorProfile({required this.serviceType, this.bio, this.location});

  /// Decode from a Map<String, dynamic> (not a JSON‐string!)
  factory VendorProfile.fromJson(Map<String, dynamic> json) {
    return VendorProfile(
      serviceType: (json['serviceType'] as String?) ?? '',
      bio: (json['bio'] as String?),
      location:
          (json['location'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList(),
    );
  }

  /// Convert to a simple JSON‐compatible Map
  Map<String, dynamic> toJson() {
    return {
      'serviceType': serviceType,
      if (bio != null) 'bio': bio,
      if (location != null) 'location': location,
    };
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String role; // "organizer" or "vendor" or "admin"
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
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      role: (json['role'] as String?) ?? 'organizer',
      phone: (json['phone'] as String?) ?? '',
      avatarUrl: (json['avatarUrl'] as String?),
      vendorProfile:
          json['vendorProfile'] != null
              ? VendorProfile.fromJson(
                json['vendorProfile'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
    };
    if (avatarUrl != null) {
      map['avatarUrl'] = avatarUrl;
    }
    if (vendorProfile != null) {
      map['vendorProfile'] = vendorProfile!.toJson();
    }
    return map;
  }
}
