import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import '../repositories/streak_repository.dart';
import '../services/notification_service.dart';
import 'package:uuid/uuid.dart';
import 'streak_provider.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return StreakRepository();
});

// Filter & sort state
enum TaskFilter { all, pending, completed, today }
enum TaskSort { newest, oldest, dueDate, priority }

class TaskFilterState {
  final TaskFilter filter;
  final TaskSort sort;
  final String searchQuery;

  const TaskFilterState({
    this.filter = TaskFilter.all,
    this.sort = TaskSort.newest,
    this.searchQuery = '',
  });

  TaskFilterState copyWith({
    TaskFilter? filter,
    TaskSort? sort,
    String? searchQuery,
  }) {
    return TaskFilterState(
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final taskFilterProvider =
    StateProvider<TaskFilterState>((ref) => const TaskFilterState());

class TaskNotifier extends StateNotifier<List<TaskModel>> {
  final TaskRepository _repo;
  final StreakRepository _streakRepo;
  final NotificationService _notificationService;
  final Ref _ref;

  TaskNotifier(this._repo, this._streakRepo, this._notificationService, this._ref)
      : super(_repo.getAll());

  void _reload() {
    state = _repo.getAll();
  }

  Future<void> addTask(TaskModel task) async {
    await _repo.add(task);
    if (task.reminderEnabled && task.dueDate != null) {
      final reminderTime = _notificationService.computeReminderTime(
        task.dueDate!,
        task.dueTime,
        task.reminderMinutes,
      );
      await _notificationService.scheduleTaskReminder(
        id: task.id.hashCode,
        title: '📝 Task Reminder',
        body: task.title,
        scheduledDate: reminderTime,
      );
    }
    _reload();
  }

  Future<void> updateTask(TaskModel task) async {
    await _repo.update(task);
    await _notificationService.cancelNotification(task.id.hashCode);
    if (task.reminderEnabled && task.dueDate != null) {
      final reminderTime = _notificationService.computeReminderTime(
        task.dueDate!,
        task.dueTime,
        task.reminderMinutes,
      );
      await _notificationService.scheduleTaskReminder(
        id: task.id.hashCode,
        title: '📝 Task Reminder',
        body: task.title,
        scheduledDate: reminderTime,
      );
    }
    _reload();
  }

  Future<void> deleteTask(String id) async {
    await _notificationService.cancelNotification(id.hashCode);
    await _repo.delete(id);
    _reload();
  }

  Future<void> toggleComplete(String id) async {
    final task = _repo.getById(id);
    if (task != null && !task.isCompleted) {
      // Recording activity for streak
      final updatedStreak = await _streakRepo.recordActivity();
      _ref.read(streakProvider.notifier).setState(updatedStreak);
    }
    await _repo.toggleComplete(id);
    _reload();
  }

  List<TaskModel> get filteredTasks {
    final filterState = _ref.read(taskFilterProvider);
    List<TaskModel> tasks = List.from(state);

    // Apply search
    if (filterState.searchQuery.isNotEmpty) {
      tasks = tasks.where((t) {
        return t.title
                .toLowerCase()
                .contains(filterState.searchQuery.toLowerCase()) ||
            t.subject
                .toLowerCase()
                .contains(filterState.searchQuery.toLowerCase());
      }).toList();
    }

    // Apply filter
    switch (filterState.filter) {
      case TaskFilter.pending:
        tasks = tasks.where((t) => !t.isCompleted).toList();
        break;
      case TaskFilter.completed:
        tasks = tasks.where((t) => t.isCompleted).toList();
        break;
      case TaskFilter.today:
        tasks = tasks.where((t) => t.isDueToday).toList();
        break;
      case TaskFilter.all:
        break;
    }

    // Apply sort
    switch (filterState.sort) {
      case TaskSort.newest:
        tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TaskSort.oldest:
        tasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case TaskSort.dueDate:
        tasks.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case TaskSort.priority:
        tasks.sort((a, b) => b.priority.compareTo(a.priority));
        break;
    }

    return tasks;
  }

  static TaskModel createNew({
    required String title,
    String description = '',
    String subject = '',
    int priority = 1,
    DateTime? dueDate,
    String? dueTime,
    bool reminderEnabled = false,
    int reminderMinutes = 30,
  }) {
    return TaskModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      subject: subject,
      priority: priority,
      dueDate: dueDate,
      dueTime: dueTime,
      reminderEnabled: reminderEnabled,
      reminderMinutes: reminderMinutes,
    );
  }
}

final taskProvider =
    StateNotifierProvider<TaskNotifier, List<TaskModel>>((ref) {
  final repo = ref.read(taskRepositoryProvider);
  final streakRepo = ref.read(streakRepositoryProvider);
  final notificationService = NotificationService();
  return TaskNotifier(repo, streakRepo, notificationService, ref);
});

final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final notifier = ref.watch(taskProvider.notifier);
  ref.watch(taskProvider);
  ref.watch(taskFilterProvider);
  return notifier.filteredTasks;
});
