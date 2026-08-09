import '../models/exam_model.dart';
import '../services/hive_service.dart';

class ExamRepository {
  List<ExamModel> getAll() {
    return HiveService.examBox.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  ExamModel? getById(String id) {
    try {
      return HiveService.examBox.values.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> add(ExamModel exam) async {
    await HiveService.examBox.put(exam.id, exam);
  }

  Future<void> update(ExamModel exam) async {
    await HiveService.examBox.put(exam.id, exam);
  }

  Future<void> delete(String id) async {
    await HiveService.examBox.delete(id);
  }

  List<ExamModel> getUpcoming() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return HiveService.examBox.values
        .where((e) => !e.date.isBefore(today))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<ExamModel> getPast() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return HiveService.examBox.values
        .where((e) => e.date.isBefore(today))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<ExamModel> getByDate(DateTime date) {
    return HiveService.examBox.values.where((e) {
      return e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day;
    }).toList();
  }

  int get upcomingCount => getUpcoming().length;
}
