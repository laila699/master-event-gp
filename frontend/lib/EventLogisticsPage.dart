import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/event_service.dart';
import '../providers/event_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class EventLogisticsPage extends ConsumerStatefulWidget {
  final String eventId;
  const EventLogisticsPage({super.key, required this.eventId});

  @override
  ConsumerState<EventLogisticsPage> createState() => _EventLogisticsPageState();
}

class _EventLogisticsPageState extends ConsumerState<EventLogisticsPage> {
  final _locationCtl = TextEditingController();
  final _scheduleCtl = TextEditingController();
  DateTime? _selectedDate;
  bool _inited = false;

  final accent1 = const Color(0xFFD81B60); // magenta-pink
  final accent2 = const Color(0xFF8E24AA); // deep purple

  @override
  void dispose() {
    _locationCtl.dispose();
    _scheduleCtl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      locale: const Locale('ar'),
      builder:
          (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: ColorScheme.dark(
                primary: accent2,
                onPrimary: Colors.black,
                surface: Colors.black.withOpacity(0.05),
                background: Colors.black,
                onBackground: Colors.white70,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: accent2),
              ),
            ),
            child: child!,
          ),
    );
    if (picked != null && picked != _selectedDate && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (_locationCtl.text.isEmpty ||
        _scheduleCtl.text.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تعبئة جميع الحقول'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final svc = ref.read(eventServiceProvider);
    await svc.updateEvent(
      eventId: widget.eventId,
      settings: {
        'logistics': {
          'location': _locationCtl.text.trim(),
          'scheduleDate': _selectedDate!.toIso8601String(),
          'scheduleDescription': _scheduleCtl.text.trim(),
        },
      },
    );
    ref.invalidate(eventDetailProvider(widget.eventId));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ الترتيبات بنجاح!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final evAsync = ref.watch(eventDetailProvider(widget.eventId));

    // Neon radial + glassmorphic backdrop for the page
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.5, -0.5),
                radius: 1.3,
                colors: [accent1, Colors.black],
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          evAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (e, _) => Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Center(
                    child: Text(
                      'خطأ: $e',
                      style: GoogleFonts.orbitron(color: Colors.redAccent),
                    ),
                  ),
                ),
            data: (event) {
              if (!_inited) {
                final lg = event.settings?.logistics as Map<String, dynamic>?;
                if (lg != null) {
                  _locationCtl.text = lg['location'] ?? '';
                  _scheduleCtl.text = lg['scheduleDescription'] ?? '';
                  if (lg['scheduleDate'] != null) {
                    _selectedDate = DateTime.tryParse(lg['scheduleDate']);
                  }
                }
                _inited = true;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'الترتيبات اللوجستية',
                      style: GoogleFonts.audiowide(
                        color: accent2,
                        fontSize: 26,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Location field
                    TextField(
                      controller: _locationCtl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'مكان الفعالية',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        prefixIcon: Icon(Icons.location_on, color: accent2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: accent2.withOpacity(0.6),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: accent2, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date selector row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? 'لم يتم اختيار التاريخ'
                                : 'التاريخ: ${_selectedDate!.toLocal().toIso8601String().split('T')[0]}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _selectDate(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('اختر التاريخ'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Schedule description
                    TextField(
                      controller: _scheduleCtl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'الجدول الزمني للتوصيل',
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: 'مثال: 8 صباحًا - معدات صوت',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        prefixIcon: Icon(Icons.schedule, color: accent2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: accent2.withOpacity(0.6),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: accent2, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save button
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [accent1, accent2]),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: _save,
                        child: Text(
                          'حفظ الترتيبات',
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
