// lib/screens/event_to_do_list_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masterevent/theme/colors.dart';

import '../models/event.dart';
import '../models/task.dart';
import '../providers/event_provider.dart';

class EventToDoListPage extends ConsumerStatefulWidget {
  final String eventId;
  const EventToDoListPage({super.key, required this.eventId});

  @override
  ConsumerState<EventToDoListPage> createState() => _EventToDoListPageState();
}

class _EventToDoListPageState extends ConsumerState<EventToDoListPage> {
  final List<Task> _tasks = [];
  final _dateFmt = DateFormat('yyyy/MM/dd');
  bool _inited = false;
  String? _filterCategory;

  void _initFromEvent(Event event) {
    final taskList = event.settings?.tasks ?? [];
    _tasks
      ..clear()
      ..addAll(taskList);
  }

  Future<void> _saveSettings() async {
    await ref
        .read(eventServiceProvider)
        .updateEvent(
          eventId: widget.eventId,
          settings: {'tasks': _tasks.map((t) => t.toJson()).toList()},
        );
    ref.invalidate(eventDetailProvider(widget.eventId));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ قائمة المهام'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }

  Widget _buildField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: AppColors.textOnNeon),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.gradientEnd, width: 2),
        ),
      ),
    );
  }

  void _editTask(Task? existing) {
    final nameCtl = TextEditingController(text: existing?.name);
    final catCtl = TextEditingController(text: existing?.category);
    final notesCtl = TextEditingController(text: existing?.notes);
    DateTime? due = existing?.dueDate;
    TaskPriority priority = existing?.priority ?? TaskPriority.medium;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.3),
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: StatefulBuilder(
              builder:
                  (ctx2, setM) => SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          existing == null ? 'إضافة مهمة' : 'تعديل المهمة',
                          style: GoogleFonts.orbitron(
                            color: AppColors.gradientStart,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildField(nameCtl, 'اسم المهمة *'),
                        const SizedBox(height: 12),
                        _buildField(catCtl, 'القسم (اختياري)'),
                        const SizedBox(height: 12),
                        _buildField(notesCtl, 'ملاحظات'),
                        const SizedBox(height: 16),

                        // Due date picker
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                due == null
                                    ? 'لا تاريخ'
                                    : _dateFmt.format(due!),
                                style: const TextStyle(
                                  color: AppColors.textOnNeon,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final p = await showDatePicker(
                                  context: ctx,
                                  initialDate: due ?? DateTime.now(),
                                  firstDate: DateTime.now().subtract(
                                    const Duration(days: 30),
                                  ),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                  builder:
                                      (ctx3, child) => Theme(
                                        data: Theme.of(ctx3).copyWith(
                                          colorScheme: ColorScheme.dark(
                                            primary: AppColors.gradientStart,
                                            onPrimary: Colors.black,
                                            surface: AppColors.gradientEnd,
                                            onSurface: AppColors.textOnNeon,
                                          ),
                                        ),
                                        child: child!,
                                      ),
                                );
                                if (p != null) setM(() => due = p);
                              },
                              child: Text(
                                'اختر تاريخ',
                                style: GoogleFonts.orbitron(
                                  color: AppColors.gradientEnd,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Priority dropdown
                        DropdownButtonFormField<TaskPriority>(
                          value: priority,
                          dropdownColor: Colors.black.withOpacity(0.3),
                          style: const TextStyle(color: AppColors.textOnNeon),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.fieldFill,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.gradientEnd,
                                width: 2,
                              ),
                            ),
                          ),
                          items:
                              TaskPriority.values.map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    Task(
                                      id: '',
                                      name: '',
                                      priority: e,
                                    ).priorityText,
                                    style: GoogleFonts.orbitron(
                                      color: AppColors.textOnNeon,
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged: (v) => setM(() => priority = v!),
                        ),
                        const SizedBox(height: 24),

                        // Save button
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.gradientStart,
                                AppColors.gradientEnd,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gradientEnd.withOpacity(0.6),
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
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              final name = nameCtl.text.trim();
                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('الرجاء إدخال اسم المهمة'),
                                  ),
                                );
                                return;
                              }
                              final t = Task(
                                id:
                                    existing?.id ??
                                    DateTime.now().millisecondsSinceEpoch
                                        .toString(),
                                name: name,
                                category:
                                    catCtl.text.trim().isEmpty
                                        ? null
                                        : catCtl.text.trim(),
                                dueDate: due,
                                notes:
                                    notesCtl.text.trim().isEmpty
                                        ? null
                                        : notesCtl.text.trim(),
                                priority: priority,
                                isDone: existing?.isDone ?? false,
                              );
                              setState(() {
                                if (existing != null) {
                                  final i = _tasks.indexWhere(
                                    (x) => x.id == existing.id,
                                  );
                                  _tasks[i] = t;
                                } else {
                                  _tasks.add(t);
                                }
                              });
                              Navigator.of(ctx).pop();
                            },
                            child: Text(
                              'حفظ',
                              style: GoogleFonts.orbitron(
                                color: AppColors.textOnNeon,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final evAsync = ref.watch(eventDetailProvider(widget.eventId));

    return Scaffold(
      // No appBar here—scaffold is transparent and built inside the async branches
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Neon radial background
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.8, -0.8),
                radius: 1.5,
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
            ),
          ),

          // Glass blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: AppColors.overlay),
          ),

          // Async content
          evAsync.when(
            loading:
                () => const Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Center(child: CircularProgressIndicator()),
                ),
            error:
                (e, _) => Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Center(
                    child: Text(
                      'خطأ: $e',
                      style: GoogleFonts.orbitron(color: AppColors.error),
                    ),
                  ),
                ),
            data: (event) {
              if (!_inited) {
                _initFromEvent(event);
                _inited = true;
              }

              final filtered =
                  _filterCategory == null
                      ? _tasks
                      : _tasks
                          .where((t) => t.category == _filterCategory)
                          .toList();

              return Theme(
                data: Theme.of(context).copyWith(
                  scaffoldBackgroundColor: Colors.transparent,
                  appBarTheme: AppBarTheme(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    elevation: 0,
                    titleTextStyle: GoogleFonts.orbitron(
                      color: AppColors.textOnNeon,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    centerTitle: true,
                    title: const Text('تنظيم المهام'),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.save),
                        color: AppColors.gradientEnd,
                        onPressed: _saveSettings,
                      ),
                    ],
                  ),
                  body: Column(
                    children: [
                      // Category filter chips
                      if (_tasks.any((t) => t.category != null))
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(8),
                          child: Wrap(
                            spacing: 6,
                            children: [
                              FilterChip(
                                label: Text(
                                  'الكل',
                                  style: GoogleFonts.orbitron(
                                    color: AppColors.textOnNeon,
                                  ),
                                ),
                                selected: _filterCategory == null,
                                selectedColor: AppColors.gradientEnd,
                                onSelected:
                                    (_) =>
                                        setState(() => _filterCategory = null),
                              ),
                              ...{
                                for (var t in _tasks)
                                  if (t.category != null) t.category!,
                              }.map(
                                (c) => FilterChip(
                                  label: Text(
                                    c,
                                    style: GoogleFonts.orbitron(
                                      color: AppColors.textOnNeon,
                                    ),
                                  ),
                                  selected: _filterCategory == c,
                                  selectedColor: AppColors.gradientStart,
                                  onSelected:
                                      (_) =>
                                          setState(() => _filterCategory = c),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Task list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) {
                            final t = filtered[i];
                            return Card(
                              color: AppColors.glass,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: Checkbox(
                                  value: t.isDone,
                                  onChanged:
                                      (_) =>
                                          setState(() => t.isDone = !t.isDone),
                                  activeColor: AppColors.gradientStart,
                                ),
                                title: Text(
                                  t.name,
                                  style: GoogleFonts.orbitron(
                                    color: AppColors.textOnNeon,
                                    decoration:
                                        t.isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (t.category != null)
                                      Text(
                                        'قسم: ${t.category}',
                                        style: GoogleFonts.orbitron(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    if (t.dueDate != null)
                                      Text(
                                        'تاريخ: ${_dateFmt.format(t.dueDate!)}',
                                        style: GoogleFonts.orbitron(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    if (t.notes != null)
                                      Text(
                                        'ملاحظات: ${t.notes}',
                                        style: GoogleFonts.orbitron(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    Text(
                                      'أولوية: ${t.priorityText}',
                                      style: GoogleFonts.orbitron(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      color: AppColors.gradientStart,
                                      onPressed: () => _editTask(t),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: AppColors.gradientStart,
                                      onPressed:
                                          () =>
                                              setState(() => _tasks.remove(t)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () => _editTask(null),
                    backgroundColor: AppColors.gradientEnd,
                    child: const Icon(Icons.add),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
