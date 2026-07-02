import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';
import '../utils/page_transitions.dart';
import 'checkin_screen.dart';
import 'home_screen.dart';

/// A brief custom splash shown right after Android's own system splash.
/// The OS-level splash icon is size-capped by the platform regardless of
/// source image padding, so this is where the mark actually gets to be big.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _proceed();
  }

  Future<void> _proceed() async {
    final results = await Future.wait([
      _hasTodayIdentity(),
      Future.delayed(const Duration(milliseconds: 700)),
    ]);
    final hasIdentity = results[0] as bool;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      immersiveRoute(
        hasIdentity ? const CheckInScreen() : const HomeScreen(),
      ),
    );
  }

  Future<bool> _hasTodayIdentity() async {
    try {
      final entry = await DatabaseHelper.instance.getEntryForDate(todayKey());
      return entry.identity != null;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: ImmersiveBackground(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.92 + 0.08 * value,
                  child: child,
                ),
              );
            },
            child: Image.asset(
              'assets/splash_icon.png',
              width: width * 0.52,
            ),
          ),
        ),
      ),
    );
  }
}
