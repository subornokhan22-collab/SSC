import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Logo 1 and Logo 2 are the supplied unmodified assets', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final appLogo = File('lib/widgets/app_logo.dart').readAsStringSync();

    expect(File('New UI 4.0/Logo 1.jpg').existsSync(), isTrue);
    expect(File('New UI 4.0/Logo 2.png').existsSync(), isTrue);
    expect(pubspec, contains('image_path: "New UI 4.0/Logo 1.jpg"'));
    expect(pubspec,
        contains('adaptive_icon_foreground: "New UI 4.0/Logo 1.jpg"'));
    expect(appLogo, contains("New UI 4.0/Logo 2.png"));
    expect(appLogo, isNot(contains('ClipOval')));
    expect(appLogo, isNot(contains('BoxShape.circle')));
  });
}
