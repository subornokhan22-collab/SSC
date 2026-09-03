import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'support/bank_fixture.dart';

import 'package:mentors_companion/data/ict/ict_chapter_catalog.dart';

import 'package:mentors_companion/data/questions_data.dart';
import 'package:mentors_companion/services/chapter_catalog.dart';
import 'package:mentors_companion/services/ict_board_pattern.dart';

void main() {
  late final List<Question> ictMcqs;

  setUpAll(() {
    BankFixture.ensureLoaded();
    ictMcqs = BankFixture.mcqsIn('ict_mcqs');
  });

  group('ICT MCQ-only chapter catalog', () {
    test('uses the exact six Bengali chapters in numeric order', () {
      expect(
        IctChapterCatalog.chapters,
        const <String>[
          'অধ্যায় ১: তথ্য ও যোগাযোগ প্রযুক্তি ও আমাদের বাংলাদেশ',
          'অধ্যায় ২: কম্পিউটার রক্ষণাবেক্ষণ ও সাইবার নিরাপত্তা',
          'অধ্যায় ৩: ইন্টারনেট ও ওয়েব পরিচিতি',
          'অধ্যায় ৪: আমার লেখালেখি ও হিসাব',
          'অধ্যায় ৫: মাল্টিমিডিয়া ও গ্রাফিক্স',
          'অধ্যায় ৬: প্রোগ্রামিংয়ের মাধ্যমে সমস্যার সমাধান',
        ],
      );
      expect(IctChapterCatalog.displayName, 'তথ্য ও যোগাযোগ প্রযুক্তি');
      expect(
        ChapterCatalog.ordered(const <String>[], subjectId: 'ict'),
        IctChapterCatalog.chapters,
      );
    });

    test('every ICT question maps to an official chapter', () {
      final valid = IctChapterCatalog.chapters.toSet();
      for (final q in ictMcqs) {
        expect(valid.contains(q.chapter), isTrue, reason: q.id);
      }
    });
  });

  group('ICT MCQ bank', () {
    test('contains exactly 1200 MCQs and 200 per chapter', () {
      expect(ictMcqs.length, 1200);
      for (final chapter in IctChapterCatalog.chapters) {
        expect(ictMcqs.where((q) => q.chapter == chapter).length, 200,
            reason: chapter);
      }
    });

    test('has unique ids and unique stems', () {
      final ids = <String>{};
      final stems = <String>{};
      for (final q in ictMcqs) {
        expect(ids.add(q.id), isTrue, reason: q.id);
        expect(stems.add(q.questionText.trim()), isTrue, reason: q.id);
      }
    });

    test('every MCQ has four distinct options, one key and explanation', () {
      for (final q in ictMcqs) {
        expect(q.subjectId, 'ict', reason: q.id);
        expect(q.options.length, 4, reason: q.id);
        expect(q.options.toSet().length, 4, reason: q.id);
        expect(q.correctIndex, inInclusiveRange(0, 3), reason: q.id);
        expect(q.options[q.correctIndex].trim(), isNotEmpty, reason: q.id);
        expect(q.explanation.trim(), isNotEmpty, reason: q.id);
        expect(q.source, QuestionSource.original, reason: q.id);
        expect(q.sourceLabel, 'Original chapter practice', reason: q.id);
      }
    });

    test('contains no LaTeX, placeholder or unverified board label', () {
      final banned = RegExp(
        r'\\begin|\\frac|TODO|FIXME|lorem ipsum|Board 20[0-9][0-9]',
        caseSensitive: false,
      );
      for (final text in ictMcqs.expand(
        (q) => <String>[q.questionText, q.explanation, ...q.options],
      )) {
        expect(banned.hasMatch(text), isFalse, reason: text);
      }
    });

    test('ICT remains MCQ-only in all existing aggregates', () {
      expect(allMCQs.where((q) => q.subjectId == 'ict').length, 1200);
      expect(allSAQs.where((q) => q.subjectId == 'ict'), isEmpty);
      expect(allCQs.where((q) => q.subjectId == 'ict'), isEmpty);
    });
  });

  group('ICT board pattern', () {
    test('generates exactly 25 original MCQs for 25 marks', () {
      final paper = IctBoardPatternGenerator.generate(
        allMCQs,
        random: Random(2027),
      );
      expect(paper.length, IctBoardPatternGenerator.mcqCount);
      expect(IctBoardPatternGenerator.mcqCount, 25);
      expect(IctBoardPatternGenerator.fullMarks, 25);
      expect(IctBoardPatternGenerator.timeMinutes, 60);
      expect(paper.map((q) => q.id).toSet().length, 25);
      for (final q in paper) {
        expect(q.subjectId, 'ict');
        expect(q.source, QuestionSource.original);
        expect(q.sourceLabel, 'Original chapter practice');
      }
    });
  });

  group('non-ICT preservation', () {
    test('existing major subject banks remain connected', () {
      expect(allMCQs.where((q) => q.subjectId == 'physics'), isNotEmpty);
      expect(allMCQs.where((q) => q.subjectId == 'chemistry').length, 605);
      expect(allMCQs.where((q) => q.subjectId == 'biology').length, 701);
      expect(allMCQs.where((q) => q.subjectId == 'general_math').length, 1363);
      expect(allMCQs.where((q) => q.subjectId == 'higher_math').length, 7);
    });
  });
}
