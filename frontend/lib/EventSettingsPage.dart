// lib/screens/event_settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masterevent/EventBudgetPage.dart';

import 'package:masterevent/EventToDoListPage.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';

class EventSettingsPage extends ConsumerWidget {
  final Event event;
  const EventSettingsPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = [
      {
        'title': 'الميزانية والتكلفة',
        'icon': Icons.attach_money,
        'builder': (_) => EventBudgetPage(eventId: event.id),
      },

      {
        'title': 'تنظيم المهام',
        'icon': Icons.checklist_rtl,
        'builder': (_) => EventToDoListPage(eventId: event.id),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الفعالية'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF7F7F7),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (ctx, i) {
          final it = items[i];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Icon(it['icon'] as IconData, color: Colors.purple),
              title: Text(it['title'] as String),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: it['builder'] as Widget Function(BuildContext),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
