// lib/models/guest.dart

class Guest {
  final String id;
  final String name;
  final String email;
  final String status; // “pending” | “yes” | “no”

  Guest({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
  });

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'status': status,
  };
}
