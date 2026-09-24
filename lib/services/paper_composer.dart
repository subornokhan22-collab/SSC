import 'dart:math';

import '../data/questions_data.dart';
import '../data/bangla_1st/bangla_1st_literature_questions.dart';
import '../data/bangla_2nd/bangla_2nd_written_questions.dart';
import '../data/english_board_data.dart';
import '../data/english_first_data.dart';
import '../models/paper_draft.dart';
import 'bangla_first_board_pattern.dart';
import 'bangla_second_board_pattern.dart';
import 'general_math_board_pattern.dart';
import 'ict_board_pattern.dart';
import 'english_paper_adapter.dart';
import 'paper_pdf.dart';

class ComposedPaper {
  final List<Question> mcqs;
  final List<ShortQuestion> saqs;
  final List<CreativeQuestion> cqs;
  final List<LiteratureQuestion> literature;
  final List<Bangla2WrittenQuestion> written;
  final List<EnglishSection> english;
  final int cqAnswers;
  final int saqAnswers;
  final int marks;
  final int minutes;
  final String note;

  const ComposedPaper(
      {this.mcqs = const [],
      this.saqs = const [],
      this.cqs = const [],
      this.literature = const [],
      this.written = const [],
      this.english = const [],
      this.cqAnswers = 0,
      this.saqAnswers = 0,
      this.marks = 0,
      this.minutes = 60,
      this.note = 'সবগুলো প্রশ্নের উত্তর দাও।'});

  ComposedPaper withMcqs(List<Question> next) => ComposedPaper(
        mcqs: List.unmodifiable(next),
        saqs: saqs,
        cqs: cqs,
        literature: literature,
        written: written,
        english: english,
        cqAnswers: cqAnswers,
        saqAnswers: saqAnswers,
        marks: marks - mcqs.length + next.length,
        minutes: minutes,
        note: note,
      );
  ComposedPaper withWritten(
      {List<ShortQuestion>? short, List<CreativeQuestion>? creative}) {
    final nextShort = short ?? saqs;
    final nextCreative = creative ?? cqs;
    final sa = min(saqAnswers, nextShort.length);
    final ca = min(cqAnswers, nextCreative.length);
    return ComposedPaper(
        mcqs: mcqs,
        saqs: List.unmodifiable(nextShort),
        cqs: List.unmodifiable(nextCreative),
        literature: literature,
        written: written,
        english: english,
        cqAnswers: ca,
        saqAnswers: sa,
        marks: marks + (sa - saqAnswers) * 2 + (ca - cqAnswers) * 10,
        minutes: minutes,
        note: ca == cqAnswers
            ? note
            : '$caটি সৃজনশীল প্রশ্নের উত্তর দাও। প্রতিটি প্রশ্নের মান ১০।');
  }
}

/// One engine for the four former entry points. A shortage is an error, never
/// a silently shortened paper. Existing subject-specific distributions are reused.
class PaperComposer {
  final List<Question> mcqBank;
  final List<ShortQuestion> saqBank;
  final List<CreativeQuestion> cqBank;
  final Random random;
  PaperComposer(
      {required this.mcqBank,
      required this.saqBank,
      required this.cqBank,
      Random? random})
      : random = random ?? Random();

  static const codes = <String, String>{
    'bangla_1st': '১০১',
    'bangla_2nd': '১০২',
    'english_1st': '১০৭',
    'english_2nd': '১০৮',
    'general_math': '১০৯',
    'religion': '১১১',
    'general_science': '১২৭',
    'agriculture': '১৩৪',
    'higher_math': '১২৬',
    'physics': '১৩৬',
    'chemistry': '১৩৭',
    'biology': '১৩৮',
    'business_ent': '১৪৩',
    'accounting': '১৪৬',
    'finance': '১৫২',
    'ict': '১৫৪',
    'bgs': '১৫০',
    'history': '১১০',
    'civics': '১৪০',
  };

  static bool isEnglish(String id) =>
      id == 'english_1st' || id == 'english_2nd';
  static const science = {
    'physics',
    'chemistry',
    'biology',
    'higher_math',
    'agriculture'
  };
  static (int, int, int) defaults(String id) => id == 'ict'
      ? (25, 0, 0)
      : science.contains(id)
          ? (25, 7, 7)
          : (30, 15, 8);

  List<T> _take<T>(Iterable<T> source, int count, String label) {
    final pool = source.toList()..shuffle(random);
    if (pool.length < count)
      throw StateError(
          '$label: requested $count, but only ${pool.length} are available. Choose more chapters or reduce the count.');
    return List.unmodifiable(pool.take(count));
  }

  List<Question> uniqueMcqs(Iterable<Question> source) {
    final stems = <String>{};
    return source
        .where((q) => stems.add(q.questionText
            .toLowerCase()
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim()))
        .toList();
  }

  ComposedPaper compose(PaperDraft draft) {
    if (draft.mcqCount < 0 ||
        draft.mcqCount > 100 ||
        draft.saqCount < 0 ||
        draft.saqCount > 30 ||
        draft.cqCount < 0 ||
        draft.cqCount > 15) {
      throw StateError('Question counts are outside the supported range.');
    }
    final sid = draft.subjectId;
    final board = draft.format == PaperFormat.board;
    if (isEnglish(sid)) {
      if (!board)
        throw StateError(
            'English uses the complete Reading/Grammar and Writing board pattern.');
      return ComposedPaper(
          english: sid == 'english_1st'
              ? EnglishPaperAdapter.first(
                  EnglishFirstMixer.mix(rng: random).set)
              : EnglishPaperAdapter.second(
                  EnglishBoardMixer.mix(rng: random).set),
          marks: 100,
          minutes: 180);
    }
    if (!board &&
        draft.format == PaperFormat.chapter &&
        draft.chapters.isEmpty) {
      throw StateError('Select at least one chapter.');
    }
    bool chapter(String ch) =>
        board || draft.chapters.isEmpty || draft.chapters.contains(ch);
    final mcqs = uniqueMcqs(
        mcqBank.where((q) => q.subjectId == sid && chapter(q.chapter)));
    final saqs = saqBank.where((q) => q.subjectId == sid && chapter(q.chapter));
    final cqs = cqBank.where((q) => q.subjectId == sid && chapter(q.chapter));
    if (board && sid == 'general_math') {
      final p = GeneralMathBoardPatternGenerator.generate(
          mcqBank: mcqs, saqBank: saqs, cqBank: cqs, random: random);
      return ComposedPaper(
          mcqs: p.mcqs,
          saqs: p.saqs,
          cqs: p.cqs,
          cqAnswers: 5,
          saqAnswers: 10,
          marks: 100,
          minutes: 180,
          note:
              '৮টি থেকে ৫টি উত্তর দাও; প্রত্যেক বিভাগ থেকে অন্তত ১টি। প্রতিটি প্রশ্নের মান ১০।');
    }
    if (board && sid == 'ict') {
      return ComposedPaper(
          mcqs: IctBoardPatternGenerator.generate(mcqs, random: random),
          marks: 25,
          minutes: 60);
    }
    if (board && sid == 'bangla_1st') {
      final p = BanglaFirstBoardPatternGenerator.generate(
          mcqBank: mcqs,
          cqBank: cqs,
          literatureBank: banglaFirstLiteratureQuestions,
          random: random);
      return ComposedPaper(
          mcqs: p.mcqs,
          cqs: p.cqs,
          literature: p.literatureQuestions,
          cqAnswers: 5,
          marks: 100,
          minutes: 180,
          note:
              'গদ্য ও কবিতা থেকে ন্যূনতম ২টি করে মোট ৫টি সৃজনশীল প্রশ্নের উত্তর দাও।');
    }
    if (board && sid == 'bangla_2nd') {
      final p = BanglaSecondBoardPatternGenerator.generate(
          mcqBank: mcqs,
          writtenBank: bangla2ndWrittenQuestions,
          random: random);
      return ComposedPaper(
          mcqs: p.mcqs, written: p.writtenQuestions, marks: 100, minutes: 180);
    }
    if (board &&
        {'finance', 'accounting', 'physical_edu', 'career'}.contains(sid)) {
      throw StateError(
          'This subject needs a dedicated board-pattern bank. Use a custom paper where questions are available; no incomplete board paper will be generated.');
    }
    final counts = board
        ? defaults(sid)
        : (
            draft.mcqCount,
            draft.format == PaperFormat.mcq ? 0 : draft.saqCount,
            draft.format == PaperFormat.mcq ? 0 : draft.cqCount
          );
    if (counts.$1 + counts.$2 + counts.$3 == 0)
      throw StateError('Add at least one question.');
    final selectedMcqs = _take(mcqs, counts.$1, 'MCQ');
    final selectedSaqs = _take(saqs, counts.$2, 'Short answer');
    final selectedCqs = _take(cqs, counts.$3, 'Creative question');
    final cqAnswers =
        board ? (science.contains(sid) ? 4 : 5) : selectedCqs.length;
    final saqAnswers =
        board ? (science.contains(sid) ? 5 : 10) : selectedSaqs.length;
    final marks = selectedMcqs.length + cqAnswers * 10 + saqAnswers * 2;
    return ComposedPaper(
        mcqs: selectedMcqs,
        saqs: selectedSaqs,
        cqs: selectedCqs,
        cqAnswers: cqAnswers,
        saqAnswers: saqAnswers,
        marks: marks,
        minutes: board
            ? 180
            : max(10, selectedMcqs.length + saqAnswers * 3 + cqAnswers * 12),
        note: board
            ? '$cqAnswersটি সৃজনশীল প্রশ্নের উত্তর দাও। প্রতিটি প্রশ্নের মান ১০।'
            : 'সবগুলো সৃজনশীল প্রশ্নের উত্তর দাও। প্রতিটি প্রশ্নের মান ১০।');
  }
}
