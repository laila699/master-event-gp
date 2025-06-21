import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masterevent/models/user.dart';
import 'package:masterevent/models/invitation_theme.dart';
import 'package:masterevent/providers/admin_provider.dart';
import 'package:masterevent/providers/auth_provider.dart';
import 'package:masterevent/screens/auth/login_screen.dart';

const Map<String, IconData> _roleIcons = {
  'organizer': Icons.event_note,
  'vendor': Icons.store_mall_directory,
  'admin': Icons.admin_panel_settings,
};

const Map<String, IconData> _vendorTypeIcons = {
  'decorator': Icons.brush,
  'furniture_store': Icons.chair,
  'photographer': Icons.camera_alt,
  'restaurant': Icons.restaurant,
  'gift_shop': Icons.card_giftcard,
  'entertainer': Icons.music_note,
};

const Map<String, String> _vendorTypeLabels = {
  'decorator': 'منسق ديكور',
  'furniture_store': 'محل أثاث',
  'photographer': 'مصور',
  'restaurant': 'مطعم',
  'gift_shop': 'محل هدايا',
  'entertainer': 'مُسلي',
};

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);
  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    ref.refresh(adminUsersProvider);
    ref.refresh(adminThemesProvider);
  }

  @override
  Widget build(BuildContext context) {
    // at the top of AdminDashboardScreen (or in a shared file)
    const Map<String, IconData> _roleIcons = {
      'organizer': Icons.event_note,
      'vendor': Icons.store_mall_directory,
      'admin': Icons.admin_panel_settings,
    };

    const Map<String, IconData> _vendorTypeIcons = {
      'decorator': Icons.brush,
      'furniture_store': Icons.chair,
      'photographer': Icons.camera_alt,
      'restaurant': Icons.restaurant,
      'gift_shop': Icons.card_giftcard,
      'entertainer': Icons.music_note,
    };

    final usersAsync = ref.watch(adminUsersProvider);
    final themesAsync = ref.watch(adminThemesProvider);
    final accent1 = Theme.of(context).colorScheme.primary;
    final accent2 = Theme.of(context).colorScheme.secondary;

    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.7, -0.7),
              radius: 1.5,
              colors: [accent1.withOpacity(0.8), Colors.black],
            ),
          ),
        ),
        // Blur overlay
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
        // Main scaffold
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'لوحة التحكم',
              style: GoogleFonts.orbitron(color: accent1),
            ),
            backgroundColor: Colors.black.withOpacity(0.4),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: accent2,
              labelStyle: GoogleFonts.orbitron(fontWeight: FontWeight.w600),
              tabs: [Tab(text: 'المستخدمون'), Tab(text: 'التصاميم')],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: accent1),
                onPressed: _refreshAll,
              ),
              IconButton(
                icon: Icon(Icons.logout, color: accent1),
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Users Tab
              usersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (e, _) => Center(
                      child: Text('خطأ: $e', style: TextStyle(color: accent2)),
                    ),
                data: (users) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length,
                    itemBuilder: (_, i) {
                      final u = users[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              color: Colors.white.withOpacity(0.05),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: accent1.withOpacity(0.2),
                                  child: Icon(
                                    _roleIcons[u.role] ?? Icons.person,
                                    color: accent1,
                                  ),
                                ),
                                title: Text(
                                  u.name,
                                  style: GoogleFonts.orbitron(color: accent1),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      u.email,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        Chip(
                                          label: Text(
                                            u.role == 'vendor'
                                                ? 'بائع'
                                                : u.role == 'organizer'
                                                ? 'منظم'
                                                : 'مشرف',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: accent2.withOpacity(
                                            0.8,
                                          ),
                                          avatar: Icon(
                                            _roleIcons[u.role]!,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        if (u.role == 'vendor' &&
                                            u.vendorProfile?.serviceType !=
                                                null)
                                          Chip(
                                            label: Text(
                                              // human‐friendly label mapping
                                              _vendorTypeLabels[u
                                                      .vendorProfile!
                                                      .serviceType] ??
                                                  '',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            backgroundColor: accent1
                                                .withOpacity(0.8),
                                            avatar: Icon(
                                              _vendorTypeIcons[u
                                                  .vendorProfile!
                                                  .serviceType]!,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: _buildUserAction(u, accent1),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              themesAsync.when(
                data:
                    (themes) => _buildGlassList(
                      themes
                          .map((t) => _themeTile(t, accent1, accent2))
                          .toList(),
                    ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (e, _) => Center(
                      child: Text('خطأ: $e', style: TextStyle(color: accent2)),
                    ),
              ),
            ],
          ),
          floatingActionButton:
              _tabController.index == 1
                  ? FloatingActionButton(
                    backgroundColor: accent2,
                    onPressed: () => _showCreateThemeDialog(context, accent2),
                    child: Icon(Icons.add, color: Colors.black),
                  )
                  : null,
        ),
      ],
    );
  }

  Widget _buildUserAction(User u, Color accent) {
    // if this is a vendor and not yet approved → show “اعتماد”
    if (u.role == 'vendor' && u.active == false) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: accent),
        child: Text('اعتماد', style: GoogleFonts.orbitron(color: Colors.black)),
        onPressed: () async {
          await ref.read(adminServiceProvider).approveUser(u.id);
          ref.refresh(adminUsersProvider);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('تم اعتماد ${u.name}')));
        },
      );
    }
    // otherwise existing delete
    return IconButton(
      icon: Icon(Icons.delete, color: accent),
      onPressed: () async {
        await ref.read(adminServiceProvider).deleteUser(u.id);
        ref.refresh(adminUsersProvider);
      },
    );
  }

  Widget _buildGlassList(List<Widget> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder:
          (_, i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.white.withOpacity(0.05),
                  child: items[i],
                ),
              ),
            ),
          ),
    );
  }

  Widget _userTile(User u, Color accent) {
    return ListTile(
      title: Text(u.name, style: GoogleFonts.orbitron(color: accent)),
      subtitle: Text(u.email, style: TextStyle(color: Colors.white70)),
      trailing: IconButton(
        icon: Icon(Icons.delete, color: accent),
        onPressed: () async {
          await ref.read(adminServiceProvider).deleteUser(u.id);
          ref.refresh(adminUsersProvider);
        },
      ),
    );
  }

  Widget _themeTile(InvitationTheme t, Color accent1, Color accent2) {
    final host = kIsWeb ? 'localhost' : '192.168.1.122';
    final base = 'http://$host:5000/api';
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: accent2, width: 2),
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage('${base}${t.imageUrl}'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(t.name, style: GoogleFonts.orbitron(color: accent1)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit, color: accent1),
            onPressed: () => _showEditThemeDialog(context, t),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: accent2),
            onPressed: () async {
              await ref.read(adminServiceProvider).deleteTheme(t.id);
              ref.refresh(adminThemesProvider);
            },
          ),
        ],
      ),
    );
  }

  void _showCreateThemeDialog(BuildContext context, Color accent) {
    String name = '';
    XFile? picked;
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.black.withOpacity(0.5),
            title: Text(
              'تصميم جديد',
              style: GoogleFonts.orbitron(color: accent),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'الاسم',
                    hintStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: accent.withOpacity(0.6)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: accent, width: 2),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: (v) => name = v,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.image),
                  label: const Text('اختر صورة'),
                  onPressed: () async {
                    final result = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (result != null) picked = result;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('إلغاء', style: TextStyle(color: accent)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: accent),
                onPressed: () async {
                  Navigator.pop(ctx);
                  if (name.isNotEmpty && picked != null) {
                    await ref
                        .read(adminServiceProvider)
                        .createTheme(name, picked);
                    ref.refresh(adminThemesProvider);
                  }
                },
                child: Text(
                  'إنشاء',
                  style: GoogleFonts.orbitron(color: Colors.black),
                ),
              ),
            ],
          ),
    );
  }

  void _showEditThemeDialog(BuildContext context, InvitationTheme t) {
    String name = t.name;
    XFile? picked;
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.black.withOpacity(0.5),
            title: Text(
              'تعديل تصميم',
              style: GoogleFonts.orbitron(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: t.name,
                    hintStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.6),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: (v) => name = v,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.black,
                  ),
                  icon: const Icon(Icons.image),
                  label: const Text('تغيير الصورة'),
                  onPressed: () async {
                    final result = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (result != null) picked = result;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await ref
                      .read(adminServiceProvider)
                      .updateTheme(t.id, name, picked);
                  ref.refresh(adminThemesProvider);
                },
                child: Text(
                  'حفظ',
                  style: GoogleFonts.orbitron(color: Colors.black),
                ),
              ),
            ],
          ),
    );
  }
}
