import 'package:flutter/material.dart';

/// The supplied Logo 2 artwork used on the opening/authentication surfaces
/// and the teacher home screen. It is rendered as-is: no circle, ring, halo,
/// clipping, or replacement artwork is added around it.
/// Consistent app-name treatment. Bartino Outline is reserved for brand
/// lockups; page titles and controls keep the more readable UI typeface.
class AppBrandName extends StatelessWidget {
  final double fontSize;
  final Color color;

  const AppBrandName({
    super.key,
    this.fontSize = 26,
    this.color = const Color(0xFF111111),
  });

  @override
  Widget build(BuildContext context) => Text(
        'Tutor’s Desk',
        maxLines: 1,
        overflow: TextOverflow.fade,
        softWrap: false,
        style: TextStyle(
          fontFamily: 'Bartino Outline',
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: .2,
          color: color,
        ),
      );
}

class AppLogo extends StatelessWidget {
  static const assetPath = 'New UI 4.0/Logo 2.png';

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
