// lib/screens/guest_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/guest.dart';
import '../providers/event_provider.dart';

class GuestTab extends ConsumerWidget {
  final String eventId;
  const GuestTab({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1) Watch the event detail (which contains the guests array)
    final evAsync = ref.watch(eventDetailProvider(eventId));

    return evAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (e, _) => Center(
            child: Text('خطأ في تحميل الضيوف: $e', style: GoogleFonts.cairo()),
          ),
      data: (event) {
        final guests = event.guests;

        return Column(
          children: [
            Expanded(
              child:
                  (guests == null || guests.isEmpty)
                      ? Center(
                        child: Text(
                          'لا توجد ضيوف بعد',
                          style: GoogleFonts.cairo(),
                        ),
                      )
                      : ListView.builder(
                        itemCount: guests.length,
                        itemBuilder: (ctx, i) {
                          final g = guests[i];
                          return ListTile(
                            title: Text(g.name, style: GoogleFonts.cairo()),
                            subtitle: Text(g.email, style: GoogleFonts.cairo()),
                            trailing: Text(
                              g.status.toUpperCase(),
                              style: GoogleFonts.cairo(
                                color:
                                    g.status == 'yes'
                                        ? Colors.green
                                        : (g.status == 'no'
                                            ? Colors.red
                                            : Colors.orange),
                              ),
                            ),
                            onTap: () async {
                              // cycle status
                              final next =
                                  g.status == 'pending'
                                      ? 'yes'
                                      : (g.status == 'yes' ? 'no' : 'pending');

                              // 2) call updateGuestStatusProvider and await
                              await ref.read(
                                updateGuestStatusProvider({
                                  'eventId': eventId,
                                  'guestId': g.id,
                                  'status': next,
                                }).future,
                              );

                              // 3) re-fetch event details
                              ref.invalidate(eventDetailProvider(eventId));
                            },
                          );
                        },
                      ),
            ),

            // 4) "Add Guest" button
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: Text('إضافة ضيف', style: GoogleFonts.cairo()),
                onPressed: () => _showAddGuestDialog(context, ref),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddGuestDialog(BuildContext ctx, WidgetRef ref) async {
    final nameCtl = TextEditingController();
    final emailCtl = TextEditingController();

    final ok = await showDialog<bool>(
      context: ctx,
      builder:
          (_) => AlertDialog(
            title: Text('إضافة ضيف', style: GoogleFonts.cairo()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtl,
                  decoration: InputDecoration(labelText: 'الاسم'),
                ),
                TextField(
                  controller: emailCtl,
                  decoration: InputDecoration(labelText: 'البريد الإلكتروني'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('إلغاء', style: GoogleFonts.cairo()),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('إضافة', style: GoogleFonts.cairo()),
              ),
            ],
          ),
    );

    if (ok == true &&
        nameCtl.text.trim().isNotEmpty &&
        emailCtl.text.trim().isNotEmpty) {
      // 5) call addGuestProvider
      try {
        await ref.read(
          addGuestProvider({
            'eventId': eventId,
            'name': nameCtl.text.trim(),
            'email': emailCtl.text.trim(),
          }).future,
        );
        // 6) re-fetch event details
        ref.invalidate(eventDetailProvider(eventId));
        // Show toast/snackbar on success
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(
              'تم إرسال الدعوة للضيف عبر البريد الإلكتروني',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء إرسال الدعوة: $e',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
