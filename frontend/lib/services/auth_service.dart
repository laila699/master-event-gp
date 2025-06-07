// lib/services/auth_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'token_storage.dart';
import '../models/user.dart';
import 'dart:convert';

class AuthService {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  AuthService(this._dio, this._tokenStorage);

  /// POST /auth/register → { token, user }
  /// Accepts: name, email, phone, password, role, optional profileImage,
  /// and optional vendorProfile (which is a VendorProfile instance).
  Future<User> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    File? profileImage,
    VendorProfile? vendorProfile,
  }) async {
    // 1) Build a Map<String, dynamic> so we can insert MultipartFile + other fields
    final Map<String, dynamic> formDataMap = {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
    };

    // 2) If vendorProfile is provided, encode it as JSON‐string
    if (vendorProfile != null) {
      formDataMap['vendorProfile'] = jsonEncode(vendorProfile.toJson());
    }

    // 3) If an image was picked, attach it
    if (profileImage != null) {
      final fileName = profileImage.path.split('/').last;
      formDataMap['profileImage'] = await MultipartFile.fromFile(
        profileImage.path,
        filename: fileName,
      );
    }

    // 4) Convert to FormData and POST
    final formData = FormData.fromMap(formDataMap);
    final response = await _dio.post(
      '/auth/register',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    // 5) Parse the returned JSON
    final data = response.data as Map<String, dynamic>;
    final token = data['token'] as String;
    final userJson = data['user'] as Map<String, dynamic>;

    // 6) Save JWT locally, then return a User object
    await _tokenStorage.saveToken(token);
    return User.fromJson(userJson);
  }

  /// POST /auth/login → { token, user }
  Future<User> login({required String email, required String password}) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = response.data as Map<String, dynamic>;
    final token = data['token'] as String;
    final userJson = data['user'] as Map<String, dynamic>;

    await _tokenStorage.saveToken(token);
    return User.fromJson(userJson);
  }

  /// GET /auth/me → current user
  Future<User> me() async {
    final response = await _dio.get('/auth/me');
    final userJson = response.data as Map<String, dynamic>;
    return User.fromJson(userJson);
  }

  /// PUT /auth/me → update profile (name, email, phone, avatar)
  Future<User> updateProfile({
    required String name,
    required String email,
    required String phone,
    File? profileImage,
  }) async {
    final Map<String, dynamic> formDataMap = {
      'name': name,
      'email': email,
      'phone': phone,
    };

    if (profileImage != null) {
      final filename = profileImage.path.split('/').last;
      formDataMap['profileImage'] = await MultipartFile.fromFile(
        profileImage.path,
        filename: filename,
      );
    }

    final formData = FormData.fromMap(formDataMap);
    final response = await _dio.put(
      '/auth/me',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = response.data as Map<String, dynamic>;
    return User.fromJson(data);
  }

  Future<void> logout() async {
    await _tokenStorage.deleteToken();
  }
}
