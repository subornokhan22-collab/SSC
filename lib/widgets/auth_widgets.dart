import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

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
          child: Icon(icon, color: AppTheme.primary, size: 24),
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
                    fontSize: 12.8, height: 1.55, color: AppTheme.muted),
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
            ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                    strokeWidth: 2.2, color: Colors.white),
              )
            : Icon(icon, size: 20),
        label: Text(busy ? 'Please wait...' : label),
      ),
    );
  }
}
