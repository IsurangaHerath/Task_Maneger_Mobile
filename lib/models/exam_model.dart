import 'package:hive/hive.dart';

part 'exam_model.g.dart';

@HiveType(typeId: 2)
class ExamModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String subject;

  @HiveField(2)
  String examType;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String? time;

  @HiveField(5)
  String venue;

  @HiveField(6)
  String notes;

  @HiveField(7)
  bool reminderEnabled;

  @HiveField(8)
  int reminderMinutes;

  @HiveField(9)
  DateTime createdAt;

  ExamModel({
    required this.id,
    required this.subject,
    this.examType = 'Final',
    required this.date,
    this.time,
    this.venue = '',
    this.notes = '',
    this.reminderEnabled = false,
    this.reminderMinutes = 1440,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ExamModel copyWith({
    String? id,
    String? subject,
    String? examType,
    DateTime? date,
    String? time,
    String? venue,
    String? notes,
    bool? reminderEnabled,
    int? reminderMinutes,
    DateTime? createdAt,
  }) {
    return ExamModel(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      examType: examType ?? this.examType,
      date: date ?? this.date,
      time: time ?? this.time,
      venue: venue ?? this.venue,
      notes: notes ?? this.notes,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  int get daysUntilExam {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final examDay = DateTime(date.year, date.month, date.day);
    return examDay.difference(today).inDays;
  }

  bool get isUpcoming => daysUntilExam >= 0;
  bool get isPast => daysUntilExam < 0;
  bool get isToday => daysUntilExam == 0;

  static const List<String> examTypes = [
    'Midterm',
    'Final',
    'Quiz',
    'Practical',
    'Oral',
    'Assignment',
    'Project',
    'Other',
  ];
}
