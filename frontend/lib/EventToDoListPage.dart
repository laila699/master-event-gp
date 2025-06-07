import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- كلاس Task و TaskPriority (مع category) ---
enum TaskPriority { low, medium, high }

class Task {
  String id; // يُستخدم للفرز حسب تاريخ الإنشاء (بافتراض أنه timestamp)
  String name;
  String? category;
  DateTime? dueDate;
  String? notes;
  TaskPriority priority;
  bool isDone;

  Task({
    required this.id,
    required this.name,
    this.category,
    this.dueDate,
    this.notes,
    this.priority = TaskPriority.medium,
    this.isDone = false,
  });

  String get priorityText {
    switch (priority) {
      case TaskPriority.high:
        return 'عالية';
      case TaskPriority.medium:
        return 'متوسطة';
      case TaskPriority.low:
        return 'منخفضة';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red.shade300;
      case TaskPriority.medium:
        return Colors.orange.shade300;
      case TaskPriority.low:
        return Colors.green.shade300;
    }
  }
}
// --- نهاية كلاس Task و TaskPriority ---

// *** تعداد لخيارات الفرز ***
enum SortOption {
  creationDateDesc, // الأحدث أولاً (افتراضي)
  creationDateAsc, // الأقدم أولاً
  dueDateAsc, // الأقرب أولاً (بدون تاريخ في النهاية)
  dueDateDesc, // الأبعد أولاً (بدون تاريخ في النهاية)
  priorityDesc, // الأولوية الأعلى أولاً
  priorityAsc, // الأولوية الأدنى أولاً
  status, // غير المكتملة أولاً
  nameAsc, // حسب الاسم أبجديًا
  nameDesc, // حسب الاسم عكس أبجديًا
}

class EventToDoListPage extends StatefulWidget {
  const EventToDoListPage({super.key});

  @override
  State<EventToDoListPage> createState() => _EventToDoListPageState();
}

class _EventToDoListPageState extends State<EventToDoListPage> {
  final List<Task> _tasks = []; // القائمة الأصلية للمهام
  final DateFormat _dateFormatter = DateFormat('yyyy/MM/dd');
  String? _selectedCategory; // لتتبع القسم المحدد للفلترة
  SortOption _currentSortOption =
      SortOption.creationDateDesc; // متغير حالة للفرز الحالي

  // دالة لإضافة أو تعديل مهمة (مع القسم)
  void _saveTask(Task? taskToEdit) {
    final nameController = TextEditingController(text: taskToEdit?.name ?? '');
    final categoryController = TextEditingController(
      text: taskToEdit?.category ?? '',
    );
    final notesController = TextEditingController(
      text: taskToEdit?.notes ?? '',
    );
    DateTime? selectedDate = taskToEdit?.dueDate;
    TaskPriority selectedPriority = taskToEdit?.priority ?? TaskPriority.medium;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        // نستخدم ctx لـ showDatePicker
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      taskToEdit == null ? 'إضافة مهمة جديدة' : 'تعديل المهمة',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم المهمة *',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        labelText: 'القسم (مثال: ديكور، طعام)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات إضافية',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 15),
                    // اختيار التاريخ
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedDate == null
                                ? 'لم يتم تحديد تاريخ انتهاء'
                                : 'تاريخ الانتهاء: ${_dateFormatter.format(selectedDate!)}',
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            selectedDate == null ? 'اختيار' : 'تغيير',
                          ),
                          onPressed: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: ctx, // *** استخدام ctx هنا ***
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 30),
                              ),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365 * 2),
                              ),
                            );
                            if (pickedDate != null) {
                              setModalState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // اختيار الأولوية
                    Row(
                      children: [
                        const Text('الأولوية: '),
                        const SizedBox(width: 10),
                        DropdownButton<TaskPriority>(
                          value: selectedPriority,
                          items:
                              TaskPriority.values.map((TaskPriority priority) {
                            return DropdownMenuItem<TaskPriority>(
                              value: priority,
                              child: Text(
                                Task(
                                  id: '',
                                  name: '',
                                  priority: priority,
                                ).priorityText,
                              ),
                            );
                          }).toList(),
                          onChanged: (TaskPriority? newValue) {
                            if (newValue != null) {
                              setModalState(() {
                                selectedPriority = newValue;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // زر الحفظ
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: Text(
                          taskToEdit == null ? 'إضافة المهمة' : 'حفظ التعديلات',
                        ),
                        onPressed: () {
                          final name = nameController.text.trim();
                          final category = categoryController.text.trim();
                          final notes = notesController.text.trim();

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('الرجاء إدخال اسم المهمة'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final newTask = Task(
                            id: taskToEdit?.id ??
                                DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                            name: name,
                            category: category.isNotEmpty ? category : null,
                            notes: notes.isNotEmpty ? notes : null,
                            dueDate: selectedDate,
                            priority: selectedPriority,
                            isDone: taskToEdit?.isDone ?? false,
                          );

                          setState(() {
                            if (taskToEdit == null) {
                              _tasks.add(newTask);
                            } else {
                              final int taskIndex = _tasks.indexWhere(
                                (t) => t.id == taskToEdit.id,
                              );
                              if (taskIndex != -1) {
                                _tasks[taskIndex] = newTask;
                              } else {
                                _tasks.add(
                                  newTask,
                                ); // Handle case where task might not be found (rare)
                              }
                            }
                            // لا نعيد تعيين الفلتر هنا، قد يرغب المستخدم في البقاء في نفس القسم
                          });
                          Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // دالة لتبديل حالة الاكتمال
  void _toggleTaskStatus(Task task) {
    final int taskIndex = _tasks.indexWhere((t) => t.id == task.id);
    if (taskIndex != -1) {
      setState(() {
        _tasks[taskIndex].isDone = !_tasks[taskIndex].isDone;
      });
    }
  }

  // دالة لحذف مهمة
  void _deleteTask(Task task) {
    final int taskIndex = _tasks.indexWhere((t) => t.id == task.id);
    if (taskIndex == -1) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف المهمة "${_tasks[taskIndex].name}"؟',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
            onPressed: () {
              final String? deletedCategory =
                  _tasks[taskIndex].category; // حفظ القسم قبل الحذف
              setState(() {
                _tasks.removeAt(taskIndex);
                // إذا كان القسم المحذوف هو القسم المفلتر حاليًا ولم يعد هناك مهام أخرى فيه، قم بإلغاء الفلتر
                if (deletedCategory != null &&
                    _selectedCategory == deletedCategory) {
                  final remainingInCategory = _tasks.any(
                    (t) => t.category == deletedCategory,
                  );
                  if (!remainingInCategory) {
                    _selectedCategory = null;
                  }
                }
              });
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف المهمة'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ويدجت لبناء شريحة الفلتر
  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            if (label == 'الكل') {
              _selectedCategory = null;
            } else {
              _selectedCategory = selected ? label : null;
            }
          });
        },
        selectedColor: Colors.purple.withOpacity(0.3),
        checkmarkColor: Colors.purple,
        labelStyle: TextStyle(
          color: isSelected ? Colors.purple : Colors.black87,
        ),
        backgroundColor: Colors.grey.shade200,
        shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade400)),
      ),
    );
  }

  // ويدجت لبناء مؤشر التقدم
  Widget _buildProgressIndicator(List<Task> tasksToShow) {
    if (tasksToShow.isEmpty) {
      return const SizedBox.shrink();
    }

    final int totalTasks = tasksToShow.length;
    final int completedTasks = tasksToShow.where((task) => task.isDone).length;
    final double progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
    final String percentageString = "${(progress * 100).toStringAsFixed(0)}%";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedCategory == null
                    ? 'تقدم جميع المهام:'
                    : 'تقدم قسم "$_selectedCategory":',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              Text(
                '$completedTasks / $totalTasks ($percentageString)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  // دالة للحصول على النص المعروض لخيار الفرز
  String _getSortOptionText(SortOption option) {
    switch (option) {
      case SortOption.creationDateDesc:
        return 'الأحدث أولاً';
      case SortOption.creationDateAsc:
        return 'الأقدم أولاً';
      case SortOption.dueDateAsc:
        return 'تاريخ الاستحقاق (الأقرب)';
      case SortOption.dueDateDesc:
        return 'تاريخ الاستحقاق (الأبعد)';
      case SortOption.priorityDesc:
        return 'الأولوية (عالية أولاً)';
      case SortOption.priorityAsc:
        return 'الأولوية (منخفضة أولاً)';
      case SortOption.status:
        return 'الحالة (غير مكتملة أولاً)';
      case SortOption.nameAsc:
        return 'الاسم (أ - ي)';
      case SortOption.nameDesc:
        return 'الاسم (ي - أ)';
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- 1. الفلترة حسب القسم ---
    final List<Task> filteredTasks = _selectedCategory == null
        ? _tasks
        : _tasks.where((task) => task.category == _selectedCategory).toList();

    // --- 2. الفرز حسب الخيار المحدد ---
    List<Task> sortedAndFilteredTasks = List.from(
      filteredTasks,
    ); // نسخة قابلة للتعديل
    sortedAndFilteredTasks.sort((a, b) {
      switch (_currentSortOption) {
        case SortOption.creationDateDesc:
          return b.id.compareTo(a.id); // افترض أن الـ ID يعكس وقت الإنشاء
        case SortOption.creationDateAsc:
          return a.id.compareTo(b.id);
        case SortOption.dueDateAsc:
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1; // بدون تاريخ في النهاية
          if (b.dueDate == null) return -1; // بدون تاريخ في النهاية
          return a.dueDate!.compareTo(b.dueDate!);
        case SortOption.dueDateDesc:
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1; // بدون تاريخ في النهاية
          if (b.dueDate == null) return -1; // بدون تاريخ في النهاية
          return b.dueDate!.compareTo(a.dueDate!);
        case SortOption.priorityDesc:
          return b.priority.index.compareTo(a.priority.index);
        case SortOption.priorityAsc:
          return a.priority.index.compareTo(b.priority.index);
        case SortOption.status:
          return (a.isDone ? 1 : 0).compareTo(b.isDone ? 1 : 0);
        case SortOption.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case SortOption.nameDesc:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
      }
    });

    // حساب قائمة الأقسام الفريدة (للفلاتر)
    final Set<String> categories = _tasks
        .where((task) => task.category != null && task.category!.isNotEmpty)
        .map((task) => task.category!)
        .toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظيم المهام'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'فرز المهام',
            onSelected: (SortOption result) {
              setState(() {
                _currentSortOption = result;
              });
            },
            itemBuilder: (BuildContext context) =>
                SortOption.values.map((option) {
              return PopupMenuItem<SortOption>(
                value: option,
                child: Text(_getSortOptionText(option)),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- منطقة الفلاتر (الأقسام) ---
          if (categories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  spacing: 6.0,
                  children: [
                    _buildFilterChip('الكل', _selectedCategory == null),
                    ...categories
                        .map(
                          (category) => _buildFilterChip(
                            category,
                            _selectedCategory == category,
                          ),
                        )
                        ,
                  ],
                ),
              ),
            ),
          if (categories.isNotEmpty) const Divider(height: 1, thickness: 1),

          // --- منطقة مؤشر التقدم ---
          _buildProgressIndicator(
            filteredTasks,
          ), // نمرر القائمة المفلترة (قبل الفرز)
          // --- منطقة عرض المهام ---
          Expanded(
            child: sortedAndFilteredTasks.isEmpty
                ? Center(
                    child: Text(
                      _tasks.isEmpty
                          ? 'لا توجد مهام حتى الآن. اضغط على + للإضافة.'
                          : _selectedCategory == null
                              ? 'جميع المهام مكتملة أو لا توجد مهام بعد.' // رسالة أوضح قليلا
                              : 'لا توجد مهام في قسم "$_selectedCategory".',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: sortedAndFilteredTasks.length,
                    padding: const EdgeInsets.only(bottom: 80.0),
                    itemBuilder: (context, index) {
                      final task = sortedAndFilteredTasks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 5.0,
                        ),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: task.priorityColor,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: task.isDone,
                            onChanged: (bool? value) => _toggleTaskStatus(task),
                            activeColor: Colors.purple,
                          ),
                          title: Text(
                            task.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: task.isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: task.isDone
                                  ? Colors.grey.shade600
                                  : Colors.black87,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (task.category != null &&
                                    task.category!.isNotEmpty)
                                  Text(
                                    'القسم: ${task.category}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                Text(
                                  'الأولوية: ${task.priorityText}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                if (task.dueDate != null)
                                  Text(
                                    'التاريخ: ${_dateFormatter.format(task.dueDate!)}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                if (task.notes != null &&
                                    task.notes!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Text(
                                      'ملاحظات: ${task.notes}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit_outlined,
                                  color: Colors.blue.shade600,
                                ),
                                tooltip: 'تعديل المهمة',
                                onPressed: () => _saveTask(task),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red.shade700,
                                ),
                                tooltip: 'حذف المهمة',
                                onPressed: () => _deleteTask(task),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          onTap: () => _toggleTaskStatus(task),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _saveTask(null),
        tooltip: 'إضافة مهمة جديدة',
        icon: const Icon(Icons.add),
        label: const Text("إضافة مهمة"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
    );
  }
}
