import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Animated black-and-metallic-gold background for the welcome/login choice page.
class MoltenGoldRiver extends StatefulWidget {
  final Widget child;
  const MoltenGoldRiver({super.key, required this.child});

  @override
  State<MoltenGoldRiver> createState() => _MoltenGoldRiverState();
}

class _MoltenGoldRiverState extends State<MoltenGoldRiver>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
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
          painter: _MoltenGoldPainter(_controller.value),
          child: child,
        ),
      );
}

class _MoltenGoldPainter extends CustomPainter {
  final double t;
  const _MoltenGoldPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF030303));
    final w = size.width;
    final h = size.height;
    final time = t * pi * 2;

    for (var river = 0; river < 5; river++) {
      final baseY = h * (.12 + river * .19);
      final thickness = 28 + sin(time + river) * 6;
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
      for (final p in upper) { riverPath.lineTo(p.dx, p.dy); }
      for (var i = lower.length - 1; i >= 0; i--) { riverPath.lineTo(lower[i].dx, lower[i].dy); }
      riverPath.close();

      final gradient = ui.Gradient.linear(
        Offset(0, baseY - thickness), Offset(0, baseY + thickness),
        const [Color(0xFF5B4210), Color(0xFFD4A843), Color(0xFFFFF0A0), Color(0xFFD4A843), Color(0xFF5B4210)],
        const [0, .24, .5, .76, 1],
      );
      canvas.drawPath(riverPath, Paint()..shader = gradient);

      final highlight = Path();
      for (var i = 0; i < upper.length; i++) {
        final p = Offset((upper[i].dx + lower[i].dx) / 2, (upper[i].dy + lower[i].dy) / 2);
        if (i == 0) { highlight.moveTo(p.dx, p.dy); } else { highlight.lineTo(p.dx, p.dy); }
      }
      canvas.drawPath(highlight, Paint()
        ..color = const Color(0xCCFFE880)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      canvas.drawPath(highlight, Paint()
        ..color = const Color(0x99FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.15);
    }
  }

  @override
  bool shouldRepaint(covariant _MoltenGoldPainter oldDelegate) => oldDelegate.t != t;
}
