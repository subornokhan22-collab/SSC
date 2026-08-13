import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:a_learning/data/bangla_1st/bangla_1st_catalog.dart';
import 'package:a_learning/data/bangla_1st/bangla_1st_cqs.dart';
import 'package:a_learning/data/bangla_1st/bangla_1st_literature_questions.dart';
import 'package:a_learning/data/bangla_1st/bangla_1st_mcqs.dart';
import 'package:a_learning/data/bangla_1st/bangla_1st_revision_questions.dart';
import 'package:a_learning/data/questions_data.dart';
import 'package:a_learning/services/bangla_first_board_pattern.dart';
import 'package:a_learning/services/chapter_catalog.dart';

void main() {
  group('Bangla First Paper final syllabus catalog', () {
    test('contains the exact 15 prose lessons', () {
      expect(BanglaFirstCatalog.goddo.length, 15);
      expect(BanglaFirstCatalog.goddo.first,
          'প্রত্যুপকার — ঈশ্বরচন্দ্র বিদ্যাসাগর');
      expect(BanglaFirstCatalog.goddo.last, 'আমাদের নতুন গৌরবগাথা — সংকলিত');
    });

    test('contains the exact 15 poems and PDF-specified final spelling', () {
      expect(BanglaFirstCatalog.kobita.length, 15);
      expect(BanglaFirstCatalog.kobita.first, 'বন্দনা — শাহ মুহম্মদ সগীর');
      expect(BanglaFirstCatalog.kobita.last, 'বোশেখ — আল মাহমুদ');
    });

    test('contains only 30 lessons plus novel and drama in exact order', () {
      expect(BanglaFirstCatalog.novel, '১৯৭১ — হুমায়ূন আহমেদ');
      expect(BanglaFirstCatalog.drama, 'বহিপীর — সৈয়দ ওয়ালীউল্লাহ');
      expect(BanglaFirstCatalog.chapters.length, 32);
      expect(
        ChapterCatalog.ordered(const <String>[], subjectId: 'bangla_1st'),
        BanglaFirstCatalog.chapters,
      );
      expect(BanglaFirstCatalog.displayName, 'বাংলা প্রথম পত্র');
    });
  });

  group('Bangla First Paper bank counts', () {
    test('grand totals match the target', () {
      expect(banglaFirstMcqs.length, 1700);
      expect(banglaFirstRevisionQuestions.length, 680);
      expect(banglaFirstCqs.length, 300);
      expect(banglaFirstLiteratureQuestions.length, 40);
    });

    test('every prose lesson has 50 MCQ, 20 revision and 10 CQ', () {
      for (final chapter
          in BanglaFirstCatalog.chapters.where((c) => c.startsWith('গদ্য:'))) {
        expect(banglaFirstMcqs.where((q) => q.chapter == chapter).length, 50,
            reason: chapter);
        expect(
            banglaFirstRevisionQuestions
                .where((q) => q.chapter == chapter)
                .length,
            20,
            reason: chapter);
        expect(banglaFirstCqs.where((q) => q.chapter == chapter).length, 10,
            reason: chapter);
      }
    });

    test('every poem has 50 MCQ, 20 revision and 10 CQ', () {
      for (final chapter
          in BanglaFirstCatalog.chapters.where((c) => c.startsWith('কবিতা:'))) {
        expect(banglaFirstMcqs.where((q) => q.chapter == chapter).length, 50,
            reason: chapter);
        expect(
            banglaFirstRevisionQuestions
                .where((q) => q.chapter == chapter)
                .length,
            20,
            reason: chapter);
        expect(banglaFirstCqs.where((q) => q.chapter == chapter).length, 10,
            reason: chapter);
      }
    });

    test('novel and drama each have 100 MCQ, 40 revision and 20 literature',
        () {
      for (final entry in const <String, String>{
        'উপন্যাস': 'উপন্যাস: ১৯৭১',
        'নাটক': 'নাটক: বহিপীর',
      }.entries) {
        expect(
            banglaFirstMcqs.where((q) => q.chapter == entry.value).length, 100);
        expect(
            banglaFirstRevisionQuestions
                .where((q) => q.chapter == entry.value)
                .length,
            40);
        expect(
            banglaFirstLiteratureQuestions
                .where((q) => q.section == entry.key)
                .length,
            20);
      }
    });
  });

  group('Bangla First Paper well-formedness', () {
    test('MCQs have unique ids/stems, four options, one key and source', () {
      final ids = <String>{};
      final stems = <String>{};
      for (final q in banglaFirstMcqs) {
        expect(ids.add(q.id), isTrue, reason: q.id);
        expect(stems.add(q.questionText.trim()), isTrue, reason: q.id);
        expect(q.options.length, 4, reason: q.id);
        expect(q.options.toSet().length, 4, reason: q.id);
        expect(q.correctIndex, inInclusiveRange(0, 3), reason: q.id);
        expect(q.explanation.trim(), isNotEmpty, reason: q.id);
        expect(q.source, QuestionSource.original, reason: q.id);
        expect(q.sourceLabel, 'Original chapter practice', reason: q.id);
      }
    });

    test('revision and creative questions are complete', () {
      for (final q in banglaFirstRevisionQuestions) {
        expect(q.answer.trim(), isNotEmpty, reason: q.id);
        expect(q.explanation.trim(), isNotEmpty, reason: q.id);
        expect(q.source, QuestionSource.original, reason: q.id);
      }
      for (final q in banglaFirstCqs) {
        expect(q.stem.trim(), isNotEmpty, reason: q.id);
        expect(q.questionK.trim(), isNotEmpty, reason: q.id);
        expect(q.questionKh.trim(), isNotEmpty, reason: q.id);
        expect(q.questionG.trim(), isNotEmpty, reason: q.id);
        expect(q.questionGh.trim(), isNotEmpty, reason: q.id);
        expect(q.marks, const <int>[1, 2, 3, 4], reason: q.id);
      }
    });

    test('literature questions use exactly two parts and 3-7 marks', () {
      final ids = <String>{};
      for (final q in banglaFirstLiteratureQuestions) {
        expect(ids.add(q.id), isTrue, reason: q.id);
        expect(q.subjectId, 'bangla_1st', reason: q.id);
        expect(<String>['উপন্যাস', 'নাটক'].contains(q.section), isTrue);
        expect(q.stem.trim(), isNotEmpty, reason: q.id);
        expect(q.questionK.trim(), isNotEmpty, reason: q.id);
        expect(q.questionKh.trim(), isNotEmpty, reason: q.id);
        expect(q.answerGuideK.trim(), isNotEmpty, reason: q.id);
        expect(q.answerGuideKh.trim(), isNotEmpty, reason: q.id);
        expect(q.marks, const <int>[3, 7], reason: q.id);
        expect(q.source, QuestionSource.original, reason: q.id);
        expect(q.sourceLabel, 'Original chapter practice', reason: q.id);
      }
    });
  });

  group('Bangla First board pattern', () {
    late BanglaFirstBoardPaper paper;
    setUp(() {
      paper = BanglaFirstBoardPatternGenerator.generate(
        mcqBank: allMCQs,
        cqBank: allCQs,
        literatureBank: banglaFirstLiteratureQuestions,
        random: Random(2027),
      );
    });

    test('generates 15+15 MCQs and 4+4 CQs', () {
      expect(paper.mcqs.length, 30);
      expect(paper.mcqs.where((q) => q.chapter.startsWith('গদ্য:')).length, 15);
      expect(
          paper.mcqs.where((q) => q.chapter.startsWith('কবিতা:')).length, 15);
      expect(paper.cqs.length, 8);
      expect(paper.cqs.where((q) => q.chapter.startsWith('গদ্য:')).length, 4);
      expect(paper.cqs.where((q) => q.chapter.startsWith('কবিতা:')).length, 4);
    });

    test('generates two novel and two drama questions', () {
      expect(paper.literatureQuestions.length, 4);
      expect(
          paper.literatureQuestions.where((q) => q.section == 'উপন্যাস').length,
          2);
      expect(paper.literatureQuestions.where((q) => q.section == 'নাটক').length,
          2);
    });

    test('answer-rule marks total exactly 100', () {
      const total = 5 * 10 + 2 * 10 + 30;
      expect(total, 100);
      expect(BanglaFirstBoardPatternGenerator.cqAnswerCount, 5);
      expect(BanglaFirstBoardPatternGenerator.literatureAnswerCount, 2);
      expect(BanglaFirstBoardPatternGenerator.mcqCount, 30);
    });
  });

  group('aggregate compatibility', () {
    test('Bangla records are reachable without replacing other subjects', () {
      expect(allMCQs.where((q) => q.subjectId == 'bangla_1st').length, 1700);
      expect(allSAQs.where((q) => q.subjectId == 'bangla_1st').length, 680);
      expect(allCQs.where((q) => q.subjectId == 'bangla_1st').length, 300);
      expect(allMCQs.where((q) => q.subjectId == 'ict').length, 1200);
      expect(allMCQs.where((q) => q.subjectId == 'general_math').length, 1363);
      expect(allMCQs.where((q) => q.subjectId == 'chemistry').length, 605);
      expect(allMCQs.where((q) => q.subjectId == 'biology').length, 701);
    });
  });
}
