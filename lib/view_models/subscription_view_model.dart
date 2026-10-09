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
  SubscriptionEntitlement? _diagnosticEntitlement;
  bool loading = false;
  Object? error;
  DateTime? expiresAt;
  int aiUsedToday = 0;
  bool initialized = false;

  static const bool planDiagnosticsEnabled =
      bool.fromEnvironment('ENABLE_PLAN_DIAGNOSTICS', defaultValue: false);
  static const String diagnosticAccount = 'subornokhan22@gmail.com';

  SubscriptionEntitlement get entitlement =>
      (_diagnosticEntitlement ?? _entitlement).effective;
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

  /// Cycles the designated diagnostic account through every plan. This code
  /// is inert unless the APK was compiled with ENABLE_PLAN_DIAGNOSTICS=true;
  /// production builds therefore remain entirely server-authoritative.
  bool cycleDiagnosticPlan({required String? accountEmail}) {
    if (!planDiagnosticsEnabled ||
        accountEmail?.trim().toLowerCase() != diagnosticAccount) {
      return false;
    }
    final plans = SubscriptionPlan.values;
    final current = (_diagnosticEntitlement ?? _entitlement).effective.plan;
    final next = plans[(plans.indexOf(current) + 1) % plans.length];
    _diagnosticEntitlement = SubscriptionEntitlement.defaults(
      next,
      expiresAt: next == SubscriptionPlan.free
          ? null
          : DateTime.now().toUtc().add(const Duration(days: 30)),
      provider: 'test-build-diagnostics',
      transactionId: 'local-diagnostic',
      lastVerifiedAt: DateTime.now().toUtc(),
    );
    expiresAt = _diagnosticEntitlement!.expiresAt;
    aiUsedToday = 0;
    notifyListeners();
    return true;
  }

  void clear({String? accountId}) {
    unawaited(repository.clear(accountId: accountId));
    _entitlement = SubscriptionEntitlement.free();
    _diagnosticEntitlement = null;
    expiresAt = null;
    aiUsedToday = 0;
    error = null;
    initialized = true;
    notifyListeners();
  }
}
