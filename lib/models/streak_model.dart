import 'package:hive/hive.dart';

part 'streak_model.g.dart';

@HiveType(typeId: 3)
class StreakModel extends HiveObject {
  @HiveField(0)
  int currentStreak;

  @HiveField(1)
  int longestStreak;

  @HiveField(2)
  DateTime? lastActivityDate;

  @HiveField(3)
  List<String> activityDates; // ISO date strings 'yyyy-MM-dd'

  @HiveField(4)
  int totalTasksCompleted;

  StreakModel({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivityDate,
    List<String>? activityDates,
    this.totalTasksCompleted = 0,
  }) : activityDates = activityDates ?? [];

  String get badgeLevel {
    if (currentStreak >= 30) return 'Platinum';
    if (currentStreak >= 14) return 'Gold';
    if (currentStreak >= 7) return 'Silver';
    if (currentStreak >= 3) return 'Bronze';
    return 'Starter';
  }

  String get badgeEmoji {
    switch (badgeLevel) {
      case 'Platinum':
        return '💎';
      case 'Gold':
        return '🥇';
      case 'Silver':
        return '🥈';
      case 'Bronze':
        return '🥉';
      default:
        return '⭐';
    }
  }

  int get nextBadgeAt {
    if (currentStreak < 3) return 3;
    if (currentStreak < 7) return 7;
    if (currentStreak < 14) return 14;
    if (currentStreak < 30) return 30;
    return 30;
  }

  List<bool> get last7DaysActivity {
    final result = List<bool>.filled(7, false);
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: 6 - i));
      final key =
          '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      result[i] = activityDates.contains(key);
    }
    return result;
  }

  StreakModel copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    List<String>? activityDates,
    int? totalTasksCompleted,
  }) {
    return StreakModel(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      activityDates: activityDates ?? this.activityDates,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
    );
  }
}
