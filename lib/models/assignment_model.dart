import 'package:hive/hive.dart';

part 'assignment_model.g.dart';

@HiveType(typeId: 1)
class AssignmentModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String courseName;

  @HiveField(3)
  String description;

  @HiveField(4)
  DateTime? dueDate;

  @HiveField(5)
  String? dueTime;

  @HiveField(6)
  int priority; // 0=low, 1=medium, 2=high

  @HiveField(7)
  bool isSubmitted;

  @HiveField(8)
  double? marksObtained;

  @HiveField(9)
  double? totalMarks;

  @HiveField(10)
  bool reminderEnabled;

  @HiveField(11)
  int reminderMinutes;

  @HiveField(12)
  DateTime createdAt;

  AssignmentModel({
    required this.id,
    required this.title,
    this.courseName = '',
    this.description = '',
    this.dueDate,
    this.dueTime,
    this.priority = 1,
    this.isSubmitted = false,
    this.marksObtained,
    this.totalMarks,
    this.reminderEnabled = false,
    this.reminderMinutes = 30,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  AssignmentModel copyWith({
    String? id,
    String? title,
    String? courseName,
    String? description,
    DateTime? dueDate,
    String? dueTime,
    int? priority,
    bool? isSubmitted,
    double? marksObtained,
    double? totalMarks,
    bool? reminderEnabled,
    int? reminderMinutes,
    DateTime? createdAt,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      courseName: courseName ?? this.courseName,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      priority: priority ?? this.priority,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      marksObtained: marksObtained ?? this.marksObtained,
      totalMarks: totalMarks ?? this.totalMarks,
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

  int get daysLeft {
    if (dueDate == null) return -1;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.difference(today).inDays;
  }

  double get progressPercentage {
    if (marksObtained == null || totalMarks == null || totalMarks == 0) {
      return 0;
    }
    return (marksObtained! / totalMarks!).clamp(0.0, 1.0);
  }

  bool get isOverdue {
    if (dueDate == null || isSubmitted) return false;
    final now = DateTime.now();
    return dueDate!.isBefore(DateTime(now.year, now.month, now.day));
  }
}
