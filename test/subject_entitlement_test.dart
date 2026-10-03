import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tutors_desk/models/subscription_entitlement.dart';
import 'package:tutors_desk/repositories/subscription_repository.dart';
import 'package:tutors_desk/services/subject_entitlement_service.dart';

class FakeSubscriptionRepository extends SubscriptionRepository {
  FakeSubscriptionRepository(this.value);

  final SubscriptionEntitlement value;

  @override
  SubscriptionEntitlement get current => value;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Free allows choosing one subject before locking the rest', () async {
    final service = SubjectEntitlementService(
      subscriptions: FakeSubscriptionRepository(
        SubscriptionEntitlement.defaults(SubscriptionPlan.free),
      ),
    );

    expect((await service.select('physics')).allowed, isTrue);
    final blocked = await service.check('chemistry');

    expect(blocked.allowed, isFalse);
    expect(blocked.selectedCount, 1);
    expect(blocked.limit, 1);
  });

  test('Basic allows three selected subjects and preserves existing ones',
      () async {
    final service = SubjectEntitlementService(
      subscriptions: FakeSubscriptionRepository(
        SubscriptionEntitlement.defaults(SubscriptionPlan.basic),
      ),
    );

    expect((await service.select('math')).allowed, isTrue);
    expect((await service.select('physics')).allowed, isTrue);
    expect((await service.select('english')).allowed, isTrue);
    final blocked = await service.check('biology');

    expect(blocked.allowed, isFalse);
    expect(blocked.alreadySelected, isFalse);
    expect(blocked.selectedCount, 3);
    expect(blocked.reason, UpgradeReason.subjectLimit);
    expect(service.selectedSubjects, {'math', 'physics', 'english'});
  });

  test('Pro allows five subjects and blocks the sixth', () async {
    final service = SubjectEntitlementService(
      subscriptions: FakeSubscriptionRepository(
        SubscriptionEntitlement.defaults(SubscriptionPlan.pro),
      ),
    );
    for (final subject in [
      'math',
      'physics',
      'english',
      'biology',
      'chemistry',
    ]) {
      expect((await service.select(subject)).allowed, isTrue);
    }

    final blocked = await service.check('ict');
    expect(blocked.allowed, isFalse);
    expect(blocked.selectedCount, 5);
    expect(blocked.limit, 5);
  });

  test('Professional allows a new subject after more than five existing ones',
      () async {
    final service = SubjectEntitlementService(
      subscriptions: FakeSubscriptionRepository(
        SubscriptionEntitlement.defaults(SubscriptionPlan.professional),
      ),
    );
    for (final subject in [
      'math',
      'physics',
      'english',
      'biology',
      'chemistry'
    ]) {
      expect((await service.select(subject)).allowed, isTrue);
    }

    final result = await service.select('ict');
    expect(result.allowed, isTrue);
    expect(service.selectedSubjects, contains('ict'));
  });
}
