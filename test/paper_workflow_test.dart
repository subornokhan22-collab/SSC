import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutors_desk/controllers/paper_controller.dart';
import 'package:tutors_desk/controllers/operation_controller.dart';
import 'package:tutors_desk/data/questions_data.dart';
import 'package:tutors_desk/models/paper_draft.dart';
import 'package:tutors_desk/services/paper_composer.dart';
import 'package:tutors_desk/services/paper_snapshot.dart';

import 'support/bank_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(BankFixture.ensureLoaded);
  setUp(() => SharedPreferences.setMockInitialValues({}));
  PaperComposer engine() => PaperComposer(
    mcqBank: allMCQs,
    saqBank: allSAQs,
    cqBank: allCQs,
    random: Random(7),
  );
  test(
    'subject-specific board distributions preserve marks and question counts',
    () {
      for (final sid in [
        'physics',
        'chemistry',
        'biology',
        'general_math',
        'ict',
        'bangla_1st',
        'bangla_2nd',
        'english_1st',
        'english_2nd',
      ]) {
        final paper = engine().compose(PaperDraft(subjectId: sid));
        expect(
          paper.marks,
          sid == 'ict'
              ? 25
              : PaperComposer.science.contains(sid)
              ? 75
              : 100,
          reason: sid,
        );
        if (sid == 'general_math') {
          expect(paper.mcqs.length, 30);
          expect(paper.saqs.length, 15);
          expect(paper.cqs.length, 8);
          expect(paper.cqAnswers, 5);
        }
        if (sid == 'ict') {
          expect(paper.saqs, isEmpty);
          expect(paper.cqs, isEmpty);
        }
        expect(
          paper.mcqs.map((q) => q.questionText).toSet().length,
          paper.mcqs.length,
        );
      }
    },
  );
  test(
    'chapter selection and shortages are enforced, not silently shortened',
    () {
      final ch = allMCQs.firstWhere((q) => q.subjectId == 'physics').chapter;
      final p = engine().compose(
        PaperDraft(
          format: PaperFormat.chapter,
          chapters: [ch],
          mcqCount: 5,
          saqCount: 0,
          cqCount: 0,
        ),
      );
      expect(p.mcqs.length, 5);
      expect(p.mcqs.every((q) => q.chapter == ch), isTrue);
      expect(p.marks, 5);
      expect(
        () => engine().compose(const PaperDraft(format: PaperFormat.chapter)),
        throwsStateError,
      );
      expect(
        () => engine().compose(
          const PaperDraft(
            format: PaperFormat.custom,
            chapters: ['missing'],
            mcqCount: 1,
            saqCount: 0,
            cqCount: 0,
          ),
        ),
        throwsStateError,
      );
      expect(
        () => engine().compose(
          const PaperDraft(
            format: PaperFormat.custom,
            mcqCount: 0,
            saqCount: 0,
            cqCount: 0,
          ),
        ),
        throwsStateError,
      );
      expect(
        () => engine().compose(const PaperDraft(subjectId: 'accounting')),
        throwsStateError,
      );
    },
  );
  test(
    'full snapshot round trips figures, written sections and English tables',
    () {
      for (final sid in [
        'general_math',
        'bangla_1st',
        'bangla_2nd',
        'english_1st',
        'english_2nd',
      ]) {
        final draft = PaperDraft(subjectId: sid, answerKey: true);
        final s = PaperSnapshot(draft, engine().compose(draft));
        final restored = PaperSnapshot.fromJson(
          jsonDecode(jsonEncode(s.toJson())) as Map<String, dynamic>,
        );
        expect(restored.toJson(), s.toJson(), reason: sid);
      }
    },
  );
  test(
    'controller undo redo and autosave retain the actual question selection',
    () async {
      final c = PaperController(composer: engine());
      await c.initialize();
      expect(await c.generate(), isTrue);
      final ids = c.paper!.mcqs.map((q) => q.id).toList();
      c.update(c.draft.copyWith(title: 'Class test'), preserveQuestions: true);
      c.undo();
      expect(c.draft.title, isNot('Class test'));
      c.redo();
      expect(c.draft.title, 'Class test');
      await c.flush();
      final restored = PaperController(composer: engine());
      await restored.initialize();
      expect(restored.draft.title, 'Class test');
      expect(restored.paper!.mcqs.map((q) => q.id), ids);
      c.dispose();
      restored.dispose();
    },
  );
  test('edits reject duplicate stems and empty paper removal', () async {
    final c = PaperController(
      composer: engine(),
      initial: const PaperDraft(format: PaperFormat.mcq, mcqCount: 2),
    );
    await c.initialize();
    expect(await c.generate(), isTrue);
    c.editQuestion(1, c.paper!.mcqs.first);
    expect(c.error, contains('already exists'));
    c.removeQuestion(1);
    expect(c.paper!.mcqs.length, 1);
    c.removeQuestion(0);
    expect(c.paper!.mcqs.length, 1);
    expect(c.error, contains('at least one'));
    c.undo();
    expect(c.paper!.mcqs.length, 2);
    c.dispose();
  });
  test(
    'corrupt draft does not crash or overwrite recovery data on dispose',
    () async {
      SharedPreferences.setMockInitialValues({
        PaperController.draftKey: 'not json',
      });
      final c = PaperController(composer: engine());
      await c.initialize();
      expect(c.saveError, isNotNull);
      c.dispose();
      expect(
        (await SharedPreferences.getInstance()).getString(
          PaperController.draftKey,
        ),
        'not json',
      );
    },
  );
  test('disposed async operations do not notify listeners', () async {
    final c = OperationController();
    var calls = 0;
    c.addListener(() => calls++);
    final pending = c.run('Test', () async {
      await Future<void>.delayed(const Duration(milliseconds: 5));
      c.progress('Done');
    });
    c.dispose();
    expect(await pending, isFalse);
    expect(calls, 1);
  });
}
