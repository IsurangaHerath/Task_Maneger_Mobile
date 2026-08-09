import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/streak_provider.dart';

class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);
    final last7Days = streak.last7DaysActivity;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Study Streak')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text('Current Streak', style: TextStyle(color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 48)),
                      const SizedBox(width: 8),
                      Text(
                        '${streak.currentStreak}',
                        style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Text('days', style: TextStyle(color: Colors.white, fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Longest: ${streak.longestStreak} days', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Current Badge', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Text(streak.badgeEmoji, style: const TextStyle(fontSize: 48)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${streak.badgeLevel} Tier', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Next badge at ${streak.nextBadgeAt} days'),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Last 7 Days', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final dayDate = now.subtract(Duration(days: 6 - index));
                final dayName = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][dayDate.weekday - 1];
                final isActive = last7Days[index];

                return Column(
                  children: [
                    Text(dayName, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? Colors.orange : Colors.grey.shade200,
                      ),
                      child: isActive ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
