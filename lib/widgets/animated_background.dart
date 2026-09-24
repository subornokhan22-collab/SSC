import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Compatibility wrapper: a quiet, static paper surface rather than a
/// continuously running decorative animation. Keeps existing call sites stable.
class AnimatedBackground extends StatelessWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: AppTheme.canvas, child: child);
}
