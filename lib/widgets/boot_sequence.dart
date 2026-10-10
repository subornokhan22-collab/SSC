import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../services/local_diagnostics.dart';
import 'app_logo.dart';
import 'motion_policy.dart';
import 'app_icon.dart';

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
        unawaited(LocalDiagnostics.record(error, stack, scope: 'startup'));
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
      backgroundColor: Colors.white,
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
                  const Text(
                    'Opening your desk',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your papers, tools and teaching workspace.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  for (var i = 0; i < widget.steps.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Row(children: [
                        if (i < completed)
                          const AppIcon(PhosphorIcons.checkCircle,
                              color: Colors.black, size: 20)
                        else if (i == completed && !failed)
                          const ActivityIndicator(size: 20, color: Colors.black)
                        else
                          AppIcon(
                              i == completed && failed
                                  ? PhosphorIcons.warningCircle
                                  : PhosphorIcons.circle,
                              size: 20,
                              color: Colors.grey),
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
                          style: const TextStyle(color: Colors.grey)),
                    ),
                  ),
                  if (failed) ...[
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: start,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      icon: const AppIcon(PhosphorIcons.arrowClockwise),
                      label: const Text('Retry opening desk'),
                    ),
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
