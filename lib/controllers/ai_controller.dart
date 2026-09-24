import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/questions_data.dart';
import '../data/question_bank.dart';
import '../services/auth_service.dart';
import '../services/ai/teacher_ai_client.dart';
import '../services/ai/question_schema_validator.dart';
import '../services/ai/duplicate_detector.dart';
import '../services/paper_snapshot.dart';
import 'operation_controller.dart';

enum TeacherCommand { create, improve, check, explain }

class AiController extends OperationController {
  final TeacherAiClient client;
  final List<Question> bank;
  final List<Question> currentPaper;
  List<Question> questions = [];
  final Set<String> checkedIds = {};
  final Map<String, String> difficulty = {};
  List<DuplicateHit> duplicates = [];
  List<Question> _previous = [];
  List<Question> _comparison = [];
  String? summary;
  List<Map<String, String>> findings = [];
  String? historyWarning;
  AiController({
    required this.bank,
    this.currentPaper = const [],
    TeacherAiClient? client,
  }) : client = client ?? TeacherAiClient();
  bool get canUse => !busy && questions.isNotEmpty && duplicates.isEmpty;
  String get _historyKey =>
      'teacher_ai_history_${AuthService.email ?? 'offline'}';

  Future<bool> execute({
    required TeacherCommand command,
    required String subjectId,
    required List<String> chapters,
    required int count,
    required String level,
    required String text,
    required String instruction,
  }) => run('Reading selected chapter metadata…', () async {
    if (chapters.isEmpty)
      throw StateError('Choose a chapter from the local question bank.');
    if (count < 1 || count > 10)
      throw StateError('Choose between 1 and 10 questions.');
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    try {
      _previous = raw == null
          ? []
          : (jsonDecode(raw) as List)
                .map(
                  (q) => questionFromJson(Map<String, dynamic>.from(q as Map)),
                )
                .toList();
    } catch (_) {
      throw StateError(
        'AI history could not be read. Restore device storage before generating, so duplicate checking is not bypassed.',
      );
    }
    final response = await client.request({
      'action': command == TeacherCommand.create ? 'generate' : command.name,
      'subjectId': subjectId,
      'chapters': chapters,
      'count': count,
      'difficulty': level,
      'text': text,
      'instruction': instruction,
    }, progress);
    if (disposed) return;
    if (response['kind'] == 'review') {
      summary = response['summary'] as String;
      findings = [
        for (final f in response['findings'] as List)
          Map<String, String>.from(f as Map),
      ];
      questions = [];
      checkedIds.clear();
      duplicates = [];
      return;
    }
    if (response['kind'] != 'questions' || response['checked'] != true)
      throw StateError(
        'The independent answer check did not complete. No questions were accepted.',
      );
    progress(
      'Checking schema and duplicates against your bank and AI history…',
    );
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final rows = response['questions'] as List;
    if (rows.length != count)
      throw StateError(
        'The server returned the wrong question count. Try again.',
      );
    final next = <Question>[];
    final levels = <String, String>{};
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i] as Map;
      final id = 'ai_${stamp}_$i';
      if (!chapters.contains(r['chapter']))
        throw StateError('A question was outside the selected chapters.');
      next.add(
        Question(
          id: id,
          subjectId: subjectId,
          chapter: r['chapter'] as String,
          questionText: r['questionText'] as String,
          options: List<String>.from(r['options'] as List),
          correctIndex: r['correctIndex'] as int,
          explanation: r['explanation'] as String,
          source: QuestionSource.ai,
          sourceLabel: 'AI practice • teacher review required',
        ),
      );
      levels[id] = r['difficulty'] as String;
    }
    final validations = QuestionSchemaValidator.validateBatch(
      next,
      expectedCount: count,
    );
    if (validations.any((v) => !v.valid))
      throw StateError(
        'Generated questions failed local validation. Try again.',
      );
    _comparison = [
      ...bank.where((q) => q.subjectId == subjectId),
      ..._previous,
      ...currentPaper,
    ];
    questions = next;
    summary = null;
    findings = [];
    checkedIds
      ..clear()
      ..addAll(next.map((q) => q.id));
    difficulty
      ..clear()
      ..addAll(levels);
    _checkDuplicates();
    // Persist even a rejected/similar batch, so retries cannot repeat it silently.
    final history = [..._previous, ...next];
    if (!await prefs.setString(
      _historyKey,
      jsonEncode(
        history
            .skip(history.length > 300 ? history.length - 300 : 0)
            .map(mcqJson)
            .toList(),
      ),
    )) {
      historyWarning = 'AI history could not be saved. Duplicate checks across restarts may be incomplete.';
    } else {
      historyWarning = null;
    }
  });
  Future<void> replace(int index) async {
    if (busy) return;
    final originals = List<Question>.of(questions);
    final originalChecked = Set<String>.of(checkedIds);
    final originalDifficulty = Map<String, String>.of(difficulty);
    final q = originals[index];
    final ok = await execute(
      command: TeacherCommand.improve,
      subjectId: q.subjectId,
      chapters: [q.chapter],
      count: 1,
      level: 'mixed',
      text: jsonEncode({'question': q.questionText, 'options': q.options}),
      instruction: 'Replace with a different concept in the same chapter. Do not merely reword it.',
    );
    if (!ok || disposed) return;
    final replacement = questions.single;
    questions = originals..[index] = replacement;
    checkedIds.addAll(originalChecked.where((id) => id != q.id));
    difficulty.addAll(originalDifficulty);
    // The retained questions must not be compared to themselves in history.
    final retainedIds = questions.map((q) => q.id).toSet();
    _comparison = _comparison
        .where((q) => !retainedIds.contains(q.id))
        .toList();
    _checkDuplicates();
    changed();
  }

  void _checkDuplicates() {
    duplicates = DuplicateDetector.findDuplicates(questions, _comparison);
    for (var i = 0; i < questions.length; i++)
      duplicates.addAll(
        DuplicateDetector.findDuplicates([questions[i]], questions.take(i)),
      );
  }

  void edit(int index, Question q) {
    if (busy) return;
    final check = QuestionSchemaValidator.validateMcq(q);
    if (!check.valid) {
      error = check.errors.join(', ');
      changed();
      return;
    }
    checkedIds.remove(questions[index].id);
    questions = List.of(questions)..[index] = q;
    _checkDuplicates();
    changed();
  }

  void remove(int index) {
    if (busy) return;
    checkedIds.remove(questions[index].id);
    questions = List.of(questions)..removeAt(index);
    _checkDuplicates();
    changed();
  }

  @override
  void dispose() {
    client.close();
    super.dispose();
  }
}
