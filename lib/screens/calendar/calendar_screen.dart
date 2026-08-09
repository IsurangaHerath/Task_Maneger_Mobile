import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../providers/task_provider.dart';
import '../../providers/assignment_provider.dart';
import '../../providers/exam_provider.dart';
import '../../themes/app_theme.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<dynamic> _getEventsForDay(DateTime day, WidgetRef ref) {
    final tasks = ref.read(taskRepositoryProvider).getByDate(day);
    final assignments = ref.read(assignmentRepositoryProvider).getByDate(day);
    final exams = ref.read(examRepositoryProvider).getByDate(day);
    return [...tasks, ...assignments, ...exams];
  }

  @override
  Widget build(BuildContext context) {
    final events = _getEventsForDay(_selectedDay ?? _focusedDay, ref);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) => _getEventsForDay(day, ref),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppTheme.warningColor,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  _selectedDay != null ? DateFormat.yMMMMd().format(_selectedDay!) : 'Events',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text('${events.length} items'),
              ],
            ),
          ),
          Expanded(
            child: events.isEmpty
                ? const Center(child: Text('No events for this day'))
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      IconData icon = Icons.event;
                      Color color = Colors.grey;
                      String title = '';
                      String subtitle = '';

                      if (event.runtimeType.toString() == 'TaskModel') {
                        icon = Icons.check_box;
                        color = AppTheme.successColor;
                        title = event.title;
                        subtitle = 'Task';
                      } else if (event.runtimeType.toString() == 'AssignmentModel') {
                        icon = Icons.assignment;
                        color = AppTheme.warningColor;
                        title = event.title;
                        subtitle = 'Assignment';
                      } else if (event.runtimeType.toString() == 'ExamModel') {
                        icon = Icons.school;
                        color = AppTheme.errorColor;
                        title = event.subject;
                        subtitle = 'Exam';
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.2),
                          child: Icon(icon, color: color),
                        ),
                        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(subtitle),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
