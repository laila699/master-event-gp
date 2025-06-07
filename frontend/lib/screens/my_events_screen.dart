import 'package:flutter/material.dart';
import 'package:masterevent/EventSettingsPage.dart';
import 'package:masterevent/InvitationScreen.dart';
import 'package:masterevent/add_event_screen.dart';
import 'package:masterevent/design.dart';
import 'package:masterevent/furniture.dart';
import 'package:masterevent/models/user.dart';
import 'package:masterevent/user_profile.dart';

// lib/screens/my_events_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:masterevent/providers/event_provider.dart';

class MyEventsScreen extends ConsumerWidget {
  final User user;

  const MyEventsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider that fetches the list of events
    final eventsAsync = ref.watch(eventListProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("مرحبًا، ${user.name} 👋"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'الإشعارات',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("صفحة الإشعارات قيد الإنشاء!")),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat),
            tooltip: 'الدردشات',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("صفحة الدردشات قيد الإنشاء!")),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'الملف الشخصي',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📆 مناسباتك القادمة",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // ── Event list area ──
            Expanded(
              child: eventsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (err, stack) => Center(
                      child: Text(
                        'حدث خطأ أثناء تحميل المناسبات.',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                data: (events) {
                  if (events.isEmpty) {
                    return const Center(child: Text('لا توجد مناسبات حالياً.'));
                  }
                  // Build a ListView of upcoming events
                  return ListView.separated(
                    itemCount: events.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return ListTile(
                        leading: const Icon(Icons.event, color: Colors.purple),
                        title: Text(event.title),
                        subtitle: Text(
                          // Format date and venue, e.g. "📅 15 أبريل 2024 | 📍 قاعة الماس"
                          '📅 ${_formatDate(event.date)} | 📍 ${event.venue}',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Here you could navigate to an EventDetail screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("سيتم فتح تفاصيل الدعوة قريباً!"),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            Text(
              "🎉 اكتشف خدمات المناسبات",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // ── Grid of service cards ──
            SizedBox(
              height:
                  200, // fixed height so the grid doesn’t expand indefinitely
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  ServiceCard(
                    icon: Icons.celebration,
                    title: "الديكورات",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DesignScreen(),
                        ),
                      );
                    },
                  ),
                  ServiceCard(
                    icon: Icons.email,
                    title: "الدعوات الإلكترونية",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InvitationScreen(),
                        ),
                      );
                    },
                  ),
                  ServiceCard(
                    icon: Icons.card_giftcard,
                    title: "التوزيعات والهدايا",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("قسم الهدايا قيد الإنشاء!"),
                        ),
                      );
                    },
                  ),
                  ServiceCard(
                    icon: Icons.chair,
                    title: "الأثاث",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FurnitureScreen(),
                        ),
                      );
                    },
                  ),
                  ServiceCard(
                    icon: Icons.menu_book,
                    title: "إدارة الفعالية",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventSettingsPage(),
                        ),
                      );
                    },
                  ),
                  ServiceCard(
                    icon: Icons.tv,
                    title: "الترفيه والعروض",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("قسم الترفيه قيد الإنشاء!"),
                        ),
                      );
                    },
                  ),
                  ServiceCard(
                    icon: Icons.camera_alt,
                    title: "التصوير والفيديو",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("قسم التصوير قيد الإنشاء!"),
                        ),
                      );
                    },
                  ),
                  ServiceCard(
                    icon: Icons.more_horiz,
                    title: " قوائم الطعام",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("المزيد من الخدمات قريباً!"),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEventScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("إضافة مناسبة جديدة"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Helper to format a DateTime in “DD MMMM YYYY” Arabic style.
  static String _formatDate(DateTime date) {
    // You can customize localization. For brevity, we use a simple approach.
    // NOTE: In a real app, use intl package for proper Arabic month names.
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;
    return '$day $month $year';
  }
}

/// --- ويدجت بطاقة الخدمة ---
class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Function()? onTap;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
