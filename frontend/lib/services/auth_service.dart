// lib/services/auth_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'token_storage.dart';
import '../models/user.dart' as app_user;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  AuthService(this._dio, this._tokenStorage);

  /// POST /auth/register → { token, user }
  /// Accepts: name, email, phone, password, role, optional profileImage,
  /// and optional vendorProfile (which is a VendorProfile instance).
  Future<app_user.User> register({
    // 🔧 Register a new user
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    File? profileImage, // ؟ Optional profile image
    app_user.VendorProfile? vendorProfile,
  }) async {
    // 1) Build a Map<String, dynamic> so we can insert MultipartFile + other fields
    final Map<String, dynamic> formDataMap = {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role,
    };

    // 2) If vendorProfile is provided, encode it as JSON‐string with post request
    if (vendorProfile != null) {
      formDataMap['vendorProfile'] = jsonEncode(vendorProfile.toJson());
    }

    // 3) If an image was picked, attach it
    if (profileImage != null) {
      final fileName =
          profileImage.path.split('/').last; // Get the file name from the path
      formDataMap['profileImage'] = await MultipartFile.fromFile(
        // Create a MultipartFile from the picked image
        profileImage.path,
        filename: fileName,
      );
    }

    // 4) Convert  map to FormData and POST
    final formData = FormData.fromMap(
      formDataMap,
    ); // Convert the map to FormData
    final response = await _dio.post(
      '/auth/register',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    // response server should return { token, user }
    // 5) Parse the returned JSON
    final data = response.data as Map<String, dynamic>;
    final token = data['token'] as String;
    final userJson = data['user'] as Map<String, dynamic>;

    // 6) Save JWT locally, then return a User object
    await _tokenStorage.saveToken(
      token,
    ); // Save the JWT token for future requests
    return app_user.User.fromJson(
      userJson,
    ); // Convert the JSON to a User object
  }

  /*
  /// POST /auth/login → { token, user }
  Future<app_user.User> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    final data = response.data as Map<String, dynamic>;
    final jwtToken = data['token'] as String;
    final userJson = data['user'] as Map<String, dynamic>;
    final firebaseToken = data['firebaseToken'] as String; // ◀ just cast

    // 1️⃣ Sign into FirebaseAuth so Firestore rules see the right UID
    try {
      await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
      print('🔐 Firebase sign-in succeeded');
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '❌ signInWithCustomToken failed: code=${e.code}, message=${e.message}',
      );
      rethrow; // or wrap in a clearer Exception
    }

    // 2️⃣ Persist your own JWT
    await _tokenStorage.saveToken(jwtToken);

    // 3️⃣ Return your app User model
    return app_user.User.fromJson(userJson);
  }
 
 */

  /// POST /auth/login → { token, user, firebaseToken }
  Future<app_user.User> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      // Send a POST request to the login endpoint
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    // response server should return { token, user, firebaseToken } dart object
    final data = response.data as Map<String, dynamic>;
    final jwtToken = data['token'] as String;
    final userJson = data['user'] as Map<String, dynamic>;
    final firebaseJwt = data['firebaseToken'] as String;

    /* 1️⃣  Sign-in to FirebaseAuth (so Firestore rules work) */
    try {
      await FirebaseAuth.instance.signInWithCustomToken(firebaseJwt);
      debugPrint('🔐 Firebase sign-in succeeded');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ signInWithCustomToken failed → ${e.code}: ${e.message}');
      rethrow;
    }

    /* 2️⃣  Persist *your* JWT so 🚀 Dio sends it on every call */
    await _tokenStorage.saveToken(jwtToken);

    /* 3️⃣  Immediately register (or re-register) the FCM token */
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await _dio.post(
          '/notifications/token', // your backend route
          data: {'token': fcmToken},
        );
        debugPrint('📲 FCM token registered on server');
      } else {
        debugPrint('⚠️  FirebaseMessaging.getToken() returned null');
      }
    } catch (e, st) {
      debugPrint('⚠️  Failed to register FCM token: $e');
      debugPrintStack(stackTrace: st);
      // Don’t throw – login itself succeeded. NotificationService will retry onTokenRefresh
    }

    /* 4️⃣  Return the deserialized user */
    return app_user.User.fromJson(userJson);
  }

  /// GET /auth/me → current user

  /// GET /auth/me → current user
  Future<app_user.User> me() async {
    final response = await _dio.get('/auth/me');
    final userJson = response.data as Map<String, dynamic>;
    return app_user.User.fromJson(userJson);
  }

  Future<String> getUserName(String id) async {
    final resp = await _dio.get("/auth/users/$id");
    final data = resp.data as Map<String, dynamic>;
    return data['name'] as String;
  }

  /// PUT /auth/me → update profile (name, email, phone, avatar)
  Future<app_user.User> updateProfile({
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
    return app_user.User.fromJson(data);
  }

  Future<void> logout() async {
    await _tokenStorage.deleteToken();
  }
}
