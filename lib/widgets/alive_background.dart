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
        builder: (context, _, child) {
          final base = AppStyle.bg;
          final accent = AppStyle.accent;
          return ColoredBox(
            color: base,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _PaperWashPainter(
                  accent,
                  motionAllowed ? motion.value : 0,
                ),
                child: child,
              ),
            ),
          );
        },
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
      accent.withOpacity(.05),
    );
    _wash(
      canvas,
      Offset(size.width * .86 - drift, size.height * .92),
      size.width * .7,
      accent.withOpacity(.035),
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
