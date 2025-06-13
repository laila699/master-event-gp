// lib/screens/vendor_dashboard/booking_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/offering_provider.dart';

class BookingTab extends ConsumerWidget {
  const BookingTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(vendorBookingsProvider);

    return bookingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
      data: (bookings) {
        if (bookings.isEmpty) {
          return Center(
            child: Text('لا توجد حجوزات بعد', style: GoogleFonts.cairo()),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: bookings.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (ctx, i) {
            final b = bookings[i];

            // Watch the two detail providers
            final evAsync = ref.watch(eventDetailProvider(b.eventId));
            final offAsync = ref.watch(offeringDetailProvider(b.offeringId));

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: evAsync.when(
                  loading:
                      () => const ListTile(title: LinearProgressIndicator()),
                  error: (e, _) => ListTile(title: Text('خطأ في الحدث: $e')),
                  data:
                      (ev) => offAsync.when(
                        loading:
                            () => ListTile(
                              title: Text('حدث: ${ev.title}'),
                              subtitle: const LinearProgressIndicator(),
                            ),

                        error:
                            (e, _) => ListTile(title: Text('خطأ في العرض: $e')),
                        data: (off) {
                          return ListTile(
                            title: Text(
                              'حدث: ${ev.title}',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'عرض: ${off.title}',
                                  style: GoogleFonts.cairo(),
                                ),

                                Text(
                                  'سعر: ${off.price.toStringAsFixed(2)} ش.إ',
                                  style: GoogleFonts.cairo(),
                                ),
                                const SizedBox(height: 8),

                                Text(
                                  'موعد: ${b.scheduledAt.toLocal()}',
                                  style: GoogleFonts.cairo(),
                                ),
                                if (b.note != null && b.note!.isNotEmpty)
                                  Text(
                                    'ملاحظة: ${b.note}',
                                    style: GoogleFonts.cairo(),
                                  ),
                                Text(
                                  'كمية: ${b.quantity}',
                                  style: GoogleFonts.cairo(),
                                ),
                                Text(
                                  'الحالة: ${b.status}',
                                  style: GoogleFonts.cairo(),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            trailing:
                                b.status == 'pending'
                                    ? Wrap(
                                      spacing: 8,
                                      children: [
                                        TextButton(
                                          onPressed:
                                              () => ref
                                                  .read(
                                                    vendorBookingsProvider
                                                        .notifier,
                                                  )
                                                  .updateStatus(
                                                    b.id,
                                                    'confirmed',
                                                  ),
                                          child: Text(
                                            'تأكيد',
                                            style: TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => ref
                                                  .read(
                                                    vendorBookingsProvider
                                                        .notifier,
                                                  )
                                                  .updateStatus(
                                                    b.id,
                                                    'declined',
                                                  ),
                                          child: Text(
                                            'رفض',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    )
                                    : null,
                          );
                        },
                      ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
