// lib/services/chat_bot_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../services/token_storage.dart';

/// Relay service for communicating with the EventBot endpoint
final chatBotServiceProvider = Provider<ChatBotService>((ref) {
  final dio = ref.read(dioProvider);
  final storage = ref.read(tokenStorageProvider);
  return ChatBotService(dio, storage);
});

class ChatBotService {
  final Dio _dio;
  final TokenStorage _storage;
  ChatBotService(this._dio, this._storage) {
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  /// Sends [message] to `/api/chat`, reading token from storage, returns bot reply.
  Future<String> sendMessage(String message) async {
    final token = await _storage.readToken();
    if (token == null) {
      throw Exception('No auth token found');
    }
    try {
      final resp = await _dio.post(
        '/chat',
        data: {'message': message},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = resp.data;
      if (data is Map<String, dynamic> && data.containsKey('reply')) {
        return data['reply'] as String;
      }
      throw FormatException('Unexpected response format: \$data');
    } on DioException catch (e) {
      final err = e.response?.data['reply'] as String?;
      if (err != null) return err;
      rethrow;
    }
  }
}
