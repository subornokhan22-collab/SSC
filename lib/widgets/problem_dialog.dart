import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'motion_policy.dart';

/// One action inside a problem dialog.
class ProblemAction {
  final String label;

  /// Called after the dialog closes.
  final VoidCallback onTap;
  final bool primary;
  const ProblemAction(this.label, this.onTap, {this.primary = false});
}

void _noop() {}

final List<ProblemAction> _defaultActions = [ProblemAction('OK', _noop)];

/// A polished, impossible-to-miss "problem" alert.
///
/// Replaces plain error snackbars/AlertDialogs with:
///  • a dark backdrop,
///  • a rounded card that scales + fades in (320 ms, ease-out — no
///    bounce),
///  • a red warning icon that gently blinks (smooth pulse) so the user
///    can't scroll past the problem,
///  • a small muted-red detail box for exact errors/tips.
///
/// Use it for error states the user must act on: scan failures,
/// scanner unavailable, print failures.
Future<void> showProblemDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? detail,
  List<ProblemAction>? actions,
  bool dismissible = true,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(.55),
    transitionDuration: MotionPolicy.duration(context, 200),
    transitionBuilder: (c, enter, _, child) {
      if (MotionPolicy.reduce(c)) return child;
      final curved = CurvedAnimation(
        parent: enter,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final scale = Tween<double>(begin: .88, end: 1).animate(curved);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(scale: scale, child: child),
      );
    },
    pageBuilder: (c, _, __) => _ProblemCard(
      title: title,
      message: message,
      detail: detail,
      actions: actions ?? _defaultActions,
    ),
  );
}

class _ProblemCard extends StatefulWidget {
  final String title;
  final String message;
  final String? detail;
  final List<ProblemAction> actions;
  const _ProblemCard({
    required this.title,
    required this.message,
    required this.detail,
    required this.actions,
  });

  @override
  State<_ProblemCard> createState() => _ProblemCardState();
}

class _ProblemCardState extends State<_ProblemCard> {
  // A warning should remain legible, not blink indefinitely.
  static const _blink = AlwaysStoppedAnimation<double>(.5);

  void _run(ProblemAction a) {
    Navigator.of(context).pop();
    a.onTap();
  }

  Widget _actionButton(ProblemAction a) {
    final isPrimary = a.primary || widget.actions.length == 1;
    if (isPrimary) {
      return FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.danger,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        onPressed: () => _run(a),
        child: Text(
          a.label,
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
        ),
      );
    }
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.danger,
        side: const BorderSide(color: Color(0xFFE5484D), width: 1.3),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
      onPressed: () => _run(a),
      child: Text(
        a.label,
        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 32),
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.danger.withOpacity(.7),
                width: 1.4,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2E16203A),
                  blurRadius: 30,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Red blinking warning icon — a smooth pulse so it reads as
                // "problem" at a glance without strobing.
                AnimatedBuilder(
                  animation: _blink,
                  builder: (c, _) {
                    final t = _blink.value;
                    final col = Color.lerp(
                      AppTheme.danger.withOpacity(.45),
                      AppTheme.danger,
                      t,
                    )!;
                    return Transform.scale(
                      scale: 1 + .05 * t,
                      child: Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: col.withOpacity(.12 + .10 * t),
                        ),
                        child: Icon(
                          Icons.error_outline_rounded,
                          size: 36,
                          color: col,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.danger,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * .45,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          widget.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.5,
                            color: Color(0xFFB23A41),
                          ),
                        ),
                        if (widget.detail != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF1F1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.detail!,
                              style: const TextStyle(
                                fontSize: 11.5,
                                height: 1.45,
                                color: Color(0xFF8A4B4E),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    for (var i = 0; i < widget.actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(child: _actionButton(widget.actions[i])),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
