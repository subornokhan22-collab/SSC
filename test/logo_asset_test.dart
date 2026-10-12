import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Logo 1 and Logo 2 are the supplied unmodified assets', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final appLogo = File('lib/widgets/app_logo.dart').readAsStringSync();
    final paperExport = File(
      'lib/services/paper_export.dart',
    ).readAsStringSync();

    expect(File('New UI 4.0/Logo 1.png').existsSync(), isTrue);
    expect(File('New UI 4.0/Logo 2.png').existsSync(), isTrue);
    expect(File('New UI 4.0/NEW LOGO.png').existsSync(), isFalse);
    expect(pubspec, contains('image_path: "New UI 4.0/Logo 1.png"'));
    expect(pubspec, contains('- New UI 4.0/Logo 2.png'));
    expect(paperExport, contains("New UI 4.0/Logo 2.png"));
    expect(paperExport, contains('includeText: index != omrPageIndex'));
    expect(paperExport, contains('if (includeText)'));
    expect(paperExport, contains('paper.mcqs.isNotEmpty'));
    expect(paperExport, contains('pages.length - 1'));
    expect(paperExport, contains('pageSize.width * .58'));
    expect(paperExport, contains('pageSize.height * .28'));
    // The printable text watermark is eight times larger than the previous
    // 4.5%-wide sizing and substantially lighter so content stays legible.
    expect(paperExport, contains('pageSize.width * .36'));
    expect(paperExport, contains("fontFamily: 'Bartino'"));
    expect(paperExport, contains('Colors.black.withAlpha(24)'));
    expect(paperExport, isNot(contains('DEMO • TUTOR’S DESK')));
    expect(pubspec, isNot(contains('adaptive_icon_foreground')));
    expect(pubspec, isNot(contains('adaptive_icon_background')));
    expect(appLogo, contains("New UI 4.0/Logo 2.png"));
    expect(appLogo, isNot(contains('ClipOval')));
    expect(appLogo, isNot(contains('BoxShape.circle')));
  });
}
