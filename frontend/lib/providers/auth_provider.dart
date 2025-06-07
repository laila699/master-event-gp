// lib/providers/auth_provider.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';
import '../models/user.dart';
import 'package:dio/dio.dart';

enum AuthStatus { unknown, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? message;

  const AuthState({required this.status, this.user, this.message});

  factory AuthState.unknown() => const AuthState(status: AuthStatus.unknown);
  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);
  factory AuthState.authenticated(User user) =>
      AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.error(String msg) =>
      AuthState(status: AuthStatus.error, message: msg);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState.unknown()) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    state = AuthState.loading();
    try {
      final user = await _authService.me();
      state = AuthState.authenticated(user);
    } on DioError catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        state = AuthState.unauthenticated();
      } else {
        state = AuthState.error('فشل في جلب بيانات المستخدم');
      }
    } catch (_) {
      state = AuthState.unauthenticated();
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = AuthState.loading();
    try {
      final user = await _authService.login(email: email, password: password);
      state = AuthState.authenticated(user);
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        state = AuthState.error('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      } else {
        state = AuthState.error('حدث خطأ أثناء تسجيل الدخول');
      }
    } catch (e) {
      state = AuthState.error('حدث خطأ غير متوقع');
    }
  }

  /// Note: we now expect a `VendorProfile? vendorProfile` object,
  /// instead of a raw JSON string.
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
    File? profileImage,
    VendorProfile? vendorProfile,
  }) async {
    state = AuthState.loading();
    try {
      final user = await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
        profileImage: profileImage,
        vendorProfile: vendorProfile,
      );
      state = AuthState.authenticated(user);
    } on DioError catch (e) {
      if (e.response?.statusCode == 400) {
        state = AuthState.error('هذا البريد مسجل بالفعل');
      } else {
        state = AuthState.error('حدث خطأ أثناء إنشاء الحساب');
      }
    } catch (e) {
      state = AuthState.error('حدث خطأ غير متوقع');
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    File? profileImage,
  }) async {
    state = AuthState.loading();
    try {
      final updatedUser = await _authService.updateProfile(
        name: name,
        email: email,
        phone: phone,
        profileImage: profileImage,
      );
      state = AuthState.authenticated(updatedUser);
    } on DioError catch (e) {
      if (e.response?.statusCode == 409) {
        state = AuthState.error('هذا البريد الإلكتروني مستخدم بالفعل');
      } else {
        state = AuthState.error('حدث خطأ أثناء تحديث الملف الشخصي');
      }
    } catch (_) {
      state = AuthState.error('حدث خطأ غير متوقع');
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState.unauthenticated();
  }
}

// Providers below (unchanged):
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final dioProvider = Provider<Dio>((ref) {
  throw UnimplementedError(
    'dioProvider must be overridden in main() using ProviderScope.overrides',
  );
});

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(tokenStorageProvider);
  return AuthService(dio, storage);
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final service = ref.read(authServiceProvider);
  return AuthNotifier(service);
});
