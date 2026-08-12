import 'package:flutter_test/flutter_test.dart';

import 'package:a_learning/data/biology/biology_chapter_catalog.dart';
import 'package:a_learning/data/biology/biology_cqs.dart';
import 'package:a_learning/data/biology/biology_mcqs.dart';
import 'package:a_learning/data/biology/biology_saqs.dart';
import 'package:a_learning/data/questions_data.dart';
import 'package:a_learning/services/chapter_catalog.dart';

void main() {
  group('Biology chapter catalog', () {
    test('uses the exact 14-chapter Bengali order', () {
      expect(
        BiologyChapterCatalog.chapters,
        equals(const <String>[
          'অধ্যায় ১: জীবন পাঠ',
          'অধ্যায় ২: জীবকোষ ও টিস্যু',
          'অধ্যায় ৩: কোষ বিভাজন',
          'অধ্যায় ৪: জীবনীশক্তি',
          'অধ্যায় ৫: খাদ্য, পুষ্টি এবং পরিপাক',
          'অধ্যায় ৬: জীবে পরিবহন',
          'অধ্যায় ৭: গ্যাসীয় বিনিময়',
          'অধ্যায় ৮: রেচন প্রক্রিয়া',
          'অধ্যায় ৯: দৃঢ়তা প্রদান ও চলন',
          'অধ্যায় ১০: সমন্বয়',
          'অধ্যায় ১১: জীবের প্রজনন',
          'অধ্যায় ১২: জীবের বংশগতি ও জৈব অভিব্যক্তি',
          'অধ্যায় ১৩: জীবের পরিবেশ',
          'অধ্যায় ১৪: জীবপ্রযুক্তি',
        ]),
      );
      expect(BiologyChapterCatalog.displayName, 'জীববিজ্ঞান');
      expect(
        ChapterCatalog.ordered(const <String>[], subjectId: 'biology'),
        BiologyChapterCatalog.chapters,
      );
    });

    test('every new Biology record maps to an official chapter', () {
      final valid = BiologyChapterCatalog.chapters.toSet();
      for (final q in biologyMcqs) {
        expect(valid.contains(q.chapter), isTrue, reason: q.id);
      }
      for (final q in biologySaqs) {
        expect(valid.contains(q.chapter), isTrue, reason: q.id);
      }
      for (final q in biologyCqs) {
        expect(valid.contains(q.chapter), isTrue, reason: q.id);
      }
    });

    test('aggregate Biology chapter labels are official and never mixed', () {
      final valid = BiologyChapterCatalog.chapters.toSet();
      final banned = RegExp(
        r'অধ্যায়\s*[০-৯0-9]+\s*ও\s*[০-৯0-9]+|মিলিয়ে|mixed|board-style',
        caseSensitive: false,
      );
      for (final q in allMCQs.where((q) => q.subjectId == 'biology')) {
        expect(valid.contains(q.chapter), isTrue, reason: q.id);
        expect(banned.hasMatch(q.chapter), isFalse, reason: q.id);
      }
    });
  });

  group('Biology coverage', () {
    test('dedicated bank has exactly the requested minimum totals', () {
      expect(biologyMcqs.length, 700);
      expect(biologySaqs.length, 280);
      expect(biologyCqs.length, 140);
    });

    test('each chapter has 50 MCQ, 20 SAQ and 10 CQ', () {
      for (final chapter in BiologyChapterCatalog.chapters) {
        expect(
          biologyMcqs.where((q) => q.chapter == chapter).length,
          50,
          reason: chapter,
        );
        expect(
          biologySaqs.where((q) => q.chapter == chapter).length,
          20,
          reason: chapter,
        );
        expect(
          biologyCqs.where((q) => q.chapter == chapter).length,
          10,
          reason: chapter,
        );
      }
    });
  });

  group('Biology well-formedness', () {
    test('ids are globally unique inside the Biology bank', () {
      final ids = <String>{};
      for (final id in <String>[
        ...biologyMcqs.map((q) => q.id),
        ...biologySaqs.map((q) => q.id),
        ...biologyCqs.map((q) => q.id),
      ]) {
        expect(ids.add(id), isTrue, reason: 'duplicate id: $id');
      }
    });

    test('MCQs have four distinct options, one key and explanations', () {
      for (final q in biologyMcqs) {
        expect(q.subjectId, 'biology', reason: q.id);
        expect(q.questionText.trim(), isNotEmpty, reason: q.id);
        expect(q.options.length, 4, reason: q.id);
        expect(q.options.toSet().length, 4, reason: q.id);
        expect(q.correctIndex, inInclusiveRange(0, 3), reason: q.id);
        expect(q.options[q.correctIndex].trim(), isNotEmpty, reason: q.id);
        expect(q.explanation.trim(), isNotEmpty, reason: q.id);
        expect(q.source, QuestionSource.original, reason: q.id);
        expect(q.sourceLabel, 'Original chapter practice', reason: q.id);
      }
    });

    test('MCQ stems do not repeat', () {
      final seen = <String>{};
      for (final q in biologyMcqs) {
        final normalized =
            q.questionText.replaceAll(RegExp(r'\s+'), ' ').trim();
        expect(seen.add(normalized), isTrue, reason: q.id);
      }
    });

    test('SAQs contain direct answer, explanation and source', () {
      final stems = <String>{};
      for (final q in biologySaqs) {
        expect(q.subjectId, 'biology', reason: q.id);
        expect(q.questionText.trim(), isNotEmpty, reason: q.id);
        expect(stems.add(q.questionText.trim()), isTrue, reason: q.id);
        expect(q.answer.trim(), isNotEmpty, reason: q.id);
        expect(q.explanation.trim(), isNotEmpty, reason: q.id);
        expect(q.source, QuestionSource.original, reason: q.id);
        expect(q.sourceLabel, 'Original chapter practice', reason: q.id);
      }
    });

    test('CQs contain stem, four parts and 1-2-3-4 marks', () {
      final stems = <String>{};
      for (final q in biologyCqs) {
        expect(q.subjectId, 'biology', reason: q.id);
        expect(q.stem.trim(), isNotEmpty, reason: q.id);
        expect(stems.add(q.stem.trim()), isTrue, reason: q.id);
        expect(q.questionK.trim(), isNotEmpty, reason: q.id);
        expect(q.questionKh.trim(), isNotEmpty, reason: q.id);
        expect(q.questionG.trim(), isNotEmpty, reason: q.id);
        expect(q.questionGh.trim(), isNotEmpty, reason: q.id);
        expect(q.marks, equals(const <int>[1, 2, 3, 4]), reason: q.id);
        expect(q.source, QuestionSource.original, reason: q.id);
        expect(q.sourceLabel, 'Original chapter practice', reason: q.id);
      }
    });

    test('no LaTeX, placeholder or unverified board label is present', () {
      final banned = RegExp(
        r'\\begin|\\frac|TODO|FIXME|lorem|placeholder|Board 20[0-9][0-9]',
        caseSensitive: false,
      );
      for (final text in <String>[
        ...biologyMcqs.expand(
          (q) => <String>[q.questionText, q.explanation, ...q.options],
        ),
        ...biologySaqs.expand(
          (q) => <String>[q.questionText, q.answer, q.explanation],
        ),
        ...biologyCqs.expand(
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

  group('aggregate compatibility', () {
    test('all Biology data is reachable through existing aggregate names', () {
      for (final q in biologyMcqs) {
        expect(allMCQs.any((item) => item.id == q.id), isTrue, reason: q.id);
      }
      for (final q in biologySaqs) {
        expect(allSAQs.any((item) => item.id == q.id), isTrue, reason: q.id);
      }
      for (final q in biologyCqs) {
        expect(allCQs.any((item) => item.id == q.id), isTrue, reason: q.id);
      }
      expect(
        allMCQs.where((q) => q.subjectId == 'biology').length,
        701,
      );
      expect(
        allMCQs
            .where((q) =>
                q.subjectId == 'biology' &&
                q.chapter == 'অধ্যায় ৬: জীবে পরিবহন')
            .length,
        51,
      );
    });

    test('existing Chemistry and other subject totals remain connected', () {
      const expectedMcqs = <String, int>{
        'chemistry': 605,
        'general_math': 513,
        'higher_math': 7,
        'finance': 1,
        'accounting': 1,
      };
      expectedMcqs.forEach((subjectId, count) {
        expect(
          allMCQs.where((q) => q.subjectId == subjectId).length,
          count,
          reason: '$subjectId data changed during Biology merge',
        );
      });
    });
  });
}
