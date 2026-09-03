import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:a_learning/models/subject_info.dart';
import 'package:a_learning/services/app_style.dart';
import 'package:a_learning/services/auth_service.dart';

/// Guards the teacher-only shape of the app: the student portal must stay
/// removed, and the shared pieces it used to own must live in their new homes.
void main() {
  group('Student portal removal', () {
    const removedScreens = <String>[
      'lib/screens/home_screen.dart',
      'lib/screens/main_home_screen.dart',
      'lib/screens/subjects_screen.dart',
      'lib/screens/subject_detail_screen.dart',
      'lib/screens/quiz_screen.dart',
      'lib/screens/cq_screen.dart',
      'lib/screens/exam_screen.dart',
      'lib/screens/model_test_screen.dart',
      'lib/screens/ai_generate_screen.dart',
      'lib/screens/ai_tutor_screen.dart',
      'lib/screens/pdf_resource_screen.dart',
      'lib/screens/splash_screen.dart',
    ];

    test('every student-only screen is gone', () {
      for (final path in removedScreens) {
        expect(File(path).existsSync(), isFalse,
            reason: '$path belongs to the removed student portal');
      }
    });

    test('no source file references a removed student screen', () {
      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = entity.readAsStringSync();
        for (final removed in removedScreens) {
          final name = removed.split('/').last;
          // Match a real import of that exact file, not a substring of
          // another name (e.g. home_screen.dart vs teacher_home_screen.dart).
          final pattern = RegExp("import\\s+'[^']*(?<![\\w])" +
              RegExp.escape(name) +
              "'");
          if (pattern.hasMatch(source)) {
            offenders.add('${entity.path} -> $name');
          }
        }
      }
      expect(offenders, isEmpty);
    });

    test('the app no longer branches on a student role', () {
      final auth = File('lib/services/auth_service.dart').readAsStringSync();
      expect(auth.contains("'student'"), isFalse);
      expect(AuthService.teacherRole, 'teacher');
    });
  });

  group('Shared teacher data', () {
    test('subject catalogue moved to lib/models and is complete', () {
      expect(File('lib/models/subject_info.dart').existsSync(), isTrue);
      expect(allSubjects, isNotEmpty);
      final ids = allSubjects.map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'subject ids must be unique');
      for (final wanted in ['physics', 'chemistry', 'general_math', 'ict']) {
        expect(ids, contains(wanted));
      }
    });

    test('subjectById resolves known ids and tolerates null', () {
      expect(subjectById('physics')?.name, 'Physics');
      expect(subjectById('not-a-subject'), isNull);
      expect(subjectById(null), isNull);
    });
  });

  group('Theme presets', () {
    test('every backdrop preset has an accent and a label', () {
      expect(AppStyle.colors.length, AppStyle.accents.length);
      expect(AppStyle.colors.length, AppStyle.labels.length);
    });

    test('index wrapping never throws', () {
      expect(() => AppStyle.colors[99 % AppStyle.colors.length], returnsNormally);
    });
  });
}
