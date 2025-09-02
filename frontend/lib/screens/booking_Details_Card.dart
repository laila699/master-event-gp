import 'dart:io';

import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // for date formatting

import 'package:softwareGP/models/booking_detail.dart';
import 'package:softwareGP/providers/booking_provider.dart'; // eventBookingDetailsProvider
import 'package:softwareGP/providers/vendor_provider.dart'; // rateVendorProvider

/// Displays every field of a BookingDetail **and** lets an organizer rate the
/// vendor once the event has passed.
class BookingDetailCard extends ConsumerStatefulWidget {
  final String eventId;

  const BookingDetailCard({
    //يجعله ثابت اذا القيم ماتغيرت
    super.key,
    required this.booking, // BookingDetail object to display
    required this.eventId, // event ID for rating
  });
  final BookingDetail booking;

  @override
  ConsumerState<BookingDetailCard> createState() => _BookingDetailCardState();
}

class _BookingDetailCardState extends ConsumerState<BookingDetailCard> {
  late bool _rated; // local variable to track if the booking has been rated

  @override
  void initState() {
    super
        .initState(); // يستدعي النسخة حتى يضمن ان التهيئة الافتراضية تحصل قبل  تنفيذ الكود
    _rated = widget.booking.rated;
  }

  // ───────────────────────── helpers ──────────────────────────
  Color _statusColor(String s) => switch (s.toLowerCase()) {
    // switch expression to determine color based on status
    'yes' => Colors.green,
    'no' => Colors.red,
    'pending' => Colors.orange,
    _ => Colors.grey,
  };
  // rate vendor dialog
  Future<void> _openRatingDialog() async {
    //سيتم الانتظار للنتيجة من مربع الحوار
    int stars = 5;
    final txt = TextEditingController();

    final bool? ok = await showDialog<bool>(
      //await: ينتظر حتى يغلق المستخدم النافذة
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('قيِّم البائع'),
            content: Column(
              mainAxisSize: MainAxisSize.min, //اقل مساحة ممكنة
              children: [
                StatefulBuilder(
                  //يتيح تحديث واجهة جزء معين من الـ dialog بدون إعادة بناء الصفحة كلها
                  builder:
                      (ctx, setS) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5, // 5 stars
                          (i) => IconButton(
                            icon: Icon(
                              i < stars ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 30,
                            ),
                            onPressed: () => setS(() => stars = i + 1),
                          ),
                        ),
                      ),
                ),
                TextField(
                  controller: txt,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'مراجعة (اختياري)',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('إرسال'),
              ),
            ],
          ),
    );

    if (ok != true) return; // if user didn't confirm, exit

    await ref.read(rateVendorProvider)(
      //send rating to server
      vendorId: widget.booking.vendorId,
      bookingId: widget.booking.id,
      value: stars, // rating value
      eventId: widget.eventId,
      review: txt.text.trim().isEmpty ? null : txt.text.trim(),
    );

    // locally mark as rated & refresh list
    setState(
      () => _rated = true,
    ); //بغير الحالة المحلية حتى يعرف انه تم تقييم الحجز
    ref.invalidate(
      eventBookingDetailsProvider(widget.booking.event.id),
    ); // refresh the booking details list

    if (mounted) {
      // check if the widget is still mounted before showing snackbar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إرسال التقييم')));
    }
  }

  // ───────────────────────── UI ───────────────────────────────
  @override
  Widget build(BuildContext context) {
    final dfDate = DateFormat('yyyy-MM-dd');
    final dfDateTm = DateFormat('yyyy-MM-dd HH:mm');
    final host = kIsWeb ? 'localhost' : '192.168.1.107';
    final base = 'http://$host:5000/api';

    final b = widget.booking; // اختصار لتسهيل الاستخدام بالكود

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // محاذاة النصوص إلى اليسار
          children: [
            // ── Header row: status + (maybe) rate button ─────────────
            Row(
              children: [
                Text(
                  'الحالة: ${b.status}',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(
                      b.status,
                    ), //يعرض حالة الحجز مع اللون المناسب
                  ),
                ),
                const Spacer(), // space between status and rate button
                if (!_rated &&
                    b.scheduledAt.isBefore(
                      DateTime.now(),
                    )) // if not rated and scheduled time has passed
                  TextButton.icon(
                    icon: const Icon(Icons.star, size: 18, color: Colors.amber),
                    label: const Text('قيّم'),
                    onPressed: _openRatingDialog, // open rating dialog
                  ),
                if (_rated)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text('تم التقييم', style: GoogleFonts.cairo()),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Trip info ───────────────────────────────────────────
            Text(
              'الرحلة: ${b.event.title}',
              style: GoogleFonts.cairo(
                color: const Color.fromARGB(255, 249, 250, 251),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'تاريخ الرحلة: ${dfDate.format(b.event.date)}',
              style: GoogleFonts.cairo(
                color: const Color.fromARGB(255, 249, 250, 251),
              ),
            ),
            const SizedBox(height: 8),

            // ── Vendor & offering ───────────────────────────────────
            Text(
              'البائع: ${b.vendorName}',
              style: GoogleFonts.cairo(
                color: const Color.fromARGB(255, 249, 250, 251),
              ),
            ),
            Text(
              'الخدمة: ${b.offeringTitle}',
              style: GoogleFonts.cairo(
                color: const Color.fromARGB(255, 249, 250, 251),
              ),
            ),
            if (b.offeringDescription != null &&
                b.offeringDescription!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'تفاصيل الخدمة: ${b.offeringDescription!}',
                style: GoogleFonts.cairo(
                  color: const Color.fromARGB(255, 249, 250, 251),
                ),
              ),
            ],
            const SizedBox(height: 8), // space before next section
            // ── Price & qty ──────────────────────────────────────────
            Row(
              children: [
                Text(
                  'السعر: ${b.offeringPrice.toStringAsFixed(2)}', // format price to 2 decimal places : 100.00
                  style: GoogleFonts.cairo(
                    color: const Color.fromARGB(255, 249, 250, 251),
                  ),
                ),
                const SizedBox(width: 16), // space between price and quantity
                Text(
                  'الكمية: ${b.quantity}',
                  style: GoogleFonts.cairo(
                    color: const Color.fromARGB(255, 249, 250, 251),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Schedule ────────────────────────────────────────────
            Text(
              'موعد الحجز: ${dfDateTm.format(b.scheduledAt)}', // format date and time
              style: GoogleFonts.cairo(
                color: const Color.fromARGB(255, 249, 250, 251),
              ),
            ),

            // ── Optional note ───────────────────────────────────────
            if (b.note != null && b.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'ملاحظة: ${b.note}',
                style: GoogleFonts.cairo(
                  color: const Color.fromARGB(255, 249, 250, 251),
                ),
              ),
            ],

            // ── Images carousel ─────────────────────────────────────
            if (b.offeringImages.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: b.offeringImages.length,
                  itemBuilder:
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            '$base${b.offeringImages[i]}', // full URL to the image
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) =>
                                    const Icon(Icons.broken_image, size: 120),
                          ),
                        ),
                      ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
