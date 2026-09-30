import 'package:flutter/widgets.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/design_tokens.dart';

/// A Phosphor duotone icon using the app's blue/light-blue pair.
///
/// Regular Phosphor icons can still be rendered with Flutter's [Icon] widget.
/// Use this wrapper when a feature surface benefits from the two-layer visual
/// treatment without scattering the palette choices across screens.
class AppDuotoneIcon extends StatelessWidget {
  final PhosphorDuotoneIconData icon;
  final double? size;
  final Color? color;
  final Color? secondaryColor;
  final double secondaryOpacity;
  final String? semanticLabel;

  const AppDuotoneIcon(
    this.icon, {
    super.key,
    this.size,
    this.color = AppColors.primary,
    this.secondaryColor = AppColors.light,
    this.secondaryOpacity = .28,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) => PhosphorIcon(
        icon,
        size: size,
        color: color,
        duotoneSecondaryColor: secondaryColor,
        duotoneSecondaryOpacity: secondaryOpacity,
        semanticLabel: semanticLabel,
      );
}
