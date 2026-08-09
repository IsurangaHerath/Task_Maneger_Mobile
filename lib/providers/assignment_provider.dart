import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/assignment_model.dart';
import '../repositories/assignment_repository.dart';
import '../services/notification_service.dart';

final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) {
  return AssignmentRepository();
});

enum AssignmentFilter { all, pending, submitted, overdue }
enum AssignmentSort { newest, dueDate, priority }

class AssignmentFilterState {
  final AssignmentFilter filter;
  final AssignmentSort sort;
  final String searchQuery;

  const AssignmentFilterState({
    this.filter = AssignmentFilter.all,
    this.sort = AssignmentSort.dueDate,
    this.searchQuery = '',
  });

  AssignmentFilterState copyWith({
    AssignmentFilter? filter,
    AssignmentSort? sort,
    String? searchQuery,
  }) {
    return AssignmentFilterState(
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final assignmentFilterProvider =
    StateProvider<AssignmentFilterState>((ref) => const AssignmentFilterState());

class AssignmentNotifier extends StateNotifier<List<AssignmentModel>> {
  final AssignmentRepository _repo;
  final NotificationService _notificationService;
  final Ref _ref;

  AssignmentNotifier(this._repo, this._notificationService, this._ref)
      : super(_repo.getAll());

  void _reload() => state = _repo.getAll();

  Future<void> addAssignment(AssignmentModel assignment) async {
    await _repo.add(assignment);
    await _scheduleReminder(assignment);
    _reload();
  }

  Future<void> updateAssignment(AssignmentModel assignment) async {
    await _repo.update(assignment);
    await _notificationService.cancelNotification(assignment.id.hashCode);
    await _scheduleReminder(assignment);
    _reload();
  }

  Future<void> deleteAssignment(String id) async {
    await _notificationService.cancelNotification(id.hashCode);
    await _repo.delete(id);
    _reload();
  }

  Future<void> toggleSubmitted(String id) async {
    await _repo.toggleSubmitted(id);
    _reload();
  }

  Future<void> _scheduleReminder(AssignmentModel a) async {
    if (a.reminderEnabled && a.dueDate != null) {
      final reminderTime = _notificationService.computeReminderTime(
        a.dueDate!, a.dueTime, a.reminderMinutes,
      );
      await _notificationService.scheduleAssignmentReminder(
        id: a.id.hashCode,
        title: '📚 Assignment Due Soon',
        body: '${a.title} — ${a.courseName}',
        scheduledDate: reminderTime,
      );
    }
  }

  List<AssignmentModel> get filteredAssignments {
    final filterState = _ref.read(assignmentFilterProvider);
    List<AssignmentModel> list = List.from(state);

    if (filterState.searchQuery.isNotEmpty) {
      list = list
          .where((a) =>
              a.title.toLowerCase().contains(filterState.searchQuery.toLowerCase()) ||
              a.courseName.toLowerCase().contains(filterState.searchQuery.toLowerCase()))
          .toList();
    }

    switch (filterState.filter) {
      case AssignmentFilter.pending:
        list = list.where((a) => !a.isSubmitted).toList();
        break;
      case AssignmentFilter.submitted:
        list = list.where((a) => a.isSubmitted).toList();
        break;
      case AssignmentFilter.overdue:
        list = list.where((a) => a.isOverdue).toList();
        break;
      case AssignmentFilter.all:
        break;
    }

    switch (filterState.sort) {
      case AssignmentSort.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case AssignmentSort.dueDate:
        list.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case AssignmentSort.priority:
        list.sort((a, b) => b.priority.compareTo(a.priority));
        break;
    }

    return list;
  }

  static AssignmentModel createNew({
    required String title,
    String courseName = '',
    String description = '',
    DateTime? dueDate,
    String? dueTime,
    int priority = 1,
    double? totalMarks,
    bool reminderEnabled = false,
    int reminderMinutes = 30,
  }) {
    return AssignmentModel(
      id: const Uuid().v4(),
      title: title,
      courseName: courseName,
      description: description,
      dueDate: dueDate,
      dueTime: dueTime,
      priority: priority,
      totalMarks: totalMarks,
      reminderEnabled: reminderEnabled,
      reminderMinutes: reminderMinutes,
    );
  }
}

final assignmentProvider =
    StateNotifierProvider<AssignmentNotifier, List<AssignmentModel>>((ref) {
  final repo = ref.read(assignmentRepositoryProvider);
  return AssignmentNotifier(repo, NotificationService(), ref);
});

final filteredAssignmentsProvider = Provider<List<AssignmentModel>>((ref) {
  final notifier = ref.watch(assignmentProvider.notifier);
  ref.watch(assignmentProvider);
  ref.watch(assignmentFilterProvider);
  return notifier.filteredAssignments;
});
