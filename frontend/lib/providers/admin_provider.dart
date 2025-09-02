// lib/providers/admin_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/invitation_theme.dart';
import '../services/admin_service.dart';

/// Exposes a singleton AdminService that uses DioClient.dio under the hood
final adminServiceProvider = Provider<AdminService>((ref) { // النوعAdminService , ref هو المرجع الذي يمكن استخدامه للوصول لمزودات أخرى، هنا لا نستخدمه إلا للتمرير.
  return AdminService();  // إرجاع كائن من AdminService نسخة
});

/// Fetches all non-admin users
final adminUsersProvider = FutureProvider<List<User>>((ref) { // سيُرجع بيانات مستقبلية (async) وهي قائمة مستخدمين List<User>.
  return ref.read(adminServiceProvider).fetchUsers(); // يستخدم مزود الخدمة لجلب المستخدمين
});

/// Fetches all invitation themes
final adminThemesProvider = FutureProvider<List<InvitationTheme>>((ref) {
  return ref.read(adminServiceProvider).fetchThemes();
});
