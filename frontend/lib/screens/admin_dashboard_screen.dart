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
                data:
                    (users) => _buildGlassList(
                      users.map((u) => _userTile(u, accent1)).toList(),
                    ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (e, _) => Center(
                      child: Text('خطأ: $e', style: TextStyle(color: accent2)),
                    ),
              ),
              // Themes Tab
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
