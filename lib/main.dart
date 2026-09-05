import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/question_bank.dart';
import 'data/question_sync.dart';
import 'services/app_style.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'screens/root_gate.dart';
import 'widgets/animated_background.dart';

Future<void> main() async {
  // Binding must exist before Supabase / preferences are touched.
  // If nothing is configured, initialisation is skipped silently.
  WidgetsFlutterBinding.ensureInitialized();

  // A crash in a single widget should never take the whole app down —
  // show a branded fallback instead of the grey/red error screen.
  ErrorWidget.builder = (details) => _FriendlyErrorView(details: details);

  SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyle);
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  // The question bank now lives in assets/questions/*.json rather than in
  // Dart source, so it must be read before any screen touches allMCQs.
  await QuestionBank.load();
  // Questions published from the web panel since the last release. The cache
  // read is instant and offline; the network pull happens after startup so
  // nothing waits on it.
  await QuestionSync.loadCache();
  await AppStyle.load();
  await AuthService.init();

  // Fire-and-forget: errors are swallowed inside refresh().
  unawaited(QuestionSync.refresh());

  runApp(const ALearningApp());
}

class ALearningApp extends StatelessWidget {
  const ALearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Tutor's Desk",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      home: const RootGate(),
      // Every screen (pushed routes included) sits on the animated backdrop,
      // and text never scales past a readable size on large-font devices.
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.25,
            ),
          ),
          child: AnimatedBackground(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}

/// Replaces Flutter's default red error box with a calm, on-brand card.
class _FriendlyErrorView extends StatelessWidget {
  final FlutterErrorDetails details;
  const _FriendlyErrorView({required this.details});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.canvas,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.build_circle_outlined,
                  color: AppTheme.accent, size: 44),
              const SizedBox(height: 14),
              const Text(
                'Something did not load correctly',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please go back and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.muted, fontSize: 13, height: 1.5),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 14),
                Text(
                  details.exceptionAsString(),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppTheme.danger, fontSize: 11, height: 1.4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
