import 'dart:io'; // For file operations
import 'dart:ui'; // For image filtering effects
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; //
import 'package:google_fonts/google_fonts.dart';
import 'package:softwareGP/models/user.dart';
import 'package:softwareGP/models/invitation_theme.dart';
import 'package:softwareGP/providers/admin_provider.dart';
import 'package:softwareGP/providers/auth_provider.dart';
import 'package:softwareGP/screens/auth/login_screen.dart';

const Map<String, IconData> _roleIcons = {
  'organizer': Icons.event_note,
  'vendor': Icons.store_mall_directory,
  'admin': Icons.admin_panel_settings,
};

const Map<String, IconData> _vendorTypeIcons = {
  'accommodation': Icons.hotel,
  'transportation': Icons.directions_bus,
  'photographer': Icons.camera_alt,
  'restaurant': Icons.restaurant,
  'tools': Icons.card_giftcard,
  'guides': Icons.hiking,
};

const Map<String, String> _vendorTypeLabels = {
  'accommodation': 'الاقامة ',
  'transportation': 'نقل ومواصلات ',
  'photographer': 'مصور',
  'restaurant': 'مطعم',
  'tools': 'محل معدات رحل',
  'guides': 'مرشدين',
};

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);
  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  // SingleTickerProviderStateMixin for TabController animation
  late TabController _tabController; // TabController for managing tabs
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    ); // 2 tabs: Users and Themes
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    // Refresh both users and themes
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
      'accommodation': Icons.hotel,
      'transportation': Icons.directions_bus,
      'photographer': Icons.camera_alt,
      'restaurant': Icons.restaurant,
      'tools': Icons.card_giftcard,
      'guides': Icons.hiking,
    };

    final usersAsync = ref.watch(adminUsersProvider); //براقب قائمة المسخدمين
    final themesAsync = ref.watch(adminThemesProvider); //براقب قائمة التصاميم
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
                onPressed: _refreshAll, // Refresh both users and themes
              ),
              IconButton(
                // Logout button
                icon: Icon(Icons.logout, color: accent1),
                onPressed: () {
                  // Logout action
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
            // TabBarView to switch between Users and Themes حسب المختار
            controller: _tabController,
            children: [
              // Users Tab
              usersAsync.when(
                // Users list
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (e, _) => Center(
                      child: Text('خطأ: $e', style: TextStyle(color: accent2)),
                    ),
                data: (users) {
                  // Display list of users
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length, // عدد المستخدمين
                    itemBuilder: (_, i) {
                      final u = users[i]; // Get user at index i
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
                                  u.name, // Display user name
                                  style: GoogleFonts.orbitron(color: accent1),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      u.email, // Display user email
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
                                          // Display user role
                                          label: Text(
                                            u.role == 'vendor'
                                                ? 'بائع'
                                                : u.role == 'organizer'
                                                ? 'منظم'
                                                : 'مشرف',
                                            style: const TextStyle(
                                              // User role text style
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor: accent2.withOpacity(
                                            0.8,
                                          ),
                                          avatar: Icon(
                                            _roleIcons[u.role]!, // Role icon
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        if (u.role == 'vendor' &&
                                            u.vendorProfile?.serviceType !=
                                                null) // لازم نوع الخدمة محدد في ملفه الشخصي
                                          Chip(
                                            // Display vendor service type
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
                                            backgroundColor:
                                                accent1 // لون خلفية الشريحة
                                                    .withOpacity(0.8),
                                            avatar: Icon(
                                              // Vendor service type icon
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
                                trailing: _buildUserAction(
                                  u,
                                  accent1,
                                ), // Action button for user . u: object يحمل البيانات
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
                // Themes tab
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
              _tabController.index ==
                      1 // Themes tab
                  ? FloatingActionButton(
                    backgroundColor: accent2, // background  button color
                    onPressed:
                        () => _showCreateThemeDialog(
                          context,
                          accent2,
                          ref,
                        ), //بفتح نافذة لانشاء الثيم
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
          ref.refresh(adminUsersProvider); // تحديث قائمة المستخدمين
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('تم اعتماد ${u.name}')));
        }, //بعرض رسالة
      );
    }
    // otherwise existing delete
    //يعني: "في غير هذه الحالات (مثل بائع غير مفعل)، اعرض زر الحذف الموجود سابقًا".

    return IconButton(
      icon: Icon(Icons.delete, color: accent),
      onPressed: () async {
        await ref.read(adminServiceProvider).deleteUser(u.id); // حذف المستخدم
        ref.refresh(adminUsersProvider);
      },
    );
  }

  Widget _buildGlassList(List<Widget> items) {
    // Creates a glassmorphism effect list
    return ListView.builder(
      // Builds a scrollable list of glassmorphism items
      padding: const EdgeInsets.all(16),
      itemCount: items.length, // عدد العناصر في القائمة
      itemBuilder:
          (_, i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10,
                  sigmaY: 10,
                ), // Applies a blur effect
                child: Container(
                  color: Colors.white.withOpacity(0.05),
                  child: items[i],
                ),
              ),
            ),
          ),
    );
  }

  //عرض بيانات مستخدم واحد بشكل ListTile  , مع امكانية الحذف
  Widget _userTile(User u, Color accent) {
    //u: object يحمل بيانات المستخدم
    return ListTile(
      // يعرض عنوان ,وصف  ,ايقونة
      title: Text(u.name, style: GoogleFonts.orbitron(color: accent)),
      subtitle: Text(u.email, style: TextStyle(color: Colors.white70)),
      trailing: IconButton(
        icon: Icon(Icons.delete, color: accent), // زر الحذف
        onPressed: () async {
          await ref.read(adminServiceProvider).deleteUser(u.id);
          ref.refresh(adminUsersProvider);
        },
      ),
    );
  }

  //ويدجت Flutter اسمها _themeTile
  //وظيفتها عرض تفاصيل موضوع دعوة (InvitationTheme) بشكل منسق في قائمة
  Widget _themeTile(InvitationTheme t, Color accent1, Color accent2) {
    // InvitationTheme : اسم وصورة
    final host = kIsWeb ? 'localhost' : '192.168.1.107';
    final base = 'http://$host:5000/api';
    return ListTile(
      leading: Container(
        // صورة الموضوع على اليسار
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
      title: Text(
        t.name,
        style: GoogleFonts.orbitron(color: accent1),
      ), // اسم موضوع الدعوة
      trailing: Row(
        // مجموعة الأزرار على اليمين , زر حذف وتعديل
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            // زر التعديل
            icon: Icon(Icons.edit, color: accent1),
            onPressed: () => _showEditThemeDialog(context, t),
          ),
          IconButton(
            // زر الحذف
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

  /*
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
  }       */

  // انشاء نافذة تصميم موضوع جديد واختيار صورة واسم
  void _showCreateThemeDialog(
    BuildContext context, // بناء النافذة
    Color accent,
    WidgetRef ref,
  ) {
    final picker = ImagePicker();
    final nameCtl = TextEditingController(); // للتحكم في حقل الاسم

    XFile? picked; // selected file يخزن الصورة المختارة
    Uint8List?
    previewBytes; // used for web preview لعرض معاينة الصورة على الويب

    showDialog(
      // انشاء نافذة جديدة
      context: context,
      barrierDismissible: false, // يمنع اغلاق النافذة بالضغط خارجها
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setState) => AlertDialog(
                  backgroundColor: Colors.black.withOpacity(.85),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    'تصميم جديد', // عنوان النافذة
                    style: GoogleFonts.orbitron(color: accent),
                  ),

                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Name field ────────────────────────────────────────────────
                        TextField(
                          //اسم التصميم ادخال
                          controller: nameCtl,
                          decoration: _inputDecoration(accent, 'الاسم'),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),

                        // ── Pick image button ────────────────────────────────────────
                        ElevatedButton.icon(
                          //زر معاينة الصورة
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.black,
                          ),
                          icon: const Icon(Icons.image_outlined),
                          label: Text(
                            picked == null
                                ? 'اختر صورة'
                                : 'تغيير الصورة', // اذا اختار الصورة يظهر تغيير اذا لا يظهر اختر
                          ),
                          onPressed: () async {
                            final res = await picker.pickImage(
                              // اختيار صورة من المعرض
                              source: ImageSource.gallery,
                            );
                            if (res != null) {
                              final bytes =
                                  await res
                                      .readAsBytes(); // works on all platforms
                              setState(() {
                                // تحديث الحالة
                                picked = res; // تخزين الصورة المختارة
                                previewBytes =
                                    bytes; // معاينة الصورة المختارة وتخزين البيانات في الخادم
                              });
                            }
                          },
                        ),

                        // ── Live preview ─────────────────────────────────────────────
                        if (previewBytes != null) ...[
                          // اذا تم اختيار صورة
                          const SizedBox(height: 12),
                          ClipRRect(
                            // عرض الصورة داخل اطار دائري
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              previewBytes!,
                              height: 130,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ── Dialog actions ────────────────────────────────────────────────
                  actions: [
                    //زر الالغاء
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('إلغاء', style: TextStyle(color: accent)),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: accent),
                      onPressed: () async {
                        if (nameCtl.text.trim().isEmpty || picked == null)
                          return; // يمنع الإجراء إذا الاسم فارغ أو لم يتم اختيار صورة
                        Navigator.pop(ctx); // close the dialog

                        await ref
                            .read(adminServiceProvider)
                            .createTheme(
                              nameCtl.text.trim(),
                              picked!,
                            ); // إنشاء تصميم جديد

                        ref.invalidate(
                          adminThemesProvider,
                        ); // تحديث قائمة التصاميم
                      },
                      child: Text(
                        'إنشاء',
                        style: GoogleFonts.orbitron(color: Colors.black),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  /// Keeps the underline styling DRY ,للحفاظ على تصميم موحد وسهل التعديل (DRY = Don't Repeat Yourself).

  InputDecoration _inputDecoration(Color accent, String hint) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accent.withOpacity(.6)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accent, width: 2),
        ),
      );

  void _showEditThemeDialog(BuildContext context, InvitationTheme t) {
    String name = t.name; // اسم التصميم الحالي
    XFile? picked; // الصورة المختارة للتحديث
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
                  // زر تغيير الصورة
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
