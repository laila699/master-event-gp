import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:masterevent/models/booking_detail.dart';
import 'package:masterevent/providers/booking_provider.dart'; // eventBookingDetailsProvider
import 'package:masterevent/providers/vendor_provider.dart'; // rateVendorProvider

/// Displays every field of a BookingDetail **and** lets an organizer rate the
/// vendor once the event has passed.
class BookingDetailCard extends ConsumerStatefulWidget {
  final String eventId;

  const BookingDetailCard({
    super.key,
    required this.booking,
    required this.eventId,
  });
  final BookingDetail booking;

  @override
  ConsumerState<BookingDetailCard> createState() => _BookingDetailCardState();
}

class _BookingDetailCardState extends ConsumerState<BookingDetailCard> {
  late bool _rated; // local copy so we can flip without full reload

  @override
  void initState() {
    super.initState();
    _rated = widget.booking.rated;
  }

  // ───────────────────────── helpers ──────────────────────────
  Color _statusColor(String s) => switch (s.toLowerCase()) {
    'yes' => Colors.green,
    'no' => Colors.red,
    'pending' => Colors.orange,
    _ => Colors.grey,
  };

  Future<void> _openRatingDialog() async {
    int stars = 5;
    final txt = TextEditingController();

    final bool? ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('قيِّم البائع'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatefulBuilder(
                  builder:
                      (ctx, setS) => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
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

    if (ok != true) return;

    await ref.read(rateVendorProvider)(
      vendorId: widget.booking.vendorId,
      bookingId: widget.booking.id,
      value: stars,
      eventId: widget.eventId,
      review: txt.text.trim().isEmpty ? null : txt.text.trim(),
    );

    // locally mark as rated & refresh list
    setState(() => _rated = true);
    ref.invalidate(eventBookingDetailsProvider(widget.booking.event.id));

    if (mounted) {
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
    final host = kIsWeb ? 'localhost' : '192.168.1.122';
    final base = 'http://$host:5000/api';

    final b = widget.booking;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row: status + (maybe) rate button ─────────────
            Row(
              children: [
                Text(
                  'الحالة: ${b.status}',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(b.status),
                  ),
                ),
                const Spacer(),
                if (!_rated && b.scheduledAt.isBefore(DateTime.now()))
                  TextButton.icon(
                    icon: const Icon(Icons.star, size: 18, color: Colors.amber),
                    label: const Text('قيّم'),
                    onPressed: _openRatingDialog,
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

            // ── Event info ───────────────────────────────────────────
            Text(
              'المناسبة: ${b.event.title}',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'تاريخ المناسبة: ${dfDate.format(b.event.date)}',
              style: GoogleFonts.cairo(),
            ),
            const SizedBox(height: 8),

            // ── Vendor & offering ───────────────────────────────────
            Text('البائع: ${b.vendorName}', style: GoogleFonts.cairo()),
            Text('الخدمة: ${b.offeringTitle}', style: GoogleFonts.cairo()),
            if (b.offeringDescription != null &&
                b.offeringDescription!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'تفاصيل الخدمة: ${b.offeringDescription!}',
                style: GoogleFonts.cairo(),
              ),
            ],
            const SizedBox(height: 8),

            // ── Price & qty ──────────────────────────────────────────
            Row(
              children: [
                Text(
                  'السعر: ${b.offeringPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.cairo(),
                ),
                const SizedBox(width: 16),
                Text('الكمية: ${b.quantity}', style: GoogleFonts.cairo()),
              ],
            ),
            const SizedBox(height: 8),

            // ── Schedule ────────────────────────────────────────────
            Text(
              'موعد الحجز: ${dfDateTm.format(b.scheduledAt)}',
              style: GoogleFonts.cairo(),
            ),

            // ── Optional note ───────────────────────────────────────
            if (b.note != null && b.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('ملاحظة: ${b.note}', style: GoogleFonts.cairo()),
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
                            '$base${b.offeringImages[i]}',
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
