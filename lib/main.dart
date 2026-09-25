import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'data/question_bank.dart';
import 'navigation/app_routes.dart';
import 'data/question_sync.dart';
import 'data/english_paper_sync.dart';
import 'data/content_catalog_sync.dart';
import 'services/app_settings.dart';
import 'services/app_style.dart';
import 'services/auth_service.dart';
import 'services/paper_library.dart';
import 'theme/app_theme.dart';
import 'screens/root_gate.dart';
import 'widgets/animated_background.dart';
import 'widgets/offline_banner.dart';

// Set by _readCrashLog(); consumed by _CrashReportGate after the first
// frame so the dialog can use a live navigator.
String? _pendingCrashReport;

Future<void> main() async {
  // Binding must exist before Supabase / preferences are touched.
  // If nothing is configured, initialisation is skipped silently.
  WidgetsFlutterBinding.ensureInitialized();

  // A crash in a single widget should never take the whole app down —
  // show a branded fallback instead of the grey/red error screen.
  ErrorWidget.builder = (details) => _FriendlyErrorView(details: details);

  SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyle);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // The question bank now lives in assets/questions/*.json rather than in
  // Dart source, so it must be read before any screen touches allMCQs.
  await QuestionBank.load();
  // Questions published from the web panel since the last release. The cache
  // read is instant and offline; the network pull happens after startup so
  // nothing waits on it.
  await QuestionSync.loadCache();
  await EnglishPaperSync.loadCache();
  await ContentCatalogSync.loadCache();
  await AppStyle.load();
  await AppSettings.load();
  await AuthService.init();

  // Fresh install (empty library)? Put the tutor's papers back from the
  // automatic backup in the shared Download folder. Silent no-op otherwise.
  unawaited(PaperBackup.tryAutoRestore());

  // Fire-and-forget: errors are swallowed inside refresh().
  unawaited(QuestionSync.refresh());
  unawaited(EnglishPaperSync.refresh());
  unawaited(ContentCatalogSync.refresh());

  // If the previous session ended in an uncaught crash, the native side
  // saved the details — surface them on first frame (see _CrashReportGate).
  _pendingCrashReport = await _readCrashLog();

  runApp(const ALearningApp());
}

/// Reads (and deletes) crash.log written by MainActivity's uncaught
/// exception handler. Returns the report text or null.
Future<String?> _readCrashLog() async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final f = File('\${dir.path}/crash.log');
    if (await f.exists()) {
      final content = (await f.readAsString()).split('---').first.trim();
      try {
        await f.delete();
      } catch (_) {}
      return content.isEmpty ? null : content;
    }
  } catch (_) {}
  return null;
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
      home: const _CrashReportGate(),
      onGenerateRoute: AppRoutes.generate,
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
          child: ConnectivityBanner(
            child: AnimatedBackground(child: child ?? const SizedBox.shrink()),
          ),
        );
      },
    );
  }
}

/// Wraps the app root; if the previous session crashed, shows the saved
/// report once (first frame) so a crash is never silent.
class _CrashReportGate extends StatefulWidget {
  const _CrashReportGate();

  @override
  State<_CrashReportGate> createState() => _CrashReportGateState();
}

class _CrashReportGateState extends State<_CrashReportGate> {
  @override
  void initState() {
    super.initState();
    if (_pendingCrashReport != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showReport());
    }
  }

  void _showReport() {
    if (!mounted) return;
    final report = _pendingCrashReport;
    _pendingCrashReport = null;
    if (report == null) return;
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('The app crashed last time'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'If you were sending a photo, audio or PDF when it closed, '
                'this report is what we need to fix it. Screenshot this '
                'window and send it to the developer.',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3F3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE3B3B3)),
                ),
                child: Text(
                  report,
                  style: const TextStyle(
                    fontSize: 10.5,
                    height: 1.35,
                    fontFamily: 'monospace',
                    color: Color(0xFF7A2020),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const RootGate();
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
              const Icon(
                Icons.build_circle_outlined,
                color: AppTheme.accent,
                size: 44,
              ),
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
                style: TextStyle(
                  color: AppTheme.muted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 14),
                Text(
                  details.exceptionAsString(),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.danger,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
