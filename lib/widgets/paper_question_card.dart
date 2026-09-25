import 'package:flutter/material.dart';

import '../data/questions_data.dart';
import '../services/ai/ai_text_formatter.dart';
import '../services/ai/question_schema_validator.dart';
import '../theme/app_theme.dart';

class PaperQuestionCard extends StatelessWidget {
  final Question question;
  final int number;
  final VoidCallback? onReplace;
  final VoidCallback? onImprove;
  final VoidCallback? onDelete;
  final ValueChanged<Question>? onEdit;
  const PaperQuestionCard({
    super.key,
    required this.question,
    required this.number,
    this.onReplace,
    this.onImprove,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MCQ $number  ·  1 mark',
                style: const TextStyle(color: AppTheme.muted, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                AiTextFormatter.format(question.questionText),
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamilyFallback: ['DejaVu Sans']),
              ),
              if (question.figure != null)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Includes a figure — visible in the paper preview.',
                    style: TextStyle(color: AppTheme.muted, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 10),
              for (var i = 0; i < question.options.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        i == question.correctIndex
                            ? Icons.check_circle_outline
                            : Icons.radio_button_unchecked,
                        size: 17,
                        color: i == question.correctIndex
                            ? AppTheme.success
                            : AppTheme.muted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${[
                            'ক',
                            'খ',
                            'গ',
                            'ঘ'
                          ][i]}. ${AiTextFormatter.format(question.options[i])}',
                          style: const TextStyle(
                              fontFamilyFallback: ['DejaVu Sans']),
                        ),
                      ),
                    ],
                  ),
                ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title:
                    const Text('Explanation', style: TextStyle(fontSize: 13)),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(AiTextFormatter.format(question.explanation),
                          style: const TextStyle(
                              fontFamilyFallback: ['DejaVu Sans'])),
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: [
                  if (onEdit != null)
                    TextButton.icon(
                      onPressed: () async {
                        final changed = await showDialog<Question>(
                          context: context,
                          builder: (_) => _QuestionEditor(question),
                        );
                        if (changed != null) onEdit!(changed);
                      },
                      icon: const Icon(Icons.edit_outlined, size: 17),
                      label: const Text('Edit / answer key'),
                    ),
                  if (onReplace != null)
                    TextButton.icon(
                      onPressed: onReplace,
                      icon: const Icon(Icons.swap_horiz, size: 17),
                      label: const Text('Replace'),
                    ),
                  if (onImprove != null)
                    TextButton.icon(
                        onPressed: onImprove,
                        icon: const Icon(Icons.auto_awesome_outlined, size: 17),
                        label: const Text('Improve with AI')),
                  if (onDelete != null)
                    IconButton(
                      tooltip: 'Remove question',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 19),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
}

class _QuestionEditor extends StatefulWidget {
  final Question question;
  const _QuestionEditor(this.question);
  @override
  State<_QuestionEditor> createState() => _QuestionEditorState();
}

class _QuestionEditorState extends State<_QuestionEditor> {
  late final List<TextEditingController> fields;
  late int answer;
  String? error;
  @override
  void initState() {
    super.initState();
    final q = widget.question;
    fields = [
      q.questionText,
      ...q.options,
      q.explanation,
    ].map((s) => TextEditingController(text: s)).toList();
    answer = q.correctIndex;
  }

  @override
  void dispose() {
    for (final c in fields) c.dispose();
    super.dispose();
  }

  void save() {
    final q = widget.question;
    final next = Question(
      id: q.id,
      subjectId: q.subjectId,
      chapter: q.chapter,
      questionText: fields[0].text.trim(),
      options: [for (var i = 1; i <= 4; i++) fields[i].text.trim()],
      correctIndex: answer,
      explanation: fields[5].text.trim(),
      source: q.source,
      sourceLabel: q.sourceLabel,
      figure: q.figure,
    );
    final v = QuestionSchemaValidator.validateMcq(next);
    if (!v.valid) {
      setState(() => error = v.errors.join('\n'));
      return;
    }
    Navigator.pop(context, next);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Review question'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < fields.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: fields[i],
                      minLines: i == 0 || i == 5 ? 2 : 1,
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: i == 0
                            ? 'Question'
                            : i == 5
                                ? 'Explanation'
                                : 'Option ${['ক', 'খ', 'গ', 'ঘ'][i - 1]}',
                      ),
                    ),
                  ),
                DropdownButtonFormField<int>(
                  value: answer,
                  decoration:
                      const InputDecoration(labelText: 'Correct answer'),
                  items: [
                    for (var i = 0; i < 4; i++)
                      DropdownMenuItem(
                        value: i,
                        child: Text(['ক', 'খ', 'গ', 'ঘ'][i]),
                      ),
                  ],
                  onChanged: (i) => setState(() => answer = i!),
                ),
                if (error != null)
                  Text(error!, style: const TextStyle(color: AppTheme.danger)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(onPressed: save, child: const Text('Save changes')),
        ],
      );
}
