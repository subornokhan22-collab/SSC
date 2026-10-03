import 'package:flutter_test/flutter_test.dart';

import 'package:tutors_desk/models/subscription_entitlement.dart';

void main() {
  group('SubscriptionEntitlement matrix', () {
    test('Free is limited, watermarked, and has no premium access', () {
      final e = SubscriptionEntitlement.defaults(SubscriptionPlan.free);
      expect(e.subjectLimit, SubscriptionEntitlement.freeSubjectLimit);
      expect(e.noWatermark, isFalse);
      expect(e.aiDailyLimit, 0);
      expect(e.canUse(PremiumFeature.aiAssistant), isFalse);
      expect(e.canUse(PremiumFeature.omrScanner), isFalse);
    });

    test('Basic allows three subjects but no AI or OMR', () {
      final e = SubscriptionEntitlement.defaults(SubscriptionPlan.basic);
      expect(e.subjectLimit, 3);
      expect(e.noWatermark, isFalse);
      expect(e.aiAssistant, isFalse);
      expect(e.aiDailyLimit, 0);
      expect(e.omrScanner, isFalse);
    });

    test('Pro allows five subjects, watermark-free export, and 20 AI requests',
        () {
      final e = SubscriptionEntitlement.defaults(SubscriptionPlan.pro);
      expect(e.subjectLimit, 5);
      expect(e.noWatermark, isTrue);
      expect(e.canUse(PremiumFeature.aiAssistant), isTrue);
      expect(e.aiDailyLimit, 20);
      expect(e.canUse(PremiumFeature.omrScanner), isFalse);
    });

    test('Professional has unlimited subjects and OMR', () {
      final e = SubscriptionEntitlement.defaults(SubscriptionPlan.professional);
      expect(e.subjectLimit, isNull);
      expect(e.noWatermark, isTrue);
      expect(e.aiDailyLimit, 50);
      expect(e.canUse(PremiumFeature.omrScanner), isTrue);
    });

    test('expired Professional immediately becomes Free', () {
      final e = SubscriptionEntitlement.defaults(
        SubscriptionPlan.professional,
        expiresAt: DateTime.now().toUtc().subtract(const Duration(minutes: 1)),
      );
      expect(e.isExpired, isTrue);
      expect(e.effective.plan, SubscriptionPlan.free);
      expect(e.effective.aiDailyLimit, 0);
      expect(e.effective.omrScanner, isFalse);
      expect(e.effective.noWatermark, isFalse);
    });

    test('legacy plan values map safely to Pro', () {
      expect(subscriptionPlanFromString('monthly'), SubscriptionPlan.pro);
      expect(subscriptionPlanFromString('yearly'), SubscriptionPlan.pro);
      expect(subscriptionPlanFromString('lifetime'), SubscriptionPlan.pro);
      expect(subscriptionPlanFromString('professional'),
          SubscriptionPlan.professional);
      expect(subscriptionPlanFromString('unknown'), SubscriptionPlan.free);
    });

    test('server plan rows override configurable limits', () {
      final e = SubscriptionEntitlement.fromPlanRow({
        'id': 'pro',
        'subject_limit': 7,
        'no_watermark': true,
        'ai_assistant': true,
        'ai_daily_limit': 31,
        'omr_scanner': false,
      });
      expect(e.subjectLimit, 7);
      expect(e.aiDailyLimit, 31);
    });
  });
}
