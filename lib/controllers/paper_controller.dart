import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/questions_data.dart';
import '../models/paper_draft.dart';
import '../models/subject_info.dart';
import '../services/chapter_catalog.dart';
import '../services/paper_composer.dart';
import '../services/paper_snapshot.dart';
import '../services/question_validation.dart';
import '../services/ai/question_schema_validator.dart';
import '../services/ai/duplicate_detector.dart';
import 'operation_controller.dart';

class PaperController extends OperationController {
  static const draftKey = 'paper_composer_draft_v1';
  final PaperComposer composer;
  PaperSnapshot _current;
  final List<PaperSnapshot> _undo = [];
  final List<PaperSnapshot> _redo = [];
  Timer? _saveTimer;
  Future<void> _writes = Future.value();
  DateTime? savedAt;
  String? saveError;
  bool initialized = false;

  PaperController({
    required this.composer,
    PaperDraft initial = const PaperDraft(),
  }) : _current = PaperSnapshot(initial, null);
  PaperDraft get draft => _current.draft;
  ComposedPaper? get paper => _current.paper;
  bool get canUndo => _undo.isNotEmpty && !busy;
  bool get canRedo => _redo.isNotEmpty && !busy;
  SubjectInfo? get subject => subjectById(draft.subjectId);
  List<String> get chapters => ChapterCatalog.ordered({
        ...composer.mcqBank
            .where((q) => q.subjectId == draft.subjectId)
            .map((q) => q.chapter),
        ...composer.saqBank
            .where((q) => q.subjectId == draft.subjectId)
            .map((q) => q.chapter),
        ...composer.cqBank
            .where((q) => q.subjectId == draft.subjectId)
            .map((q) => q.chapter),
      }, subjectId: draft.subjectId);

  Future<void> initialize({bool restore = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = restore ? prefs.getString(draftKey) : null;
      if (raw != null && !disposed) {
        final snapshot = PaperSnapshot.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
        if (subjectById(snapshot.draft.subjectId) == null)
          throw const FormatException('Subject no longer available');
        final restored = snapshot.paper;
        if (restored != null) {
          if (restored.marks <= 0 ||
              restored.minutes <= 0 ||
              restored.mcqs.length > 100 ||
              restored.saqAnswers > restored.saqs.length ||
              restored.cqAnswers > restored.cqs.length ||
              restored.mcqs.any(
                (q) => q.subjectId != snapshot.draft.subjectId,
              ) ||
              QuestionSchemaValidator.validateBatch(restored.mcqs)
                  .any((v) => !v.valid)) {
            throw const FormatException('Invalid paper draft');
          }
        }
        _current = snapshot;
      }
    } catch (_) {
      saveError =
          'The previous draft could not be restored. Start a new paper to replace it.';
    } finally {
      initialized = true;
      changed();
    }
  }

  void _apply(PaperSnapshot snapshot) {
    _undo.add(_current);
    if (_undo.length > 60) _undo.removeAt(0);
    _redo.clear();
    _current = snapshot;
    error = null;
    _scheduleSave();
    changed();
  }

  void update(PaperDraft next, {bool preserveQuestions = false}) {
    if (busy || !initialized) return;
    _apply(PaperSnapshot(next, preserveQuestions ? paper : null));
  }

  void selectSubject(String id) {
    final counts = PaperComposer.defaults(id);
    update(
      draft.copyWith(
        clearEnglishPaper: true,
        subjectId: id,
        chapters: [],
        mcqCount: counts.$1,
        saqCount: counts.$2,
        cqCount: counts.$3,
        format: PaperComposer.isEnglish(id)
            ? PaperFormat.board
            : !PaperComposer.codes.containsKey(id)
                ? PaperFormat.custom
                : draft.format,
      ),
    );
  }

  void undo() {
    if (!canUndo) return;
    _redo.add(_current);
    _current = _undo.removeLast();
    _scheduleSave();
    changed();
  }

  void redo() {
    if (!canRedo) return;
    _undo.add(_current);
    _current = _redo.removeLast();
    _scheduleSave();
    changed();
  }

  Future<bool> generate() => run(
        'Selecting questions and checking the paper…',
        () async {
          await Future<void>.delayed(const Duration(milliseconds: 16));
          final result = composer.compose(draft);
          for (final q in <Object>[
            ...result.mcqs,
            ...result.saqs,
            ...result.cqs
          ]) {
            final v = QuestionValidationService.validate(q);
            if (!v.valid)
              throw StateError(
                'A selected question needs review: ${v.errors.join(', ')}',
              );
          }
          if (!disposed) _apply(PaperSnapshot(draft, result));
        },
      );

  void replaceQuestion(int index) {
    if (busy || paper == null) return;
    final old = paper!.mcqs[index];
    final used =
        paper!.mcqs.map((q) => q.questionText.trim().toLowerCase()).toSet();
    final pool = composer.mcqBank
        .where(
          (q) =>
              q.subjectId == old.subjectId &&
              q.chapter == old.chapter &&
              !used.contains(q.questionText.trim().toLowerCase()) &&
              QuestionSchemaValidator.validateMcq(q).valid,
        )
        .toList()
      ..shuffle(composer.random);
    if (pool.isEmpty) {
      error = 'No unused question is available in this chapter.';
      changed();
      return;
    }
    editQuestion(index, pool.first);
  }

  void editQuestion(int index, Question q) {
    if (busy || paper == null) return;
    final v = QuestionSchemaValidator.validateMcq(q);
    if (!v.valid) {
      error = v.errors.join('\n');
      changed();
      return;
    }
    if (paper!.mcqs.asMap().entries.any(
          (e) =>
              e.key != index &&
              DuplicateDetector.isDuplicate(
                q.questionText,
                e.value.questionText,
                threshold: 1,
              ),
        )) {
      error = 'This question already exists in the paper.';
      changed();
      return;
    }
    final next = List<Question>.of(paper!.mcqs)..[index] = q;
    _apply(PaperSnapshot(draft, paper!.withMcqs(next)));
  }

  void removeQuestion(int index) {
    if (busy || paper == null || draft.format == PaperFormat.board) return;
    if (paper!.mcqs.length == 1 && paper!.saqs.isEmpty && paper!.cqs.isEmpty) {
      error = 'Keep at least one question in the paper.';
      changed();
      return;
    }
    final next = List<Question>.of(paper!.mcqs)..removeAt(index);
    _apply(
      PaperSnapshot(
        draft.copyWith(mcqCount: next.length),
        paper!.withMcqs(next),
      ),
    );
  }

  void useAiQuestions(List<Question> questions) {
    if (busy || questions.isEmpty) return;
    if (questions.length > 100 ||
        QuestionSchemaValidator.validateBatch(questions).any((v) => !v.valid))
      throw StateError('Invalid or duplicate AI questions.');
    for (final q in questions) {
      if (!QuestionSchemaValidator.validateMcq(q).valid ||
          q.subjectId != questions.first.subjectId) {
        throw StateError(
          'AI questions must be valid and belong to one subject.',
        );
      }
    }
    _apply(
      PaperSnapshot(
        draft.copyWith(
          subjectId: questions.first.subjectId,
          format: PaperFormat.mcq,
          chapters: questions.map((q) => q.chapter).toSet().toList(),
          mcqCount: questions.length,
          saqCount: 0,
          cqCount: 0,
        ),
        ComposedPaper(
          mcqs: List.unmodifiable(questions),
          marks: questions.length,
          minutes: questions.length < 10 ? 10 : questions.length,
        ),
      ),
    );
  }

  void editWritten(int index, Object question) {
    if (busy || paper == null) return;
    final validation = QuestionValidationService.validate(question);
    if (!validation.valid) {
      error = validation.errors.join(', ');
      changed();
      return;
    }
    if (question is ShortQuestion) {
      if (paper!.saqs.asMap().entries.any((e) =>
          e.key != index &&
          DuplicateDetector.isDuplicate(
              question.questionText, e.value.questionText,
              threshold: 1))) {
        error = 'This question already exists in the paper.';
        changed();
        return;
      }
      final next = List<ShortQuestion>.of(paper!.saqs)..[index] = question;
      _apply(PaperSnapshot(draft, paper!.withWritten(short: next)));
    } else if (question is CreativeQuestion) {
      if (paper!.cqs.asMap().entries.any((e) =>
          e.key != index &&
          DuplicateDetector.isDuplicate(question.stem, e.value.stem,
              threshold: 1))) {
        error = 'This stimulus already exists in the paper.';
        changed();
        return;
      }
      final next = List<CreativeQuestion>.of(paper!.cqs)..[index] = question;
      _apply(PaperSnapshot(draft, paper!.withWritten(creative: next)));
    }
  }

  void replaceWritten(int index, {required bool creative}) {
    if (busy || paper == null) return;
    final candidates = <Object>[];
    String? section;
    if (creative) {
      final old = paper!.cqs[index];
      final used = paper!.cqs.map((q) => q.stem.trim()).toSet();
      final ids = paper!.cqs.map((q) => q.id).toSet();
      section = RegExp(r'^\[[^\]]+\]\s*').firstMatch(old.stem)?.group(0);
      candidates.addAll(composer.cqBank.where((q) =>
          q.subjectId == old.subjectId &&
          q.chapter == old.chapter &&
          q.marks.length == old.marks.length &&
          !ids.contains(q.id) &&
          !used.contains(q.stem.trim())));
    } else {
      final old = paper!.saqs[index];
      final used = paper!.saqs.map((q) => q.questionText.trim()).toSet();
      final ids = paper!.saqs.map((q) => q.id).toSet();
      candidates.addAll(composer.saqBank.where((q) =>
          q.subjectId == old.subjectId &&
          q.chapter == old.chapter &&
          !ids.contains(q.id) &&
          !used.contains(q.questionText.trim())));
    }
    candidates.removeWhere((q) => !QuestionValidationService.validate(q).valid);
    candidates.shuffle(composer.random);
    if (candidates.isEmpty) {
      error = 'No unused question is available in this chapter.';
      changed();
      return;
    }
    var selected = candidates.first;
    if (selected is CreativeQuestion && section != null) {
      selected = CreativeQuestion(
          id: selected.id,
          subjectId: selected.subjectId,
          chapter: selected.chapter,
          stem: '$section${selected.stem}',
          questionK: selected.questionK,
          questionKh: selected.questionKh,
          questionG: selected.questionG,
          questionGh: selected.questionGh,
          marks: selected.marks,
          source: selected.source,
          sourceLabel: selected.sourceLabel,
          figure: selected.figure);
    }
    editWritten(index, selected);
  }

  void removeWritten(int index, {required bool creative}) {
    if (busy || paper == null || draft.format == PaperFormat.board) return;
    if (paper!.mcqs.length + paper!.saqs.length + paper!.cqs.length <= 1) {
      error = 'Keep at least one question in the paper.';
      changed();
      return;
    }
    if (creative) {
      final next = List<CreativeQuestion>.of(paper!.cqs)..removeAt(index);
      _apply(PaperSnapshot(draft.copyWith(cqCount: next.length),
          paper!.withWritten(creative: next)));
    } else {
      final next = List<ShortQuestion>.of(paper!.saqs)..removeAt(index);
      _apply(PaperSnapshot(draft.copyWith(saqCount: next.length),
          paper!.withWritten(short: next)));
    }
  }

  void addAiQuestions(List<Question> added) {
    if (busy || paper == null || added.isEmpty) return;
    if (paper!.mcqs.length + added.length > 100) {
      error = 'A paper supports at most 100 MCQs.';
      changed();
      return;
    }
    if (added.any((q) => q.subjectId != draft.subjectId) ||
        QuestionSchemaValidator.validateBatch(added).any((v) => !v.valid) ||
        DuplicateDetector.findDuplicates(added, paper!.mcqs).isNotEmpty) {
      error =
          'AI questions must be valid, from this subject and different from the paper.';
      changed();
      return;
    }
    final next = [...paper!.mcqs, ...added];
    _apply(
      PaperSnapshot(
        draft.copyWith(
          format: PaperFormat.custom,
          mcqCount: next.length,
          saqCount: paper!.saqs.length,
          cqCount: paper!.cqs.length,
        ),
        paper!.withMcqs(next),
      ),
    );
  }

  void _scheduleSave() {
    savedAt = null;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 450), () {
      unawaited(flush());
    });
  }

  Future<void> flush() {
    _saveTimer?.cancel();
    final snapshot = _current;
    final raw = jsonEncode(snapshot.toJson());
    _writes = _writes.then((_) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        if (!await prefs.setString(draftKey, raw))
          throw StateError('Storage rejected draft');
        if (identical(snapshot, _current)) {
          savedAt = DateTime.now();
          saveError = null;
        }
      } catch (_) {
        saveError = 'Draft was not saved. Check device storage and try again.';
      }
      changed();
    });
    return _writes;
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    if (initialized && saveError == null) unawaited(flush());
    super.dispose();
  }
}
