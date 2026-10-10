import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutors_desk/services/app_settings.dart';
import 'package:tutors_desk/services/app_style.dart';
import 'package:tutors_desk/theme/design_tokens.dart';
import 'package:tutors_desk/widgets/alive_background.dart';
import 'package:tutors_desk/widgets/aurora_ribbons.dart';
import 'package:tutors_desk/widgets/motion_policy.dart';

Widget host(Widget child, {bool systemReduce = false}) => MaterialApp(
      home: Builder(
        builder: (context) => MediaQuery(
          data:
              MediaQuery.of(context).copyWith(disableAnimations: systemReduce),
          child: MotionPolicy(child: Scaffold(body: child)),
        ),
      ),
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppSettings.reduceMotion.value = false;
    AppStyle.bgIndex.value = 0;
    AppStyle.mood.value = WorkspaceMood.home;
  });

  group('workspace colour language', () {
    test('OMR uses the requested sheet and scanner colours', () {
      expect(AppColors.omr, Colors.black);
      expect(AppColors.omrSoft, const Color(0xFFE5E5E5));
      expect(AppColors.omrTemplateInk, const Color(0xFFEB3897));
      expect(AppColors.omrTemplateSoft, const Color(0xFFFCDEEE));
    });

    test('workspace moods use neutral grey colors except black OMR', () {
      AppStyle.mood.value = WorkspaceMood.papers;
      expect(AppStyle.moodColor, AppColors.science);
      AppStyle.mood.value = WorkspaceMood.ai;
      expect(AppStyle.moodColor, AppColors.ai);
      AppStyle.mood.value = WorkspaceMood.english;
      expect(AppStyle.moodColor, AppColors.writing);
      AppStyle.mood.value = WorkspaceMood.omr;
      expect(AppStyle.moodColor, AppColors.omr);
      expect(AppColors.omr, Colors.black);
      expect(AppColors.omrSoft, const Color(0xFFE5E5E5));
      expect(AppColors.omrTemplateInk, const Color(0xFFEB3897));
      expect(AppColors.omrTemplateSoft, const Color(0xFFFCDEEE));
    });

    test('home follows the chosen workspace preset, not a fixed hue', () async {
      AppStyle.mood.value = WorkspaceMood.home;
      final daylight = AppStyle.moodColor;
      await AppStyle.set(4); // Light Grey
      expect(AppStyle.moodColor, AppColors.workspaceAccents[4]);
      expect(AppStyle.moodColor, daylight);
      expect(AppStyle.moodColor, AppColors.primary);
    });

    test('the backdrop gradient is solid white for every preset', () async {
      expect(AppStyle.gradient.colors, [Colors.white, Colors.white]);
      await AppStyle.set(2); // Cool Grey
      expect(AppStyle.gradient.colors, [Colors.white, Colors.white]);
    });
  });

  group('backdrop', () {
    testWidgets('paints a solid white workspace background', (tester) async {
      await tester.pumpWidget(host(const AliveBackground(child: Text('desk'))));
      await tester.pump();

      expect(find.text('desk'), findsOneWidget);
      expect(AppStyle.gradient.colors, [Colors.white, Colors.white]);
    });

    testWidgets('rapid area switching survives without throwing', (
      tester,
    ) async {
      await tester.pumpWidget(host(const AliveBackground(child: Text('desk'))));
      await tester.pump();

      // Slam through the areas faster than the 300ms transition can finish.
      // Deliberately no pumpAndSettle: the backdrop owns a repeating drift loop,
      // so the tree never settles by design.
      for (final mood in WorkspaceMood.values) {
        AppStyle.mood.value = mood;
        await tester.pump(const Duration(milliseconds: 40));
      }
      await tester.pump(const Duration(milliseconds: 500));

      expect(AppStyle.mood.value, WorkspaceMood.english);
      expect(tester.takeException(), isNull);
      expect(find.text('desk'), findsOneWidget);
    });
  });

  group('auth background remains solid white', () {
    testWidgets('does not schedule frames while disabled', (tester) async {
      await tester.pumpWidget(
        host(const AuroraRibbons(child: Text('sign in'))),
      );
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('enabled ribbons remain static and white', (tester) async {
      await tester.pumpWidget(
        host(const AuroraRibbons(enabled: true, child: Text('sign in'))),
      );
      await tester.pump();
      expect(find.text('sign in'), findsOneWidget);
      expect(AppStyle.gradient.colors, [Colors.white, Colors.white]);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  });
}
