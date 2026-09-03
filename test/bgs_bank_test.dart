import 'package:flutter_test/flutter_test.dart';

import 'support/bank_fixture.dart';

import 'package:mentors_companion/data/bgs/bgs_chapter_catalog.dart';

import 'package:mentors_companion/data/questions_data.dart';
import 'package:mentors_companion/services/chapter_catalog.dart';

void main() {
  late final List<CreativeQuestion> bgsCqs;
  late final List<Question> bgsMcqs;
  late final List<ShortQuestion> bgsSaqs;

  setUpAll(() {
    BankFixture.ensureLoaded();
    bgsCqs = BankFixture.cqsIn('bgs_cqs');
    bgsMcqs = BankFixture.mcqsIn('bgs_mcqs');
    bgsSaqs = BankFixture.saqsIn('bgs_saqs');
  });

  group('BGS chapter catalog', () {
    test('uses the exact supplied 15-chapter Bengali sequence', () {
      expect(
        BgsChapterCatalog.chapters,
        equals(const <String>[
          'অধ্যায় ১: পূর্ব বাংলার আন্দোলন ও জাতীয়তাবাদের উত্থান (১৯৪৭-১৯৭০)',
          'অধ্যায় ২: বাংলাদেশের স্বাধীনতা',
          'অধ্যায় ৩: সৌরজগৎ ও ভূমণ্ডল',
          'অধ্যায় ৪: বাংলাদেশের ভূপ্রকৃতি ও জলবায়ু',
          'অধ্যায় ৫: বাংলাদেশের নদ-নদী ও প্রাকৃতিক সম্পদ',
          'অধ্যায় ৬: রাষ্ট্র, নাগরিকতা ও আইন',
          'অধ্যায় ৭: বাংলাদেশ সরকারের বিভিন্ন অঙ্গ ও প্রশাসন ব্যবস্থা',
          'অধ্যায় ৮: বাংলাদেশের গণতন্ত্র ও নির্বাচন ব্যবস্থা',
          'অধ্যায় ৯: জাতিসংঘ ও বাংলাদেশ',
          'অধ্যায় ১০: জাতীয় সম্পদ ও অর্থনৈতিক ব্যবস্থা',
          'অধ্যায় ১১: অর্থনৈতিক নির্দেশকসমূহ ও বাংলাদেশের অর্থনীতির প্রকৃতি',
          'অধ্যায় ১২: বাংলাদেশ সরকারের অর্থ ও ব্যাংক ব্যবস্থা',
          'অধ্যায় ১৩: বাংলাদেশের পরিবার কাঠামো ও সামাজিকীকরণ',
          'অধ্যায় ১৪: বাংলাদেশের সামাজিক পরিবর্তন',
          'অধ্যায় ১৫: বাংলাদেশের সামাজিক সমস্যা ও প্রতিকার',
        ]),
      );
      expect(BgsChapterCatalog.subjectId, 'bgs');
      expect(BgsChapterCatalog.displayName, 'বাংলাদেশ ও বিশ্বপরিচয়');
      expect(
        ChapterCatalog.ordered(const <String>[], subjectId: 'bgs'),
        BgsChapterCatalog.chapters,
      );
    });

    test('every BGS item maps to one official, non-mixed chapter', () {
      final valid = BgsChapterCatalog.chapters.toSet();
      final banned = RegExp(
        r'অধ্যায়\s*[০-৯0-9]+\s*ও\s*[০-৯0-9]+|মিলিয়ে|mixed|board-style',
        caseSensitive: false,
      );
      for (final chapterAndId in <(String, String)>[
        ...bgsMcqs.map((q) => (q.chapter, q.id)),
        ...bgsSaqs.map((q) => (q.chapter, q.id)),
        ...bgsCqs.map((q) => (q.chapter, q.id)),
      ]) {
        expect(valid.contains(chapterAndId.$1), isTrue,
            reason: chapterAndId.$2);
        expect(banned.hasMatch(chapterAndId.$1), isFalse,
            reason: chapterAndId.$2);
      }
    });
  });

  group('BGS exact coverage', () {
    test('contains 1500 MCQs, 300 SAQs and 150 CQs', () {
      expect(bgsMcqs.length, 1500);
      expect(bgsSaqs.length, 300);
      expect(bgsCqs.length, 150);
    });

    test('each chapter has exactly 100 MCQs, 20 SAQs and 10 CQs', () {
      for (final chapter in BgsChapterCatalog.chapters) {
        expect(bgsMcqs.where((q) => q.chapter == chapter).length, 100,
            reason: chapter);
        expect(bgsSaqs.where((q) => q.chapter == chapter).length, 20,
            reason: chapter);
        expect(bgsCqs.where((q) => q.chapter == chapter).length, 10,
            reason: chapter);
      }
    });
  });

  group('BGS well-formedness and originality', () {
    test('all IDs are globally unique within the BGS bank', () {
      final seen = <String>{};
      for (final id in <String>[
        ...bgsMcqs.map((q) => q.id),
        ...bgsSaqs.map((q) => q.id),
        ...bgsCqs.map((q) => q.id),
      ]) {
        expect(seen.add(id), isTrue, reason: 'duplicate ID: $id');
      }
    });

    test('every MCQ has four distinct options, one valid key and provenance',
        () {
      final stems = <String>{};
      for (final q in bgsMcqs) {
        expect(q.subjectId, 'bgs', reason: q.id);
        expect(q.questionText.trim(), isNotEmpty, reason: q.id);
        expect(stems.add(q.questionText.replaceAll(RegExp(r'\s+'), ' ').trim()),
            isTrue,
            reason: 'duplicate stem: ${q.id}');
        expect(q.options.length, 4, reason: q.id);
        expect(q.options.map((o) => o.trim()).toSet().length, 4, reason: q.id);
        expect(q.options.every((o) => o.trim().isNotEmpty), isTrue,
            reason: q.id);
        expect(q.correctIndex, inInclusiveRange(0, 3), reason: q.id);
        expect(q.explanation.trim(), isNotEmpty, reason: q.id);
        expect(q.source, QuestionSource.original, reason: q.id);
        expect(q.sourceLabel, 'Original chapter practice', reason: q.id);
      }
    });

    test('every SAQ has a unique stem, concise answer and explanation', () {
      final stems = <String>{};
      for (final q in bgsSaqs) {
        expect(q.subjectId, 'bgs', reason: q.id);
        expect(stems.add(q.questionText.trim()), isTrue,
            reason: 'duplicate stem: ${q.id}');
        expect(q.answer.trim(), isNotEmpty, reason: q.id);
        expect(q.explanation.trim(), isNotEmpty, reason: q.id);
        expect(q.source, QuestionSource.original, reason: q.id);
        expect(q.sourceLabel, 'Original chapter practice', reason: q.id);
      }
    });

    test('every CQ has a unique stem, four parts and 1-2-3-4 marks', () {
      final stems = <String>{};
      for (final q in bgsCqs) {
        expect(q.subjectId, 'bgs', reason: q.id);
        expect(stems.add(q.stem.trim()), isTrue,
            reason: 'duplicate stem: ${q.id}');
        expect(q.stem.trim(), isNotEmpty, reason: q.id);
        expect(q.questionK.trim(), isNotEmpty, reason: q.id);
        expect(q.questionKh.trim(), isNotEmpty, reason: q.id);
        expect(q.questionG.trim(), isNotEmpty, reason: q.id);
        expect(q.questionGh.trim(), isNotEmpty, reason: q.id);
        expect(q.marks, const <int>[1, 2, 3, 4], reason: q.id);
        expect(q.source, QuestionSource.original, reason: q.id);
        expect(q.sourceLabel, 'Original chapter practice', reason: q.id);
      }
    });

    test('content has no LaTeX, placeholder or false board-year labels', () {
      final banned = RegExp(
        r'\\begin|\\frac|TODO|FIXME|lorem|placeholder|Board 20[0-9][0-9]',
        caseSensitive: false,
      );
      for (final text in <String>[
        ...bgsMcqs.expand(
          (q) => <String>[q.questionText, q.explanation, ...q.options],
        ),
        ...bgsSaqs.expand(
          (q) => <String>[q.questionText, q.answer, q.explanation],
        ),
        ...bgsCqs.expand(
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

  group('BGS aggregate compatibility', () {
    test('all dedicated records remain reachable through existing aggregates',
        () {
      final aggregateMcqIds = allMCQs.map((q) => q.id).toSet();
      final aggregateSaqIds = allSAQs.map((q) => q.id).toSet();
      final aggregateCqIds = allCQs.map((q) => q.id).toSet();
      expect(aggregateMcqIds.containsAll(bgsMcqs.map((q) => q.id)), isTrue);
      expect(aggregateSaqIds.containsAll(bgsSaqs.map((q) => q.id)), isTrue);
      expect(aggregateCqIds.containsAll(bgsCqs.map((q) => q.id)), isTrue);
    });

    test('selected-chapter pools can honor any requested total up to 100', () {
      for (final chapter in BgsChapterCatalog.chapters) {
        final pool = allMCQs
            .where((q) => q.subjectId == 'bgs' && q.chapter == chapter)
            .toList();
        expect(pool.length, 100, reason: chapter);
        pool.shuffle();
        expect(pool.take(100).length, 100, reason: chapter);
      }
    });

    test('pre-existing subject banks remain connected', () {
      const minimums = <String, int>{
        'physics': 1,
        'chemistry': 1,
        'biology': 1,
        'general_math': 1,
        'ict': 1,
        'bangla_1st': 1,
        'bangla_2nd': 1,
      };
      minimums.forEach((subjectId, minimum) {
        expect(allMCQs.where((q) => q.subjectId == subjectId).length,
            greaterThanOrEqualTo(minimum),
            reason: '$subjectId was disconnected during the BGS merge');
      });
    });
  });
}
