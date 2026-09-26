import 'package:flutter/material.dart';

import '../services/app_settings.dart';

/// One policy for system accessibility, the in-app preference and lifecycle.
/// Keep this above the Navigator so pushed routes inherit it too.
class MotionPolicy extends StatefulWidget {
  final Widget child;
  const MotionPolicy({super.key, required this.child});

  static bool reduce(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);
  static Duration duration(BuildContext context, int milliseconds) =>
      reduce(context) ? Duration.zero : Duration(milliseconds: milliseconds);

  @override
  State<MotionPolicy> createState() => _MotionPolicyState();
}

class _MotionPolicyState extends State<MotionPolicy>
    with WidgetsBindingObserver {
  bool foreground = true;
  @override
  void initState() {
    super.initState();
    final state = WidgetsBinding.instance.lifecycleState;
    foreground = state == null || state == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => foreground = state == AppLifecycleState.resumed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
        valueListenable: AppSettings.reduceMotion,
        builder: (context, reduce, _) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations:
                reduce || MediaQuery.disableAnimationsOf(context),
          ),
          child: TickerMode(
            enabled: foreground && TickerMode.of(context),
            child: widget.child,
          ),
        ),
      );
}

/// Repeating effects stop their controllers, not just their paint, when
/// reduced, offstage or backgrounded. Reconfiguration works after creation.
abstract class MotionLoopState<T extends StatefulWidget> extends State<T>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController motion;
  bool _foreground = true;
  Duration get period;
  bool get enabled => true;
  bool get reverse => false;
  bool get motionAllowed =>
      enabled &&
      _foreground &&
      !MotionPolicy.reduce(context) &&
      TickerMode.of(context);

  @override
  void initState() {
    super.initState();
    motion = AnimationController(vsync: this, duration: period);
    final state = WidgetsBinding.instance.lifecycleState;
    _foreground = state == null || state == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground) {
      motion.stop();
    } else {
      synchronize();
    }
  }

  void synchronize() {
    if (motionAllowed) {
      if (!motion.isAnimating) motion.repeat(reverse: reverse);
    } else {
      motion.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    synchronize();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (motion.duration != period) {
      motion.stop();
      motion.duration = period;
    }
    synchronize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    motion.dispose();
    super.dispose();
  }
}

/// A busy indicator is not a percentage. Reduced motion gets a static glyph;
/// its surrounding live-region label still announces the real operation.
class ActivityIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  const ActivityIndicator({super.key, this.size = 18, this.color});
  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: MotionPolicy.reduce(context)
            ? Icon(Icons.hourglass_top_rounded, size: size, color: color)
            : CircularProgressIndicator(strokeWidth: 2, color: color),
      );
}
