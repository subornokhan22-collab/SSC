import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/subscription_entitlement.dart';
import '../repositories/subscription_repository.dart';

/// Reactive subscription state shared by home, payment, AI, OMR and export UI.
class SubscriptionViewModel extends ChangeNotifier {
  SubscriptionViewModel({SubscriptionRepository? repository})
      : repository = repository ?? SubscriptionRepository();

  final SubscriptionRepository repository;
  SubscriptionEntitlement _entitlement = SubscriptionEntitlement.free();
  bool loading = false;
  Object? error;
  DateTime? expiresAt;
  int aiUsedToday = 0;
  bool initialized = false;

  SubscriptionEntitlement get entitlement => _entitlement.effective;
  SubscriptionPlan get plan => entitlement.plan;
  bool get isExpired => _entitlement.isExpired;
  int get aiRemainingToday =>
      (entitlement.aiDailyLimit - aiUsedToday).clamp(0, 1 << 31).toInt();
  bool get canUseAI =>
      entitlement.canUse(PremiumFeature.aiAssistant) && aiRemainingToday > 0;
  bool get canUseOMR => entitlement.canUse(PremiumFeature.omrScanner);
  bool get shouldShowWatermark => !entitlement.noWatermark;

  Future<void> initialize({bool refresh = true}) async {
    _entitlement = await repository.load();
    expiresAt = _entitlement.expiresAt;
    aiUsedToday = await repository.cachedAiUsedToday;
    initialized = true;
    notifyListeners();
    if (refresh) await this.refresh();
  }

  Future<void> refresh() async {
    if (loading) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      _entitlement = await repository.refresh();
      expiresAt = _entitlement.expiresAt;
      aiUsedToday = await repository.refreshAiUsage();
    } catch (e) {
      error = e;
    } finally {
      loading = false;
      initialized = true;
      notifyListeners();
    }
  }

  Future<void> refreshAfterPayment() => refresh();

  Future<void> refreshAiUsage() async {
    aiUsedToday = await repository.refreshAiUsage();
    notifyListeners();
  }

  bool canUse(PremiumFeature feature) =>
      entitlement.canUse(feature) &&
      (feature != PremiumFeature.aiAssistant || aiRemainingToday > 0);

  UpgradeReason? reasonFor(PremiumFeature feature) => entitlement.reasonFor(
        feature,
        dailyLimitReached: feature == PremiumFeature.aiAssistant &&
            entitlement.aiAssistant &&
            aiRemainingToday <= 0,
      );

  void clear({String? accountId}) {
    unawaited(repository.clear(accountId: accountId));
    _entitlement = SubscriptionEntitlement.free();
    expiresAt = null;
    aiUsedToday = 0;
    error = null;
    initialized = true;
    notifyListeners();
  }
}
