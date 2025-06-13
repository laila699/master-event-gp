import 'dart:io';
import 'package:dio/dio.dart';
import '../models/user.dart';
import '../models/invitation_theme.dart';
import 'token_storage.dart';

class AdminService {
  final Dio _dio;

  AdminService(this._dio);

  // --- Users ---
  Future<List<User>> fetchUsers() async {
    final resp = await _dio.get('/users');
    return (resp.data as List)
        .map((u) => User.fromJson(u as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteUser(String id) async {
    await _dio.delete('/users/$id');
  }

  // --- Themes ---
  Future<List<InvitationTheme>> fetchThemes() async {
    final resp = await _dio.get('/invitation-themes');
    return (resp.data as List)
        .map((t) => InvitationTheme.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  Future<InvitationTheme> createTheme(String name, File image) async {
    final form = FormData.fromMap({
      'name': name,
      'image': await MultipartFile.fromFile(
        image.path,
        filename: image.path.split(Platform.pathSeparator).last,
      ),
    });
    final resp = await _dio.post('/invitation-themes', data: form);
    return InvitationTheme.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<InvitationTheme> updateTheme(
    String id,
    String name,
    File? image,
  ) async {
    final Map<String, dynamic> map = {'name': name};
    if (image != null) {
      map['image'] = await MultipartFile.fromFile(
        image.path,
        filename: image.path.split(Platform.pathSeparator).last,
      );
    }
    final form = FormData.fromMap(map);
    final resp = await _dio.put('/invitation-themes/$id', data: form);
    return InvitationTheme.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> deleteTheme(String id) async {
    await _dio.delete('/invitation-themes/$id');
  }
}
