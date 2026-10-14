import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/app_theme.dart';
import 'app_icon.dart';
import 'app_logo.dart';
import 'motion_policy.dart';

/// Header used at the top of the sign-in / sign-up screens.
class AuthHero extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const AuthHero({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primary.withOpacity(.12),
            border: Border.all(color: AppTheme.primary.withOpacity(.4)),
          ),
          child: AppIcon(icon, color: AppTheme.primary, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.8,
                  height: 1.55,
                  color: AppTheme.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Full-width primary action with an inline busy spinner.
class SubmitButton extends StatelessWidget {
  final bool busy;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final double height;

  const SubmitButton({
    super.key,
    required this.busy,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton.icon(
        onPressed: busy ? null : onPressed,
        icon: busy
            ? const ActivityIndicator(size: 17, color: Colors.white)
            : AppIcon(icon, size: 20),
        label: Text(busy ? 'Please wait...' : label),
      ),
    );
  }
}

/// A branded front door, without animating the logo or changing auth behavior.
class DeskWelcome extends StatelessWidget {
  const DeskWelcome({super.key});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              AppLogo(size: 52),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBrandName(fontSize: 27),
                    Text(
                      'YOUR TEACHING WORKSPACE',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.2,
                        color: AppTheme.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Welcome back.',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Less preparation. More teaching.\nSign in to open your desk.',
            style: TextStyle(color: AppTheme.muted, height: 1.6),
          ),
        ],
      );
}
