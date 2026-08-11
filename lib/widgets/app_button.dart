import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'animations.dart';

/// Consistent gold primary action with tactile motion and an optional outline style.
class AppButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool outlined;
  final bool fullWidth;
  const AppButton({super.key, required this.label, this.icon, required this.onPressed, this.outlined = false, this.fullWidth = true});
  @override State<AppButton> createState() => _AppButtonState();
}
class _AppButtonState extends State<AppButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    final fg = widget.outlined ? AppTheme.accent : const Color(0xFF211806);
    final child = Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
      if (widget.icon != null) ...[Icon(widget.icon, size: 20, color: fg), const SizedBox(width: 8)],
      Flexible(child: Text(widget.label, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: fg))),
    ]);
    final button = AnimatedScale(
      scale: _pressed ? .97 : 1, duration: const Duration(milliseconds: 100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160), width: widget.fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: widget.outlined || disabled ? null : const LinearGradient(colors: [Color(0xFFFFD86B), AppTheme.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
          color: disabled ? const Color(0xFF3A404B) : (widget.outlined ? const Color(0xFF171B25) : null),
          border: widget.outlined ? Border.all(color: AppTheme.primary.withOpacity(.7)) : null,
          boxShadow: widget.outlined || disabled ? [] : [BoxShadow(color: AppTheme.primary.withOpacity(_pressed ? .12 : .25), blurRadius: _pressed ? 7 : 15, offset: Offset(0, _pressed ? 2 : 6))],
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
