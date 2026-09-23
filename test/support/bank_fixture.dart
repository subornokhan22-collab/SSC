import 'dart:convert';
import 'dart:io';

import 'package:tutors_desk/data/question_bank.dart';
import 'package:tutors_desk/data/questions_data.dart';

/// Loads the exported JSON bank straight from disk for unit tests.
///
/// The questions used to be `const` Dart lists that tests could import
/// directly. They now live in `assets/questions/*.json`, so the tests read
/// them through this helper instead — same data, same types, no Flutter
/// asset bundle or binding required.
class BankFixture {
  BankFixture._();

  static bool _loaded = false;

  /// Reads every exported file and installs it into [QuestionBank], so both
  /// the per-subject getters below and the `allMCQs` / `allSAQs` / `allCQs`
  /// aggregates work inside tests.
  static void ensureLoaded() {
    if (_loaded) return;

    final dir = Directory('assets/questions');
    if (!dir.existsSync()) {
      throw StateError(
        'assets/questions is missing — run: python3 tool/extract_questions.py',
      );
    }

    final mcqs = <Question>[];
    final saqs = <ShortQuestion>[];
    final cqs = <CreativeQuestion>[];

    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .where((f) => !f.path.endsWith('manifest.json'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    for (final file in files) {
      final rows = json.decode(file.readAsStringSync()) as List;
      for (final row in rows) {
        final map = row as Map<String, dynamic>;
        // The exported files use camelCase bank ids (physicsCqs); tests
        // address them in snake_case (physics_cqs) — register both.
        final bank = map['bank'] as String;
        (_banks[bank] ??= <String>{}).add(map['id'] as String);
        final alias = _snake(bank);
        if (alias != bank) {
          (_banks[alias] ??= <String>{}).add(map['id'] as String);
        }
        switch (map['type']) {
          case 'mcq':
            mcqs.add(questionFromJson(map));
          case 'saq':
            saqs.add(shortQuestionFromJson(map));
          case 'cq':
            cqs.add(creativeQuestionFromJson(map));
        }
      }
    }

    QuestionBank.seed(mcqs: mcqs, saqs: saqs, cqs: cqs);
    _loaded = true;
  }

  /// camelCase -> snake_case (physicsCqs -> physics_cqs,
  /// generalMathMcqs -> general_math_mcqs, physicsSAQs -> physics_saqs).
  static String _snake(String camel) => camel
          .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}')
          .toLowerCase();

  /// Ids belonging to one exported bank file, e.g. `physics_mcqs`.
  static final Map<String, Set<String>> _banks = {};

  static Set<String> _bankIds(String bank) {
    ensureLoaded();
    final ids = _banks[bank];
    if (ids == null) {
      throw StateError('unknown bank "$bank" — check assets/questions/');
    }
    return ids;
  }

  /// The MCQs from one exported bank file, preserving the exact membership
  /// of the Dart list it replaced (so per-chapter counts still hold).
  static List<Question> mcqsIn(String bank) {
    final ids = _bankIds(bank);
    return allMCQs.where((q) => ids.contains(q.id)).toList();
  }

  static List<ShortQuestion> saqsIn(String bank) {
    final ids = _bankIds(bank);
    return allSAQs.where((q) => ids.contains(q.id)).toList();
  }

  static List<CreativeQuestion> cqsIn(String bank) {
    final ids = _bankIds(bank);
    return allCQs.where((q) => ids.contains(q.id)).toList();
  }
}
