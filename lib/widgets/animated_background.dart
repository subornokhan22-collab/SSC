import 'dart:math';
import 'package:flutter/material.dart';

/// Rich animated background: multiple soft glowing blobs drifting slowly
/// plus tiny twinkling particles floating upward.
/// Uses pure CustomPaint + RadialGradient falloff (no maskFilter blur),
/// wrapped in a RepaintBoundary, so it stays smooth on low-end phones.
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
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 70))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF2F7FC),
                  Color(0xFFEAF1F8),
                  Colors.white,
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ScenePainter(_controller.value),
                );
              },
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _ScenePainter extends CustomPainter {
  final double t;
  _ScenePainter(this.t);

  static const _blobs = [
    _Blob(Color(0xFF0D4782), 0.34, 0.00, 0.085),
    _Blob(Color(0xFF10828C), 0.36, 0.22, 0.075),
    _Blob(Color(0xFFFFC107), 0.24, 0.45, 0.080),
    _Blob(Color(0xFF7B4BFF), 0.22, 0.62, 0.050),
    _Blob(Color(0xFF19C2B8), 0.26, 0.80, 0.055),
    _Blob(Color(0xFFFF6FA5), 0.18, 0.90, 0.040),
  ];

  static const int _particleCount = 22;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBlobs(canvas, size);
    _paintParticles(canvas, size);
  }

  void _paintBlobs(Canvas canvas, Size size) {
    for (final blob in _blobs) {
      final angle = 2 * pi * ((t + blob.phase) % 1.0);
      final cx = size.width * (0.5 + 0.38 * cos(angle));
      final cy =
          size.height * (0.24 + 0.26 * sin(angle * 1.15 + blob.phase * 5));
      final radius = size.shortestSide * blob.relativeSize;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            blob.color.withOpacity(blob.opacity),
            blob.color.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));

      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }
  }

  void _paintParticles(Canvas canvas, Size size) {
    final rnd = Random(7); // fixed seed → stable layout
    for (var i = 0; i < _particleCount; i++) {
      final baseX = rnd.nextDouble();
      final baseY = rnd.nextDouble();
      final speed = 0.05 + rnd.nextDouble() * 0.12;
      final dotRadius = 1.2 + rnd.nextDouble() * 2.2;
      final phase = rnd.nextDouble() * 2 * pi;

      // Drift slowly upward and wrap around.
      final y = ((baseY - t * speed) % 1.0) * size.height;
      final x = (baseX + 0.015 * sin(2 * pi * t + phase)) * size.width;

      // Twinkle.
      final twinkle = 0.5 + 0.5 * sin(4 * pi * t + phase);
      final alpha = 0.05 + 0.10 * twinkle;

      final paint = Paint()
        ..color = const Color(0xFF0D4782).withOpacity(alpha);
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
        }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter oldDelegate) =>
      oldDelegate.t != t;
}

class _Blob {
  final Color color;
  final double relativeSize;
  final double phase;
  final double opacity;
  const _Blob(this.color, this.relativeSize, this.phase, this.opacity);
}
