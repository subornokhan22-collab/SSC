import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'animations.dart';
import 'motion_policy.dart';

class WorkflowProgress extends StatelessWidget {
  final List<String> steps;
  final int current;
  const WorkflowProgress(
      {super.key, required this.steps, required this.current});
  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();
    final index = current.clamp(0, steps.length - 1);
    return Semantics(
      liveRegion: true,
      label: 'Step ${index + 1} of ${steps.length}: ${steps[index]}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            for (var i = 0; i < steps.length; i++)
              Expanded(
                  child: Padding(
                padding: EdgeInsets.only(right: i == steps.length - 1 ? 0 : 4),
                child: AnimatedContainer(
                  duration: MotionPolicy.duration(context, 180),
                  height: 5,
                  decoration: BoxDecoration(
                    color: i <= index ? AppTheme.primary : AppTheme.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              )),
          ]),
          const SizedBox(height: 10),
          SoftSwitcher(
            child: Text('${index + 1} / ${steps.length}  •  ${steps[index]}',
                key: ValueKey(index),
                style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
    );
  }
}

/// Displays only controller/server events. No timers, invented stages or
/// simulated percentages; returning from a request alone is not verification.
class OperationNotice extends StatelessWidget {
  final String? error;
  final String? activity;
  final Color accent;
  const OperationNotice(
      {super.key, this.error, this.activity, this.accent = AppTheme.primary});
  @override
  Widget build(BuildContext context) {
    if (error == null && activity == null) return const SizedBox.shrink();
    final color = error == null ? accent : AppTheme.danger;
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(.06),
          border: Border.all(color: color.withOpacity(.16)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (error != null)
            Icon(Icons.info_outline, color: color, size: 20)
          else
            ActivityIndicator(color: color),
          const SizedBox(width: 10),
          Expanded(
              child: SoftSwitcher(
            child: SizedBox(
              key: ValueKey(error ?? activity),
              width: double.infinity,
              child: Text(error ?? activity!),
            ),
          )),
        ]),
      ),
    );
  }
}
