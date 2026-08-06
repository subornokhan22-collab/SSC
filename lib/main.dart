import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'screens/root_gate.dart';
import 'widgets/animated_background.dart';

Future<void> main() async {
  // Supabase-এর আগে binding দরকার; কনফিগ না থাকলে init নিঃশব্দে skip হবে
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
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
      // লগইন থাকলে ভূমিকা অনুযায়ী হোম, না থাকলে সাইন-ইন/সাইন-আপ পর্দা
      home: const RootGate(),
      // Wraps EVERY screen (tabs and pushed routes alike) with the
      // animated background painted underneath, so nothing needs to
      // remember to add it individually.
      builder: (context, child) => AnimatedBackground(child: child!),
    );
  }
}
