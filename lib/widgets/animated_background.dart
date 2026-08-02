import 'dart:math';
import 'package:flutter/material.dart';

/// A subtle animated background: soft floating gradient blobs.
/// Wrap any screen's body with this for a polished, alive feel
/// without hurting performance.
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
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))
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
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _BlobPainter(_controller.value),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _BlobPainter extends CustomPainter {
  final double t; // 0..1 animation progress
  _BlobPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final blobs = [
      _Blob(const Color(0xFF0D4782), 0.20, 0.0),
      _Blob(const Color(0xFF10828C), 0.26, 0.33),
      _Blob(const Color(0xFFFFC107), 0.14, 0.66),
    ];

    for (final blob in blobs) {
      final angle = 2 * pi * ((t + blob.phase) % 1.0);
      final cx = size.width * (0.5 + 0.35 * cos(angle));
      final cy = size.height * (0.25 + 0.20 * sin(angle * 1.3));
      final radius = size.shortestSide * blob.relativeSize;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [blob.color.withOpacity(0.10), blob.color.withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius))
        ..blendMode = BlendMode.srcOver;

      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) => oldDelegate.t != t;
}

class _Blob {
  final Color color;
  final double relativeSize;
  final double phase;
  _Blob(this.color, this.relativeSize, this.phase);
}
