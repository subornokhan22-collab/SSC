import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'motion_policy.dart';

/// Slow pastel ribbons for the few places that deserve atmosphere.
///
/// Deliberately opt-in and deliberately rare: sign-in, sign-up, the AI landing
/// and the home hero. The paper editor, the OMR scanner and question reading
/// screens must not use it — a teacher working with text needs a still surface,
/// and every ribbon is a blurred path repainted per frame.
///
/// It is a translucent veil, not a background: the chosen workspace paper and
/// its gradient show straight through, so the preset the teacher picked is
/// never hidden. Motion policy decides whether it moves at all; reduced motion,
/// a hidden tab or a backgrounded app leaves the same static wash with no
/// running controller.
class AuroraRibbons extends StatefulWidget {
  final Widget child;
  final bool enabled;

  /// Overall strength. Keep well below 1 anywhere text sits on top.
  final double opacity;

  const AuroraRibbons({
    super.key,
    required this.child,
    this.enabled = false,
    this.opacity = .6,
  });

  @override
  State<AuroraRibbons> createState() => _AuroraRibbonsState();
}

class _AuroraRibbonsState extends MotionLoopState<AuroraRibbons> {
  @override
  Duration get period => const Duration(seconds: 12);

  @override
  bool get enabled => widget.enabled;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: motion,
        child: widget.child,
        builder: (_, child) => RepaintBoundary(
          child: CustomPaint(
            painter: _AuroraPainter(
              motionAllowed ? motion.value : 0,
              widget.opacity,
            ),
            child: child,
          ),
        ),
      );
}

/// Three ribbons, sampled coarsely. Five blurred bands at 4px steps measured
/// badly on low-end Android for a decorative layer, so the sampling is half as
/// dense and the count is fixed at three.
class _AuroraPainter extends CustomPainter {
  final double t;
  final double opacity;
  const _AuroraPainter(this.t, this.opacity);

  static const _bands = <List<Color>>[
    [Color(0x333157D5), Color(0x553157D5), Color(0x22FFFFFF)],
    [Color(0x2616845B), Color(0x44087F8C), Color(0x22FFFFFF)],
    [Color(0x267C5CE0), Color(0x447C5CE0), Color(0x22FFFFFF)],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final time = t * pi * 2;

    for (var river = 0; river < _bands.length; river++) {
      final baseY = h * (.16 + river * .28);
      final thickness = 54 + sin(time + river) * 12;
      final band = _bands[river];
      final speed = .8 + river * .15;
      final phase = river * 1.3;
      final upper = <Offset>[];
      final lower = <Offset>[];

      for (double x = -18; x <= w + 18; x += 8) {
        final nx = x / w;
        final wave = sin(nx * pi * 2.5 + time * speed + phase) * 34 +
            sin(nx * pi * 4 + time * speed * 1.3 + phase) * 15 +
            cos(nx * pi * 1.5 + time * speed * .7) * 11;
        upper.add(Offset(x, baseY + wave - thickness / 2));
        lower.add(Offset(x, baseY + wave + thickness / 2));
      }

      final riverPath = Path()..moveTo(upper.first.dx, upper.first.dy);
      for (final p in upper) {
        riverPath.lineTo(p.dx, p.dy);
      }
      for (var i = lower.length - 1; i >= 0; i--) {
        riverPath.lineTo(lower[i].dx, lower[i].dy);
      }
      riverPath.close();

      canvas.drawPath(
        riverPath,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, baseY - thickness),
            Offset(0, baseY + thickness),
            [
              _fade(band[2]),
              _fade(band[0]),
              _fade(band[1]),
              _fade(band[0]),
              _fade(band[2]),
            ],
            const [0, .24, .5, .76, 1],
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );

      final highlight = Path();
      for (var i = 0; i < upper.length; i++) {
        final p = Offset(
          (upper[i].dx + lower[i].dx) / 2,
          (upper[i].dy + lower[i].dy) / 2,
        );
        if (i == 0) {
          highlight.moveTo(p.dx, p.dy);
        } else {
          highlight.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(
        highlight,
        Paint()
          ..color = _fade(Colors.white.withOpacity(.55))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
  }

  /// Scales a band colour by the widget's [opacity]. Cheaper than a
  /// [Canvas.saveLayer], which costs a full offscreen buffer per frame.
  Color _fade(Color c) =>
      c.withOpacity((c.opacity * opacity).clamp(0.0, 1.0).toDouble());

  @override
  bool shouldRepaint(covariant _AuroraPainter old) =>
      old.t != t || old.opacity != opacity;
}
