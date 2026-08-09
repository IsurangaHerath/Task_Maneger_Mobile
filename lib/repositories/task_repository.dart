import '../models/task_model.dart';
import '../services/hive_service.dart';

class TaskRepository {
  List<TaskModel> getAll() {
    return HiveService.taskBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  TaskModel? getById(String id) {
    try {
      return HiveService.taskBox.values.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> add(TaskModel task) async {
    await HiveService.taskBox.put(task.id, task);
  }

  Future<void> update(TaskModel task) async {
    await HiveService.taskBox.put(task.id, task);
  }

  Future<void> delete(String id) async {
    await HiveService.taskBox.delete(id);
  }

  Future<void> toggleComplete(String id) async {
    final task = getById(id);
    if (task != null) {
      final updated = task.copyWith(isCompleted: !task.isCompleted);
      await update(updated);
    }
  }

  List<TaskModel> getByDate(DateTime date) {
    return HiveService.taskBox.values.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == date.year &&
          t.dueDate!.month == date.month &&
          t.dueDate!.day == date.day;
    }).toList();
  }

  List<TaskModel> getTodayTasks() => getByDate(DateTime.now());

  List<TaskModel> getCompleted() =>
      HiveService.taskBox.values.where((t) => t.isCompleted).toList();

  List<TaskModel> getPending() =>
      HiveService.taskBox.values.where((t) => !t.isCompleted).toList();

  int get completedCount =>
      HiveService.taskBox.values.where((t) => t.isCompleted).length;

  int get pendingCount =>
      HiveService.taskBox.values.where((t) => !t.isCompleted).length;
}
