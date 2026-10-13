import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'support/bank_fixture.dart';

import 'package:tutors_desk/data/general_math/general_math_chapter_catalog.dart';

import 'package:tutors_desk/data/general_math/general_math_divisions.dart';

import 'package:tutors_desk/data/questions_data.dart';
import 'package:tutors_desk/services/chapter_catalog.dart';
import 'package:tutors_desk/services/general_math_board_pattern.dart';

void main() {
  late final List<CreativeQuestion> generalMathCqs;
  late final List<Question> generalMathMcqs;
  late final List<ShortQuestion> generalMathSaqs;

  setUpAll(() {
    BankFixture.ensureLoaded();
    generalMathCqs = BankFixture.cqsIn('general_math_cqs');
    generalMathMcqs = BankFixture.mcqsIn('general_math_mcqs');
    generalMathSaqs = BankFixture.saqsIn('general_math_saqs');
  });

  group('General Mathematics catalog and divisions', () {
    test('uses the exact 17-chapter numeric order', () {
      expect(
        GeneralMathChapterCatalog.chapters,
        equals(const <String>[
          'অধ্যায় ১: বাস্তব সংখ্যা',
          'অধ্যায় ২: সেট ও ফাংশন',
          'অধ্যায় ৩: বীজগাণিতিক রাশি',
          'অধ্যায় ৪: সূচক ও লগারিদম',
          'অধ্যায় ৫: এক চলকবিশিষ্ট সমীকরণ',
          'অধ্যায় ৬: রেখা, কোণ ও ত্রিভুজ',
          'অধ্যায় ৭: ব্যবহারিক জ্যামিতি',
          'অধ্যায় ৮: বৃত্ত',
          'অধ্যায় ৯: ত্রিকোণমিতিক অনুপাত',
          'অধ্যায় ১০: দূরত্ব ও উচ্চতা',
          'অধ্যায় ১১: বীজগাণিতিক অনুপাত ও সমানুপাত',
          'অধ্যায় ১২: দুই চলকবিশিষ্ট সরল সহসমীকরণ',
          'অধ্যায় ১৩: সসীম ধারা',
          'অধ্যায় ১৪: অনুপাত, সদৃশতা ও প্রতিসমতা',
          'অধ্যায় ১৫: ক্ষেত্রফল সম্পর্কিত উপপাদ্য ও সম্পাদ্য',
          'অধ্যায় ১৬: পরিমিতি',
          'অধ্যায় ১৭: পরিসংখ্যান',
        ]),
      );
      expect(GeneralMathChapterCatalog.displayName, 'গণিত');
      expect(
        ChapterCatalog.ordered(const <String>[], subjectId: 'general_math'),
        GeneralMathChapterCatalog.chapters,
      );
    });

    test('division chapter-number lists match the requested mapping', () {
      expect(GeneralMathDivisions.algebraChapters, const <int>[
        1,
        2,
        3,
        4,
        5,
        11,
        12,
        13,
      ]);
      expect(GeneralMathDivisions.geometryChapters, const <int>[
        6,
        7,
        8,
        14,
        15,
      ]);
      expect(GeneralMathDivisions.trigonometryMensurationChapters, const <int>[
        9,
        10,
        16,
      ]);
      expect(GeneralMathDivisions.statisticsChapters, const <int>[17]);
      expect(GeneralMathDivisions.names, const <String>[
        'ক বিভাগ — বীজগণিত',
        'খ বিভাগ — জ্যামিতি',
        'গ বিভাগ — ত্রিকোণমিতি ও পরিমিতি',
        'ঘ বিভাগ — পরিসংখ্যান',
      ]);
    });

    test('every new record uses an official chapter', () {
      final valid = GeneralMathChapterCatalog.chapters.toSet();
      for (final q in generalMathMcqs) {
        expect(valid.contains(q.chapter), isTrue, reason: q.id);
      }
      for (final q in generalMathSaqs) {
        expect(valid.contains(q.chapter), isTrue, reason: q.id);
      }
      for (final q in generalMathCqs) {
        expect(valid.contains(q.chapter), isTrue, reason: q.id);
      }
    });
  });

  group('General Mathematics coverage and shape', () {
    test('totals are exactly 850 MCQ, 340 SAQ and 170 CQ', () {
      expect(generalMathMcqs.length, 850);
      expect(generalMathSaqs.length, 340);
      expect(generalMathCqs.length, 170);
    });

    test('each chapter has exactly 50 MCQ, 20 SAQ and 10 CQ', () {
      for (final chapter in GeneralMathChapterCatalog.chapters) {
        expect(
          generalMathMcqs.where((q) => q.chapter == chapter).length,
          50,
          reason: chapter,
        );
        expect(
          generalMathSaqs.where((q) => q.chapter == chapter).length,
          20,
          reason: chapter,
        );
        expect(
          generalMathCqs.where((q) => q.chapter == chapter).length,
          10,
          reason: chapter,
        );
      }
    });

    test('ids and new question stems do not repeat', () {
      final ids = <String>{};
      final mcqStems = <String>{};
      final saqStems = <String>{};
      final cqStems = <String>{};
      for (final q in generalMathMcqs) {
        expect(ids.add(q.id), isTrue, reason: q.id);
        expect(mcqStems.add(q.questionText.trim()), isTrue, reason: q.id);
      }
      for (final q in generalMathSaqs) {
        expect(ids.add(q.id), isTrue, reason: q.id);
        expect(saqStems.add(q.questionText.trim()), isTrue, reason: q.id);
      }
      for (final q in generalMathCqs) {
        expect(ids.add(q.id), isTrue, reason: q.id);
        expect(cqStems.add(q.stem.trim()), isTrue, reason: q.id);
      }
    });

    test('MCQs have four distinct options, one key and explanation', () {
      for (final q in generalMathMcqs) {
        expect(q.subjectId, 'general_math', reason: q.id);
        expect(q.options.length, 4, reason: q.id);
        expect(q.options.toSet().length, 4, reason: q.id);
        expect(q.correctIndex, inInclusiveRange(0, 3), reason: q.id);
        expect(q.options[q.correctIndex].trim(), isNotEmpty, reason: q.id);
        expect(q.explanation.trim(), isNotEmpty, reason: q.id);
        expect(q.source, QuestionSource.original, reason: q.id);
        expect(q.sourceLabel, 'Original chapter practice', reason: q.id);
      }
    });

    test('SAQs have concise answer, explanation and provenance', () {
      for (final q in generalMathSaqs) {
        expect(q.questionText.trim(), isNotEmpty, reason: q.id);
        expect(q.answer.trim(), isNotEmpty, reason: q.id);
        expect(q.explanation.trim(), isNotEmpty, reason: q.id);
        expect(q.source, QuestionSource.original, reason: q.id);
        expect(q.sourceLabel, 'Original chapter practice', reason: q.id);
      }
    });

    test('Mathematics CQs use three parts with 2-4-4 marks', () {
      for (final q in generalMathCqs) {
        expect(q.stem.trim(), isNotEmpty, reason: q.id);
        expect(q.questionK.trim(), isNotEmpty, reason: q.id);
        expect(q.questionKh.trim(), isNotEmpty, reason: q.id);
        expect(q.questionG.trim(), isNotEmpty, reason: q.id);
        expect(q.questionGh, isEmpty, reason: q.id);
        expect(q.marks, const <int>[2, 4, 4], reason: q.id);
        expect(q.source, QuestionSource.original, reason: q.id);
        expect(q.sourceLabel, 'Original chapter practice', reason: q.id);
      }
    });

    test('no LaTeX, placeholders or unverified board labels', () {
      final banned = RegExp(
        r'\\begin|\\frac|TODO|FIXME|lorem|placeholder|Board 20[0-9][0-9]',
        caseSensitive: false,
      );
      for (final text in <String>[
        ...generalMathMcqs.expand(
          (q) => <String>[q.questionText, q.explanation, ...q.options],
        ),
        ...generalMathSaqs.expand(
          (q) => <String>[q.questionText, q.answer, q.explanation],
        ),
        ...generalMathCqs.expand(
          (q) => <String>[q.stem, q.questionK, q.questionKh, q.questionG],
        ),
      ]) {
        expect(banned.hasMatch(text), isFalse, reason: text);
      }
    });
  });

  group('100-mark Mathematics board pattern', () {
    late GeneralMathBoardPaper paper;

    setUp(() {
      paper = GeneralMathBoardPatternGenerator.generate(
        mcqBank: allMCQs,
        saqBank: allSAQs,
        cqBank: allCQs,
        random: Random(2027),
      );
    });

    int countByDivision(Iterable<dynamic> questions, String division) {
      final valid = GeneralMathDivisions.chaptersFor(division).toSet();
      return questions.where((q) => valid.contains(q.chapter)).length;
    }

    test('creates exact available/answer counts and 100 answer marks', () {
      expect(paper.mcqs.length, 30);
      expect(paper.saqs.length, 15);
      expect(paper.cqs.length, 8);
      const answerMarks = GeneralMathBoardPatternGenerator.cqAnswerCount * 10 +
          GeneralMathBoardPatternGenerator.saqAnswerCount * 2 +
          GeneralMathBoardPatternGenerator.mcqAnswerCount;
      expect(answerMarks, 100);
    });

    test('MCQ division distribution is 13, 12, 4 and 1', () {
      expect(countByDivision(paper.mcqs, GeneralMathDivisions.algebra), 13);
      expect(countByDivision(paper.mcqs, GeneralMathDivisions.geometry), 12);
      expect(
        countByDivision(
          paper.mcqs,
          GeneralMathDivisions.trigonometryMensuration,
        ),
        4,
      );
      expect(countByDivision(paper.mcqs, GeneralMathDivisions.statistics), 1);
    });

    test('SAQ division distribution is fair at 4, 4, 4 and 3', () {
      expect(countByDivision(paper.saqs, GeneralMathDivisions.algebra), 4);
      expect(countByDivision(paper.saqs, GeneralMathDivisions.geometry), 4);
      expect(
        countByDivision(
          paper.saqs,
          GeneralMathDivisions.trigonometryMensuration,
        ),
        4,
      );
      expect(countByDivision(paper.saqs, GeneralMathDivisions.statistics), 3);
    });

    test('CQs provide two from each division and use 2-4-4 marks', () {
      for (final division in GeneralMathDivisions.names) {
        expect(countByDivision(paper.cqs, division), 2, reason: division);
      }
      for (final q in paper.cqs) {
        expect(q.marks, const <int>[2, 4, 4], reason: q.id);
        expect(q.questionGh, isEmpty, reason: q.id);
      }
    });
  });

  group('aggregate compatibility', () {
    test('new records are reachable through existing aggregate names', () {
      expect(allMCQs.where((q) => q.subjectId == 'general_math').length, 1363);
      expect(allSAQs.where((q) => q.subjectId == 'general_math').length, 340);
      expect(
        allCQs.where((q) => q.subjectId == 'general_math').length,
        greaterThanOrEqualTo(170),
      );
      for (final q in generalMathMcqs.take(20)) {
        expect(allMCQs.any((item) => item.id == q.id), isTrue, reason: q.id);
      }
    });

    test('non-Math banks remain connected', () {
      expect(allMCQs.where((q) => q.subjectId == 'physics'), isNotEmpty);
      expect(allMCQs.where((q) => q.subjectId == 'chemistry').length, 605);
      expect(allMCQs.where((q) => q.subjectId == 'biology').length, 720);
      expect(allMCQs.where((q) => q.subjectId == 'higher_math').length, 7);
    });
  });
}
