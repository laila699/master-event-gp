// lib/screens/event_budget_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masterevent/models/event.dart';
import 'package:masterevent/theme/colors.dart';
import '../providers/event_provider.dart';

class EventBudgetPage extends ConsumerStatefulWidget {
  final String eventId;
  const EventBudgetPage({Key? key, required this.eventId}) : super(key: key);

  @override
  ConsumerState<EventBudgetPage> createState() => _EventBudgetPageState();
}

class _EventBudgetPageState extends ConsumerState<EventBudgetPage> {
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  final accent1 = AppColors.gradientStart;
  final accent2 = AppColors.gradientEnd;
  List<Map<String, dynamic>> _categories = [];
  bool _initialized = false;

  @override
  void dispose() {
    _totalController.dispose();
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _initialize(EventSettings? settings) {
    if (_initialized) return;
    _initialized = true;
    final bud = settings?.budget;
    if (bud != null) {
      if (bud['total'] != null) {
        _totalController.text = bud['total'].toString();
      }
      if (bud['categories'] is List) {
        _categories = List<Map<String, dynamic>>.from(
          bud['categories'] as List,
        );
      }
    }
  }

  double get _allocated =>
      _categories.fold(0.0, (sum, c) => sum + (c['amount'] as num).toDouble());

  void _addCategory() {
    final name = _categoryController.text.trim();
    final amt = double.tryParse(_amountController.text.trim());
    if (name.isEmpty || amt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال اسم القسم وقيمة صحيحة')),
      );
      return;
    }
    setState(() {
      _categories.add({'name': name, 'amount': amt});
      _categoryController.clear();
      _amountController.clear();
    });
  }

  Future<void> _save() async {
    final total = double.tryParse(_totalController.text.trim()) ?? 0;
    final budgetMap = {'total': total, 'categories': _categories};

    // send update
    await ref.read(
      updateEventProvider({
        'eventId': widget.eventId,
        'settings': {'budget': budgetMap},
      }).future,
    );

    // refetch details
    ref.invalidate(eventDetailProvider(widget.eventId));

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حفظ الميزانية')));
    Navigator.of(context).pop();
  }

  void _removeCategory(int index) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.black.withOpacity(0.5),
            title: const Text(
              'تأكيد الحذف',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'هل تريد حذف القسم "${_categories[index]['name']}"؟',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _categories.removeAt(index));
                  Navigator.pop(context);
                },
                child: Text('حذف', style: TextStyle(color: accent1)),
              ),
            ],
          ),
    );
  }

  Future<void> _editCategory(int index) async {
    final existing = _categories[index];
    _categoryController.text = existing['name'];
    _amountController.text = existing['amount'].toString();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.3),
      builder:
          (_) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'تعديل القسم',
                  style: GoogleFonts.orbitron(color: accent2, fontSize: 18),
                ),
                const SizedBox(height: 12),
                _buildField(_categoryController, 'اسم القسم'),
                const SizedBox(height: 8),
                _buildField(_amountController, 'المبلغ', numeric: true),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent1,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    final name = _categoryController.text.trim();
                    final amt = double.tryParse(_amountController.text.trim());
                    if (name.isEmpty || amt == null) return;
                    setState(
                      () => _categories[index] = {'name': name, 'amount': amt},
                    );
                    _categoryController.clear();
                    _amountController.clear();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'حفظ',
                    style: GoogleFonts.orbitron(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool numeric = false,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.textOnNeon),
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.fieldFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.gradientEnd.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.gradientStart,
            width: 2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final evAsync = ref.watch(eventDetailProvider(widget.eventId));

    return Stack(
      children: [
        // 1) Neon radial background from accent1 → accent2
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.7, -0.7),
              radius: 1.8,
              colors: [accent1, accent2],
            ),
          ),
        ),
        // 2) Glass blur overlay
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
        // 3) Content
        evAsync.when(
          loading:
              () => const Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(child: CircularProgressIndicator()),
              ),
          error:
              (e, _) => Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.black.withOpacity(0.4),
                  elevation: 0,
                  title: const Text(
                    'الميزانية',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                body: Center(
                  child: Text(
                    'خطأ: $e',
                    style: GoogleFonts.orbitron(color: accent1),
                  ),
                ),
              ),
          data: (event) {
            _initialize(event.settings);
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Theme(
                data: Theme.of(context).copyWith(
                  scaffoldBackgroundColor: Colors.transparent,
                  appBarTheme: AppBarTheme(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    elevation: 0,
                    titleTextStyle: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    centerTitle: true,
                    title: const Text('الميزانية والتكلفة'),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildField(
                          _totalController,
                          'الميزانية الإجمالية',
                          numeric: true,
                        ),
                        const SizedBox(height: 16),
                        _buildField(_categoryController, 'اسم القسم'),
                        const SizedBox(height: 8),
                        _buildField(
                          _amountController,
                          'ميزانية القسم',
                          numeric: true,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _addCategory,
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('أضف القسم'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gradientStart,
                            foregroundColor: AppColors.textOnNeon,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'الأقسام (${_categories.length}), المخصص: ${_allocated.toStringAsFixed(2)}',
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Divider(color: Colors.white30),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _categories.length,
                            itemBuilder: (_, i) {
                              final c = _categories[i];
                              return Card(
                                color: Colors.white.withOpacity(0.05),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  title: Text(
                                    c['name'],
                                    style: GoogleFonts.orbitron(
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${c['amount'].toStringAsFixed(2)} ش.إ',
                                    style: GoogleFonts.orbitron(color: accent2),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        color: accent1,
                                        onPressed: () => _editCategory(i),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        color: accent1,
                                        onPressed: () => _removeCategory(i),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _save,
                          child: const Text('حفظ الميزانية'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent1,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
