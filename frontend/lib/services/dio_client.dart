// lib/services/dio_client.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'token_storage.dart';

class DioClient {
  static late final Dio dio;

  static Future<void> init(TokenStorage tokenStorage) async {
    // On web (Chrome), we point to localhost.
    // On Android emulator/device, we use 10.0.2.2 → host machine.
    final host = kIsWeb ? '127.0.0.1' : '172.16.0.38';
    print('Using host: $host');
    final baseUrl = 'http://$host:5000/api';

    dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      )
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = await tokenStorage.readToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            return handler.next(options);
          },
        ),
      );
  }
}
