import 'package:flutter/material.dart';

/// Compatibility wrapper for the sign-in and sign-up screens.
///
/// The previous decorative ribbons made those screens lavender and violet.
/// They now intentionally inherit the same solid white background as the rest
/// of the application.
class AuroraRibbons extends StatelessWidget {
  final Widget child;
  final bool enabled;
  final double opacity;

  const AuroraRibbons({
    super.key,
    required this.child,
    this.enabled = false,
    this.opacity = .6,
  });

  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: Colors.white, child: child);
}
