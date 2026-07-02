import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const DrifterApp());
}

class DrifterApp extends StatelessWidget {
  const DrifterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drifter',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const SplashScreen(),
    );
  }
}
