import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:masterevent/models/task.dart';
import '../models/event.dart';
import '../services/event_service.dart';
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
    // event.settings!.tasks is already List<Task>
    final taskList = event.settings?.tasks ?? [];
    _tasks
      ..clear()
      ..addAll(taskList);
  }

  Future<void> _saveSettings() async {
    final svc = ref.read(eventServiceProvider);
    await svc.updateEvent(
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

  @override
  Widget build(BuildContext context) {
    final evAsync = ref.watch(eventDetailProvider(widget.eventId));
    return evAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('خطأ: $e'))),
      data: (event) {
        if (!_inited) {
          _initFromEvent(event);
          _inited = true;
        }

        final filtered =
            _filterCategory == null
                ? _tasks
                : _tasks.where((t) => t.category == _filterCategory).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('تنظيم المهام'),
            backgroundColor: Colors.purple,
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveSettings,
                tooltip: 'حفظ المهام',
              ),
            ],
          ),
          body: Column(
            children: [
              // filter chips
              if (_tasks.any((t) => t.category != null))
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    spacing: 6,
                    children: [
                      FilterChip(
                        label: const Text('الكل'),
                        selected: _filterCategory == null,
                        onSelected:
                            (_) => setState(() => _filterCategory = null),
                      ),
                      ...{
                        for (var t in _tasks)
                          if (t.category != null) t.category!,
                      }.map(
                        (c) => FilterChip(
                          label: Text(c),
                          selected: _filterCategory == c,
                          onSelected:
                              (_) => setState(() => _filterCategory = c),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final t = filtered[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: Checkbox(
                          value: t.isDone,
                          onChanged:
                              (v) => setState(() => t.isDone = v ?? false),
                        ),
                        title: Text(
                          t.name,
                          style: TextStyle(
                            decoration:
                                t.isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (t.category != null) Text('قسم: ${t.category}'),
                            if (t.dueDate != null)
                              Text('تاريخ: ${_dateFmt.format(t.dueDate!)}'),
                            if (t.notes != null) Text('ملاحظات: ${t.notes}'),
                            Text('أولوية: ${t.priorityText}'),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editTask(t),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => setState(() => _tasks.remove(t)),
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
            child: const Icon(Icons.add),
            backgroundColor: Colors.purple,
          ),
        );
      },
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
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              top: 20,
            ),
            child: StatefulBuilder(
              builder:
                  (ctx2, setM) => SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          existing == null ? 'إضافة مهمة' : 'تعديل المهمة',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        TextField(
                          controller: nameCtl,
                          decoration: const InputDecoration(labelText: 'اسم *'),
                        ),
                        TextField(
                          controller: catCtl,
                          decoration: const InputDecoration(labelText: 'القسم'),
                        ),
                        TextField(
                          controller: notesCtl,
                          decoration: const InputDecoration(
                            labelText: 'ملاحظات',
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                due == null
                                    ? 'لا تاريخ'
                                    : _dateFmt.format(due!),
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
                                );
                                if (p != null) setM(() => due = p);
                              },
                              child: const Text('اختر تاريخ'),
                            ),
                          ],
                        ),
                        DropdownButton<TaskPriority>(
                          value: priority,
                          items:
                              TaskPriority.values
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        Task(
                                          id: '',
                                          name: '',
                                          priority: e,
                                        ).priorityText,
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) => setM(() => priority = v!),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                          ),
                          child: const Text('حفظ'),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
            ),
          ),
    );
  }
}
