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
              colorScheme: const ColorScheme.light(
                primary: Colors.purple,
                onPrimary: Colors.white,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: Colors.purple),
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
    return evAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (e, _) => Scaffold(
            body: Center(child: Text('خطأ: $e', style: GoogleFonts.cairo())),
          ),
      data: (event) {
        // init from settings once
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

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('الترتيبات اللوجستية'),
              backgroundColor: Colors.purple,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _locationCtl,
                    decoration: InputDecoration(
                      labelText: 'مكان الفعالية',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.purple,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? 'لم يتم اختيار التاريخ'
                              : 'التاريخ المختار: ${_selectedDate!.toLocal().toIso8601String().split('T')[0]}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _selectDate(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade300,
                        ),
                        child: const Text('اختر التاريخ'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _scheduleCtl,
                    decoration: InputDecoration(
                      labelText: 'الجدول الزمني للتوصيل',
                      hintText: 'مثال: الساعة 8 صباحًا - المعدات الصوتية',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.purple,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('حفظ الترتيبات'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
