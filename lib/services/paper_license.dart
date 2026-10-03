import '../models/subscription_entitlement.dart';
import 'subscription_state.dart';

/// Backwards-compatible facade for older callers.
///
/// Subscription rules no longer live here. All callers should consume
/// [SubscriptionState.instance] and [SubscriptionEntitlement]. The facade is
/// retained briefly so downstream integrations do not break during migration.
@Deprecated('Use SubscriptionState.instance.entitlement instead.')
class PaperLicense {
  static Future<bool> isPro() async {
    final state = SubscriptionState.instance;
    if (!state.initialized) await state.initialize(refresh: false);
    return state.entitlement.isPaid;
  }

  static Future<void> markProFromServer({DateTime? until}) async {
    await SubscriptionState.instance.refresh();
  }

  static Future<void> deactivate() async {
    SubscriptionState.instance.clear();
  }

  static const int demoMcqLimit = 6;
  static const int demoCqLimit = 2;
}
