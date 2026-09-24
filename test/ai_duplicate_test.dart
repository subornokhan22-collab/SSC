import 'package:flutter_test/flutter_test.dart';

import 'package:tutors_desk/services/ai/duplicate_detector.dart';
import 'package:tutors_desk/data/questions_data.dart';

Question q(String id, String stem) => Question(
      id: id,
      subjectId: 'physics',
      chapter: 'অধ্যায় ২: গতি',
      questionText: stem,
      options: const ['a', 'b', 'c', 'd'],
      correctIndex: 0,
      explanation: 'test',
    );

void main() {
  group('similarity', () {
    test('identical texts score 1.0', () {
      expect(
          DuplicateDetector.similarity(
              'The force on a body is mass times acceleration.',
              'The force on a body is mass times acceleration.'),
          1.0);
    });

    test('reordering the same words stays high', () {
      final s = DuplicateDetector.similarity(
          'The force on a body is mass times acceleration.',
          'Acceleration times mass is the force on a body.');
      expect(s, greaterThan(DuplicateDetector.defaultThreshold));
    });

    test('unrelated topics score low', () {
      final s = DuplicateDetector.similarity(
          'The force on a body is mass times acceleration.',
          'Sound is a longitudinal wave that needs a medium to travel.');
      expect(s, lessThan(DuplicateDetector.defaultThreshold));
    });
  });

  group('isDuplicate', () {
    test('exact match after normalization', () {
      expect(
          DuplicateDetector.isDuplicate(
              'What is the SI unit of force?', 'What is the SI unit of force'),
          isTrue);
    });

    test('a few added/changed words are still a duplicate', () {
      // 10 shared of 12 tokens = 0.83 — clearly the same question.
      // (Full semantic paraphrasing is model-checked in Phase 5; this
      // detector is the lexical first line.)
      expect(
          DuplicateDetector.isDuplicate(
              'Photosynthesis occurs mainly in the chloroplast of a plant cell',
              'Photosynthesis occurs mainly in the chloroplast of a plant cell under sunlight'),
          isTrue);
    });

    test('different questions on the same topic are not duplicates', () {
      expect(
          DuplicateDetector.isDuplicate('What is the SI unit of force?',
              'Define acceleration with its SI unit.'),
          isFalse);
    });

    test('Bengali reordering is caught', () {
      expect(
          DuplicateDetector.isDuplicate(
              'স্বাধীনতার পর বাংলাদেশের অর্থনীতি কেমন ছিল',
              'বাংলাদেশের অর্থনীতি স্বাধীনতার পর কেমন ছিল'),
          isTrue);
    });
  });

  group('findDuplicates', () {
    final bank = [
      q('bank_1', 'What is the SI unit of force?'),
      q('bank_2',
          'Sound is a longitudinal wave that needs a medium to travel.'),
    ];

    test('flags the near copy and reports its source', () {
      final generated = [
        q('gen_1', 'What is the SI unit of force'),
        q('gen_2', 'A body is in equilibrium when the net force is zero.'),
      ];
      final hits = DuplicateDetector.findDuplicates(generated, bank);
      expect(hits.length, 1);
      expect(hits.first.generated.id, 'gen_1');
      expect(hits.first.source.id, 'bank_1');
      expect(hits.first.similarity, greaterThanOrEqualTo(0.75));
    });

    test('empty bank produces no hits', () {
      expect(DuplicateDetector.findDuplicates([q('g', 'x y z w')], const []),
          isEmpty);
    });
  });
}
