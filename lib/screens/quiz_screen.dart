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
  late List<Question> questions;
  int currentIndex = 0;
  int? selectedIndex;
  bool answered = false;
  int score = 0;

  @override
  void initState() {
    super.initState();
    questions = QuestionsData.mcqs
        .where((q) => q.subject == widget.subjectId)
        .toList();
  }

  void handleAnswer(int index) {
    if (answered) return;
    setState(() {
      selectedIndex = index;
      answered = true;
      if (index == questions[currentIndex].correctOptionIndex) {
        score++;
      }
    });
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedIndex = null;
        answered = false;
      });
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('অনুশীলন সম্পন্ন!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars, color: Colors.amber, size: 60),
            const SizedBox(height: 12),
            Text(
              'আপনার স্কোর: $score / ${questions.length}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'সঠিকতা: ${((score / questions.length) * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to subject list
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A82BB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('ঠিক আছে', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.subjectName)),
        body: const Center(child: Text('এই বিষয়ে কোনো প্রশ্ন নেই।')),
      );
    }

    final currentQuestion = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subjectName} MCQ'),
        backgroundColor: const Color(0xFF1A82BB),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (currentIndex + 1) / questions.length,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF1A82BB),
            ),
            const SizedBox(height: 16),

            // Header Meta Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'প্রশ্ন ${currentIndex + 1}/${questions.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Chip(
                  label: Text(
                    currentQuestion.sourceLabel,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  backgroundColor: currentQuestion.source == 'board'
                      ? Colors.green.shade700
                      : Colors.orange.shade800,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Question Box
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  currentQuestion.questionText,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Options List
            ...List.generate(currentQuestion.options.length, (index) {
              Color optionColor = Colors.white;
              Color borderBorder = Colors.grey.shade300;

              if (answered) {
                if (index == currentQuestion.correctOptionIndex) {
                  optionColor = Colors.green.shade50;
                  borderBorder = Colors.green;
                } else if (index == selectedIndex) {
                  optionColor = Colors.red.shade50;
                  borderBorder = Colors.red;
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => handleAnswer(index),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: optionColor,
                      border: Border.all(color: borderBorder, width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.grey.shade200,
                          child: Text(
                            String.fromCharCode(65 + index), // A, B, C, D
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black800),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            currentQuestion.options[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        if (answered && index == currentQuestion.correctOptionIndex)
                          const Icon(Icons.check_circle, color: Colors.green),
                        if (answered && index == selectedIndex && index != currentQuestion.correctOptionIndex)
                          const Icon(Icons.cancel, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Explanation Card (Shows after answer selection)
            if (answered) ...[
              Card(
                color: Colors.blue.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.blue.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.amber),
                          SizedBox(width: 8),
                          Text(
                            'ব্যাখ্যা (Explanation)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentQuestion.explanation.isNotEmpty
                            ? currentQuestion.explanation
                            : 'এই প্রশ্নের জন্য অতিরিক্ত ব্যাখ্যা দেওয়া নেই।',
                        style: const TextStyle(fontSize: 15, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Next Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A82BB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    currentIndex < questions.length - 1 ? 'পরবর্তী প্রশ্ন ➔' : 'ফলাফল দেখুন',
                    style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
