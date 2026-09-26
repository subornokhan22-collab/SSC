import 'package:flutter/material.dart';

import '../services/local_diagnostics.dart';
import '../theme/app_theme.dart';
import 'app_logo.dart';
import 'motion_policy.dart';

class BootStep {
  final String label;
  final Future<void> Function() run;
  const BootStep(this.label, this.run);
}

/// Paint first, then initialize in dependency order. Completed steps are not
/// repeated on retry; failures never expose partially initialized app routes.
class BootSequence extends StatefulWidget {
  final List<BootStep> steps;
  final Widget child;
  const BootSequence({super.key, required this.steps, required this.child});
  @override
  State<BootSequence> createState() => _BootSequenceState();
}

class _BootSequenceState extends State<BootSequence> {
  int completed = 0;
  bool failed = false;
  bool running = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) start();
    });
  }

  Future<void> start() async {
    if (running) return;
    setState(() {
      failed = false;
      running = true;
    });
    while (mounted && completed < widget.steps.length) {
      try {
        await widget.steps[completed].run();
        if (!mounted) return;
        setState(() => completed++);
      } catch (error, stack) {
        await LocalDiagnostics.record(error, stack, scope: 'startup');
        if (!mounted) return;
        setState(() {
          failed = true;
          running = false;
        });
        return;
      }
    }
    running = false;
  }

  @override
  Widget build(BuildContext context) {
    if (completed == widget.steps.length) return widget.child;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLogo(size: 64),
                  const SizedBox(height: 24),
                  Text('Opening your desk',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  const Text('Your papers, tools and teaching workspace.',
                      style: TextStyle(color: AppTheme.muted)),
                  const SizedBox(height: 24),
                  for (var i = 0; i < widget.steps.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Row(children: [
                        if (i < completed)
                          const Icon(Icons.check_circle_outline,
                              color: AppTheme.success, size: 20)
                        else if (i == completed && !failed)
                          const ActivityIndicator(size: 20)
                        else
                          Icon(
                              i == completed && failed
                                  ? Icons.error_outline
                                  : Icons.circle_outlined,
                              size: 20,
                              color: i == completed && failed
                                  ? AppTheme.danger
                                  : AppTheme.muted),
                        const SizedBox(width: 12),
                        Expanded(child: Text(widget.steps[i].label)),
                      ]),
                    ),
                  Semantics(
                    liveRegion: true,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                          failed
                              ? 'This step could not finish. Your saved data has not been cleared.'
                              : '${completed + 1} of ${widget.steps.length}: ${widget.steps[completed].label}',
                          style: TextStyle(
                              color:
                                  failed ? AppTheme.danger : AppTheme.muted)),
                    ),
                  ),
                  if (failed) ...[
                    const SizedBox(height: 12),
                    FilledButton.icon(
                        onPressed: start,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry opening desk')),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
