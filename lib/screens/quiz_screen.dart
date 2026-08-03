import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final String? subjectId;
  final String? chapter;
  final List<dynamic>? customQuestions;
  final String? customTitle;

  const QuizScreen({
    super.key,
    this.subjectId,
    this.chapter,
    this.customQuestions,
    this.customTitle,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  Widget build(BuildContext context) {
    final title = widget.customTitle ?? 'Quiz';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          widget.customQuestions != null && widget.customQuestions!.isNotEmpty
              ? 'Loaded ${widget.customQuestions!.length} custom questions'
              : 'Standard Quiz Mode',
        ),
      ),
    );
  }
}
