// lib/screens/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('الإشعارات', style: GoogleFonts.cairo()),
        centerTitle: true,
      ),
      body:
          notifications.isEmpty
              ? Center(
                child: Text(
                  'لا توجد إشعارات جديدة',
                  style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                itemCount: notifications.length,
                itemBuilder: (ctx, i) {
                  final n = notifications[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Icon(
                        Icons.notifications,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      title: Text(
                        n.title,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(n.body, style: GoogleFonts.cairo(fontSize: 14)),
                          const SizedBox(height: 8),
                          Text(
                            _formatTime(n.receivedAt),
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // e.g. deep-link into booking detail:
                        final bookingId = n.data?['bookingId'];
                        if (bookingId != null) {
                          Navigator.pushNamed(context, '/booking/${bookingId}');
                        }
                      },
                    ),
                  );
                },
              ),
    );
  }

  String _formatTime(DateTime dt) {
    // e.g. "14:23 - 10/06/2025"
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    return '$h:$m  $d/$mo/$y';
  }
}
