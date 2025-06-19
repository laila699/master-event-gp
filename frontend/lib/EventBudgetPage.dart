// lib/screens/event_budget_page.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/event.dart';
import '../models/recommended_offers.dart';
import '../providers/event_provider.dart';
import '../theme/colors.dart';

class EventBudgetPage extends ConsumerStatefulWidget {
  final String eventId;
  const EventBudgetPage({Key? key, required this.eventId}) : super(key: key);

  @override
  ConsumerState<EventBudgetPage> createState() => _EventBudgetPageState();
}

class _EventBudgetPageState extends ConsumerState<EventBudgetPage> {
  final _totalCtl = TextEditingController();
  final _catNameCtl = TextEditingController();
  final _catAmountCtl = TextEditingController();

  final accent1 = AppColors.gradientStart;
  final accent2 = AppColors.gradientEnd;

  List<Map<String, dynamic>> _categories = [];
  bool _initDone = false;
  bool _saving = false;

  //---------------------------------------------------------------------------
  // helpers
  //---------------------------------------------------------------------------
  void _init(EventSettings? s) {
    if (_initDone) return;
    _initDone = true;
    if (s?.budget != null) {
      final bud = s!.budget!;
      if (bud['total'] != null) _totalCtl.text = bud['total'].toString();
      if (bud['categories'] is List) {
        _categories =
            List<Map<String, dynamic>>.from(bud['categories'] as List).toList();
      }
    }
  }

  double get _allocated => _categories.fold<double>(
    0.0,
    (sum, c) => sum + (c['amount'] as num).toDouble(),
  );

  //---------------------------------------------------------------------------
  // CRUD on categories
  //---------------------------------------------------------------------------
  void _addCategory() {
    final name = _catNameCtl.text.trim();
    final amt = double.tryParse(_catAmountCtl.text.trim());
    if (name.isEmpty || amt == null) {
      _snack('يرجى إدخال اسم وقيمة صحيحة');
      return;
    }
    setState(() {
      _categories.add({'name': name, 'amount': amt});
      _catNameCtl.clear();
      _catAmountCtl.clear();
    });
  }

  void _removeCategory(int idx) => setState(() => _categories.removeAt(idx));

  Future<void> _editCategory(int idx) async {
    _catNameCtl.text = _categories[idx]['name'];
    _catAmountCtl.text = _categories[idx]['amount'].toString();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'تعديل القسم',
                  style: GoogleFonts.orbitron(
                    fontSize: 18,
                    color: accent2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _field(_catNameCtl, 'اسم القسم'),
                const SizedBox(height: 8),
                _field(_catAmountCtl, 'القيمة', numeric: true),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 32,
                    ),
                  ),
                  onPressed: () {
                    final nm = _catNameCtl.text.trim();
                    final val = double.tryParse(_catAmountCtl.text.trim());
                    if (nm.isEmpty || val == null) return;
                    setState(
                      () => _categories[idx] = {'name': nm, 'amount': val},
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('حفظ'),
                ),
              ],
            ),
          ),
    );
  }

  //---------------------------------------------------------------------------
  // SAVE
  //---------------------------------------------------------------------------
  Future<void> _save() async {
    setState(() => _saving = true);
    final total = double.tryParse(_totalCtl.text.trim()) ?? 0;
    final body = {'total': total, 'categories': _categories};

    await ref.read(
      updateEventProvider({
        'eventId': widget.eventId,
        'settings': {'budget': body},
      }).future,
    );

    ref.invalidate(eventDetailProvider(widget.eventId));
    ref.invalidate(recommendedOffersFamily(widget.eventId));

    setState(() => _saving = false);
    _snack('تم حفظ الميزانية بنجاح');
  }

  //---------------------------------------------------------------------------
  // SUGGESTIONS
  //---------------------------------------------------------------------------
  Future<void> _showSuggestions() async {
    final recAsync = ref.read(recommendedOffersFamily(widget.eventId));
    final buckets = await recAsync.when(
      data: (b) => Future.value(b),
      error: (_, __) => Future<List<RecBucket>>.value([]),
      loading: () => Future<List<RecBucket>>.value([]),
    );

    if (buckets.isEmpty) {
      _snack('لا توجد عروض مناسبة الآن');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => DraggableScrollableSheet(
            expand: false,
            builder:
                (ctx, controller) => ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  children: buckets.map((b) => _bucketCard(b)).toList(),
                ),
          ),
    );
  }

  Widget _bucketCard(RecBucket b) {
    return Card(
      color: Colors.white10,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        collapsedIconColor: accent2,
        iconColor: accent2,
        title: Text(
          'عروض ${b.category} (متبقّي ${b.remaining.toStringAsFixed(0)} ش.إ)',
          style: GoogleFonts.orbitron(color: accent2),
        ),
        children:
            b.offers
                .map(
                  (o) => ListTile(
                    title: Text(
                      o.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${o.price.toStringAsFixed(0)} ش.إ — ${o.vendorName}'
                      '${o.vendorRating != null ? " ⭐${o.vendorRating}" : ""}',
                      style: GoogleFonts.cairo(color: Colors.white70),
                    ),
                    onTap: () {
                      // Navigator.pushNamed(context, '/offer/${o.id}');
                    },
                  ),
                )
                .toList(),
      ),
    );
  }

  //---------------------------------------------------------------------------
  // UI helpers
  //---------------------------------------------------------------------------
  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Widget _field(
    TextEditingController ctl,
    String label, {
    bool numeric = false,
  }) {
    return TextField(
      controller: ctl,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white12,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent2.withOpacity(.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent2, width: 2),
        ),
      ),
    );
  }

  //---------------------------------------------------------------------------
  // build
  //---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final evAsync = ref.watch(eventDetailProvider(widget.eventId));

    return Stack(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.7, -0.7),
              radius: 1.6,
              colors: [accent1, AppColors.background],
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(color: Colors.black54),
        ),
        evAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ: $e')),
          data: (event) {
            _init(event.settings);
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.black87,
                title: const Text('الميزانية والتكلفة'),
                centerTitle: true,
              ),
              floatingActionButton: FloatingActionButton.extended(
                backgroundColor: accent2,
                onPressed: _showSuggestions,
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('اقتراحات ذكية'),
              ),
              body: GestureDetector(
                // dismiss keyboard
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _field(_totalCtl, 'الميزانية الإجمالية', numeric: true),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _field(_catNameCtl, 'اسم القسم')),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _field(
                              _catAmountCtl,
                              'القيمة',
                              numeric: true,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle, size: 30),
                            color: accent2,
                            onPressed: _addCategory,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'مخصَّص: ${_allocated.toStringAsFixed(2)} / الإجمالي',
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _categories.length,
                        itemBuilder: (_, i) {
                          final c = _categories[i];
                          return Card(
                            color: Colors.black45,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              title: Text(
                                c['name'],
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                '${c['amount'].toStringAsFixed(2)} ش.إ',
                                style: TextStyle(color: accent2),
                              ),
                              trailing: Wrap(
                                spacing: 8,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    color: accent2,
                                    onPressed: () => _editCategory(i),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    color: Colors.redAccent,
                                    onPressed: () => _removeCategory(i),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _saving
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent1,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('حفظ الميزانية'),
                            ),
                          ),
                      const SizedBox(height: 80), // leave space for FAB
                    ],
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
