import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/exam_model.dart';
import '../repositories/exam_repository.dart';
import '../services/notification_service.dart';

final examRepositoryProvider = Provider<ExamRepository>((ref) {
  return ExamRepository();
});

class ExamNotifier extends StateNotifier<List<ExamModel>> {
  final ExamRepository _repo;
  final NotificationService _notificationService;

  ExamNotifier(this._repo, this._notificationService) : super(_repo.getAll());

  void _reload() => state = _repo.getAll();

  Future<void> addExam(ExamModel exam) async {
    await _repo.add(exam);
    await _scheduleReminder(exam);
    _reload();
  }

  Future<void> updateExam(ExamModel exam) async {
    await _repo.update(exam);
    await _notificationService.cancelNotification(exam.id.hashCode);
    await _scheduleReminder(exam);
    _reload();
  }

  Future<void> deleteExam(String id) async {
    await _notificationService.cancelNotification(id.hashCode);
    await _repo.delete(id);
    _reload();
  }

  Future<void> _scheduleReminder(ExamModel exam) async {
    if (exam.reminderEnabled) {
      final reminderTime = _notificationService.computeReminderTime(
        exam.date, exam.time, exam.reminderMinutes,
      );
      await _notificationService.scheduleExamReminder(
        id: exam.id.hashCode,
        title: '🎓 Exam Reminder',
        body: '${exam.subject} — ${exam.examType}',
        scheduledDate: reminderTime,
      );
    }
  }

  List<ExamModel> get upcoming => _repo.getUpcoming();
  List<ExamModel> get past => _repo.getPast();

  static ExamModel createNew({
    required String subject,
    String examType = 'Final',
    required DateTime date,
    String? time,
    String venue = '',
    String notes = '',
    bool reminderEnabled = false,
    int reminderMinutes = 1440,
  }) {
    return ExamModel(
      id: const Uuid().v4(),
      subject: subject,
      examType: examType,
      date: date,
      time: time,
      venue: venue,
      notes: notes,
      reminderEnabled: reminderEnabled,
      reminderMinutes: reminderMinutes,
    );
  }
}

final examProvider =
    StateNotifierProvider<ExamNotifier, List<ExamModel>>((ref) {
  final repo = ref.read(examRepositoryProvider);
  return ExamNotifier(repo, NotificationService());
});

final upcomingExamsProvider = Provider<List<ExamModel>>((ref) {
  final notifier = ref.watch(examProvider.notifier);
  ref.watch(examProvider);
  return notifier.upcoming;
});
