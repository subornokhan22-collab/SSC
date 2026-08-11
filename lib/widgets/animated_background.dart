import 'dart:math';
import 'package:flutter/material.dart';

/// Low-cost premium background: deep navy, slow gold aura and fine particles.
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 55))..repeat();
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Stack(children: [
    const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF080A0F), Color(0xFF101521), Color(0xFF090B11)]),
    ))),
    Positioned.fill(child: RepaintBoundary(child: AnimatedBuilder(
      animation: _controller, builder: (_, __) => CustomPaint(painter: _PremiumScene(_controller.value)),
    ))),
    widget.child,
  ]);
}

class _PremiumScene extends CustomPainter {
  final double t;
  const _PremiumScene(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final a = 2 * pi * t;
    void glow(Offset p, double radius, Color c, double opacity) {
      final paint = Paint()..shader = RadialGradient(colors: [c.withOpacity(opacity), c.withOpacity(0)])
        .createShader(Rect.fromCircle(center: p, radius: radius));
      canvas.drawCircle(p, radius, paint);
    }
    glow(Offset(size.width * (.72 + .14 * cos(a)), size.height * (.10 + .08 * sin(a))), size.width * .55, const Color(0xFFD4A72C), .13);
    glow(Offset(size.width * (.15 + .08 * sin(a * .8)), size.height * (.72 + .12 * cos(a))), size.width * .48, const Color(0xFF243A66), .35);
    final r = Random(42);
    for (var i = 0; i < 28; i++) {
      final x = r.nextDouble() * size.width;
      final y = ((r.nextDouble() - t * (.035 + r.nextDouble() * .05)) % 1) * size.height;
      final alpha = .03 + .09 * (sin(a * 2 + i) + 1) / 2;
      canvas.drawCircle(Offset(x, y), .7 + r.nextDouble() * 1.7, Paint()..color = const Color(0xFFFFD86B).withOpacity(alpha));
    }
  }
  @override bool shouldRepaint(covariant _PremiumScene old) => old.t != t;
}
