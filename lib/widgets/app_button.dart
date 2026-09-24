import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

/// Shared primary action. Loading disables both pointer and semantic actions.
class AppButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool outlined;
  final bool fullWidth;
  final bool loading;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.outlined = false,
    this.fullWidth = true,
    this.loading = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.loading;
    final pressed = _pressed && !disabled;
    final foreground = widget.outlined ? AppTheme.primary : AppColors.surface;
    final radius = BorderRadius.circular(AppRadii.action);
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.loading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          )
        else if (widget.icon != null)
          Icon(widget.icon, size: 20, color: foreground),
        if (widget.loading || widget.icon != null)
          const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            widget.label,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.button.copyWith(color: foreground),
          ),
        ),
      ],
    );
    final button = AnimatedScale(
      scale: pressed ? .97 : 1,
      duration: const Duration(milliseconds: 100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: widget.fullWidth ? double.infinity : null,
        padding: AppSpacing.buttonPadding,
        decoration: BoxDecoration(
          borderRadius: radius,
          color: disabled
              ? AppColors.disabled
              : (widget.outlined ? AppColors.surface : AppColors.primary),
          border: widget.outlined
              ? Border.all(color: AppTheme.primary.withOpacity(.45), width: 1.3)
              : null,
          boxShadow: const [],
        ),
        child: child,
      ),
    );
    return Semantics(
      button: true,
      enabled: !disabled,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
        onTapCancel: disabled ? null : () => setState(() => _pressed = false),
        onTap: disabled ? null : widget.onPressed,
        child: button,
      ),
    );
  }
}
