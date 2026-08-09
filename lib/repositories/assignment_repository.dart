import '../models/assignment_model.dart';
import '../services/hive_service.dart';

class AssignmentRepository {
  List<AssignmentModel> getAll() {
    return HiveService.assignmentBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  AssignmentModel? getById(String id) {
    try {
      return HiveService.assignmentBox.values.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> add(AssignmentModel assignment) async {
    await HiveService.assignmentBox.put(assignment.id, assignment);
  }

  Future<void> update(AssignmentModel assignment) async {
    await HiveService.assignmentBox.put(assignment.id, assignment);
  }

  Future<void> delete(String id) async {
    await HiveService.assignmentBox.delete(id);
  }

  Future<void> toggleSubmitted(String id) async {
    final assignment = getById(id);
    if (assignment != null) {
      final updated = assignment.copyWith(isSubmitted: !assignment.isSubmitted);
      await update(updated);
    }
  }

  List<AssignmentModel> getUpcoming() {
    final now = DateTime.now();
    return HiveService.assignmentBox.values
        .where((a) => !a.isSubmitted && a.dueDate != null && a.dueDate!.isAfter(now))
        .toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  }

  List<AssignmentModel> getByDate(DateTime date) {
    return HiveService.assignmentBox.values.where((a) {
      if (a.dueDate == null) return false;
      return a.dueDate!.year == date.year &&
          a.dueDate!.month == date.month &&
          a.dueDate!.day == date.day;
    }).toList();
  }

  int get submittedCount =>
      HiveService.assignmentBox.values.where((a) => a.isSubmitted).length;

  int get pendingCount =>
      HiveService.assignmentBox.values.where((a) => !a.isSubmitted).length;
}
