import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFF04050C);
  static const backgroundGlow = Color(0xFF0B123A);
  static const surface = Color(0xFF0D1024);
  static const surfaceHigh = Color(0xFF161B3A);
  static const royalBlue = Color(0xFF3D5AFE);
  static const royalBlueDeep = Color(0xFF1B2470);
  static const accent = Color(0xFF8B9CFF);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.dark(
    surface: AppColors.surface,
    onSurface: Colors.white,
    surfaceContainerHighest: AppColors.surfaceHigh,
    onSurfaceVariant: Colors.white70,
    primary: AppColors.royalBlue,
    onPrimary: Colors.white,
    primaryContainer: AppColors.royalBlueDeep,
    onPrimaryContainer: Colors.white,
    secondary: AppColors.accent,
    onSecondary: Colors.black,
    outline: AppColors.royalBlue.withValues(alpha: 0.35),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
    ),
    textTheme: ThemeData.dark().textTheme,
  );
}

TextStyle quoteTextStyle(BuildContext context) {
  return GoogleFonts.playfairDisplay(
    fontSize: 26,
    height: 1.35,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w500,
    color: Colors.white.withValues(alpha: 0.92),
  );
}

/// Deep royal-blue-on-black gradient used behind the app's screens.
class ImmersiveBackground extends StatelessWidget {
  final Widget child;

  const ImmersiveBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.6, -0.9),
          radius: 1.6,
          colors: [AppColors.backgroundGlow, AppColors.background],
          stops: [0.0, 0.75],
        ),
      ),
      child: child,
    );
  }
}
