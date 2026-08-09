import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/home/main_scaffold.dart';
import '../screens/tasks/tasks_screen.dart';
import '../screens/tasks/add_edit_task_screen.dart';
import '../screens/assignments/assignments_screen.dart';
import '../screens/assignments/add_edit_assignment_screen.dart';
import '../screens/exams/exams_screen.dart';
import '../screens/exams/add_edit_exam_screen.dart';
import '../screens/streak/streak_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../models/task_model.dart';
import '../models/assignment_model.dart';
import '../models/exam_model.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainScaffold(),
      routes: [
        GoRoute(
          path: 'task/add',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const AddEditTaskScreen(),
        ),
        GoRoute(
          path: 'task/edit',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final task = state.extra as TaskModel;
            return AddEditTaskScreen(task: task);
          },
        ),
        GoRoute(
          path: 'assignment/add',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const AddEditAssignmentScreen(),
        ),
        GoRoute(
          path: 'assignment/edit',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final assignment = state.extra as AssignmentModel;
            return AddEditAssignmentScreen(assignment: assignment);
          },
        ),
        GoRoute(
          path: 'exam/add',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const AddEditExamScreen(),
        ),
        GoRoute(
          path: 'exam/edit',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final exam = state.extra as ExamModel;
            return AddEditExamScreen(exam: exam);
          },
        ),
        GoRoute(
          path: 'streak',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const StreakScreen(),
        ),
        GoRoute(
          path: 'settings',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
