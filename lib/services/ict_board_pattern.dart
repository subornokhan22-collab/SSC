import 'dart:math';

import '../data/questions_data.dart';

/// Generates the official MCQ-only ICT board pattern.
class IctBoardPatternGenerator {
  IctBoardPatternGenerator._();

  static const int mcqCount = 25;
  static const int fullMarks = 25;
  static const int timeMinutes = 60;

  static List<Question> generate(Iterable<Question> bank, {Random? random}) {
    final rng = random ?? Random();
    final pool = bank
        .where(
          (q) =>
              q.subjectId == 'ict' &&
              q.source == QuestionSource.original &&
              q.sourceLabel == 'Original chapter practice',
        )
        .toList()
      ..shuffle(rng);
    if (pool.length < mcqCount) {
      throw StateError(
        'ICT বোর্ড প্যাটার্নে ${mcqCount}টি MCQ দরকার, কিন্তু ব্যাংকে ${pool.length}টি আছে।',
      );
    }
    return List<Question>.unmodifiable(pool.take(mcqCount));
  }
}
