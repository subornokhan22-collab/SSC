import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:tutors_desk/widgets/feature_carousel.dart';

const _features = [
  FeatureHighlight(
    icon: PhosphorIcons.fileTextDuotone,
    title: 'Paper builder',
    description: 'Compose papers.',
  ),
  FeatureHighlight(
    icon: PhosphorIcons.scanDuotone,
    title: 'OMR scanner',
    description: 'Review answer sheets.',
  ),
];

void main() {
  test('carousel belongs to account choice, not the sign-in welcome', () {
    final choice =
        File('lib/screens/auth_choice_screen.dart').readAsStringSync();
    final authWidgets =
        File('lib/widgets/auth_widgets.dart').readAsStringSync();
    final carousel =
        File('lib/widgets/feature_carousel.dart').readAsStringSync();
    expect(choice, contains('FeatureCarousel('));
    expect(choice, contains('showThreeCards:'));
    expect(choice, contains('width >= 700'));
    expect(carousel, contains('widget.viewportFraction'));
    expect(carousel, contains('_buildWideCarousel'));
    expect(carousel, contains('AnimatedSwitcher'));
    expect(choice, contains("title: 'PDF export'"));
    expect(choice, contains("title: 'Saved papers'"));
    expect(choice, contains("title: 'Class insights'"));
    expect(choice, contains("title: 'Secure workspace'"));
    expect(choice, contains('AppLogo(size: 96)'));
    expect(choice, contains('AppBrandName(fontSize: 36)'));
    expect(choice, contains('YOUR TEACHING WORKSPACE'));
    expect(choice, isNot(contains('Question papers, ready for class.')));
    expect(authWidgets, isNot(contains('FeatureCarousel(')));
    expect(carousel, isNot(contains('Listener(')));
    expect(carousel, isNot(contains('_touching')));
    expect(carousel, contains('addPostFrameCallback'));
    expect(carousel, contains('_controller.animateToPage('));
  });

  testWidgets('reduced motion renders a static feature card', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(body: FeatureCarousel(features: _features)),
        ),
      ),
    );

    expect(find.byType(PageView), findsNothing);
    expect(find.text('Paper builder'), findsOneWidget);
    expect(find.text('OMR scanner'), findsNothing);
  });

  testWidgets('carousel exposes a page view when motion is allowed',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: FeatureCarousel(features: _features)),
      ),
    );

    expect(find.byType(PageView), findsOneWidget);
    expect(find.text('Paper builder'), findsWidgets);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
