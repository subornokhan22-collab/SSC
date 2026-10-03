import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Flutter UI uses the Phosphor icon family', () {
    final materialIconUsages = <String>[];
    final phosphorImportMissing = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      final usesPhosphor = source.contains('PhosphorIcons.');
      final hasStandaloneMaterialIcon = source
          .split('\n')
          .where((line) =>
              line.contains('Icons.') && !line.contains('PhosphorIcons.'))
          .isNotEmpty;

      if (hasStandaloneMaterialIcon) materialIconUsages.add(entity.path);
      if (usesPhosphor &&
          !source.contains(
            "package:phosphoricons_flutter/phosphoricons_flutter.dart",
          )) {
        phosphorImportMissing.add(entity.path);
      }
    }

    expect(materialIconUsages, isEmpty);
    expect(phosphorImportMissing, isEmpty);
  });
}
