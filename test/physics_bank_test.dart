import 'package:flutter_test/flutter_test.dart';

import 'package:a_learning/data/questions_data.dart';
import 'package:a_learning/data/physics/physics_mcqs.dart';
import 'package:a_learning/data/physics/physics_saqs.dart';
import 'package:a_learning/data/physics/physics_cqs.dart';
import 'package:a_learning/services/chapter_catalog.dart';

/// Contract tests for the SSC Physics question bank.
///
/// These guard the invariants the bank was built to satisfy: correct chapter
/// names, per-chapter minimum counts, unique ids, well-formed options and
/// explanations, and the presence of all four provenance kinds.
void main() {
  group('chapter names', () {
    test('physicsChapterNames matches ChapterCatalog.physics exactly', () {
      expect(physicsChapterNames, equals(ChapterCatalog.physics));
      expect(physicsChapterNames.length, 13);
    });

    test('every question points at a catalogued chapter', () {
      final valid = ChapterCatalog.physics.toSet();
      for (final q in physicsMcqs) {
        expect(valid.contains(q.chapter), isTrue, reason: 'MCQ ${q.id}');
      }
      for (final q in physicsSAQs) {
        expect(valid.contains(q.chapter), isTrue, reason: 'SAQ ${q.id}');
      }
      for (final q in physicsCqs) {
        expect(valid.contains(q.chapter), isTrue, reason: 'CQ ${q.id}');
      }
    });
  });

  group('coverage', () {
    test('totals meet the required minimums', () {
      expect(physicsMcqs.length, greaterThanOrEqualTo(650));
      expect(physicsSAQs.length, greaterThanOrEqualTo(260));
      expect(physicsCqs.length, greaterThanOrEqualTo(130));
    });

    test('every chapter meets its per-chapter minimum', () {
      for (final name in ChapterCatalog.physics) {
        expect(physicsMcqs.where((q) => q.chapter == name).length,
            greaterThanOrEqualTo(50),
            reason: 'MCQ shortfall in $name');
        expect(physicsSAQs.where((q) => q.chapter == name).length,
            greaterThanOrEqualTo(20),
            reason: 'SAQ shortfall in $name');
        expect(physicsCqs.where((q) => q.chapter == name).length,
            greaterThanOrEqualTo(10),
            reason: 'CQ shortfall in $name');
      }
    });

    test('all four sources appear in every chapter', () {
      for (final name in ChapterCatalog.physics) {
        final sources = physicsMcqs
            .where((q) => q.chapter == name)
            .map((q) => q.source)
            .toSet();
        for (final s in QuestionSource.values) {
          expect(sources.contains(s), isTrue,
              reason: 'chapter "$name" is missing ${s.name} questions');
        }
      }
    });
  });

  group('well-formedness', () {
    test('ids are unique across the whole bank', () {
      final ids = <String>{};
      for (final id in [
        ...physicsMcqs.map((q) => q.id),
        ...physicsSAQs.map((q) => q.id),
        ...physicsCqs.map((q) => q.id),
      ]) {
        expect(ids.add(id), isTrue, reason: 'duplicate id $id');
      }
    });

    test('MCQs have four distinct non-empty options and a valid key', () {
      for (final q in physicsMcqs) {
        expect(q.options.length, 4, reason: q.id);
        expect(q.options.toSet().length, 4,
            reason: 'repeated option in ${q.id}');
        for (final o in q.options) {
          expect(o.trim(), isNotEmpty, reason: 'blank option in ${q.id}');
        }
        expect(q.correctIndex, inInclusiveRange(0, 3), reason: q.id);
      }
    });

    test('no question text or explanation is blank', () {
      for (final q in physicsMcqs) {
        expect(q.questionText.trim(), isNotEmpty, reason: q.id);
        expect(q.explanation.trim(), isNotEmpty, reason: q.id);
      }
      for (final q in physicsSAQs) {
        expect(q.questionText.trim(), isNotEmpty, reason: q.id);
        expect(q.answer.trim(), isNotEmpty, reason: q.id);
      }
    });

    test('no duplicate MCQ stems', () {
      final seen = <String>{};
      for (final q in physicsMcqs) {
        final key = q.questionText.replaceAll(RegExp(r'\s+'), ' ').trim();
        expect(seen.add(key), isTrue, reason: 'duplicate stem in ${q.id}');
      }
    });

    test('CQs carry a stem, four parts and 1-2-3-4 marks', () {
      for (final q in physicsCqs) {
        expect(q.stem.trim(), isNotEmpty, reason: q.id);
        expect(q.questionK.trim(), isNotEmpty, reason: q.id);
        expect(q.questionKh.trim(), isNotEmpty, reason: q.id);
        expect(q.questionG.trim(), isNotEmpty, reason: q.id);
        expect(q.questionGh.trim(), isNotEmpty, reason: q.id);
        expect(q.marks, equals(const [1, 2, 3, 4]), reason: q.id);
      }
    });

    test('no placeholder text leaks into the bank', () {
      final banned =
          RegExp(r'TODO|FIXME|lorem|placeholder|xxx', caseSensitive: false);
      for (final q in physicsMcqs) {
        expect(banned.hasMatch(q.questionText), isFalse, reason: q.id);
        expect(banned.hasMatch(q.explanation), isFalse, reason: q.id);
      }
    });
  });

  group('aggregate wiring', () {
    test('other subjects keep every one of their questions', () {
      // The upstream bank (questions_data.dart + extra_questions.dart) holds
      // these non-physics MCQs. Physics is merged in by spreading, never by
      // replacing, so these counts must survive untouched.
      const expected = <String, int>{
        'general_math': 513,
        'higher_math': 7,
        // Chemistry now has its own additive bank plus the pre-existing item.
        'chemistry': 605,
        'biology': 1,
        'finance': 1,
        'accounting': 1,
      };
      expected.forEach((subject, count) {
        expect(allMCQs.where((q) => q.subjectId == subject).length, count,
            reason: '$subject lost questions during the physics merge');
      });
    });

    test('physics questions are reachable through the aggregates', () {
      expect(allMCQs.length, greaterThanOrEqualTo(physicsMcqs.length));
      expect(allCQs.length, greaterThanOrEqualTo(physicsCqs.length));
      expect(allSAQs.length, greaterThanOrEqualTo(physicsSAQs.length));
      for (final q in physicsMcqs.take(25)) {
        expect(allMCQs.any((m) => m.id == q.id), isTrue, reason: q.id);
      }
      // The 55 physics MCQs that predate this bank must still be present.
      expect(allMCQs.where((q) => q.subjectId == 'physics').length,
          physicsMcqs.length + 55);
    });
  });
}
