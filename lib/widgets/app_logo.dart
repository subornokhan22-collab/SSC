import 'package:flutter/material.dart';

/// The supplied Logo 2 artwork used on the opening/authentication surfaces
/// and the teacher home screen. It is rendered as-is: no circle, ring, halo,
/// clipping, or replacement artwork is added around it.
class AppLogo extends StatelessWidget {
  static const assetPath = 'New UI 4.0/NEW LOGO.png';

  final double size;

  const AppLogo({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}
