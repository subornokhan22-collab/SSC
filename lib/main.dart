import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'widgets/animated_background.dart';

void main() {
  runApp(const ALearningApp());
}

class ALearningApp extends StatelessWidget {
  const ALearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A-Learning',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SplashScreen(),
      // Wraps EVERY screen (tabs and pushed routes alike) with the
      // animated background painted underneath, so nothing needs to
      // remember to add it individually.
      builder: (context, child) => AnimatedBackground(child: child!),
    );
  }
}
