import '../models/streak_model.dart';
import '../services/hive_service.dart';

class StreakRepository {
  static const String _key = 'streak_data';

  StreakModel getStreak() {
    return HiveService.streakBox.get(_key) ?? StreakModel();
  }

  Future<void> saveStreak(StreakModel streak) async {
    await HiveService.streakBox.put(_key, streak);
  }

  /// Call this whenever the user completes a task.
  Future<StreakModel> recordActivity() async {
    final streak = getStreak();
    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Already recorded today
    if (streak.activityDates.contains(todayKey)) return streak;

    final dates = List<String>.from(streak.activityDates)..add(todayKey);

    // Compute new streak
    int newCurrent;
    final lastActivity = streak.lastActivityDate;
    if (lastActivity == null) {
      newCurrent = 1;
    } else {
      final lastDay = DateTime(lastActivity.year, lastActivity.month, lastActivity.day);
      final today = DateTime(now.year, now.month, now.day);
      final diff = today.difference(lastDay).inDays;
      if (diff == 1) {
        newCurrent = streak.currentStreak + 1;
      } else if (diff == 0) {
        newCurrent = streak.currentStreak;
      } else {
        newCurrent = 1; // Streak broken
      }
    }

    final newLongest =
        newCurrent > streak.longestStreak ? newCurrent : streak.longestStreak;

    final updated = StreakModel(
      currentStreak: newCurrent,
      longestStreak: newLongest,
      lastActivityDate: now,
      activityDates: dates,
      totalTasksCompleted: streak.totalTasksCompleted + 1,
    );

    await saveStreak(updated);
    return updated;
  }

  Future<void> reset() async {
    await HiveService.streakBox.delete(_key);
  }
}
