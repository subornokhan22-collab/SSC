import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// Visual language used by the supplied home-screen reference: quiet lavender
/// canvas, white cards, near-black icons, and generous rounded controls.
abstract final class ReferencePalette {
  static const background = Color(0xFFECEBF1);
  static const surface = Colors.white;
  static const ink = Color(0xFF050505);
  static const mutedInk = Color(0xFF686870);
  static const border = Color(0xFFE2E1E7);
}

/// Renders either a regular Phosphor icon or a duotone Phosphor icon without
/// switching icon libraries. Reference screens intentionally use black ink.
class ReferenceIcon extends StatelessWidget {
  final Object icon;
  final double size;
  final Color color;
  final Color secondaryColor;
  final double secondaryOpacity;

  const ReferenceIcon(
    this.icon, {
    super.key,
    this.size = 34,
    this.color = ReferencePalette.ink,
    this.secondaryColor = ReferencePalette.mutedInk,
    this.secondaryOpacity = .24,
  });

  @override
  Widget build(BuildContext context) => PhosphorIcon(
        icon,
        size: size,
        color: color,
        duotoneSecondaryColor: secondaryColor,
        duotoneSecondaryOpacity: secondaryOpacity,
      );
}

class ReferenceCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;

  const ReferenceCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: const BorderSide(color: ReferencePalette.border),
    );
    return Material(
      color: ReferencePalette.surface,
      shape: shape,
      elevation: 0,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        borderRadius: BorderRadius.circular(radius),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class ReferenceActionCard extends StatelessWidget {
  final Object icon;
  final String label;
  final VoidCallback onTap;
  final bool large;
  final bool multiline;

  const ReferenceActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.large = false,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) => ReferenceCard(
        onTap: onTap,
        padding: large
            ? const EdgeInsets.fromLTRB(18, 18, 18, 22)
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
        child: large
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: ReferencePalette.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        letterSpacing: .7,
                      ),
                    ),
                  ),
                  ReferenceIcon(icon, size: 72),
                ],
              )
            : Row(
                children: [
                  ReferenceIcon(icon, size: 48),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: multiline ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ReferencePalette.ink,
                        fontSize: 19,
                        fontWeight: FontWeight.w400,
                        letterSpacing: .1,
                      ),
                    ),
                  ),
                ],
              ),
      );
}

class ReferenceBottomBar extends StatelessWidget {
  final VoidCallback onSettings;

  const ReferenceBottomBar({super.key, required this.onSettings});

  Widget _item({
    required Object icon,
    required String label,
    required VoidCallback onTap,
  }) => Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ReferenceIcon(icon, size: 42),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: ReferencePalette.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Material(
        color: ReferencePalette.surface,
        elevation: 8,
        shadowColor: Colors.black26,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 128,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 58),
              child: Row(
                children: [
                  _item(
                    icon: PhosphorIcons.house,
                    label: 'Home',
                    onTap: () {},
                  ),
                  _item(
                    icon: PhosphorIcons.gear,
                    label: 'Settings',
                    onTap: onSettings,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
