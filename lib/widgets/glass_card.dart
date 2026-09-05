
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'animations.dart';

/// Frosted, softly-lit white surface used for every panel in the tutor
/// portal. The translucency keeps the animated backdrop visible while the
/// content sits on clean paper-white so long text stays easy to read.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? tint;
  final bool highlighted;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.radius = 22,
    this.tint,
    this.highlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = highlighted
        ? AppTheme.primary.withOpacity(.45)
        : AppTheme.border;
    // No BackdropFilter here on purpose. The card fill is 88-94% opaque, so
    // the blur behind it was barely visible, but it is one of the most
    // expensive things Flutter can draw — and during a page transition two
    // screens' worth of them render at once, which is what made navigation
    // feel laggy.
    final body = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: RepaintBoundary(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (tint ?? Colors.white).withOpacity(.94),
                (tint ?? const Color(0xFFF7F9FE)).withOpacity(.88),
              ],
            ),
            border: Border.all(color: border, width: highlighted ? 1.3 : 1),
            boxShadow: [
              BoxShadow(
                color: highlighted
                    ? AppTheme.primary.withOpacity(.16)
                    : const Color(0xFF16203A).withOpacity(.07),
                blurRadius: highlighted ? 26 : 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    final wrapped = Padding(
      padding: margin ?? EdgeInsets.zero,
      child: body,
    );
    if (onTap == null) return wrapped;
    return PressableScale(onTap: onTap, child: wrapped);
  }
}

/// Section heading with a small brand rule — used to break long forms up.
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const SectionTitle({super.key, required this.title, this.subtitle, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: subtitle == null ? 20 : 36,
            margin: const EdgeInsets.only(right: 10, top: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.primary, AppTheme.secondary],
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 17, color: AppTheme.primary),
                      const SizedBox(width: 7),
                    ],
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                          letterSpacing: .2,
                        ),
                      ),
                    ),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                        fontSize: 12.5, height: 1.45, color: AppTheme.muted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small rounded status pill (PRO / DEMO / counts / hints).
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusPill({
    super.key,
    required this.label,
    this.color = AppTheme.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.11),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(.34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
                fontSize: 11.5, color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Inline feedback banner (success / error / info) with an entrance animation.
class InfoBanner extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;

  const InfoBanner({
    super.key,
    required this.text,
    required this.color,
    this.icon = Icons.info_outline_rounded,
  });

  factory InfoBanner.success(String text) => InfoBanner(
        text: text,
        color: AppTheme.success,
        icon: Icons.check_circle_outline_rounded,
      );

  factory InfoBanner.error(String text) => InfoBanner(
        text: text,
        color: AppTheme.danger,
        icon: Icons.error_outline_rounded,
      );

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      offset: const Offset(0, 10),
      duration: const Duration(milliseconds: 320),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: color.withOpacity(.09),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(.32)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 12.8, height: 1.5, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen friendly empty / hint state.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
        child: Column(
          children: [
            Pulse(
              min: .95,
              max: 1.05,
              period: const Duration(milliseconds: 1900),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(.10),
                  border: Border.all(color: AppTheme.primary.withOpacity(.35)),
                ),
                child: Icon(icon, size: 34, color: AppTheme.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark),
            ),
            if (message != null) ...[
              const SizedBox(height: 7),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12.8, height: 1.55, color: AppTheme.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Branded busy indicator used while papers/PDFs are generated.
class BusyIndicator extends StatelessWidget {
  final String message;
  const BusyIndicator({super.key, this.message = 'Working...'});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 34),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 74,
              height: 74,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const HaloRing(size: 74, strokeWidth: 2.4),
                  Pulse(
                    min: .88,
                    max: 1.06,
                    period: const Duration(milliseconds: 1100),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: AppTheme.primary, size: 26),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13.2, height: 1.5, color: AppTheme.muted),
            ),
          ],
        ),
      ),
    );
  }
}
