import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// Visual language used by the supplied home-screen reference: solid white
/// canvas, white cards, black icons, and neutral grey borders.
abstract final class ReferencePalette {
  static const background = Colors.white;
  static const surface = Colors.white;
  static const ink = Color(0xFF050505);
  static const mutedInk = Color(0xFF666666);
  static const border = Color(0xFFD6D6D6);
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

class ReferenceImageIcon extends StatelessWidget {
  final String asset;
  final double size;

  const ReferenceImageIcon(this.asset, {super.key, this.size = 34});

  @override
  Widget build(BuildContext context) => Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      );
}

class ReferenceAiMark extends StatelessWidget {
  const ReferenceAiMark({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 64,
        height: 52,
        child: CustomPaint(painter: _ReferenceAiPainter()),
      );
}

class _ReferenceAiPainter extends CustomPainter {
  const _ReferenceAiPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = ReferencePalette.ink
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 7;
    final a = Path()
      ..moveTo(5, size.height - 8)
      ..lineTo(size.width * .42, 6)
      ..lineTo(size.width * .72, size.height - 8);
    canvas.drawPath(a, stroke);
    canvas.drawLine(
      Offset(size.width * .23, size.height * .57),
      Offset(size.width * .56, size.height * .57),
      stroke,
    );
    canvas.drawCircle(
      Offset(size.width * .88, 9),
      4,
      Paint()..color = ReferencePalette.ink,
    );
    canvas.drawLine(
      Offset(size.width * .88, 22),
      Offset(size.width * .88, size.height - 8),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _ReferenceAiPainter oldDelegate) => false;
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
  static const _iconSize = 40.0;

  final Object icon;
  final String? asset;
  final Widget? customIcon;
  final String label;
  final VoidCallback onTap;
  final bool large;
  final bool multiline;
  final bool locked;

  const ReferenceActionCard({
    super.key,
    required this.icon,
    this.asset,
    this.customIcon,
    required this.label,
    required this.onTap,
    this.large = false,
    this.multiline = false,
    this.locked = false,
  });

  Widget _icon() =>
      customIcon ??
      (asset == null
          ? ReferenceIcon(icon, size: _iconSize)
          : ReferenceImageIcon(asset!, size: _iconSize));

  Widget _lockIcon() => const Icon(
        PhosphorIcons.lock,
        size: 18,
        color: ReferencePalette.mutedInk,
      );

  @override
  Widget build(BuildContext context) => ReferenceCard(
        onTap: onTap,
        padding: large
            ? const EdgeInsets.fromLTRB(18, 18, 18, 22)
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
        child: large
            ? Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          label,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: ReferencePalette.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: .45,
                          ),
                        ),
                      ),
                      _icon(),
                    ],
                  ),
                  if (locked) Positioned(right: 0, top: 0, child: _lockIcon()),
                ],
              )
            : Row(
                children: [
                  _icon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: multiline
                        ? Text(
                            label,
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                            style: const TextStyle(
                              color: ReferencePalette.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              letterSpacing: .05,
                            ),
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              label,
                              maxLines: 1,
                              style: const TextStyle(
                                color: ReferencePalette.ink,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                letterSpacing: .05,
                              ),
                            ),
                          ),
                  ),
                  if (locked) ...[
                    const SizedBox(width: 12),
                    _lockIcon(),
                  ],
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
    String? asset,
  }) =>
      Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                asset == null
                    ? ReferenceIcon(icon, size: 30)
                    : ReferenceImageIcon(asset, size: 30),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: ReferencePalette.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 106,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            // Match the upper tab: 200 logical pixels narrower than the
            // former 360-pixel reference width.
            constraints: const BoxConstraints(maxWidth: 160),
            child: Material(
              color: ReferencePalette.surface,
              elevation: 8,
              shadowColor: Colors.black26,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 106,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        _item(
                          icon: PhosphorIcons.house,
                          label: 'Home',
                          onTap: () {},
                          asset: 'New UI 4.0/Home.png',
                        ),
                        _item(
                          icon: PhosphorIcons.gear,
                          label: 'Settings',
                          onTap: onSettings,
                          asset: 'New UI 4.0/Settings.png',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
