import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masterevent/providers/booking_provider.dart';
import 'package:masterevent/providers/event_provider.dart';
import 'package:masterevent/services/booking_service.dart';
import '../models/offering.dart';
import '../models/event.dart';
import '../theme/colors.dart';

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
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder:
          (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: ColorScheme.dark(
                primary: AppColors.gradientStart,
                onPrimary: AppColors.textOnNeon,
                surface: AppColors.glass,
                onSurface: AppColors.textOnNeon,
              ),
            ),
            child: child!,
          ),
    );
    if (d != null) setState(() => _pickedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder:
          (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              timePickerTheme: TimePickerThemeData(
                backgroundColor: AppColors.glass,
                dayPeriodTextColor: AppColors.textOnNeon,
                dialBackgroundColor: AppColors.background,
              ),
            ),
            child: child!,
          ),
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
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إنشاء الحجز')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ: \$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventListProvider);
    final accent1 = AppColors.gradientStart;
    final accent2 = AppColors.gradientEnd;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Neon radial background
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.7, -0.7),
                radius: 1.5,
                colors: [accent1, AppColors.background],
              ),
            ),
          ),
          // Glass overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: AppColors.overlay),
          ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: eventsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (e, _) => Center(
                    child: Text(
                      'خطأ: \$e',
                      style: GoogleFonts.orbitron(color: AppColors.error),
                    ),
                  ),
              data:
                  (events) => SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'حجز: ${widget.offering.title}',
                          style: GoogleFonts.orbitron(
                            color: AppColors.textOnNeon,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${widget.offering.price.toStringAsFixed(2)} ش.إ',
                          style: GoogleFonts.orbitron(
                            color: accent2,
                            fontSize: 20,
                          ),
                        ),
                        const Divider(color: Colors.white24, height: 32),

                        // 1) Event dropdown
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.fieldFill,
                            labelText: 'اختر المناسبة',
                            labelStyle: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            prefixIcon: Icon(Icons.event, color: accent1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: accent1, width: 2),
                            ),
                          ),
                          items:
                              events
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e.id,
                                      child: Text(
                                        e.title,
                                        style: GoogleFonts.orbitron(
                                          color: AppColors.textOnNeon,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (v) => setState(() => _selectedEventId = v),
                        ),
                        const SizedBox(height: 16),

                        // 2) Date & Time
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _pickDate,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.glass,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: Text(
                                  _pickedDate == null
                                      ? 'اختر التاريخ'
                                      : '${_pickedDate!.year}-${_pickedDate!.month.toString().padLeft(2, '0')}-${_pickedDate!.day.toString().padLeft(2, '0')}',
                                  style: GoogleFonts.orbitron(
                                    color: AppColors.textOnNeon,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _pickTime,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.glass,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: Text(
                                  _pickedTime == null
                                      ? 'اختر الوقت'
                                      : _pickedTime!.format(context),
                                  style: GoogleFonts.orbitron(
                                    color: AppColors.textOnNeon,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 3) Quantity
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'الكمية',
                              style: GoogleFonts.orbitron(
                                color: AppColors.textOnNeon,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  color: AppColors.textOnNeon,
                                  onPressed:
                                      _quantity > 1
                                          ? () => setState(() => _quantity--)
                                          : null,
                                ),
                                Text(
                                  '$_quantity',
                                  style: GoogleFonts.orbitron(
                                    color: AppColors.textOnNeon,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  color: AppColors.textOnNeon,
                                  onPressed: () => setState(() => _quantity++),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 4) Note
                        TextField(
                          controller: _noteCtl,
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'ملاحظة (اختياري)',
                            labelStyle: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            filled: true,
                            fillColor: AppColors.fieldFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: accent1, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Submit
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accent1, accent2],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: accent2.withOpacity(0.6),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'تأكيد الحجز',
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
