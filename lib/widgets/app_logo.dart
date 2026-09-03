import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The Mentor's Companion mark, drawn from the real launcher icon.
///
/// Every place that used to show a generic graduation-cap glyph now shows
/// this, so the brand is identical from the splash screen to the profile
/// header. The asset is already square and circular, so it is simply clipped
/// and given a soft ring.
class AppLogo extends StatelessWidget {
  /// Overall diameter of the badge, including the ring.
  final double size;

  /// Draws the ring + halo. Turn it off when the logo sits inside another
  /// decorated container.
  final bool framed;

  /// Ring / glow colour. Defaults to the brand primary.
  final Color? ringColor;

  const AppLogo({super.key, this.size = 44, this.framed = true, this.ringColor});

  @override
  Widget build(BuildContext context) {
    final ring = ringColor ?? AppTheme.primary;
    final image = ClipOval(
      child: Image.asset(
        'assets/icon/icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        // If the asset ever fails to decode the app still shows a mark
        // instead of a broken-image box.
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.brandGradient,
          ),
          child: Text(
            'MC',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: size * .34,
              letterSpacing: .5,
            ),
          ),
        ),
      ),
    );

    if (!framed) return image;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: ring.withOpacity(.35), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: ring.withOpacity(.18),
            blurRadius: size * .38,
            offset: Offset(0, size * .08),
          ),
        ],
      ),
      // Inset a hair so the artwork does not touch the ring.
      child: Padding(
        padding: EdgeInsets.all(size * .04),
        child: image,
      ),
    );
  }
}
