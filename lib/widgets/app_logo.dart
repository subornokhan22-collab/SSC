import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

/// The Tutor's Desk mark from the supplied New UI 4.0 artwork.
///
/// Every place that shows the app mark uses the same square source, clipped
/// inside a light circular badge so the black and grey artwork remains visible
/// on white loading and authentication screens.
class AppLogo extends StatelessWidget {
  static const assetPath = 'New UI 4.0/NEW LOGO.png';

  /// Overall diameter of the badge, including the ring.
  final double size;

  /// Draws the ring + halo. Turn it off when the logo sits inside another
  /// decorated container.
  final bool framed;

  /// Ring / glow colour. Defaults to the brand primary.
  final Color? ringColor;

  const AppLogo({
    super.key,
    this.size = 44,
    this.framed = true,
    this.ringColor,
  });

  @override
  Widget build(BuildContext context) {
    final ring = ringColor ?? AppTheme.primary;
    final image = Padding(
      padding: EdgeInsets.all(size * .12),
      child: ClipOval(
        child: Image.asset(
          assetPath,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          // If the asset ever fails to decode the app still shows a mark
          // instead of a broken-image box.
          errorBuilder: (_, __, ___) => Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
            child: Text(
              'TD',
              style: TextStyle(
                color: AppColors.onColor,
                fontWeight: FontWeight.w900,
                fontSize: size * .34,
                letterSpacing: .5,
              ),
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
      child: Padding(padding: EdgeInsets.all(size * .04), child: image),
    );
  }
}
