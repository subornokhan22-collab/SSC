import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class WorkflowProgress extends StatelessWidget {
  final List<String> steps;
  final int current;
  const WorkflowProgress({
    super.key,
    required this.steps,
    required this.current,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Step ${current + 1} of ${steps.length}: ${steps[current]}',
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < steps.length; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: i == steps.length - 1 ? 0 : 4,
                    ),
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= current
                            ? AppTheme.primary
                            : AppTheme.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${current + 1} / ${steps.length}  •  ${steps[current]}',
            style: const TextStyle(
              color: AppTheme.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

class OperationNotice extends StatelessWidget {
  final String? error;
  final String? activity;
  const OperationNotice({super.key, this.error, this.activity});
  @override
  Widget build(BuildContext context) {
    if (error == null && activity == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: error != null
            ? AppTheme.danger.withOpacity(.07)
            : AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (error != null)
            const Icon(Icons.info_outline, color: AppTheme.danger, size: 20)
          else
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          const SizedBox(width: 10),
          Expanded(child: Text(error ?? activity!)),
        ],
      ),
    );
  }
}
