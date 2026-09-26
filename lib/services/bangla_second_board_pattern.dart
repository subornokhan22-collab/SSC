import 'dart:math';

import '../data/bangla_2nd/bangla_2nd_written_questions.dart';
import '../data/questions_data.dart';

class BanglaSecondBoardPaper {
  final List<Question> mcqs;
  final List<Bangla2WrittenQuestion> writtenQuestions;

  const BanglaSecondBoardPaper({
    required this.mcqs,
    required this.writtenQuestions,
  });
}

class BanglaSecondBoardPatternGenerator {
  BanglaSecondBoardPatternGenerator._();

  static const int mcqCount = 30;
  static const int fullMarks = 100;
  static const int writtenMarks = 70;
  static const int mcqMarks = 30;

  static const Map<Bangla2WrittenType, int> availability =
      <Bangla2WrittenType, int>{
    Bangla2WrittenType.paragraph: 2,
    Bangla2WrittenType.letterOrReport: 2,
    Bangla2WrittenType.summaryOrGist: 2,
    Bangla2WrittenType.thoughtExpansion: 2,
    Bangla2WrittenType.translation: 2,
    Bangla2WrittenType.composition: 3,
  };

  static List<T> _take<T>(List<T> values, int count, Random random) {
    final pool = List<T>.from(values)..shuffle(random);
    if (pool.length < count) {
      throw StateError(
        'বাংলা দ্বিতীয় পত্রে ${count}টি প্রশ্ন দরকার, কিন্তু ব্যাংকে ${pool.length}টি আছে।',
      );
    }
    return pool.take(count).toList(growable: false);
  }

  static BanglaSecondBoardPaper generate({
    required Iterable<Question> mcqBank,
    required Iterable<Bangla2WrittenQuestion> writtenBank,
    Random? random,
  }) {
    final rng = random ?? Random();
    final grammar = mcqBank
        .where(
          (q) =>
              q.subjectId == 'bangla_2nd' &&
              q.source == QuestionSource.original &&
              q.sourceLabel == 'Original grammar practice',
        )
        .toList();
    final mcqs = _take(grammar, mcqCount, rng);
    final written = <Bangla2WrittenQuestion>[];
    for (final entry in availability.entries) {
      final pool = writtenBank
          .where(
            (q) =>
                q.type == entry.key &&
                q.source == QuestionSource.original &&
                q.sourceLabel == 'Original written practice',
          )
          .toList();
      written.addAll(_take(pool, entry.value, rng));
    }
    if (written.length != 13) {
      throw StateError(
        'বাংলা দ্বিতীয় পত্রের রচনামূলক প্রশ্নসংখ্যা সঠিক হয়নি।',
      );
    }
    return BanglaSecondBoardPaper(
      mcqs: List<Question>.unmodifiable(mcqs),
      writtenQuestions: List<Bangla2WrittenQuestion>.unmodifiable(written),
    );
  }
}
