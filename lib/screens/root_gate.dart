import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import 'auth_choice_screen.dart';
import 'teacher_home_screen.dart';
import '../widgets/app_logo.dart';
import '../services/connectivity_service.dart';
import '../widgets/offline_dialog.dart';

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
    _checkOfflineOnOpen();
  }

  /// App-open page: if the app is opened with no internet, show the
  /// red offline error once. The global banner covers the session
  /// afterwards (and re-appears if the connection drops later).
  Future<void> _checkOfflineOnOpen() async {
    await ConnectivityService.instance.refresh();
    if (!mounted || ConnectivityService.instance.isOnline) return;
    await showOfflineDialog(context);
  }

  /// Warms up the profile/Pro state before showing the workspace so the
  /// home screen never flickers between logged-out and logged-in states.
  Future<bool> _prepare() async {
    if (!AuthService.ready || !AuthService.isLoggedIn) return false;
    Future<void> bootSync() async {
      await AuthService.ensureTeacherProfile();
      await AuthService.syncProFromServer();
    }
    try {
      // Hard cap: a dead network must never hold the boot screen — the
      // profile sync gets 8 seconds, then the app opens with local state.
      await bootSync().timeout(const Duration(seconds: 8));
    } catch (_) {
      // Offline / slow network — the local Pro flag and banked questions
      // still work.
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

/// Branded loading state shown while the session is restored.
class _BootSplash extends StatelessWidget {
  const _BootSplash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 104,
              height: 104,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const HaloRing(size: 104, strokeWidth: 2.6),
                  Pulse(
                    min: .92,
                    max: 1.08,
                    period: const Duration(milliseconds: 1400),
                    child: const AppLogo(size: 72),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FadeSlideIn(
              delay: const Duration(milliseconds: 120),
              child: const Text(
                "Tutor's Desk",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            const SizedBox(height: 6),
            FadeSlideIn(
              delay: const Duration(milliseconds: 240),
              child: const Text(
                'Preparing your tutor workspace...',
                style: TextStyle(fontSize: 12.8, color: AppTheme.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
