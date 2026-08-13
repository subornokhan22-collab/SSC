import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:a_learning/data/bangla_2nd/bangla_2nd_catalog.dart';
import 'package:a_learning/data/bangla_2nd/bangla_2nd_grammar_mcqs.dart';
import 'package:a_learning/data/bangla_2nd/bangla_2nd_written_questions.dart';
import 'package:a_learning/data/questions_data.dart';
import 'package:a_learning/services/bangla_second_board_pattern.dart';
import 'package:a_learning/services/chapter_catalog.dart';

void main() {
  group('Bangla Second Paper grammar catalog', () {
    test('contains all exact 43 sections in numeric order', () {
      expect(BanglaSecondCatalog.grammarChapters.length, 43);
      expect(BanglaSecondCatalog.grammarChapters.first,
          'পরিচ্ছেদ ১: ভাষা ও বাংলা ভাষা');
      expect(BanglaSecondCatalog.grammarChapters.last, 'পরিচ্ছেদ ৪৩: শব্দজোড়');
      expect(
        ChapterCatalog.ordered(const <String>[], subjectId: 'bangla_2nd'),
        BanglaSecondCatalog.grammarChapters,
      );
      expect(BanglaSecondCatalog.displayName, 'বাংলা দ্বিতীয় পত্র');
    });
  });

  group('Bangla Second Paper bank counts and shape', () {
    test('contains exactly 4300 grammar MCQs and 100 per section', () {
      expect(bangla2ndGrammarMcqs.length, 4300);
      for (final chapter in BanglaSecondCatalog.grammarChapters) {
        expect(
          bangla2ndGrammarMcqs.where((q) => q.chapter == chapter).length,
          100,
          reason: chapter,
        );
      }
    });

    test('MCQs have unique ids/stems, four options and one answer', () {
      final ids = <String>{};
      final stems = <String>{};
      for (final q in bangla2ndGrammarMcqs) {
        expect(ids.add(q.id), isTrue, reason: q.id);
        expect(stems.add('${q.chapter}|${q.questionText}'), isTrue,
            reason: q.id);
        expect(q.subjectId, 'bangla_2nd', reason: q.id);
        expect(q.options.length, 4, reason: q.id);
        expect(q.options.toSet().length, 4, reason: q.id);
        expect(q.correctIndex, inInclusiveRange(0, 3), reason: q.id);
        expect(q.explanation.trim(), isNotEmpty, reason: q.id);
        expect(q.source, QuestionSource.original, reason: q.id);
        expect(q.sourceLabel, 'Original grammar practice', reason: q.id);
      }
    });

    test('contains 100 written questions in each of six types', () {
      expect(bangla2ndWrittenQuestions.length, 600);
      for (final type in Bangla2WrittenType.values) {
        expect(
          bangla2ndWrittenQuestions.where((q) => q.type == type).length,
          100,
          reason: type.name,
        );
      }
    });

    test('written marks are 10 except composition which is 20', () {
      for (final q in bangla2ndWrittenQuestions) {
        expect(q.prompt.trim(), isNotEmpty, reason: q.id);
        expect(q.answerGuide.trim(), isNotEmpty, reason: q.id);
        expect(
          q.marks,
          q.type == Bangla2WrittenType.composition ? 20 : 10,
          reason: q.id,
        );
        expect(q.source, QuestionSource.original, reason: q.id);
        expect(q.sourceLabel, 'Original written practice', reason: q.id);
      }
    });

    test('Bangla Second remains free of CQ and SAQ aggregates', () {
      expect(allMCQs.where((q) => q.subjectId == 'bangla_2nd').length, 4300);
      expect(allCQs.where((q) => q.subjectId == 'bangla_2nd'), isEmpty);
      expect(allSAQs.where((q) => q.subjectId == 'bangla_2nd'), isEmpty);
    });
  });

  group('Bangla Second board pattern', () {
    late BanglaSecondBoardPaper paper;
    setUp(() {
      paper = BanglaSecondBoardPatternGenerator.generate(
        mcqBank: allMCQs,
        writtenBank: bangla2ndWrittenQuestions,
        random: Random(2027),
      );
    });

    test('generates exactly 30 grammar MCQs', () {
      expect(paper.mcqs.length, 30);
      expect(paper.mcqs.map((q) => q.id).toSet().length, 30);
      for (final q in paper.mcqs) {
        expect(q.subjectId, 'bangla_2nd');
        expect(q.sourceLabel, 'Original grammar practice');
      }
    });

    test('generates 2,2,2,2,2,3 written availability', () {
      expect(paper.writtenQuestions.length, 13);
      for (final entry
          in BanglaSecondBoardPatternGenerator.availability.entries) {
        expect(
          paper.writtenQuestions.where((q) => q.type == entry.key).length,
          entry.value,
          reason: entry.key.name,
        );
      }
    });

    test('answer-rule marks total exactly 100', () {
      const written = 10 + 10 + 10 + 10 + 10 + 20;
      const mcq = 30;
      expect(written, 70);
      expect(written + mcq, 100);
      expect(BanglaSecondBoardPatternGenerator.fullMarks, 100);
    });
  });

  group('other subject preservation', () {
    test('existing banks remain connected', () {
      expect(allMCQs.where((q) => q.subjectId == 'bangla_1st').length, 1700);
      expect(allMCQs.where((q) => q.subjectId == 'ict').length, 1200);
      expect(allMCQs.where((q) => q.subjectId == 'general_math').length, 1363);
      expect(allMCQs.where((q) => q.subjectId == 'chemistry').length, 605);
      expect(allMCQs.where((q) => q.subjectId == 'biology').length, 701);
      expect(allMCQs.where((q) => q.subjectId == 'physics'), isNotEmpty);
    });
  });
}
