import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String subject;

  @HiveField(4)
  int priority; // 0=low, 1=medium, 2=high

  @HiveField(5)
  DateTime? dueDate;

  @HiveField(6)
  String? dueTime; // HH:mm

  @HiveField(7)
  bool isCompleted;

  @HiveField(8)
  bool reminderEnabled;

  @HiveField(9)
  int reminderMinutes; // 5, 30, 60, 1440

  @HiveField(10)
  DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    this.subject = '',
    this.priority = 1,
    this.dueDate,
    this.dueTime,
    this.isCompleted = false,
    this.reminderEnabled = false,
    this.reminderMinutes = 30,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? subject,
    int? priority,
    DateTime? dueDate,
    String? dueTime,
    bool? isCompleted,
    bool? reminderEnabled,
    int? reminderMinutes,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get priorityLabel {
    switch (priority) {
      case 0:
        return 'Low';
      case 1:
        return 'Medium';
      case 2:
        return 'High';
      default:
        return 'Medium';
    }
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    return dueDate!.isBefore(DateTime(now.year, now.month, now.day));
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }
}
