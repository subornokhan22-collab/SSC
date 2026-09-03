import 'package:flutter_test/flutter_test.dart';

import 'support/bank_fixture.dart';

import 'package:mentors_companion/data/chemistry/chemistry_chapter_catalog.dart';

import 'package:mentors_companion/data/questions_data.dart';
import 'package:mentors_companion/services/chapter_catalog.dart';

void main() {
  late final List<CreativeQuestion> chemistryCqs;
  late final List<Question> chemistryMcqs;
  late final List<ShortQuestion> chemistrySaqs;

  setUpAll(() {
    BankFixture.ensureLoaded();
    chemistryCqs = BankFixture.cqsIn('chemistry_cqs');
    chemistryMcqs = BankFixture.mcqsIn('chemistry_mcqs');
    chemistrySaqs = BankFixture.saqsIn('chemistry_saqs');
  });

  group('Chemistry chapter catalog', () {
    test('uses the exact 12-chapter NCTB textbook order', () {
      expect(
        ChemistryChapterCatalog.chapters,
        equals(const <String>[
          'অধ্যায় ১: রসায়নের ধারণা',
          'অধ্যায় ২: পদার্থের অবস্থা',
          'অধ্যায় ৩: পদার্থের গঠন',
          'অধ্যায় ৪: পর্যায় সারণি',
          'অধ্যায় ৫: রাসায়নিক বন্ধন',
          'অধ্যায় ৬: মোলের ধারণা ও রাসায়নিক গণনা',
          'অধ্যায় ৭: রাসায়নিক বিক্রিয়া',
          'অধ্যায় ৮: রসায়ন ও শক্তি',
          'অধ্যায় ৯: এসিড-ক্ষারক সমতা',
          'অধ্যায় ১০: খনিজ সম্পদ: ধাতু-অধাতু',
          'অধ্যায় ১১: খনিজ সম্পদ: জীবাশ্ম',
          'অধ্যায় ১২: আমাদের জীবনে রসায়ন',
        ]),
      );
      expect(ChemistryChapterCatalog.displayName, 'রসায়ন');
      expect(
        ChapterCatalog.ordered(const <String>[], subjectId: 'chemistry'),
        ChemistryChapterCatalog.chapters,
      );
    });

    test('every Chemistry record points to a catalog chapter', () {
      final valid = ChemistryChapterCatalog.chapters.toSet();
      for (final q in chemistryMcqs) {
        expect(valid.contains(q.chapter), isTrue, reason: q.id);
      }
      for (final q in chemistrySaqs) {
        expect(valid.contains(q.chapter), isTrue, reason: q.id);
      }
      for (final q in chemistryCqs) {
        expect(valid.contains(q.chapter), isTrue, reason: q.id);
      }
    });

    test('mixed/generated labels never enter the Chemistry catalog', () {
      final banned = RegExp(
        r'অধ্যায়\s*[০-৯0-9]+\s*ও\s*[০-৯0-9]+|মিলিয়ে|mixed|board-style',
        caseSensitive: false,
      );
      for (final chapter in ChemistryChapterCatalog.chapters) {
        expect(banned.hasMatch(chapter), isFalse, reason: chapter);
      }
    });
  });

  group('Chemistry coverage', () {
    test('grand totals meet the required target', () {
      expect(chemistryMcqs.length, greaterThanOrEqualTo(600));
      expect(chemistrySaqs.length, greaterThanOrEqualTo(240));
      expect(chemistryCqs.length, greaterThanOrEqualTo(120));
    });

    test('every chapter has at least 50 MCQ, 20 SAQ and 10 CQ', () {
      for (final chapter in ChemistryChapterCatalog.chapters) {
        expect(
          chemistryMcqs.where((q) => q.chapter == chapter).length,
          greaterThanOrEqualTo(50),
          reason: 'MCQ shortfall in $chapter',
        );
        expect(
          chemistrySaqs.where((q) => q.chapter == chapter).length,
          greaterThanOrEqualTo(20),
          reason: 'SAQ shortfall in $chapter',
        );
        expect(
          chemistryCqs.where((q) => q.chapter == chapter).length,
          greaterThanOrEqualTo(10),
          reason: 'CQ shortfall in $chapter',
        );
      }
    });
  });

  group('Chemistry well-formedness', () {
    test('ids are unique across all three Chemistry banks', () {
      final ids = <String>{};
      for (final id in <String>[
        ...chemistryMcqs.map((q) => q.id),
        ...chemistrySaqs.map((q) => q.id),
        ...chemistryCqs.map((q) => q.id),
      ]) {
        expect(ids.add(id), isTrue, reason: 'duplicate id: $id');
      }
    });

    test('MCQs have exactly four distinct options and a valid key', () {
      for (final q in chemistryMcqs) {
        expect(q.subjectId, 'chemistry', reason: q.id);
        expect(q.questionText.trim(), isNotEmpty, reason: q.id);
        expect(q.options.length, 4, reason: q.id);
        expect(q.options.toSet().length, 4, reason: q.id);
        expect(q.correctIndex, inInclusiveRange(0, 3), reason: q.id);
        expect(q.options[q.correctIndex].trim(), isNotEmpty, reason: q.id);
        expect(q.explanation.trim(), isNotEmpty, reason: q.id);
        expect(q.source, QuestionSource.original, reason: q.id);
        expect(q.sourceLabel?.trim(), isNotEmpty, reason: q.id);
      }
    });

    test('MCQ stems are unique', () {
      final seen = <String>{};
      for (final q in chemistryMcqs) {
        final normalized =
            q.questionText.replaceAll(RegExp(r'\s+'), ' ').trim();
        expect(seen.add(normalized), isTrue, reason: q.id);
      }
    });

    test('SAQs contain answer, explanation and provenance', () {
      for (final q in chemistrySaqs) {
        expect(q.subjectId, 'chemistry', reason: q.id);
        expect(q.questionText.trim(), isNotEmpty, reason: q.id);
        expect(q.answer.trim(), isNotEmpty, reason: q.id);
        expect(q.explanation.trim(), isNotEmpty, reason: q.id);
        expect(q.source, QuestionSource.original, reason: q.id);
        expect(q.sourceLabel?.trim(), isNotEmpty, reason: q.id);
      }
    });

    test('CQs contain four parts and const 1-2-3-4 marks', () {
      for (final q in chemistryCqs) {
        expect(q.subjectId, 'chemistry', reason: q.id);
        expect(q.stem.trim(), isNotEmpty, reason: q.id);
        expect(q.questionK.trim(), isNotEmpty, reason: q.id);
        expect(q.questionKh.trim(), isNotEmpty, reason: q.id);
        expect(q.questionG.trim(), isNotEmpty, reason: q.id);
        expect(q.questionGh.trim(), isNotEmpty, reason: q.id);
        expect(q.marks, equals(const <int>[1, 2, 3, 4]), reason: q.id);
        expect(q.source, QuestionSource.original, reason: q.id);
        expect(q.sourceLabel?.trim(), isNotEmpty, reason: q.id);
      }
    });

    test('no LaTeX or placeholder content is present', () {
      final banned = RegExp(
        r'\\begin|\\frac|\\mathrm|TODO|FIXME|lorem|placeholder',
        caseSensitive: false,
      );
      for (final text in <String>[
        ...chemistryMcqs.expand(
          (q) => <String>[q.questionText, q.explanation, ...q.options],
        ),
        ...chemistrySaqs.expand(
          (q) => <String>[q.questionText, q.answer, q.explanation],
        ),
        ...chemistryCqs.expand(
          (q) => <String>[
            q.stem,
            q.questionK,
            q.questionKh,
            q.questionG,
            q.questionGh,
          ],
        ),
      ]) {
        expect(banned.hasMatch(text), isFalse, reason: text);
      }
    });
  });

  group('aggregate wiring and compatibility', () {
    test('all Chemistry records are reachable through existing aggregates', () {
      for (final q in chemistryMcqs) {
        expect(allMCQs.any((item) => item.id == q.id), isTrue, reason: q.id);
      }
      for (final q in chemistrySaqs) {
        expect(allSAQs.any((item) => item.id == q.id), isTrue, reason: q.id);
      }
      for (final q in chemistryCqs) {
        expect(allCQs.any((item) => item.id == q.id), isTrue, reason: q.id);
      }
      // One Chemistry figure MCQ predated this additive bank and is preserved.
      expect(
        allMCQs.where((q) => q.subjectId == 'chemistry').length,
        chemistryMcqs.length + 1,
      );
    });

    test('pre-existing non-Chemistry subject totals remain intact', () {
      const expectedMcqs = <String, int>{
        'general_math': 1363,
        'higher_math': 7,
        'biology': 701,
        'finance': 1,
        'accounting': 1,
      };
      expectedMcqs.forEach((subjectId, count) {
        expect(
          allMCQs.where((q) => q.subjectId == subjectId).length,
          count,
          reason: '$subjectId data changed during Chemistry merge',
        );
      });
    });
  });
}
