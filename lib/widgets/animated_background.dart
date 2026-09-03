import 'dart:math';
import 'package:flutter/material.dart';

import '../services/app_style.dart';

/// Low-cost premium backdrop: deep gradient, slow drifting auras, fine
/// particles and a very soft vignette. Painted once behind the whole app.
///
/// Everything lives in a single [RepaintBoundary] driven by one controller,
/// so adding it globally costs one animation ticker for the entire app.
class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 60))
          ..repeat();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Stop burning frames while the app is in the background.
    if (state == AppLifecycleState.resumed) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppStyle.bgIndex,
      builder: (context, _, child) {
        final base = AppStyle.bg;
        final accent = AppStyle.accent;
        return Stack(
          children: [
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      base,
                      Color.alphaBlend(Colors.white.withOpacity(.035), base),
                      base,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) => CustomPaint(
                    painter: _PremiumScene(_controller.value, accent),
                  ),
                ),
              ),
            ),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}

class _PremiumScene extends CustomPainter {
  final double t;
  final Color accent;
  const _PremiumScene(this.t, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final a = 2 * pi * t;

    void glow(Offset p, double radius, Color c, double opacity) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [c.withOpacity(opacity), c.withOpacity(0)],
        ).createShader(Rect.fromCircle(center: p, radius: radius));
      canvas.drawCircle(p, radius, paint);
    }

    // Two slow auras that drift on different phases.
    glow(
      Offset(size.width * (.74 + .13 * cos(a)), size.height * (.10 + .07 * sin(a))),
      size.width * .58,
      accent,
      .13,
    );
    glow(
      Offset(size.width * (.16 + .09 * sin(a * .8)),
          size.height * (.74 + .11 * cos(a))),
      size.width * .50,
      const Color(0xFF2A4270),
      .30,
    );
    glow(
      Offset(size.width * (.50 + .18 * sin(a * .55)), size.height * .45),
      size.width * .40,
      accent,
      .05,
    );

    // Fine rising particles — deterministic seed keeps them stable.
    final r = Random(42);
    for (var i = 0; i < 26; i++) {
      final x = r.nextDouble() * size.width;
      final speed = .035 + r.nextDouble() * .05;
      final y = ((r.nextDouble() - t * speed) % 1) * size.height;
      final alpha = .03 + .09 * (sin(a * 2 + i) + 1) / 2;
      canvas.drawCircle(
        Offset(x, y),
        .7 + r.nextDouble() * 1.7,
        Paint()..color = accent.withOpacity(alpha),
      );
    }

    // Soft vignette focuses attention on the content.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          radius: .95,
          colors: [Colors.transparent, Colors.black.withOpacity(.30)],
          stops: const [.62, 1],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _PremiumScene old) =>
      old.t != t || old.accent != accent;
}
