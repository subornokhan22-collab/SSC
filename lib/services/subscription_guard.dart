import 'package:flutter/material.dart';

import '../models/subscription_entitlement.dart';
import 'subscription_state.dart';

/// Centralized UI gate. The route should remain discoverable, but every
/// action still calls the same entitlement check before doing work.
class SubscriptionGuard {
  static Future<bool> require(
    BuildContext context,
    PremiumFeature feature, {
    String? title,
  }) async {
    final state = SubscriptionState.instance;
    if (!state.initialized) await state.initialize(refresh: false);
    if (state.canUse(feature)) return true;
    final reason = state.reasonFor(feature);
    final message = switch (reason) {
      UpgradeReason.aiDailyLimit =>
        'Daily AI limit reached. Resets at midnight.',
      UpgradeReason.aiAssistant =>
        'AI Assistant requires an active Pro or Professional plan.',
      UpgradeReason.omrScanner => 'OMR Scanner is available on Professional.',
      UpgradeReason.watermark => 'Upgrade to remove the PDF watermark.',
      UpgradeReason.subjectLimit =>
        'Your current plan has reached its subject limit.',
      null => 'This feature is not available on your current plan.',
    };
    if (context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title ?? 'Upgrade required'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    return false;
  }
}
