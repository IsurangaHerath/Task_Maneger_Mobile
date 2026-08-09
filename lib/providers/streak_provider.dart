import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/streak_model.dart';
import '../repositories/streak_repository.dart';

final streakProvider =
    StateNotifierProvider<StreakNotifier, StreakModel>((ref) {
  final repo = StreakRepository();
  return StreakNotifier(repo);
});

class StreakNotifier extends StateNotifier<StreakModel> {
  final StreakRepository _repo;

  StreakNotifier(this._repo) : super(_repo.getStreak());

  void setState(StreakModel streak) {
    state = streak;
  }

  Future<void> recordActivity() async {
    final updated = await _repo.recordActivity();
    state = updated;
  }

  Future<void> refresh() async {
    state = _repo.getStreak();
  }

  Future<void> reset() async {
    await _repo.reset();
    state = StreakModel();
  }
}
