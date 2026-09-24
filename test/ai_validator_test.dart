import 'package:flutter_test/flutter_test.dart';

import 'package:tutors_desk/services/ai/question_schema_validator.dart';
import 'package:tutors_desk/data/questions_data.dart';

Question q({
  String id = 'ai_test_1',
  String stem = 'Which gas do plants absorb during photosynthesis?',
  List<String>? options,
  int correctIndex = 0,
  String? explanation,
}) =>
    Question(
      id: id,
      subjectId: 'biology',
      chapter: 'অধ্যায় ৩: কোষ বিভাজন',
      questionText: stem,
      options: options ??
          const [
            'Carbon dioxide',
            'Oxygen',
            'Nitrogen',
            'Hydrogen',
          ],
      correctIndex: correctIndex,
      explanation: explanation ??
          'Plants absorb carbon dioxide during photosynthesis to make glucose.',
    );

void main() {
  group('schema validator', () {
    test('accepts a well-formed MCQ', () {
      final v = QuestionSchemaValidator.validateMcq(q());
      expect(v.valid, isTrue, reason: '${v.errors}');
      expect(v.warnings, isEmpty);
    });

    test('rejects the wrong option count', () {
      final v = QuestionSchemaValidator.validateMcq(
          q(options: const ['a', 'b', 'c']));
      expect(v.valid, isFalse);
      expect(v.errors.any((e) => e.contains('options')), isTrue);
    });

    test('rejects duplicate options', () {
      final v = QuestionSchemaValidator.validateMcq(q(options: const [
        'Carbon dioxide',
        'Carbon dioxide',
        'Oxygen',
        'Nitrogen'
      ]));
      expect(v.valid, isFalse);
      expect(v.errors.any((e) => e.contains('distinct')), isTrue);
    });

    test('rejects an out-of-range answer key', () {
      final v = QuestionSchemaValidator.validateMcq(q(correctIndex: 5));
      expect(v.valid, isFalse);
    });

    test('rejects an empty stem', () {
      final v = QuestionSchemaValidator.validateMcq(q(stem: '   '));
      expect(v.valid, isFalse);
    });

    test('rejects an empty explanation', () {
      final v = QuestionSchemaValidator.validateMcq(q(explanation: ''));
      expect(v.valid, isFalse);
    });

    test('rejects LaTeX markup in any field', () {
      final v = QuestionSchemaValidator.validateMcq(
          q(explanation: r'Use \frac{a}{b} and \begin{equation}.'));
      expect(v.valid, isFalse);
    });

    test('warns when the explanation quotes a distractor', () {
      final v = QuestionSchemaValidator.validateMcq(q(
          correctIndex: 1,
          explanation:
              'The answer is Nitrogen, which plants absorb during photosynthesis.'));
      expect(v.valid, isTrue, reason: '${v.errors}');
      expect(v.warnings, isNotEmpty);
    });

    test('batch: count mismatch flags the whole batch', () {
      final vs = QuestionSchemaValidator.validateBatch([q(id: 'a'), q(id: 'b')],
          expectedCount: 3);
      expect(vs.every((v) => !v.valid), isTrue);
    });

    test('batch: an in-batch duplicate is flagged', () {
      final vs =
          QuestionSchemaValidator.validateBatch([q(id: 'a'), q(id: 'b')]);
      expect(vs[1].valid, isFalse);
      expect(vs[1].errors.any((e) => e.contains('duplicate')), isTrue);
      expect(vs[0].valid, isTrue);
    });
  });
}
