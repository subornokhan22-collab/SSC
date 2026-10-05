import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tutors_desk/services/paper_limits.dart';
import 'package:tutors_desk/services/paper_usage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('paper safety limits apply to every plan', () {
    expect(
      PaperLimits.validCounts(mcq: 100, saq: 30, cq: 15),
      isTrue,
    );
    expect(
      PaperLimits.validCounts(mcq: 101, saq: 0, cq: 0),
      isFalse,
    );
    expect(
      PaperLimits.validCounts(mcq: 0, saq: 31, cq: 0),
      isFalse,
    );
    expect(
      PaperLimits.validCounts(mcq: 0, saq: 0, cq: 16),
      isFalse,
    );
  });

  test('offline creation consumes only a previously cached allowance',
      () async {
    final now = DateTime.now().toUtc().add(const Duration(hours: 6));
    final month = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    SharedPreferences.setMockInitialValues({
      'paper_allowance_v2_offline': 1,
      'paper_allowance_v2_offline_month': month,
    });
    final service = PaperUsageService();
    Future<PaperUsageClaim> claim() => service.claim(
          mcqCount: 1,
          saqCount: 0,
          cqCount: 0,
        );
    final first = await claim();
    expect(first.allowed, isTrue);
    expect(first.monthlyLimit, 2);
    expect(first.offline, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getStringList('paper_allowance_pending_ids_v1_offline'),
      hasLength(1),
    );
    final second = await claim();
    expect(second.allowed, isFalse);
    expect(second.reason, 'server_required');
    await service.refund(first);
    final afterRefund = await SharedPreferences.getInstance();
    expect(
      afterRefund.getStringList('paper_allowance_pending_ids_v1_offline'),
      isEmpty,
    );
    expect(afterRefund.getInt('paper_allowance_pending_v1_offline'), isNull);
    final retried = await claim();
    expect(retried.allowed, isTrue);
  });
}
