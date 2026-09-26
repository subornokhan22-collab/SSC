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
                data: MediaQuery.of(context)
                    .copyWith(disableAnimations: systemReduce),
                child: MotionPolicy(child: Scaffold(body: child)),
              )),
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppSettings.reduceMotion.value = false;
    AppStyle.bgIndex.value = 0;
    AppStyle.mood.value = WorkspaceMood.home;
  });

  group('workspace colour language', () {
    test('every area owns a distinct token instead of the primary indigo', () {
      AppStyle.mood.value = WorkspaceMood.papers;
      expect(AppStyle.moodColor, AppColors.science);
      AppStyle.mood.value = WorkspaceMood.omr;
      expect(AppStyle.moodColor, AppColors.omr);
      AppStyle.mood.value = WorkspaceMood.ai;
      expect(AppStyle.moodColor, AppColors.ai);
      AppStyle.mood.value = WorkspaceMood.english;
      expect(AppStyle.moodColor, AppColors.writing);

      final areas = {
        AppColors.science,
        AppColors.omr,
        AppColors.ai,
        AppColors.writing,
      };
      expect(areas.length, 4, reason: 'areas must not collapse onto one hue');
      expect(areas.contains(AppColors.primary), isFalse);
    });

    test('home follows the chosen workspace preset, not a fixed hue', () async {
      AppStyle.mood.value = WorkspaceMood.home;
      final daylight = AppStyle.moodColor;
      await AppStyle.set(4); // Lavender
      expect(AppStyle.moodColor, AppColors.workspaceAccents[4]);
      expect(AppStyle.moodColor, isNot(daylight));
    });

    test('the gradient token tracks the preset the teacher picked', () async {
      expect(AppStyle.gradient.colors.first, AppStyle.bg);
      await AppStyle.set(2); // Sky
      expect(AppStyle.gradient.colors.first, AppColors.workspaceBackgrounds[2]);
      expect(AppStyle.gradient.colors.length, 3);
    });
  });

  group('backdrop', () {
    testWidgets('paints the workspace gradient rather than a flat colour',
        (tester) async {
      await tester.pumpWidget(host(const AliveBackground(child: Text('desk'))));
      await tester.pump();

      final decorated = tester
          .widgetList<DecoratedBox>(find.descendant(
            of: find.byType(AliveBackground),
            matching: find.byType(DecoratedBox),
          ))
          .where((w) => w.decoration is BoxDecoration)
          .map((w) => (w.decoration as BoxDecoration).gradient)
          .whereType<Gradient>();
      expect(decorated, isNotEmpty,
          reason: 'AppStyle.gradient must actually reach the screen');
    });

    testWidgets('rapid area switching survives without throwing',
        (tester) async {
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

  group('aurora is opt-in atmosphere, not a global background', () {
    testWidgets('does not schedule frames while disabled', (tester) async {
      await tester
          .pumpWidget(host(const AuroraRibbons(child: Text('sign in'))));
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('animates when enabled and stops for reduced motion',
        (tester) async {
      await tester.pumpWidget(host(
        const AuroraRibbons(enabled: true, child: Text('sign in')),
        systemReduce: true,
      ));
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse,
          reason: 'reduced motion must leave a still wash, not a hidden cost');

      await tester.pumpWidget(
          host(const AuroraRibbons(enabled: true, child: Text('sign in'))));
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isTrue);
    });
  });
}
