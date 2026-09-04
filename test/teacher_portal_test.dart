import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tutors_desk/models/subject_info.dart';
import 'package:tutors_desk/services/app_style.dart';
import 'package:tutors_desk/services/auth_service.dart';
import 'package:tutors_desk/theme/app_theme.dart';

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

    test('every backdrop preset is light', () {
      for (var i = 0; i < AppStyle.colors.length; i++) {
        expect(AppStyle.colors[i].computeLuminance(), greaterThan(0.8),
            reason: '${AppStyle.labels[i]} must be a light backdrop');
      }
    });

    test('the app theme is light, not dark', () {
      final theme = AppTheme.light();
      expect(theme.brightness, Brightness.light);
      expect(AppTheme.canvas.computeLuminance(), greaterThan(0.8));
      expect(AppTheme.surface.computeLuminance(), greaterThan(0.9));
      expect(AppTheme.textDark.computeLuminance(), lessThan(0.2));
      final main = File('lib/main.dart').readAsStringSync();
      expect(main.contains('ThemeMode.dark'), isFalse);
      expect(main.contains('AppTheme.light()'), isTrue);
    });
  });

  group('Sign-in uses a password, never a code', () {
    test('the sign-in screen has no OTP field or send-code call', () {
      final src = File('lib/screens/signin_screen.dart').readAsStringSync();
      expect(src.contains('signInWithPassword'), isTrue);
      expect(src.contains('sendOtp'), isFalse);
      expect(src.contains('verifyOtp'), isFalse);
      expect(src.contains('Send Code'), isFalse);
    });

    test('the profile screen signs in with a password too', () {
      final src = File('lib/screens/profile_screen.dart').readAsStringSync();
      expect(src.contains('signInWithPassword'), isTrue);
      expect(src.contains('sendOtp'), isFalse);
    });

    test('the code step exists only in sign-up', () {
      final src = File('lib/screens/signup_screen.dart').readAsStringSync();
      expect(src.contains('signUpWithPassword'), isTrue);
      expect(src.contains('verifySignUpCode'), isTrue);
    });

    test('AuthService no longer exposes a passwordless sign-in', () {
      final src = File('lib/services/auth_service.dart').readAsStringSync();
      expect(src.contains('signInWithOtp'), isFalse,
          reason: 'sign-in must never trigger a magic-link/OTP email');
      expect(src.contains('signInWithPassword'), isTrue);
      expect(AuthService.minPasswordLength, greaterThanOrEqualTo(8));
    });
  });

  group('Branding', () {
    test('the package and app are named after Tutor\'s Desk', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec.contains('name: tutors_desk'), isTrue);
      expect(pubspec.contains('a_learning'), isFalse);
      final manifest =
          File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      expect(manifest.contains("Tutor\'s Desk"), isTrue);
      expect(manifest.contains('ssc_prep_app'), isFalse);
    });

    test('no screen still shows the graduation-cap placeholder', () {
      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (entity.readAsStringSync().contains('Icons.school_rounded')) {
          offenders.add(entity.path);
        }
      }
      expect(offenders, isEmpty,
          reason: 'use AppLogo (the real app icon) instead');
    });

    test('the logo widget points at the real launcher asset', () {
      final logo = File('lib/widgets/app_logo.dart');
      expect(logo.existsSync(), isTrue);
      expect(logo.readAsStringSync().contains('assets/icon/icon.png'), isTrue);
      expect(File('assets/icon/icon.png').existsSync(), isTrue);
    });
  });
}
