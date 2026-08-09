import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/exam_model.dart';
import '../../providers/exam_provider.dart';
import '../../themes/app_theme.dart';

class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingExams = ref.watch(upcomingExamsProvider);
    final pastExams = ref.watch(examProvider.notifier).past;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exams'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ExamList(exams: upcomingExams, isUpcoming: true),
            _ExamList(exams: pastExams, isUpcoming: false),
          ],
        ),
      ),
    );
  }
}

class _ExamList extends StatelessWidget {
  final List<ExamModel> exams;
  final bool isUpcoming;

  const _ExamList({required this.exams, required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    if (exams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? 'No upcoming exams' : 'No past exams',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        return _ExamCard(exam: exams[index]);
      },
    );
  }
}

class _ExamCard extends StatelessWidget {
  final ExamModel exam;

  const _ExamCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    final daysUntil = exam.daysUntilExam;
    Color dateColor = Colors.grey.shade600;
    
    if (daysUntil >= 0 && daysUntil <= 7) {
      dateColor = AppTheme.errorColor;
    } else if (daysUntil > 7 && daysUntil <= 14) {
      dateColor = AppTheme.warningColor;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.go('/home/exam/edit', extra: exam),
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
                      exam.subject,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      exam.examType,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_month, size: 16, color: dateColor),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat.yMMMMEEEEd().format(exam.date),
                    style: TextStyle(color: dateColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (exam.time != null && exam.time!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      exam.time!,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
              if (exam.venue.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      exam.venue,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              if (daysUntil >= 0)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    daysUntil == 0 ? 'TODAY!' : 'In $daysUntil days',
                    style: TextStyle(
                      color: dateColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
