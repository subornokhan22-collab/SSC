import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutors_desk/services/local_diagnostics.dart';

// Keep storage queue tests in a real async zone, separate from widget-test
// FakeAsync zones whose microtask queues are disposed between test cases.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('diagnostics omit private messages and keep only bounded app frames',
      () async {
    await LocalDiagnostics.clear();
    for (var i = 0; i < 12; i++) {
      await LocalDiagnostics.record(
        StateError('Bearer secret-token user@example.com prompt and photo.pdf'),
        StackTrace.fromString(
            '#0 app (package:tutors_desk/main.dart:12:4)\n#1 https://private.example/key=secret\n/home/private/photo.pdf'),
        scope: 'user@example.com',
      );
    }
    final report = await LocalDiagnostics.report();
    for (final private in [
      'secret',
      'user@example.com',
      'photo.pdf',
      'private.example',
      '/home/private',
      'prompt'
    ]) {
      expect(report, isNot(contains(private)));
    }
    expect(report, contains('package:tutors_desk/main.dart:12:4'));
    expect('"type"'.allMatches(report).length, LocalDiagnostics.maxEntries);
    await LocalDiagnostics.clear();
    expect(await LocalDiagnostics.report(), 'No local diagnostics recorded.');
  });
}
