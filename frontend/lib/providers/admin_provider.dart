// lib/providers/admin_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/invitation_theme.dart';
import '../services/admin_service.dart';

/// Exposes a singleton AdminService that uses DioClient.dio under the hood
final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService();
});

/// Fetches all non-admin users
final adminUsersProvider = FutureProvider<List<User>>((ref) {
  return ref.read(adminServiceProvider).fetchUsers();
});

/// Fetches all invitation themes
final adminThemesProvider = FutureProvider<List<InvitationTheme>>((ref) {
  return ref.read(adminServiceProvider).fetchThemes();
});
