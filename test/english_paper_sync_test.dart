import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutors_desk/data/english_paper_sync.dart';
import 'package:tutors_desk/models/paper_draft.dart';
import 'package:tutors_desk/services/paper_composer.dart';

Map<String, dynamic> fixture(String type) => jsonDecode(
        File('web-admin/tests/fixtures/english-$type.json').readAsStringSync())
    as Map<String, dynamic>;
void main() {
  tearDown(() => EnglishPaperSync.replaceRows([]));
  test('source first/second paper models feed the actual PDF adapter', () {
    for (final type in ['first', 'second']) {
      final p = EnglishPaperDocument.fromJson(fixture(type));
      expect(p.sections.where((s) => RegExp(r'^\d+\.').hasMatch(s.head)).length,
          type == 'first' ? 11 : 12);
      expect(p.answers.values, everyElement(isNull));
      expect(p.board, 'Dhaka');
    }
  });
  test('only active published papers are synced; removal reconciles choices',
      () {
    final row = fixture('first');
    EnglishPaperSync.replaceRows([row]);
    expect(EnglishPaperSync.papers, isEmpty);
    row['review_status'] = 'published';
    EnglishPaperSync.replaceRows([row]);
    expect(EnglishPaperSync.choices('english_1st'), contains(row['id']));
    expect(EnglishPaperSync.choices('english_2nd'), isNot(contains(row['id'])));
    row['is_active'] = false;
    EnglishPaperSync.replaceRows([row]);
    expect(EnglishPaperSync.papers, isEmpty);
    expect(
        () => EnglishPaperSync.compose(
            'english_1st', row['id'] as String, Random(1)),
        throwsStateError);
  });
  test('saved draft retains selected board identity', () {
    final row = fixture('second')..['review_status'] = 'published';
    EnglishPaperSync.replaceRows([row]);
    final draft = PaperDraft(
        subjectId: 'english_2nd', englishPaperId: row['id'] as String);
    final saved = PaperDraft.fromJson(draft.toJson());
    expect(saved.englishPaperId, row['id']);
    final paper =
        PaperComposer(mcqBank: [], saqBank: [], cqBank: [], random: Random(2))
            .compose(saved);
    expect(
        paper.english.where((s) => RegExp(r'^\d+\.').hasMatch(s.head)).length,
        12);
    expect(paper.marks, 100);
    expect(saved.copyWith(clearEnglishPaper: true).englishPaperId, isNull);
  });
  test('malformed remote tables are rejected without replacing bundled sets',
      () {
    final row = fixture('first');
    (row['data'] as Map)['q4Table'] = [
      ['one'],
      ['two', 'three']
    ];
    expect(() => EnglishPaperDocument.fromJson(row), throwsFormatException);
  });
}
