import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Reusable animation toolkit for the whole app.
/// All widgets are self-contained and pure-Flutter (no packages needed).
/// ─────────────────────────────────────────────────────────────────────────

/// Fade + slide entrance animation. Use [delay] to stagger lists/grids.
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final Curve curve;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 550),
    this.offset = const Offset(0, 24),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    final span = duration.inMilliseconds;
    // A zero-length animation would divide by zero below; just show the child.
    if (span <= 0) return child;
    final total = (duration + delay).inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Curves.linear,
      builder: (context, value, child) {
        final raw =
            ((value * total - delay.inMilliseconds) / span).clamp(0.0, 1.0);
        final t = curve.transform(raw);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(offset.dx * (1 - t), offset.dy * (1 - t)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Scales down slightly while pressed — makes any widget feel tactile.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.96,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// A soft light band that periodically sweeps across its child.
/// Wrap buttons/banners for a premium shine effect.
class ShineSweep extends StatefulWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final Duration period;
  final bool enabled;

  const ShineSweep({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.period = const Duration(milliseconds: 2600),
    this.enabled = true,
  });

  @override
  State<ShineSweep> createState() => _ShineSweepState();
}

class _ShineSweepState extends State<ShineSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.period);
    if (widget.enabled) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, _) {
                  // Band travels from offscreen-left to offscreen-right,
                  // with a pause built in at both ends of the loop.
                  final pos = -0.7 + _c.value * 2.6;
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(pos - 0.25, 0),
                        end: Alignment(pos + 0.25, 0),
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.22),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gently scales the child in and out (breathing effect).
class Pulse extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final double min;
  final double max;
  final Duration period;

  const Pulse({
    super.key,
    required this.child,
    this.enabled = true,
    this.min = 0.93,
    this.max = 1.07,
    this.period = const Duration(milliseconds: 800),
  });

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.period);
    if (widget.enabled) _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_c.value);
        return Transform.scale(
          scale: widget.min + (widget.max - widget.min) * t,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Animates a number counting up from 0 to [value].
class CountUp extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;

  const CountUp({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, v, _) => Text('${v.round()}', style: style),
    );
  }
}

/// Shimmer placeholder (for loading states).
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final pos = -0.7 + _c.value * 2.6;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(pos - 0.3, 0),
              end: Alignment(pos + 0.3, 0),
              colors: const [
                Color(0xFFE8ECF5),
                Color(0xFFF6F8FC),
                Color(0xFFE8ECF5),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Global page transition: gentle slide + fade for every Navigator.push.
/// Wired up once in AppTheme (pageTransitionsTheme).
class SmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  const SmoothPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Incoming page: slide up a touch, fade and scale in.
    final inCurve = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // Outgoing page: the screen being covered. Without this the old screen
    // stays fully opaque underneath, and because every Scaffold in this app
    // is transparent (the animated backdrop shows through) you briefly see
    // both screens stacked on top of each other.
    final outCurve = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeInCubic,
      reverseCurve: Curves.easeOutCubic,
    );

    // Slide + fade only: no ScaleTransition. Scaling forces the whole page
    // layer to be resampled every frame, which is the expensive part on
    // mid-range Android. Two transform layers per page is enough to read as
    // a proper transition and stays cheap.
    return SlideTransition(
      // Push the old page a little left as the new one arrives.
      position: Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.14, 0),
      ).animate(outCurve),
      child: FadeTransition(
        // Fade it out over the first 55% so the two never read as one
        // jumbled screen.
        opacity: Tween<double>(begin: 1, end: 0).animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: const Interval(0, 0.55),
          ),
        ),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.12, 0),
            end: Offset.zero,
          ).animate(inCurve),
          child: FadeTransition(
            opacity: inCurve,
            // Isolate the page so the animated backdrop behind it does not
            // repaint together with the moving content.
            child: RepaintBoundary(child: child),
          ),
        ),
      ),
    );
  }
}

/// Staggers the entrance of a list of children with a per-item delay.
/// Keeps list code tidy: `children: Stagger.list(items)`.
class Stagger {
  const Stagger._();

  static List<Widget> list(
    List<Widget> children, {
    Duration step = const Duration(milliseconds: 70),
    Duration duration = const Duration(milliseconds: 520),
    Offset offset = const Offset(0, 26),
    int maxStaggered = 14,
  }) {
    return List<Widget>.generate(children.length, (i) {
      final n = i < maxStaggered ? i : maxStaggered;
      return FadeSlideIn(
        delay: step * n,
        duration: duration,
        offset: offset,
        child: children[i],
      );
    });
  }
}

/// Animated glow ring that slowly rotates behind a widget (logo halo).
class HaloRing extends StatefulWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  final Duration period;

  const HaloRing({
    super.key,
    this.size = 120,
    this.color = const Color(0xFF3D5AFE),
    this.strokeWidth = 2,
    this.period = const Duration(seconds: 7),
  });

  @override
  State<HaloRing> createState() => _HaloRingState();
}

class _HaloRingState extends State<HaloRing> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.period)..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Transform.rotate(
          angle: _c.value * 2 * 3.1415926,
          child: CustomPaint(
            size: Size.square(widget.size),
            painter: _HaloPainter(widget.color, widget.strokeWidth),
          ),
        ),
      ),
    );
  }
}

class _HaloPainter extends CustomPainter {
  final Color color;
  final double stroke;
  const _HaloPainter(this.color, this.stroke);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..shader = SweepGradient(
        colors: [
          color.withOpacity(0),
          color.withOpacity(.85),
          color.withOpacity(0),
          color.withOpacity(0),
        ],
        stops: const [0, .18, .42, 1],
      ).createShader(rect);
    canvas.drawArc(rect.deflate(stroke), 0, 2 * 3.1415926, false, paint);
  }

  @override
  bool shouldRepaint(covariant _HaloPainter old) =>
      old.color != color || old.stroke != stroke;
}

/// Fades/slides between two children whenever the child key changes.
class SoftSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  const SoftSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 320),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, .05), end: Offset.zero)
              .animate(animation),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
