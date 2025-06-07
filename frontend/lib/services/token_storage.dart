// lib/services/token_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A simple wrapper around flutter_secure_storage for saving a JWT.
class TokenStorage {
  // Use flutter_secure_storage so tokens aren’t stored in plain SharedPreferences.
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// The key under which we store the JWT.
  static const _tokenKey = 'jwt_token';

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> readToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }
}
