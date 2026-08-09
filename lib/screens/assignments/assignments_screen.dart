import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/assignment_provider.dart';
import '../../models/assignment_model.dart';
import '../../themes/app_theme.dart';

class AssignmentsScreen extends ConsumerWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignments = ref.watch(filteredAssignmentsProvider);
    final filterState = ref.watch(assignmentFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SearchBar(
              hintText: 'Search assignments...',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                ref.read(assignmentFilterProvider.notifier).state =
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
            child: assignments.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: assignments.length,
                    itemBuilder: (context, index) {
                      final assignment = assignments[index];
                      return _AssignmentCard(assignment: assignment);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(WidgetRef ref, AssignmentFilterState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            selected: state.filter == AssignmentFilter.all,
            onSelected: (_) {
              ref.read(assignmentFilterProvider.notifier).state =
                  state.copyWith(filter: AssignmentFilter.all);
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Pending',
            selected: state.filter == AssignmentFilter.pending,
            onSelected: (_) {
              ref.read(assignmentFilterProvider.notifier).state =
                  state.copyWith(filter: AssignmentFilter.pending);
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Submitted',
            selected: state.filter == AssignmentFilter.submitted,
            onSelected: (_) {
              ref.read(assignmentFilterProvider.notifier).state =
                  state.copyWith(filter: AssignmentFilter.submitted);
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
          Icon(Icons.assignment_add, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No assignments yet',
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
      selectedColor: Theme.of(context).colorScheme.tertiaryContainer,
      labelStyle: TextStyle(
        color: selected
            ? Theme.of(context).colorScheme.onTertiaryContainer
            : Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _AssignmentCard extends ConsumerWidget {
  final AssignmentModel assignment;

  const _AssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysLeft = assignment.daysLeft;
    final isOverdue = assignment.isOverdue;

    Color dateColor = Colors.grey.shade600;
    if (!assignment.isSubmitted) {
      if (isOverdue) {
        dateColor = AppTheme.errorColor;
      } else if (daysLeft >= 0 && daysLeft <= 2) {
        dateColor = AppTheme.warningColor;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.go('/home/assignment/edit', extra: assignment),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      assignment.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: assignment.isSubmitted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  _buildStatusBadge(assignment),
                ],
              ),
              if (assignment.courseName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  assignment.courseName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: dateColor),
                  const SizedBox(width: 6),
                  Text(
                    assignment.dueDate != null
                        ? DateFormat.yMMMd().format(assignment.dueDate!)
                        : 'No date',
                    style: TextStyle(color: dateColor, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  if (!assignment.isSubmitted && assignment.dueDate != null)
                    Text(
                      isOverdue
                          ? 'Overdue!'
                          : (daysLeft == 0 ? 'Due Today' : '$daysLeft days left'),
                      style: TextStyle(
                        color: dateColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(assignmentProvider.notifier).toggleSubmitted(assignment.id);
                  },
                  icon: Icon(
                    assignment.isSubmitted ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: assignment.isSubmitted ? AppTheme.successColor : null,
                  ),
                  label: Text(assignment.isSubmitted ? 'Mark as Pending' : 'Mark as Submitted'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AssignmentModel a) {
    if (a.isSubmitted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Submitted', style: TextStyle(color: AppTheme.successColor, fontSize: 12)),
      );
    }
    return const SizedBox();
  }
}
