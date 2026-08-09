import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import '../../themes/app_theme.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(filteredTasksProvider);
    final filterState = ref.watch(taskFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.stars_rounded),
            onPressed: () => context.go('/home/streak'),
            tooltip: 'Study Streak',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/home/settings'),
            tooltip: 'Settings',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SearchBar(
              hintText: 'Search tasks...',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                ref.read(taskFilterProvider.notifier).state = 
                    filterState.copyWith(searchQuery: value);
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(ref, filterState),
          Expanded(
            child: tasks.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _TaskCard(task: task);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(WidgetRef ref, TaskFilterState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            selected: state.filter == TaskFilter.all,
            onSelected: (_) {
              ref.read(taskFilterProvider.notifier).state =
                  state.copyWith(filter: TaskFilter.all);
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Pending',
            selected: state.filter == TaskFilter.pending,
            onSelected: (_) {
              ref.read(taskFilterProvider.notifier).state =
                  state.copyWith(filter: TaskFilter.pending);
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Completed',
            selected: state.filter == TaskFilter.completed,
            onSelected: (_) {
              ref.read(taskFilterProvider.notifier).state =
                  state.copyWith(filter: TaskFilter.completed);
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Today',
            selected: state.filter == TaskFilter.today,
            onSelected: (_) {
              ref.read(taskFilterProvider.notifier).state =
                  state.copyWith(filter: TaskFilter.today);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No tasks found',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: selected
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _TaskCard extends ConsumerWidget {
  final TaskModel task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color priorityColor = task.priority == 2
        ? AppTheme.highPriority
        : (task.priority == 1 ? AppTheme.mediumPriority : AppTheme.lowPriority);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.go('/home/task/edit', extra: task),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: (_) {
                  ref.read(taskProvider.notifier).toggleComplete(task.id);
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (task.subject.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.subject,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    if (task.dueDate != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: task.isOverdue ? AppTheme.errorColor : Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat.yMMMd().format(task.dueDate!),
                            style: TextStyle(
                              fontSize: 12,
                              color: task.isOverdue ? AppTheme.errorColor : Colors.grey.shade600,
                              fontWeight: task.isOverdue ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (task.dueTime != null && task.dueTime!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              task.dueTime!,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ]
                        ],
                      ),
                    ]
                  ],
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: priorityColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
