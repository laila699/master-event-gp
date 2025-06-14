import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:masterevent/models/booking_detail.dart';

/// A single card displaying every field of a BookingDetail
class BookingDetailCard extends StatelessWidget {
  final BookingDetail booking;
  const BookingDetailCard({Key? key, required this.booking}) : super(key: key);

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'yes':
        return Colors.green;
      case 'no':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dfDate = DateFormat('yyyy-MM-dd');
    final dfDateTime = DateFormat('yyyy-MM-dd HH:mm');
    final host = kIsWeb ? 'localhost' : '192.168.1.122';
    final base = 'http://$host:5000/api';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status
            Text(
              'الحالة: ${booking.status}',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _statusColor(booking.status),
              ),
            ),
            const SizedBox(height: 8),

            // Booking ID
            const SizedBox(height: 8),

            // Event info
            Text(
              'المناسبة: ${booking.event.title}',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'تاريخ المناسبة: ${dfDate.format(booking.event.date)}',
              style: GoogleFonts.cairo(fontSize: 14),
            ),
            const SizedBox(height: 8),

            // Vendor & Offering
            Text(
              'البائع: ${booking.vendorName}',
              style: GoogleFonts.cairo(fontSize: 14),
            ),
            Text(
              'الخدمة: ${booking.offeringTitle}',
              style: GoogleFonts.cairo(fontSize: 14),
            ),

            if (booking.offeringDescription != null) ...[
              const SizedBox(height: 4),
              Text(
                'تفاصيل الخدمة: ${booking.offeringDescription!}',
                style: GoogleFonts.cairo(fontSize: 14),
              ),
            ],
            const SizedBox(height: 8),

            // Price & Quantity
            Row(
              children: [
                Text(
                  'السعر: ${booking.offeringPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.cairo(fontSize: 14),
                ),
                const SizedBox(width: 16),
                Text(
                  'الكمية: ${booking.quantity}',
                  style: GoogleFonts.cairo(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Scheduled time
            Text(
              'موعد الحجز: ${dfDateTime.format(booking.scheduledAt)}',
              style: GoogleFonts.cairo(fontSize: 14),
            ),

            // Optional note
            if (booking.note != null && booking.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'ملاحظة: ${booking.note}',
                style: GoogleFonts.cairo(fontSize: 14),
              ),
            ],

            // Images carousel
            if (booking.offeringImages.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: booking.offeringImages.length,
                  itemBuilder: (ctx, i) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          "${host}${booking.offeringImages[i]}",
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) =>
                                  Icon(Icons.broken_image, size: 120),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
