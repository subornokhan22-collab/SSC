import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Animated pastel-ribbon background for the welcome / sign-in choice page.
///
/// Soft indigo-to-teal bands drift across a paper-white canvas, so the light
/// theme keeps a sense of motion without ever fighting the dark text on top.
class AuroraRibbons extends StatefulWidget {
  final Widget child;
  const AuroraRibbons({super.key, required this.child});

  @override
  State<AuroraRibbons> createState() => _AuroraRibbonsState();
}

class _AuroraRibbonsState extends State<AuroraRibbons>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (_, child) => CustomPaint(
          painter: _AuroraPainter(_controller.value),
          child: child,
        ),
      );
}

class _AuroraPainter extends CustomPainter {
  final double t;
  const _AuroraPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFF7F9FE));
    final w = size.width;
    final h = size.height;
    final time = t * pi * 2;

    // Pastel band palette, cycled per ribbon.
    const bands = <List<Color>>[
      [Color(0x333D5AFE), Color(0x553D5AFE), Color(0x22FFFFFF)],
      [Color(0x2600B8A9), Color(0x4400897B), Color(0x22FFFFFF)],
      [Color(0x267C5CE0), Color(0x447C5CE0), Color(0x22FFFFFF)],
    ];

    for (var river = 0; river < 5; river++) {
      final baseY = h * (.12 + river * .19);
      final thickness = 54 + sin(time + river) * 12;
      final band = bands[river % bands.length];
      final speed = .8 + river * .15;
      final phase = river * 1.3;
      final upper = <Offset>[];
      final lower = <Offset>[];

      for (double x = -18; x <= w + 18; x += 4) {
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

      final gradient = ui.Gradient.linear(
        Offset(0, baseY - thickness),
        Offset(0, baseY + thickness),
        [band[2], band[0], band[1], band[0], band[2]],
        const [0, .24, .5, .76, 1],
      );
      canvas.drawPath(
        riverPath,
        Paint()
          ..shader = gradient
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );

      final highlight = Path();
      for (var i = 0; i < upper.length; i++) {
        final p = Offset(
            (upper[i].dx + lower[i].dx) / 2, (upper[i].dy + lower[i].dy) / 2);
        if (i == 0) {
          highlight.moveTo(p.dx, p.dy);
        } else {
          highlight.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(
          highlight,
          Paint()
            ..color = Colors.white.withOpacity(.55)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
      canvas.drawPath(
          highlight,
          Paint()
            ..color = band[1].withOpacity(.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.15);
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) =>
      oldDelegate.t != t;
}
