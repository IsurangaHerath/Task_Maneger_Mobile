import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/task_provider.dart';
import '../../providers/assignment_provider.dart';
import '../../providers/streak_provider.dart';
import '../../themes/app_theme.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);
    final assignments = ref.watch(assignmentProvider);
    final streak = ref.watch(streakProvider);

    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final pendingTasks = tasks.where((t) => !t.isCompleted).length;
    
    final submittedAssignments = assignments.where((a) => a.isSubmitted).length;
    final pendingAssignments = assignments.where((a) => !a.isSubmitted).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _StatCard(title: 'Streak', value: '${streak.currentStreak} 🔥', color: Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _StatCard(title: 'Tasks Done', value: '$completedTasks', color: AppTheme.successColor)),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Task Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: tasks.isEmpty
                  ? const Center(child: Text('No task data'))
                  : PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            value: completedTasks.toDouble(),
                            title: '$completedTasks',
                            color: AppTheme.successColor,
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          PieChartSectionData(
                            value: pendingTasks.toDouble(),
                            title: '$pendingTasks',
                            color: AppTheme.warningColor,
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Indicator(color: AppTheme.successColor, text: 'Completed'),
                const SizedBox(width: 16),
                _Indicator(color: AppTheme.warningColor, text: 'Pending'),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Assignment Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: assignments.isEmpty
                  ? const Center(child: Text('No assignment data'))
                  : PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            value: submittedAssignments.toDouble(),
                            title: '$submittedAssignments',
                            color: AppTheme.infoColor,
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          PieChartSectionData(
                            value: pendingAssignments.toDouble(),
                            title: '$pendingAssignments',
                            color: AppTheme.errorColor,
                            radius: 50,
                            titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Indicator(color: AppTheme.infoColor, text: 'Submitted'),
                const SizedBox(width: 16),
                _Indicator(color: AppTheme.errorColor, text: 'Pending'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;

  const _Indicator({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
