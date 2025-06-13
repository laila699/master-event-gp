// lib/providers/admin_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masterevent/providers/auth_provider.dart';
import '../models/user.dart';
import '../models/invitation_theme.dart';
import '../services/admin_service.dart';

/// Exposes a singleton AdminService
final adminServiceProvider = Provider<AdminService>((ref) {
  final dio = ref.watch(dioProvider);

  return AdminService(dio);
});

/// Fetches all non-admin users
final adminUsersProvider = FutureProvider<List<User>>((ref) async {
  final svc = ref.watch(adminServiceProvider);
  return svc.fetchUsers();
});

/// Fetches all invitation themes
final adminThemesProvider = FutureProvider<List<InvitationTheme>>((ref) async {
  final svc = ref.watch(adminServiceProvider);
  return svc.fetchThemes();
});
