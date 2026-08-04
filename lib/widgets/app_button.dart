import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'animations.dart';

/// A polished gradient button with a tactile press animation and an
/// automatic shine sweep. Use this in place of ElevatedButton wherever
/// a primary action lives (submit, next, start) for a premium feel.
class AppButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool outlined;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.outlined = false,
    this.fullWidth = true,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon,
              size: 20,
              color: widget.outlined ? AppTheme.primary : Colors.white),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: widget.outlined ? AppTheme.primary : Colors.white,
            ),
          ),
        ),
      ],
    );

    final button = AnimatedScale(
      scale: _pressed ? 0.965 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        width: widget.fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: widget.outlined || disabled
              ? null
              : const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color:
              widget.outlined ? Colors.white : (disabled ? Colors.grey.shade400 : null),
          border: widget.outlined
              ? Border.all(color: AppTheme.primary.withOpacity(0.6), width: 1.4)
              : null,
          boxShadow: (widget.outlined || disabled)
              ? []
              : [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(_pressed ? 0.16 : 0.32),
                    blurRadius: _pressed ? 6 : 16,
                    offset: Offset(0, _pressed ? 2 : 7),
                  ),
                ],
        ),
        child: content,
      ),
    );

    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      // Shine sweep only on filled, enabled buttons.
      child: (widget.outlined || disabled)
          ? button
          : ShineSweep(
              borderRadius: BorderRadius.circular(14),
              child: button,
            ),
    );
  }
}
