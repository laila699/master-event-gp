// lib/models/invitation_theme.dart

class InvitationTheme {
  final String id;
  final String name;
  final String imageUrl;

  InvitationTheme({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory InvitationTheme.fromJson(Map<String, dynamic> json) {
    return InvitationTheme(
      id: (json['_id'] as String?) ?? (json['id'] as String),
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      // imageUrl is set by backend after upload; we don’t send it here
    };
  }
}
