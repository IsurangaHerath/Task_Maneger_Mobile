import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../tasks/tasks_screen.dart';
import '../assignments/assignments_screen.dart';
import '../exams/exams_screen.dart';
import '../calendar/calendar_screen.dart';
import '../statistics/statistics_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TasksScreen(),
    AssignmentsScreen(),
    ExamsScreen(),
    CalendarScreen(),
    StatisticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_box_outlined),
            selectedIcon: Icon(Icons.check_box),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Exams',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
      floatingActionButton: _currentIndex < 3
          ? FloatingActionButton(
              onPressed: () {
                if (_currentIndex == 0) {
                  context.go('/home/task/add');
                } else if (_currentIndex == 1) {
                  context.go('/home/assignment/add');
                } else if (_currentIndex == 2) {
                  context.go('/home/exam/add');
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
