import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'animations.dart';

/// Consistent brand primary action with tactile motion and an optional outline style.
class AppButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool outlined;
  final bool fullWidth;
  /// While true the button is disabled and shows a small spinner in
  /// place of its icon (long-running actions: saving, PDF rendering).
  final bool loading;
  const AppButton({super.key, required this.label, this.icon, required this.onPressed, this.outlined = false, this.fullWidth = true, this.loading = false});
  @override State<AppButton> createState() => _AppButtonState();
}
class _AppButtonState extends State<AppButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.loading;
    final fg = widget.outlined ? AppTheme.primary : Colors.white;
    final child = Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
      if (widget.loading)
        SizedBox(width: 18, height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg))
      else if (widget.icon != null)
        Icon(widget.icon, size: 20, color: fg),
      if (widget.loading || widget.icon != null) const SizedBox(width: 8),
      Flexible(child: Text(widget.label, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: fg))),
    ]);
    final button = AnimatedScale(
      scale: _pressed ? .97 : 1, duration: const Duration(milliseconds: 100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160), width: widget.fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: widget.outlined || disabled ? null : AppTheme.brandGradient,
          color: disabled ? const Color(0xFFC9D0E2) : (widget.outlined ? Colors.white : null),
          border: widget.outlined ? Border.all(color: AppTheme.primary.withOpacity(.45), width: 1.3) : null,
          boxShadow: widget.outlined || disabled ? [] : [BoxShadow(color: AppTheme.primary.withOpacity(_pressed ? .14 : .28), blurRadius: _pressed ? 7 : 16, offset: Offset(0, _pressed ? 2 : 7))],
        ), child: child,
      ),
    );
    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true), onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: disabled ? null : () => setState(() => _pressed = false), onTap: widget.onPressed,
      child: widget.outlined || disabled ? button : ShineSweep(borderRadius: BorderRadius.circular(15), child: button),
    );
  }
}
