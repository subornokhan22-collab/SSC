import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutors_desk/theme/app_theme.dart';
import 'package:tutors_desk/widgets/app_button.dart';

Widget host(AppButton button) => MaterialApp(
      theme: AppTheme.light(),
      home: Scaffold(body: Center(child: button)),
    );

void main() {
  testWidgets('enabled action invokes its callback', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      host(AppButton(label: 'Save paper', onPressed: () => calls++)),
    );
    await tester.tap(find.text('Save paper'));
    expect(calls, 1);
  });

  testWidgets('loading blocks taps and replaces the icon with a spinner', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      host(
        AppButton(
          label: 'Save paper',
          icon: Icons.save,
          loading: true,
          onPressed: () => calls++,
        ),
      ),
    );
    await tester.tap(find.text('Save paper'));
    expect(calls, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.save), findsNothing);
  });

  testWidgets('a null callback is disabled without a loading indicator', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const AppButton(label: 'Save paper', onPressed: null)),
    );
    await tester.tap(find.text('Save paper'));
    expect(tester.takeException(), isNull);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('leaving loading state re-enables the action', (tester) async {
    var calls = 0;
    var loading = true;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return AppButton(
                label: 'Save paper',
                loading: loading,
                onPressed: () => calls++,
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Save paper'));
    expect(calls, 0);
    update(() => loading = false);
    await tester.pump();
    await tester.tap(find.text('Save paper'));
    expect(calls, 1);
  });
}
