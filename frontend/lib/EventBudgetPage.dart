import 'package:flutter/material.dart';

class EventBudgetPage extends StatefulWidget {
  const EventBudgetPage({super.key});

  @override
  _EventBudgetPageState createState() => _EventBudgetPageState();
}

class _EventBudgetPageState extends State<EventBudgetPage> {
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  final List<Map<String, String>> budgetCategories = [];

  double? _totalBudget;

  @override
  void dispose() {
    _budgetController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _addCategory() {
    final String categoryName = _categoryController.text.trim();
    final String budgetAmountStr = _budgetController.text.trim();
    final double? budgetAmount = double.tryParse(budgetAmountStr);

    if (categoryName.isNotEmpty &&
        budgetAmountStr.isNotEmpty &&
        budgetAmount != null) {
      setState(() {
        budgetCategories.add({
          'category': categoryName,
          'budget': budgetAmountStr,
        });
      });
      _categoryController.clear();
      _budgetController.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت إضافة قسم "$categoryName"'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال اسم قسم وميزانية صحيحة'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  double _calculateAllocatedBudget() {
    double total = 0;
    for (var item in budgetCategories) {
      total += double.tryParse(item['budget'] ?? '0') ?? 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final double allocatedBudget = _calculateAllocatedBudget();
    final double remainingBudget = (_totalBudget ?? 0) - allocatedBudget;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الميزانية والتكلفة'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _budgetController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'ميزانية القسم',
                  hintText: 'أدخل الميزانية المخصصة لهذا القسم',
                  prefixIcon: Icon(
                    Icons.monetization_on_outlined,
                    color: Colors.grey.shade600,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Colors.purple,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'اسم القسم',
                  hintText: 'مثال: الديكور، الطعام، التصوير...',
                  prefixIcon: Icon(
                    Icons.category_outlined,
                    color: Colors.grey.shade600,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(
                      color: Colors.purple,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('إضافة القسم للميزانية'),
                onPressed: _addCategory,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'الأقسام المضافة (${budgetCategories.length}):',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Divider(),

              Expanded(
                child:
                    budgetCategories.isEmpty
                        ? const Center(
                          child: Text('لم تتم إضافة أي أقسام بعد.'),
                        ) //
                        : ListView.builder(
                          itemCount: budgetCategories.length,
                          itemBuilder: (context, index) {
                            final item = budgetCategories[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(
                                vertical: 6,
                              ), //
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.purple.shade100,
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: Colors.purple.shade800,
                                    ),
                                  ),
                                ),
                                title: Text(item['category'] ?? 'قسم غير مسمى'),
                                subtitle: Text(
                                  'الميزانية: ${item['budget'] ?? '0'}',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),

                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red.shade300,
                                  ),
                                  tooltip: 'حذف القسم',
                                  onPressed: () {
                                    setState(() {
                                      budgetCategories.removeAt(index);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'تم حذف قسم "${item['category']}"',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
