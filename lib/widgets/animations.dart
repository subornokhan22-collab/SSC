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
    final total = (duration + delay).inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Curves.linear,
      builder: (context, value, child) {
        final raw = ((value * total - delay.inMilliseconds) /
                duration.inMilliseconds)
            .clamp(0.0, 1.0);
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
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade100,
                Colors.grey.shade200,
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
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.06, 0.02),
        end: Offset.zero,
      ).animate(curved),
      child: FadeTransition(opacity: curved, child: child),
    );
  }
}
