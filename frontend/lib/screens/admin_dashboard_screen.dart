import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masterevent/models/invitation_theme.dart';
import 'package:masterevent/providers/admin_provider.dart';

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
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم (Admin Dashboard)'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'المستخدمون'), Tab(text: 'التصاميم')],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshAll),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Users tab
          usersAsync.when(
            data:
                (users) => ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) {
                    final u = users[i];
                    return ListTile(
                      title: Text(u.name),
                      subtitle: Text(u.email),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await ref.read(adminServiceProvider).deleteUser(u.id);
                          ref.refresh(adminUsersProvider);
                        },
                      ),
                    );
                  },
                ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطأ: \$e')),
          ),

          // Themes tab
          themesAsync.when(
            data:
                (themes) => ListView.separated(
                  itemCount: themes.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) {
                    final t = themes[i];
                    return ListTile(
                      leading: Image.network(
                        t.imageUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                      title: Text(t.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditThemeDialog(context, t),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await ref
                                  .read(adminServiceProvider)
                                  .deleteTheme(t.id);
                              ref.refresh(adminThemesProvider);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطأ: \$e')),
          ),
        ],
      ),
      floatingActionButton:
          _tabController.index == 1
              ? FloatingActionButton(
                onPressed: () => _showCreateThemeDialog(context),
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  // Dialogs to create/edit themes (implement name input, image picker, calls to service)
  void _showCreateThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        String name = '';
        File? image;
        return AlertDialog(
          title: const Text('إنشاء تصميم جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'الاسم'),
                onChanged: (v) => name = v,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('اختر صورة'),
                onPressed: () async {
                  final result = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (result != null) image = File(result.path);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (name.isEmpty || image == null) return;
                Navigator.pop(ctx);
                await ref.read(adminServiceProvider).createTheme(name, image!);
                ref.refresh(adminThemesProvider);
              },
              child: const Text('إنشاء'),
            ),
          ],
        );
      },
    );
  }

  void _showEditThemeDialog(BuildContext context, InvitationTheme theme) {
    showDialog(
      context: context,
      builder: (ctx) {
        String name = theme.name;
        File? image;
        return AlertDialog(
          title: const Text('تعديل التصميم'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'الاسم'),
                controller: TextEditingController(text: theme.name),
                onChanged: (v) => name = v,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('اختر صورة جديدة'),
                onPressed: () async {
                  final result = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (result != null) image = File(result.path);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ref
                    .read(adminServiceProvider)
                    .updateTheme(theme.id, name, image);
                ref.refresh(adminThemesProvider);
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }
}
