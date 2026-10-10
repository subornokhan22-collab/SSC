import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the complete supplied SVG icon archive is registered and safe', () {
    final files = Directory('assets/icons')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.svg'))
        .toList();

    expect(files, hasLength(67));
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('flutter_svg:'));
    expect(pubspec, contains('- assets/icons/'));

    for (final file in files) {
      final svg = file.readAsStringSync().toLowerCase();
      expect(svg, contains('<svg'), reason: file.path);
      expect(svg, isNot(contains('<script')), reason: file.path);
      expect(svg, isNot(contains('javascript:')), reason: file.path);
      expect(svg, isNot(contains('<image')), reason: file.path);
    }
  });

  test('every Phosphor icon used by the app has an SVG mapping', () {
    final adapter = File('lib/widgets/app_icon.dart').readAsStringSync();
    final usePattern = RegExp(r'PhosphorIcons\.([A-Za-z0-9_]+)');
    final mapped =
        usePattern.allMatches(adapter).map((match) => match.group(1)).toSet();
    final used = <String>{};

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File ||
          !entity.path.endsWith('.dart') ||
          entity.path.endsWith('app_icon.dart')) {
        continue;
      }
      used.addAll(
        usePattern
            .allMatches(entity.readAsStringSync())
            .map((match) => match.group(1)!),
      );
    }

    expect(used.difference(mapped), isEmpty);
    expect(
      adapter,
      contains("value == PhosphorIcons.arrowLeftDuotone ? 2 : 0"),
    );
    expect(adapter, contains("asset('Next')"));
  });

  test('direct Flutter and Phosphor icon renderers stay centralized', () {
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      if (entity.path.endsWith('app_icon.dart')) continue;
      expect(
        RegExp(r'\bIcon\(').hasMatch(source),
        isFalse,
        reason: entity.path,
      );
      expect(source.contains('PhosphorIcon('), isFalse, reason: entity.path);
    }
  });
}
