// lib/services/admin_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import '../models/user.dart';
import '../models/invitation_theme.dart';
import 'dio_client.dart';

class AdminService {
  // use the singleton Dio instance you already initialized in main.dart
  final Dio _dio = DioClient.dio;

  // ─── Users ─────────────────────────────────────────────────────────────

  Future<List<User>> fetchUsers() async {
    final resp = await _dio.get('/admin/users');
    return (resp.data as List)
        .map((u) => User.fromJson(u as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteUser(String id) async {
    if (id.isEmpty) {
      throw Exception('Invalid user id: "$id"');
    }
    final path = '/admin/users/${id}';
    print('→ DELETE $path');
    await _dio.delete(path);
  }

  Future<void> approveUser(String id) async {
    if (id.isEmpty) throw Exception('Invalid user id: "$id"');
    await _dio.put('/admin/users/$id/approve');
  }

  // ─── Invitation Themes ─────────────────────────────────────────────────

  Future<List<InvitationTheme>> fetchThemes() async {
    final resp = await _dio.get('/admin/invitation-themes');
    return (resp.data as List)
        .map((t) => InvitationTheme.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  Future<InvitationTheme> createTheme(String name, dynamic image) async {
    MultipartFile imagePart;

    if (kIsWeb && image is XFile) {
      // on web, image_picker returns XFile
      final bytes = await image.readAsBytes();
      imagePart = MultipartFile.fromBytes(
        bytes,
        filename: image.name,
        // contentType: MediaType('image', 'jpeg'), // optional
      );
    } else if (image is File) {
      // on mobile/desktop
      imagePart = await MultipartFile.fromFile(
        image.path,
        filename: image.path,
      );
    } else {
      throw ArgumentError('Unsupported image type: ${image.runtimeType}');
    }

    final form = FormData.fromMap({'name': name, 'image': imagePart});

    return InvitationTheme.fromJson(
      (await _dio.post(
            '/admin/invitation-themes',
            data: form,
            options: Options(contentType: 'multipart/form-data'),
          )).data
          as Map<String, dynamic>,
    );
  }

  Future<InvitationTheme> updateTheme(
    String id,
    String name,
    dynamic? image,
  ) async {
    MultipartFile imagePart;

    if (kIsWeb && image is XFile) {
      // on web, image_picker returns XFile
      final bytes = await image.readAsBytes();
      imagePart = MultipartFile.fromBytes(
        bytes,
        filename: image.name,
        // contentType: MediaType('image', 'jpeg'), // optional
      );
    } else if (image is File) {
      // on mobile/desktop
      imagePart = await MultipartFile.fromFile(
        image.path,
        filename: image.path,
      );
    } else {
      throw ArgumentError('Unsupported image type: ${image.runtimeType}');
    }

    final Map<String, dynamic> map = {'name': name};
    if (image != null) {
      map['image'] = await MultipartFile.fromFile(
        image.path,
        filename: image.path,
      );
    }
    final resp = await _dio.put(
      '/admin/invitation-themes/$id',
      data: FormData.fromMap(map),
      options: Options(contentType: 'multipart/form-data'),
    );
    return InvitationTheme.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> deleteTheme(String id) async {
    await _dio.delete('/admin/invitation-themes/$id');
  }
}
