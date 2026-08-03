import 'dart:math';
import 'package:flutter/material.dart';

/// Lightweight animated background: soft glowing blobs drifting slowly,
/// using pure RadialGradient falloff (no maskFilter blur — that was the
/// expensive part) for smooth performance even on low-end phones.
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
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 50))
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
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _BlobPainter(_controller.value),
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

class _BlobPainter extends CustomPainter {
  final double t;
  _BlobPainter(this.t);

  static const _blobs = [
    _Blob(Color(0xFF0D4782), 0.32, 0.00, 0.12),
    _Blob(Color(0xFF10828C), 0.36, 0.33, 0.10),
    _Blob(Color(0xFFFFC107), 0.22, 0.66, 0.09),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final blob in _blobs) {
      final angle = 2 * pi * ((t + blob.phase) % 1.0);
      final cx = size.width * (0.5 + 0.35 * cos(angle));
      final cy = size.height * (0.22 + 0.24 * sin(angle * 1.2 + blob.phase * 5));
      final radius = size.shortestSide * blob.relativeSize;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [blob.color.withOpacity(blob.opacity), blob.color.withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));

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
  final double opacity;
  const _Blob(this.color, this.relativeSize, this.phase, this.opacity);
}
