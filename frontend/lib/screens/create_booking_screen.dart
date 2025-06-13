import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masterevent/providers/booking_provider.dart';
import '../../models/offering.dart';
import '../../models/event.dart';
import '../../providers/event_provider.dart';
import '../../services/booking_service.dart'; // you’ll wire this up to your API

class CreateBookingScreen extends ConsumerStatefulWidget {
  final Offering offering;
  const CreateBookingScreen({Key? key, required this.offering})
    : super(key: key);

  @override
  ConsumerState<CreateBookingScreen> createState() =>
      _CreateBookingScreenState();
}

class _CreateBookingScreenState extends ConsumerState<CreateBookingScreen> {
  String? _selectedEventId;
  DateTime? _pickedDate;
  TimeOfDay? _pickedTime;
  final _noteCtl = TextEditingController();
  int _quantity = 1;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: now,
    );
    if (d != null) setState(() => _pickedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t != null) setState(() => _pickedTime = t);
  }

  Future<void> _submit() async {
    if (_selectedEventId == null ||
        _pickedDate == null ||
        _pickedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول المطلوبة')),
      );
      return;
    }

    final scheduledAt = DateTime(
      _pickedDate!.year,
      _pickedDate!.month,
      _pickedDate!.day,
      _pickedTime!.hour,
      _pickedTime!.minute,
    );

    // Call your BookingService (you need to implement this)
    try {
      await ref
          .read(bookingServiceProvider)
          .createBooking(
            eventId: _selectedEventId!,
            offeringId: widget.offering.id,
            quantity: _quantity,
            scheduledAt: scheduledAt,
            note: _noteCtl.text.trim(),
          );
      Navigator.of(context).pop(); // back to listing
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إنشاء الحجز')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('حجز العرض', style: GoogleFonts.cairo()),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: eventsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
          data: (events) {
            return ListView(
              children: [
                // Offering summary
                Text(
                  widget.offering.title,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.offering.price.toStringAsFixed(2)} ش.إ',
                  style: GoogleFonts.cairo(fontSize: 18),
                ),
                const Divider(height: 32),

                // 1) Event dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'اختر الفعالية',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      events
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.title, style: GoogleFonts.cairo()),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => _selectedEventId = v),
                ),
                const SizedBox(height: 16),

                // 2) Date & Time pickers
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _pickDate,
                        child: Text(
                          _pickedDate == null
                              ? 'اختر التاريخ'
                              : '${_pickedDate!.toLocal()}'.split(' ')[0],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _pickTime,
                        child: Text(
                          _pickedTime == null
                              ? 'اختر الوقت'
                              : _pickedTime!.format(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3) Quantity stepper
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الكمية', style: GoogleFonts.cairo(fontSize: 16)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed:
                              _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                        ),
                        Text('$_quantity', style: GoogleFonts.cairo()),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setState(() => _quantity++),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 4) Optional note
                TextField(
                  controller: _noteCtl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظة (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _submit,
                  child: Text(
                    'تأكيد الحجز',
                    style: GoogleFonts.cairo(fontSize: 18),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
