import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'question_figure.dart' show QuestionFigure;
import 'questions_data.dart';

/// Loads the question bank from the JSON assets in `assets/questions/`.
///
/// Step 1 of docs/question-bank-migration.md: the questions used to be
/// ~250k lines of `const` Dart literals. They are now data files, generated
/// by `tool/extract_questions.py`.
///
/// The public getters [allMCQs], [allSAQs] and [allCQs] keep the exact names
/// and types the old `questions_data.dart` exported, so every screen and
/// pattern generator is unchanged. The only new requirement is that
/// [QuestionBank.load] completes before they are read — `main()` awaits it.
class QuestionBank {
  QuestionBank._();

  static List<Question> _mcqs = const [];
  static List<ShortQuestion> _saqs = const [];
  static List<CreativeQuestion> _cqs = const [];
  static bool _loaded = false;

  /// True once the bank has been read from assets.
  static bool get isLoaded => _loaded;

  static List<Question> get mcqs => _mcqs;
  static List<ShortQuestion> get saqs => _saqs;
  static List<CreativeQuestion> get cqs => _cqs;

  /// Number of questions currently held, across all three types.
  static int get total => _mcqs.length + _saqs.length + _cqs.length;

  /// Reads every file listed in `assets/questions/manifest.json`.
  ///
  /// Safe to call more than once; later calls are no-ops. Decoding happens on
  /// a background isolate so the splash screen keeps animating.
  static Future<void> load() async {
    if (_loaded) return;

    final manifestRaw =
        await rootBundle.loadString('assets/questions/manifest.json');
    final manifest = json.decode(manifestRaw) as Map<String, dynamic>;
    final files = (manifest['files'] as List).cast<String>();

    final sources = <String>[];
    for (final name in files) {
      sources.add(await rootBundle.loadString('assets/questions/$name'));
    }

    final parsed = await compute(_decodeAll, sources);

    _mcqs = List<Question>.unmodifiable(parsed.mcqs);
    _saqs = List<ShortQuestion>.unmodifiable(parsed.saqs);
    _cqs = List<CreativeQuestion>.unmodifiable(parsed.cqs);
    _loaded = true;

    final expected = manifest['total'];
    if (expected is int && expected != total) {
      debugPrint(
        'QuestionBank: manifest says $expected questions but loaded $total',
      );
    }
  }

  /// Test seam — lets widget tests install a small bank without touching
  /// the asset bundle.
  @visibleForTesting
  static void seed({
    List<Question> mcqs = const [],
    List<ShortQuestion> saqs = const [],
    List<CreativeQuestion> cqs = const [],
  }) {
    _mcqs = List<Question>.unmodifiable(mcqs);
    _saqs = List<ShortQuestion>.unmodifiable(saqs);
    _cqs = List<CreativeQuestion>.unmodifiable(cqs);
    _loaded = true;
  }
}

/// Result holder so one `compute` call can return all three lists.
class _Decoded {
  final List<Question> mcqs;
  final List<ShortQuestion> saqs;
  final List<CreativeQuestion> cqs;
  const _Decoded(this.mcqs, this.saqs, this.cqs);
}

/// Runs on a background isolate.
_Decoded _decodeAll(List<String> sources) {
  final mcqs = <Question>[];
  final saqs = <ShortQuestion>[];
  final cqs = <CreativeQuestion>[];

  for (final raw in sources) {
    final rows = json.decode(raw) as List;
    for (final row in rows) {
      final map = row as Map<String, dynamic>;
      switch (map['type']) {
        case 'mcq':
          mcqs.add(questionFromJson(map));
        case 'saq':
          saqs.add(shortQuestionFromJson(map));
        case 'cq':
          cqs.add(creativeQuestionFromJson(map));
      }
    }
  }
  return _Decoded(mcqs, saqs, cqs);
}

QuestionSource _sourceFrom(Object? v) => switch (v) {
      'board' => QuestionSource.board,
      'original' => QuestionSource.original,
      'internet' => QuestionSource.internet,
      _ => QuestionSource.ai,
    };

QuestionFigure? _figureFrom(Object? v) {
  if (v == null) return null;
  final m = v as Map<String, dynamic>;
  final headers = (m['headers'] as List?)?.cast<String>() ?? const <String>[];
  final caption = m['caption'] as String?;
  switch (m['kind']) {
    case 'table':
      return QuestionFigure.table(
        headers: headers,
        rows: ((m['rows'] as List?) ?? const [])
            .map((r) => (r as List).cast<String>())
            .toList(growable: false),
        caption: caption,
      );
    case 'triangle':
      return QuestionFigure.triangle(
        vertices: headers,
        sides: (m['sides'] as List?)?.cast<String>() ?? const <String>[],
        angles: (m['angles'] as List?)?.cast<String>() ?? const <String>[],
        rightAngleAt: m['rightAngleAt'] as String?,
        caption: caption,
      );
    case 'barChart':
      return QuestionFigure.barChart(
        labels: headers,
        values: (m['values'] as List?)?.cast<int>() ?? const <int>[],
        caption: caption,
      );
    case 'image':
      return QuestionFigure.image(
        imagePath: m['imagePath'] as String? ?? '',
        aspect: (m['aspect'] as num?)?.toDouble() ?? 1.4,
        caption: caption,
      );
  }
  return null;
}

/// Rebuilds a [Question] from one exported JSON row.
Question questionFromJson(Map<String, dynamic> m) {
  final p = m['payload'] as Map<String, dynamic>;
  return Question(
    id: m['id'] as String,
    subjectId: m['subjectId'] as String,
    chapter: m['chapter'] as String,
    questionText: p['questionText'] as String,
    options: (p['options'] as List).cast<String>(),
    correctIndex: p['correctIndex'] as int,
    explanation: (p['explanation'] as String?) ?? '',
    source: _sourceFrom(m['source']),
    sourceLabel: m['sourceLabel'] as String?,
    figure: _figureFrom(m['figure']),
  );
}

/// Rebuilds a [ShortQuestion] from one exported JSON row.
ShortQuestion shortQuestionFromJson(Map<String, dynamic> m) {
  final p = m['payload'] as Map<String, dynamic>;
  return ShortQuestion(
    id: m['id'] as String,
    subjectId: m['subjectId'] as String,
    chapter: m['chapter'] as String,
    questionText: p['questionText'] as String,
    answer: p['answer'] as String,
    explanation: (p['explanation'] as String?) ?? '',
    source: _sourceFrom(m['source']),
    sourceLabel: m['sourceLabel'] as String?,
    figure: _figureFrom(m['figure']),
  );
}

/// Rebuilds a [CreativeQuestion] from one exported JSON row.
CreativeQuestion creativeQuestionFromJson(Map<String, dynamic> m) {
  final p = m['payload'] as Map<String, dynamic>;
  return CreativeQuestion(
    id: m['id'] as String,
    subjectId: m['subjectId'] as String,
    chapter: m['chapter'] as String,
    stem: p['stem'] as String,
    questionK: p['questionK'] as String,
    questionKh: p['questionKh'] as String,
    questionG: p['questionG'] as String,
    questionGh: p['questionGh'] as String,
    marks: (p['marks'] as List?)?.cast<int>() ?? const [1, 2, 3, 4],
    source: _sourceFrom(m['source']),
    sourceLabel: m['sourceLabel'] as String?,
    figure: _figureFrom(m['figure']),
  );
}
