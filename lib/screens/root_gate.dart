import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'auth_choice_screen.dart';
import 'main_home_screen.dart';
import 'teacher_home_screen.dart';

/// অ্যাপ চালুর "দারোয়ান" —
///  • লগইন নেই → সাইন-ইন/সাইন-আপ পর্দা
///  • শিক্ষক  → কালো-সোনালি টিউটর হোম
///  • শিক্ষার্থী → আগের ছাত্র-হোম
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AuthService.ready || !AuthService.isLoggedIn) {
      return const AuthChoiceScreen();
    }
    return FutureBuilder<String?>(
      future: AuthService.role(refresh: true),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppTheme.primary),
                  const SizedBox(height: 14),
                  const Text('প্রোফাইল লোড হচ্ছে...'),
                ],
              ),
            ),
          );
        }
        if (snap.data == 'teacher') return const TeacherHomeScreen();
        return const MainHomeScreen();
      },
    );
  }

  /// লগইন/লগআউটের পর গেটে ফেরার সবচেয়ে নিরাপদ পথ
  static void restart(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RootGate()),
      (_) => false,
    );
  }
}
