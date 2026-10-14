import 'package:flutter/material.dart';

/// App-wide solid white page background.
///
/// The wrapper remains available to the app root so existing navigation and
/// motion-policy call sites stay unchanged, but decorative washes are removed
/// to keep every screen consistently white.
class AliveBackground extends StatelessWidget {
  final Widget child;
  final bool drift;

  const AliveBackground({super.key, required this.child, this.drift = true});

  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: Colors.white, child: child);
}
