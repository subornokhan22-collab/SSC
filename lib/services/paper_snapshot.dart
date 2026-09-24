import '../data/question_bank.dart';
import '../data/question_figure.dart';
import '../data/questions_data.dart';
import '../data/bangla_1st/bangla_1st_literature_questions.dart';
import '../data/bangla_2nd/bangla_2nd_written_questions.dart';
import '../models/paper_draft.dart';
import 'paper_composer.dart';
import 'paper_pdf.dart';

Map<String, dynamic>? figureJson(QuestionFigure? f) => f == null
    ? null
    : {
        'kind': f.kind.name,
        'headers': f.headers,
        'rows': f.rows,
        'sides': f.sides,
        'angles': f.angles,
        'values': f.values,
        'rightAngleAt': f.rightAngleAt,
        'caption': f.caption,
        'imagePath': f.imagePath,
        'aspect': f.aspect,
      };

Map<String, dynamic> mcqJson(Question q) => {
      'id': q.id,
      'type': 'mcq',
      'subjectId': q.subjectId,
      'chapter': q.chapter,
      'source': q.source.name,
      'sourceLabel': q.sourceLabel,
      'figure': figureJson(q.figure),
      'payload': {
        'questionText': q.questionText,
        'options': q.options,
        'correctIndex': q.correctIndex,
        'explanation': q.explanation,
      },
    };

class PaperSnapshot {
  final PaperDraft draft;
  final ComposedPaper? paper;
  const PaperSnapshot(this.draft, this.paper);

  Map<String, dynamic> toJson() => {
        'version': 1,
        'draft': draft.toJson(),
        if (paper != null)
          'paper': {
            'mcqs': paper!.mcqs.map(mcqJson).toList(),
            'saqs': [
              for (final q in paper!.saqs)
                {
                  'id': q.id,
                  'subjectId': q.subjectId,
                  'chapter': q.chapter,
                  'source': q.source.name,
                  'sourceLabel': q.sourceLabel,
                  'figure': figureJson(q.figure),
                  'payload': {
                    'questionText': q.questionText,
                    'answer': q.answer,
                    'explanation': q.explanation,
                  },
                },
            ],
            'cqs': [
              for (final q in paper!.cqs)
                {
                  'id': q.id,
                  'subjectId': q.subjectId,
                  'chapter': q.chapter,
                  'source': q.source.name,
                  'sourceLabel': q.sourceLabel,
                  'figure': figureJson(q.figure),
                  'payload': {
                    'stem': q.stem,
                    'questionK': q.questionK,
                    'questionKh': q.questionKh,
                    'questionG': q.questionG,
                    'questionGh': q.questionGh,
                    'marks': q.marks,
                  },
                },
            ],
            'literature': paper!.literature.map((q) => q.id).toList(),
            'written': paper!.written.map((q) => q.id).toList(),
            'english': [
              for (final s in paper!.english)
                {
                  'head': s.head,
                  'lines': s.lines,
                  'table': s.table,
                  'centerTable': s.centerTable,
                },
            ],
            'cqAnswers': paper!.cqAnswers,
            'saqAnswers': paper!.saqAnswers,
            'marks': paper!.marks,
            'minutes': paper!.minutes,
            'note': paper!.note,
          },
      };

  factory PaperSnapshot.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1)
      throw const FormatException('Unsupported draft version');
    final draft = PaperDraft.fromJson(
      Map<String, dynamic>.from(json['draft'] as Map),
    );
    final p = json['paper'] as Map?;
    if (p == null) return PaperSnapshot(draft, null);
    List<Map<String, dynamic>> rows(String k) =>
        (p[k] as List).map((r) => Map<String, dynamic>.from(r as Map)).toList();
    return PaperSnapshot(
      draft,
      ComposedPaper(
        mcqs: List.unmodifiable(rows('mcqs').map(questionFromJson)),
        saqs: List.unmodifiable(rows('saqs').map(shortQuestionFromJson)),
        cqs: List.unmodifiable(rows('cqs').map(creativeQuestionFromJson)),
        literature: [
          for (final id in p['literature'] as List)
            banglaFirstLiteratureQuestions.firstWhere((q) => q.id == id),
        ],
        written: [
          for (final id in p['written'] as List)
            bangla2ndWrittenQuestions.firstWhere((q) => q.id == id),
        ],
        english: [
          for (final e in rows('english'))
            EnglishSection(
              e['head'] as String,
              List<String>.from(e['lines'] as List),
              table: (e['table'] as List?)
                  ?.map((r) => List<String>.from(r as List))
                  .toList(),
              centerTable: e['centerTable'] == true,
            ),
        ],
        cqAnswers: p['cqAnswers'] as int,
        saqAnswers: p['saqAnswers'] as int,
        marks: p['marks'] as int,
        minutes: p['minutes'] as int,
        note: p['note'] as String,
      ),
    );
  }
}
