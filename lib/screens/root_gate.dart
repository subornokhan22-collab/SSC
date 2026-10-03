import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/subscription_state.dart';
import '../widgets/animations.dart';
import 'auth_choice_screen.dart';
import 'teacher_home_screen.dart';
import '../widgets/app_logo.dart';
import '../widgets/motion_policy.dart';

/// App gatekeeper —
///  • not signed in → welcome / sign-in screen
///  • signed in     → the teacher (tutor) portal
///
/// Tutor's Desk is a teacher-only product, so there is no role branching:
/// every authenticated account lands in the tutor workspace.
class RootGate extends StatefulWidget {
  const RootGate({super.key});

  @override
  State<RootGate> createState() => _RootGateState();

  /// Safest way back to the gate after signing in or out — clears the whole
  /// navigation stack so no authenticated screen stays behind.
  static void restart(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RootGate()),
      (_) => false,
    );
  }
}

class _RootGateState extends State<RootGate> {
  late Future<bool> _boot;

  @override
  void initState() {
    super.initState();
    _boot = _prepare();
  }

  /// Warms up the profile/Pro state before showing the workspace so the
  /// home screen never flickers between logged-out and logged-in states.
  Future<bool> _prepare() async {
    if (!AuthService.ready || !AuthService.isLoggedIn) {
      SubscriptionState.instance.clear();
      return false;
    }
    try {
      await AuthService.ensureTeacherProfile();
      // Cached entitlements are loaded before the first workspace frame. The
      // server refresh runs reactively and never holds the app at the splash.
      await SubscriptionState.instance.initialize(refresh: false);
      unawaited(SubscriptionState.instance.refresh());
    } catch (_) {
      // Offline / slow network — cached entitlement and banked questions still
      // work, while the view model can refresh when connectivity returns.
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _boot,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _BootSplash();
        }
        return SoftSwitcher(
          duration: const Duration(milliseconds: 420),
          child: snap.data == true
              ? const TeacherHomeScreen(key: ValueKey('teacher'))
              : const AuthChoiceScreen(key: ValueKey('auth')),
        );
      },
    );
  }
}

/// A short functional loading state, without a perpetual decorative animation.
class _BootSplash extends StatelessWidget {
  const _BootSplash();
  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLogo(size: 64),
              SizedBox(height: 24),
              Text(
                "Tutor’s Desk",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 20),
              ActivityIndicator(size: 24, color: Colors.black),
              SizedBox(height: 12),
              Text(
                'Opening your workspace…',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
}
