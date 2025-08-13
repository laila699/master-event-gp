// lib/screens/guest_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/guest.dart';
import '../providers/event_provider.dart';

class GuestTab extends ConsumerWidget {
  final String eventId; // ID of the event to show guests for
  const GuestTab({Key? key, required this.eventId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // context : معلومات عن البيئة الحالية
    // 1) Watch the event detail (which contains the guests array)
    final evAsync = ref.watch(eventDetailProvider(eventId));

    return evAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (e, _) => Center(
            child: Text(
              'خطأ في تحميل المشاركين: $e',
              style: GoogleFonts.cairo(),
            ),
          ),
      data: (event) {
        final guests = event.guests; // Get the list of guests from the event
        // Check if guests list is empty
        return Column(
          children: [
            Expanded(
              child:
                  (guests == null || guests.isEmpty)
                      ? Center(
                        child: Text(
                          'لا توجد مشاركين بعد',
                          style: GoogleFonts.cairo(),
                        ),
                      )
                      : ListView.builder(
                        // Build a list of guests
                        itemCount:
                            guests
                                .length, // Number of guests =  number of items
                        itemBuilder: (ctx, i) {
                          //  دالة ترجع عنصر (Widget) لكل ضيف، حسب الفهرس i.
                          final g = guests[i]; // Get the guest at index i
                          return ListTile(
                            // عنصر قائمة يمثل ضيف واحد
                            title: Text(
                              g.name,
                              style: GoogleFonts.cairo(),
                            ), // name
                            subtitle: Text(
                              g.email,
                              style: GoogleFonts.cairo(),
                            ), // email
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
                              // Toggle guest status on tap
                              // cycle status
                              final next =
                                  g.status == 'pending'
                                      ? 'yes'
                                      : (g.status == 'yes' ? 'no' : 'pending');

                              // 2) call update GuestStatus Provider and await
                              //حتى نحدث الحالة
                              await ref.read(
                                //  ينفذ بشكل متزامن
                                updateGuestStatusProvider({
                                  'eventId': eventId,
                                  'guestId': g.id,
                                  'status': next, // new status
                                }).future,
                              );

                              // 3) re-fetch event details
                              ref.invalidate(
                                eventDetailProvider(eventId),
                              ); // invalidate:نُعيد تحميل بيانات الحدث من جديد من db
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
                label: Text('إضافة مشارك', style: GoogleFonts.cairo()),
                onPressed: () => _showAddGuestDialog(context, ref),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddGuestDialog(BuildContext ctx, WidgetRef ref) async {
    final nameCtl = TextEditingController(); //name controller
    final emailCtl = TextEditingController(); // email controller

    final ok = await showDialog<bool>(
      context: ctx,
      builder:
          (_) => AlertDialog(
            title: Text('إضافة مشارك', style: GoogleFonts.cairo()),
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
    // check if user confirmed
    if (ok == true &&
        nameCtl.text.trim().isNotEmpty &&
        emailCtl.text.trim().isNotEmpty) {
      // 5) call addGuestProvider
      try {
        await ref.read(
          //wait for the future to complete "send date"
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
              'تم إرسال الدعوة للمشارك عبر البريد الإلكتروني',
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
