import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/app_style.dart';
import 'motion_policy.dart';

/// The one workspace backdrop: paper first, atmosphere second.
///
/// Scaffolds are transparent so this is what the teacher actually sees, and it
/// follows the chosen workspace preset instead of ignoring it. The whole app
/// owns exactly one background AnimationController, and it only runs while the
/// workspace is visible, foreground and motion is allowed — reduced motion or
/// background leaves the same static paper, not a hidden frame cost.
class AliveBackground extends StatefulWidget {
  final Widget child;

  /// Slow ambient drift. Turn off for previews/tests that want pure paper.
  final bool drift;

  const AliveBackground({super.key, required this.child, this.drift = true});

  @override
  State<AliveBackground> createState() => _AliveBackgroundState();
}

class _AliveBackgroundState extends MotionLoopState<AliveBackground> {
  @override
  Duration get period => const Duration(seconds: 14);

  @override
  bool get enabled => widget.drift;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: AppStyle.bgIndex,
        builder: (context, _, child) => ValueListenableBuilder<WorkspaceMood>(
          valueListenable: AppStyle.mood,
          // ColorTween is a Tween<Color?>, so the builder is typed nullable and
          // falls back to the current mood colour on the very first frame.
          builder: (context, _, child) => TweenAnimationBuilder<Color?>(
            // ~300ms between areas: enough to read as a move, short enough that
            // rapid tab switching never feels laggy.
            tween: ColorTween(end: AppStyle.moodColor),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: child,
            builder: (context, tint, child) => DecoratedBox(
              decoration: BoxDecoration(gradient: AppStyle.gradient),
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _PaperWashPainter(
                    tint ?? AppStyle.moodColor,
                    motionAllowed ? motion.value : 0,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
          child: child,
        ),
        child: widget.child,
      );
}

/// Two very soft washes. Low alpha keeps long Bengali text crisp and printable;
/// [t] moves them a few percent across one slow loop.
class _PaperWashPainter extends CustomPainter {
  final Color accent;
  final double t;
  const _PaperWashPainter(this.accent, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final drift = math.sin(t * 2 * math.pi) * size.width * .02;
    _wash(
      canvas,
      Offset(size.width * .18 + drift, size.height * .12),
      size.width * .8,
      accent.withOpacity(.075),
    );
    _wash(
      canvas,
      Offset(size.width * .86 - drift, size.height * .92),
      size.width * .7,
      accent.withOpacity(.05),
    );
  }

  void _wash(Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [color, color.withOpacity(0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(covariant _PaperWashPainter old) =>
      old.accent != accent || old.t != t;
}
