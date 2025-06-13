// lib/models/task.dart

enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String name;
  final String? category;
  final DateTime? dueDate;
  final String? notes;
  final TaskPriority priority;
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

  factory Task.fromJson(Map<String, dynamic> json) {
    // priority comes as 'low' | 'medium' | 'high'
    final p = (json['priority'] as String?) ?? 'medium';
    return Task(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String?,
      dueDate:
          json['dueDate'] != null
              ? DateTime.parse(json['dueDate'] as String)
              : null,
      notes: json['notes'] as String?,
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString().split('.').last == p,
        orElse: () => TaskPriority.medium,
      ),
      isDone: json['isDone'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (category != null) 'category': category,
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
      if (notes != null) 'notes': notes,
      'priority': priority.toString().split('.').last,
      'isDone': isDone,
    };
  }

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
}
