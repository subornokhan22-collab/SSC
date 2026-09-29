import 'package:flutter/material.dart';
import '../data/questions_data.dart';
import '../services/question_validation.dart';
import '../theme/app_theme.dart';

class WrittenQuestionCard extends StatelessWidget {
  final Object question;
  final int number;
  final ValueChanged<Object> onEdit;
  final VoidCallback onReplace;
  final VoidCallback? onDelete;
  const WrittenQuestionCard(
      {super.key,
      required this.question,
      required this.number,
      required this.onEdit,
      required this.onReplace,
      this.onDelete});
  @override
  Widget build(BuildContext context) {
    final q = question;
    final short = q is ShortQuestion;
    final lines = short
        ? <String>[q.questionText, q.answer]
        : [
            (q as CreativeQuestion).stem,
            'ক. ${q.questionK}',
            'খ. ${q.questionKh}',
            'গ. ${q.questionG}',
            if (q.questionGh.isNotEmpty) 'ঘ. ${q.questionGh}'
          ];
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  '${short ? 'Short answer' : 'সৃজনশীল প্রশ্ন'} $number · ${short ? 2 : 10} marks',
                  style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
              const SizedBox(height: 8),
              Text(lines.first,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (short)
                ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text('Answer'),
                    children: [Text(lines.last)])
              else
                Text(lines.skip(1).join('\n')),
              Wrap(spacing: 8, children: [
                TextButton.icon(
                    onPressed: () async {
                      final edited = await showDialog<Object>(
                          context: context, builder: (_) => _Editor(q));
                      if (edited != null) onEdit(edited);
                    },
                    icon: const Icon(Icons.edit_outlined, size: 17),
                    label: const Text('Edit')),
                TextButton.icon(
                    onPressed: onReplace,
                    icon: const Icon(Icons.swap_horiz, size: 17),
                    label: const Text('Replace')),
                if (onDelete != null)
                  IconButton(
                      tooltip: 'Remove question',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 18)),
              ]),
            ])));
  }
}

class _Editor extends StatefulWidget {
  final Object question;
  const _Editor(this.question);
  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  late final List<TextEditingController> fields;
  String? error;
  @override
  void initState() {
    super.initState();
    final q = widget.question;
    final values = q is ShortQuestion
        ? [q.questionText, q.answer]
        : [
            (q as CreativeQuestion).stem,
            q.questionK,
            q.questionKh,
            q.questionG,
            if (q.marks.length == 4) q.questionGh
          ];
    fields = values.map((s) => TextEditingController(text: s)).toList();
  }

  @override
  void dispose() {
    for (final c in fields) c.dispose();
    super.dispose();
  }

  void save() {
    final q = widget.question;
    final values = fields.map((c) => c.text.trim()).toList();
    final Object next = q is ShortQuestion
        ? ShortQuestion(
            id: q.id,
            subjectId: q.subjectId,
            chapter: q.chapter,
            questionText: values[0],
            answer: values[1],
            explanation: q.explanation,
            source: q.source,
            sourceLabel: q.sourceLabel,
            figure: q.figure)
        : CreativeQuestion(
            id: (q as CreativeQuestion).id,
            subjectId: q.subjectId,
            chapter: q.chapter,
            stem: values[0],
            questionK: values[1],
            questionKh: values[2],
            questionG: values[3],
            questionGh: values.length == 5 ? values[4] : '',
            marks: q.marks,
            source: q.source,
            sourceLabel: q.sourceLabel,
            figure: q.figure);
    final v = QuestionValidationService.validate(next);
    if (!v.valid) {
      setState(() => error = v.errors.join('\n'));
      return;
    }
    Navigator.pop(context, next);
  }

  @override
  Widget build(BuildContext context) {
    final short = widget.question is ShortQuestion;
    return AlertDialog(
        title: Text(short ? 'Edit short answer' : 'Edit creative question'),
        content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              for (var i = 0; i < fields.length; i++)
                Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                        controller: fields[i],
                        minLines: 2,
                        maxLines: 8,
                        decoration: InputDecoration(
                            labelText: short
                                ? (i == 0 ? 'Question' : 'Answer')
                                : (i == 0
                                    ? 'উদ্দীপক'
                                    : ['ক', 'খ', 'গ', 'ঘ'][i - 1])))),
              if (error != null)
                Text(error!, style: const TextStyle(color: AppTheme.danger)),
            ]))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(onPressed: save, child: const Text('Save changes'))
        ]);
  }
}
