import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masterevent/models/event.dart';
import '../providers/event_provider.dart';

class EventBudgetPage extends ConsumerStatefulWidget {
  final String eventId;
  const EventBudgetPage({Key? key, required this.eventId}) : super(key: key);

  @override
  _EventBudgetPageState createState() => _EventBudgetPageState();
}

class _EventBudgetPageState extends ConsumerState<EventBudgetPage> {
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  List<Map<String, dynamic>> _categories = [];
  bool _initialized = false;

  @override
  void dispose() {
    _totalController.dispose();
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _initialize(EventSettings? s) {
    if (_initialized) return;
    _initialized = true;
    final bud = s?.budget;
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

    // 1) send update
    await ref.read(
      updateEventProvider({
        'eventId': widget.eventId,
        'settings': {'budget': budgetMap},
      }).future,
    );

    // 2) force a refetch of the event details
    ref.invalidate(eventDetailProvider(widget.eventId));

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حفظ الميزانية')));

    // 3) pop back
    Navigator.of(context).pop();
  }

  void _removeCategory(int i) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: Text('هل تريد حذف القسم "${_categories[i]['name']}"؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _categories.removeAt(i));
                  Navigator.pop(context);
                },
                child: const Text('حذف', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Future<void> _editCategory(int i) async {
    final existing = _categories[i];
    _categoryController.text = existing['name'] as String;
    _amountController.text = existing['amount'].toString();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'اسم القسم'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'المبلغ'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final name = _categoryController.text.trim();
                    final amt = double.tryParse(_amountController.text.trim());
                    if (name.isEmpty || amt == null) return;
                    setState(() {
                      _categories[i] = {'name': name, 'amount': amt};
                      _categoryController.clear();
                      _amountController.clear();
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('حفظ'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
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
            appBar: AppBar(title: const Text('الميزانية')),
            body: Center(child: Text('خطأ: \$e')),
          ),
      data: (event) {
        _initialize(event.settings);
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Theme(
            data: Theme.of(context).copyWith(
              textTheme: GoogleFonts.cairoTextTheme(
                Theme.of(context).textTheme,
              ),
            ),
            child: Scaffold(
              appBar: AppBar(
                title: const Text('الميزانية والتكلفة'),
                backgroundColor: Colors.purple,
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _totalController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'الميزانية الإجمالية',
                        prefixIcon: const Icon(Icons.monetization_on),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        labelText: 'اسم القسم',
                        prefixIcon: const Icon(Icons.category),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'ميزانية القسم',
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _addCategory,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('أضف القسم'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'الأقسام (${_categories.length}), المخصص: ${_allocated.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _categories.length,
                        itemBuilder: (_, i) {
                          final c = _categories[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              title: Text(
                                c['name'],
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              subtitle: Text(
                                '\$${(c['amount'] as num).toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleSmall!
                                    .copyWith(color: Colors.grey[700]),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    splashRadius: 20,
                                    onPressed: () => _editCategory(i),
                                    tooltip: 'تعديل',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    splashRadius: 20,
                                    onPressed: () => _removeCategory(i),
                                    tooltip: 'حذف',
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
