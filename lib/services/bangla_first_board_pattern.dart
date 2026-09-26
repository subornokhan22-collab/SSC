import 'dart:math';

import '../data/bangla_1st/bangla_1st_catalog.dart';
import '../data/bangla_1st/bangla_1st_literature_questions.dart';
import '../data/questions_data.dart';

class BanglaFirstBoardPaper {
  final List<Question> mcqs;
  final List<CreativeQuestion> cqs;
  final List<LiteratureQuestion> literatureQuestions;

  const BanglaFirstBoardPaper({
    required this.mcqs,
    required this.cqs,
    required this.literatureQuestions,
  });
}

class BanglaFirstBoardPatternGenerator {
  BanglaFirstBoardPatternGenerator._();

  static const int mcqCount = 30;
  static const int cqAvailableCount = 8;
  static const int cqAnswerCount = 5;
  static const int literatureAvailableCount = 4;
  static const int literatureAnswerCount = 2;

  static List<T> _take<T>(List<T> pool, int count, Random random) {
    final values = List<T>.from(pool)..shuffle(random);
    if (values.length < count) {
      throw StateError(
        'বাংলা প্রথম পত্র বোর্ড প্যাটার্নে ${count}টি প্রশ্ন দরকার, কিন্তু ব্যাংকে ${values.length}টি আছে।',
      );
    }
    return values.take(count).toList(growable: false);
  }

  static CreativeQuestion _labelCq(CreativeQuestion q, String section) =>
      CreativeQuestion(
        id: q.id,
        subjectId: q.subjectId,
        chapter: q.chapter,
        stem: '[$section] ${q.stem}',
        questionK: q.questionK,
        questionKh: q.questionKh,
        questionG: q.questionG,
        questionGh: q.questionGh,
        marks: q.marks,
        source: q.source,
        sourceLabel: q.sourceLabel,
        figure: q.figure,
      );

  static BanglaFirstBoardPaper generate({
    required Iterable<Question> mcqBank,
    required Iterable<CreativeQuestion> cqBank,
    required Iterable<LiteratureQuestion> literatureBank,
    Random? random,
  }) {
    final rng = random ?? Random();
    bool original(String? label, QuestionSource source) =>
        source == QuestionSource.original &&
        label == 'Original chapter practice';

    final goddoChapters = BanglaFirstCatalog.chapters
        .where((chapter) => chapter.startsWith('গদ্য:'))
        .toSet();
    final kobitaChapters = BanglaFirstCatalog.chapters
        .where((chapter) => chapter.startsWith('কবিতা:'))
        .toSet();

    final goddoMcqs = mcqBank
        .where(
          (q) =>
              q.subjectId == 'bangla_1st' &&
              goddoChapters.contains(q.chapter) &&
              original(q.sourceLabel, q.source),
        )
        .toList();
    final kobitaMcqs = mcqBank
        .where(
          (q) =>
              q.subjectId == 'bangla_1st' &&
              kobitaChapters.contains(q.chapter) &&
              original(q.sourceLabel, q.source),
        )
        .toList();
    final goddoCqs = cqBank
        .where(
          (q) =>
              q.subjectId == 'bangla_1st' &&
              goddoChapters.contains(q.chapter) &&
              original(q.sourceLabel, q.source),
        )
        .toList();
    final kobitaCqs = cqBank
        .where(
          (q) =>
              q.subjectId == 'bangla_1st' &&
              kobitaChapters.contains(q.chapter) &&
              original(q.sourceLabel, q.source),
        )
        .toList();
    final novel = literatureBank
        .where(
          (q) =>
              q.subjectId == 'bangla_1st' &&
              q.section == 'উপন্যাস' &&
              original(q.sourceLabel, q.source),
        )
        .toList();
    final drama = literatureBank
        .where(
          (q) =>
              q.subjectId == 'bangla_1st' &&
              q.section == 'নাটক' &&
              original(q.sourceLabel, q.source),
        )
        .toList();

    final mcqs = <Question>[
      ..._take(goddoMcqs, 15, rng),
      ..._take(kobitaMcqs, 15, rng),
    ]..shuffle(rng);
    final cqs = <CreativeQuestion>[
      ..._take(goddoCqs, 4, rng).map((q) => _labelCq(q, 'গদ্য')),
      ..._take(kobitaCqs, 4, rng).map((q) => _labelCq(q, 'কবিতা')),
    ];
    final literature = <LiteratureQuestion>[
      ..._take(novel, 2, rng),
      ..._take(drama, 2, rng),
    ];

    return BanglaFirstBoardPaper(
      mcqs: List<Question>.unmodifiable(mcqs),
      cqs: List<CreativeQuestion>.unmodifiable(cqs),
      literatureQuestions: List<LiteratureQuestion>.unmodifiable(literature),
    );
  }
}
