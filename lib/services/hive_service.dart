import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import '../models/assignment_model.dart';
import '../models/exam_model.dart';
import '../models/streak_model.dart';

class HiveService {
  static const String taskBoxName = 'tasks';
  static const String assignmentBoxName = 'assignments';
  static const String examBoxName = 'exams';
  static const String streakBoxName = 'streak';
  static const String settingsBoxName = 'settings';

  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AssignmentModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ExamModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(StreakModelAdapter());
    }

    // Open boxes
    await Hive.openBox<TaskModel>(taskBoxName);
    await Hive.openBox<AssignmentModel>(assignmentBoxName);
    await Hive.openBox<ExamModel>(examBoxName);
    await Hive.openBox<StreakModel>(streakBoxName);
    await Hive.openBox(settingsBoxName);
  }

  static Box<TaskModel> get taskBox => Hive.box<TaskModel>(taskBoxName);
  static Box<AssignmentModel> get assignmentBox =>
      Hive.box<AssignmentModel>(assignmentBoxName);
  static Box<ExamModel> get examBox => Hive.box<ExamModel>(examBoxName);
  static Box<StreakModel> get streakBox =>
      Hive.box<StreakModel>(streakBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);

  static Future<void> clearAll() async {
    await taskBox.clear();
    await assignmentBox.clear();
    await examBox.clear();
    await streakBox.clear();
  }
}
