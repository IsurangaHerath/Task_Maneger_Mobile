import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.school_rounded,
              size: 100,
              color: Colors.white,
            )
            .animate()
            .scale(duration: 500.ms, curve: Curves.easeOutBack)
            .fadeIn(),
            const SizedBox(height: 24),
            const Text(
              'Study Planner',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            )
            .animate()
            .slideY(begin: 0.5, end: 0, duration: 500.ms, curve: Curves.easeOut)
            .fadeIn(),
            const SizedBox(height: 8),
            const Text(
              'Organize your academic life',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            )
            .animate()
            .slideY(begin: 0.5, end: 0, duration: 500.ms, delay: 200.ms, curve: Curves.easeOut)
            .fadeIn(),
          ],
        ),
      ),
    );
  }
}
