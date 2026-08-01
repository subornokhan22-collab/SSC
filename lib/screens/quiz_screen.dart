import 'package:flutter/material.dart';
import '../data/questions_data.dart';

class QuizScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;

  const QuizScreen({
    Key? key,
    required this.subjectId,
    required this.subjectName,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _subjectQuestions = [];
  Map<int, int> _selectedAnswers = {};
  Map<int, bool> _showExplanations = {};

  @override
  void initState() {
    super.initState();
    _subjectQuestions = sampleQuestions.where((q) => q.subject == widget.subjectId).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subjectName} - MCQ'),
        backgroundColor: const Color(0xFF1A82BB),
        foregroundColor: Colors.white,
      ),
      body: _subjectQuestions.isEmpty
          ? const Center(child: Text('এই বিষয়ের কোনো প্রশ্ন এখনো যুক্ত করা হয়নি।'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _subjectQuestions.length,
              itemBuilder: (context, index) {
                final q = _subjectQuestions[index];
                final selectedOption = _selectedAnswers[index];
                final showExp = _showExplanations[index] ?? false;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              label: Text(q.chapter, style: const TextStyle(fontSize: 12)),
                              backgroundColor: Colors.blue.shade50,
                            ),
                            Chip(
                              label: Text(q.sourceLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                              backgroundColor: Colors.amber.shade100,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${index + 1}. ${q.questionText}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(q.options.length, (optIndex) {
                          Color? tileColor;
                          if (selectedOption != null) {
                            if (optIndex == q.correctOptionIndex) {
                              tileColor = Colors.green.shade100;
                            } else if (optIndex == selectedOption) {
                              tileColor = Colors.red.shade100;
                            }
                          }

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            color: tileColor,
                            child: RadioListTile<int>(
                              title: Text(q.options[optIndex]),
                              value: optIndex,
                              groupValue: selectedOption,
                              onChanged: (val) {
                                setState(() {
                                  if (val != null) {
                                    _selectedAnswers[index] = val;
                                  }
                                });
                              },
                            ),
                          );
                        }),
                        if (selectedOption != null) ...[
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _showExplanations[index] = !showExp;
                              });
                            },
                            icon: Icon(showExp ? Icons.visibility_off : Icons.visibility),
                            label: Text(showExp ? 'ব্যাখ্যা লুকান' : 'ব্যাখ্যা দেখুন'),
                          ),
                          if (showExp)
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                q.explanation,
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
