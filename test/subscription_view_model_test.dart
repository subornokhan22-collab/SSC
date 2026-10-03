import 'package:flutter_test/flutter_test.dart';

import 'package:tutors_desk/models/subscription_entitlement.dart';
import 'package:tutors_desk/repositories/subscription_repository.dart';
import 'package:tutors_desk/view_models/subscription_view_model.dart';

class FakeSubscriptionRepository extends SubscriptionRepository {
  FakeSubscriptionRepository(this.value, {this.used = 0});

  SubscriptionEntitlement value;
  int used;

  @override
  Future<SubscriptionEntitlement> load() async => value;

  @override
  Future<SubscriptionEntitlement> refresh() async => value;

  @override
  Future<int> get cachedAiUsedToday async => used;

  @override
  Future<int> refreshAiUsage() async => used;
}

void main() {
  test('view model exposes effective Free state after expiry', () async {
    final repository = FakeSubscriptionRepository(
      SubscriptionEntitlement.defaults(
        SubscriptionPlan.pro,
        expiresAt: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
      ),
      used: 12,
    );
    final viewModel = SubscriptionViewModel(repository: repository);

    await viewModel.initialize(refresh: false);

    expect(viewModel.plan, SubscriptionPlan.free);
    expect(viewModel.entitlement.aiAssistant, isFalse);
    expect(viewModel.shouldShowWatermark, isTrue);
    expect(viewModel.aiUsedToday, 12);
  });

  test('view model preserves plan capabilities and remaining quota', () async {
    final repository = FakeSubscriptionRepository(
      SubscriptionEntitlement.defaults(SubscriptionPlan.pro),
      used: 7,
    );
    final viewModel = SubscriptionViewModel(repository: repository);

    await viewModel.initialize(refresh: false);

    expect(viewModel.plan, SubscriptionPlan.pro);
    expect(viewModel.entitlement.subjectLimit, 5);
    expect(viewModel.aiRemainingToday, 13);
    expect(viewModel.canUse(PremiumFeature.aiAssistant), isTrue);
    expect(viewModel.canUse(PremiumFeature.omrScanner), isFalse);
  });

  test('Dhaka date cache key follows the Asia/Dhaka calendar day', () {
    expect(
      SubscriptionRepository.dhakaDateString(
        DateTime.utc(2026, 1, 1, 17, 59),
      ),
      '2026-01-01',
    );
    expect(
      SubscriptionRepository.dhakaDateString(
        DateTime.utc(2026, 1, 1, 18),
      ),
      '2026-01-02',
    );
  });
}
