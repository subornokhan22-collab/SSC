import 'dart:math';

import '../data/general_math/general_math_divisions.dart';
import '../data/questions_data.dart';

class GeneralMathBoardPaper {
  final List<Question> mcqs;
  final List<ShortQuestion> saqs;
  final List<CreativeQuestion> cqs;

  const GeneralMathBoardPaper({
    required this.mcqs,
    required this.saqs,
    required this.cqs,
  });
}

/// Builds the SSC Mathematics 100-mark board pattern from the stored bank.
class GeneralMathBoardPatternGenerator {
  GeneralMathBoardPatternGenerator._();

  static const int mcqAnswerCount = 30;
  static const int saqAvailableCount = 15;
  static const int saqAnswerCount = 10;
  static const int cqAvailableCount = 8;
  static const int cqAnswerCount = 5;

  static const Map<String, int> mcqDistribution = <String, int>{
    GeneralMathDivisions.algebra: 13,
    GeneralMathDivisions.geometry: 12,
    GeneralMathDivisions.trigonometryMensuration: 4,
    GeneralMathDivisions.statistics: 1,
  };

  static const Map<String, int> saqDistribution = <String, int>{
    GeneralMathDivisions.algebra: 4,
    GeneralMathDivisions.geometry: 4,
    GeneralMathDivisions.trigonometryMensuration: 4,
    GeneralMathDivisions.statistics: 3,
  };

  static const Map<String, int> cqDistribution = <String, int>{
    GeneralMathDivisions.algebra: 2,
    GeneralMathDivisions.geometry: 2,
    GeneralMathDivisions.trigonometryMensuration: 2,
    GeneralMathDivisions.statistics: 2,
  };

  static List<T> _take<T>(
    Iterable<T> values,
    String Function(T value) chapterOf,
    String division,
    int count,
    Random random,
  ) {
    final validChapters = GeneralMathDivisions.chaptersFor(division).toSet();
    final pool =
        values
            .where((value) => validChapters.contains(chapterOf(value)))
            .toList()
          ..shuffle(random);
    if (pool.length < count) {
      throw StateError(
        '$division-এ ${count}টি প্রশ্ন দরকার, কিন্তু ব্যাংকে ${pool.length}টি আছে।',
      );
    }
    return pool.take(count).toList(growable: false);
  }

  static CreativeQuestion _mathThreePart(
    CreativeQuestion question,
    String division,
  ) => CreativeQuestion(
    id: question.id,
    subjectId: question.subjectId,
    chapter: question.chapter,
    stem: '[$division] ${question.stem}',
    questionK: question.questionK,
    questionKh: question.questionKh,
    questionG: question.questionG,
    questionGh: '',
    marks: const <int>[2, 4, 4],
    source: question.source,
    sourceLabel: question.sourceLabel,
    figure: question.figure,
  );

  static GeneralMathBoardPaper generate({
    required Iterable<Question> mcqBank,
    required Iterable<ShortQuestion> saqBank,
    required Iterable<CreativeQuestion> cqBank,
    Random? random,
  }) {
    final rng = random ?? Random();
    final mathMcqs = mcqBank.where(
      (q) =>
          q.subjectId == 'general_math' &&
          q.source == QuestionSource.original &&
          q.sourceLabel == 'Original chapter practice',
    );
    final mathSaqs = saqBank.where(
      (q) =>
          q.subjectId == 'general_math' &&
          q.source == QuestionSource.original &&
          q.sourceLabel == 'Original chapter practice',
    );
    final mathCqs = cqBank.where(
      (q) =>
          q.subjectId == 'general_math' &&
          q.source == QuestionSource.original &&
          q.sourceLabel == 'Original chapter practice',
    );

    final mcqs = <Question>[];
    final saqs = <ShortQuestion>[];
    final cqs = <CreativeQuestion>[];

    for (final division in GeneralMathDivisions.names) {
      mcqs.addAll(
        _take(
          mathMcqs,
          (q) => q.chapter,
          division,
          mcqDistribution[division]!,
          rng,
        ),
      );
      saqs.addAll(
        _take(
          mathSaqs,
          (q) => q.chapter,
          division,
          saqDistribution[division]!,
          rng,
        ),
      );
      cqs.addAll(
        _take(
          mathCqs,
          (q) => q.chapter,
          division,
          cqDistribution[division]!,
          rng,
        ).map((q) => _mathThreePart(q, division)),
      );
    }

    mcqs.shuffle(rng);
    saqs.shuffle(rng);

    if (mcqs.length != mcqAnswerCount ||
        saqs.length != saqAvailableCount ||
        cqs.length != cqAvailableCount) {
      throw StateError('গণিত বোর্ড প্যাটার্নের প্রশ্নসংখ্যা সঠিক হয়নি।');
    }

    return GeneralMathBoardPaper(
      mcqs: List<Question>.unmodifiable(mcqs),
      saqs: List<ShortQuestion>.unmodifiable(saqs),
      cqs: List<CreativeQuestion>.unmodifiable(cqs),
    );
  }
}
