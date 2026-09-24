import '../../data/questions_data.dart';

/// One validation outcome.
///
/// [errors] are fatal — the question must not be shown as AI-verified.
/// [warnings] are suspicion flags (the question may still be fine, but
/// a teacher should look) — e.g. the explanation talks about a
/// different option than the stored key.
class QuestionValidation {
  bool get valid => errors.isEmpty;
  final List<String> errors;
  final List<String> warnings;
  const QuestionValidation({this.errors = const [], this.warnings = const []});

  /// Merges another validation into a new one.
  QuestionValidation merged(QuestionValidation other) =>
      QuestionValidation(
        errors: [...errors, ...other.errors],
        warnings: [...warnings, ...other.warnings],
      );
}

/// Structural + content validation for AI-generated MCQs (review items
/// #2 and #6). Runs before any AI question reaches the UI:
///
///   Generate → schema validation → duplicate check → (answer check) → UI
///
/// The old string-slicing JSON parser is gone; whatever generates the
/// questions must still pass through this — a model can emit malformed
/// arrays, nested brackets, or a wrong "correct" index at any time.
class QuestionSchemaValidator {
  QuestionSchemaValidator._();

  /// Same banned patterns the bundled-bank guard tests use: no LaTeX
  /// markup, no placeholder text, no invented board-year claims.
  static final RegExp _banned = RegExp(
    r'\\begin|\\frac|TODO|FIXME|lorem|placeholder|Board 20[0-9][0-9]',
    caseSensitive: false,
  );

  /// Validates one MCQ.
  static QuestionValidation validateMcq(Question q) {
    final errors = <String>[];
    final warnings = <String>[];

    final stem = q.questionText.trim();
    if (stem.isEmpty) errors.add('empty question text');

    if (q.options.length != 4) {
      errors.add('has ${q.options.length} options, expected 4');
    }
    final normOpts = [
      for (final o in q.options) _norm(o),
    ];
    if (normOpts.toSet().length != normOpts.length) {
      errors.add('options are not distinct');
    }
    for (var i = 0; i < q.options.length; i++) {
      if (q.options[i].trim().isEmpty) errors.add('option $i is empty');
    }
    if (q.correctIndex < 0 || q.correctIndex >= q.options.length) {
      errors.add('correctIndex ${q.correctIndex} out of range');
    }
    if (q.explanation.trim().isEmpty) {
      errors.add('explanation is empty');
    }

    for (final text in [q.questionText, q.explanation, ...q.options]) {
      if (_banned.hasMatch(text)) {
        errors.add('banned content (LaTeX/placeholder): ${text.trim().substring(0, text.trim().length > 40 ? 40 : text.trim().length)}…');
        break;
      }
    }

    // Answer-sanity heuristic (review item #6, cheap local half): if the
    // explanation quotes an option's wording, it should quote the
    // correct one — not a distractor.
    if (errors.isNotEmpty) return QuestionValidation(errors: errors);
    final exp = _norm(q.explanation);
    if (exp.isNotEmpty) {
      String? mentionedWrong;
      bool mentionsCorrect = false;
      for (var i = 0; i < normOpts.length; i++) {
        final opt = normOpts[i];
        if (opt.length < 8) continue; // too short to be a meaningful quote
        final quoted = exp.contains(opt) || _sharesLongFragment(exp, opt);
        if (!quoted) continue;
        if (i == q.correctIndex) {
          mentionsCorrect = true;
        } else {
          mentionedWrong ??= q.options[i].trim();
        }
      }
      if (mentionedWrong != null && !mentionsCorrect) {
        warnings.add(
            'explanation appears to reference option "${mentionedWrong.length > 40 ? '${mentionedWrong.substring(0, 40)}…' : mentionedWrong}" instead of the stored key');
      }
    }
    return QuestionValidation(errors: errors, warnings: warnings);
  }

  /// Validates a batch: per-question checks plus batch-level rules
  /// (requested count, in-batch duplicates).
  static List<QuestionValidation> validateBatch(List<Question> questions,
      {int expectedCount = -1}) {
    final out = [for (final q in questions) validateMcq(q)];
    if (expectedCount > 0 && questions.length != expectedCount) {
      for (var i = 0; i < out.length; i++) {
        out[i] = out[i].merged(QuestionValidation(
            errors:
                ['batch has ${questions.length} questions, expected $expectedCount']));
      }
    }
    final seen = <String, int>{};
    for (var i = 0; i < questions.length; i++) {
      final key = _norm(questions[i].questionText);
      final first = seen[key];
      if (first != null) {
        out[i] = out[i].merged(QuestionValidation(
            errors: ['duplicate of question #${first + 1} in the same batch']));
      } else {
        seen[key] = i;
      }
    }
    return out;
  }

  /// True when [hay] contains a word-run of [needle] at least 8 chars —
  /// catches "option text" quotes that survive light rephrasing.
  static bool _sharesLongFragment(String hay, String needle) {
    if (needle.length < 8) return false;
    final words = needle.split(' ').where((w) => w.length >= 8).toList();
    for (final w in words) {
      if (hay.contains(w)) return true;
    }
    // Otherwise check the first 12-char run.
    final run = needle.length >= 12 ? needle.substring(0, 12) : needle;
    return hay.contains(run);
  }

  static String _norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
}
