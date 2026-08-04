import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'widgets/animated_gradient_background.dart';

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
      // flowing gradient background painted underneath.
      builder: (context, child) => AnimatedGradientBackground(
        duration: const Duration(seconds: 7),
        softWash: true, // পূর্ণ রঙিন ব্যাকগ্রাউন্ড চাইলে false করো
        child: child!,
      ),
    );
  }
}
