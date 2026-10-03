import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Logo 1 and Logo 2 are the supplied unmodified assets', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final appLogo = File('lib/widgets/app_logo.dart').readAsStringSync();
    final paperExport =
        File('lib/services/paper_export.dart').readAsStringSync();

    expect(File('New UI 4.0/Logo 1.jpg').existsSync(), isTrue);
    expect(File('New UI 4.0/Logo 2.png').existsSync(), isTrue);
    expect(File('New UI 4.0/NEW LOGO.png').existsSync(), isFalse);
    expect(pubspec, contains('image_path: "New UI 4.0/Logo 1.jpg"'));
    expect(pubspec, contains('- New UI 4.0/Logo 2.png'));
    expect(paperExport, contains("New UI 4.0/Logo 2.png"));
    expect(paperExport, contains('Future.wait(images.map(_watermarkPage))'));
    expect(paperExport, isNot(contains('DEMO • TUTOR’S DESK')));
    expect(pubspec, isNot(contains('adaptive_icon_foreground')));
    expect(pubspec, isNot(contains('adaptive_icon_background')));
    expect(appLogo, contains("New UI 4.0/Logo 2.png"));
    expect(appLogo, isNot(contains('ClipOval')));
    expect(appLogo, isNot(contains('BoxShape.circle')));
  });
}
