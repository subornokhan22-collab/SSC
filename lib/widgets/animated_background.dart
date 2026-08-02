import 'dart:math';
import 'package:flutter/material.dart';

/// High-end animated background: layered glowing blobs with blur,
/// independent motion per blob, plus a subtle drifting particle field.
/// This paints the app's actual background, so screens should use a
/// transparent Scaffold background (handled globally via AppTheme).
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 40))
      ..repeat();

    final rnd = Random(7);
    _particles = List.generate(28, (i) {
      return _Particle(
        dx: rnd.nextDouble(),
        dy: rnd.nextDouble(),
        speed: 0.05 + rnd.nextDouble() * 0.12,
        radius: 1.5 + rnd.nextDouble() * 2.5,
        phase: rnd.nextDouble(),
        opacity: 0.15 + rnd.nextDouble() * 0.35,
      );
    });
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
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF3F7FB),
                  const Color(0xFFEDF3F7),
                  Colors.white,
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _MotionPainter(_controller.value, _particles),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Particle {
  final double dx, dy, speed, radius, phase, opacity;
  _Particle({
    required this.dx,
    required this.dy,
    required this.speed,
    required this.radius,
    required this.phase,
    required this.opacity,
  });
}

class _MotionPainter extends CustomPainter {
  final double t;
  final List<_Particle> particles;
  _MotionPainter(this.t, this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final blobs = [
      _Blob(const Color(0xFF0D4782), 0.30, 0.00, 0.55, 1.0),
      _Blob(const Color(0xFF10828C), 0.34, 0.28, 0.42, 1.3),
      _Blob(const Color(0xFFFFC107), 0.20, 0.55, 0.30, 0.8),
      _Blob(const Color(0xFF6A5ACD), 0.24, 0.78, 0.38, 1.15),
    ];

    for (final blob in blobs) {
      final angle = 2 * pi * ((t * blob.speedMul + blob.phase) % 1.0);
      final cx = size.width * (0.5 + 0.38 * cos(angle));
      final cy = size.height * (0.22 + 0.28 * sin(angle * 1.4 + blob.phase * 6));
      final pulse = 0.85 + 0.15 * sin(2 * pi * ((t * 2 + blob.phase) % 1.0));
      final radius = size.shortestSide * blob.relativeSize * pulse;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [blob.color.withOpacity(blob.opacity), blob.color.withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }

    // Drifting sparkle/particle field for a "lively" feel
    for (final p in particles) {
      final progress = (t * p.speed + p.phase) % 1.0;
      final x = size.width * ((p.dx + progress * 0.3) % 1.0);
      final y = size.height * ((p.dy + progress) % 1.0);
      final twinkle = (sin(2 * pi * (t * 3 + p.phase)) + 1) / 2;
      final paint = Paint()
        ..color = const Color(0xFF0D4782).withOpacity(p.opacity * twinkle)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MotionPainter oldDelegate) => oldDelegate.t != t;
}

class _Blob {
  final Color color;
  final double relativeSize;
  final double phase;
  final double opacity;
  final double speedMul;
  _Blob(this.color, this.relativeSize, this.phase, this.opacity, this.speedMul);
}
