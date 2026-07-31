// lib/screens/exam_screen.dart

import 'package:flutter/material.dart';
import '../data/questions_data.dart';
import 'quiz_screen.dart';

class ExamScreen extends StatelessWidget {
  const ExamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mixed-subject question set, capped for a focused live exam.
    final shuffled = List<Question>.from(allQuestions)..shuffle();
    final questionSet = shuffled.take(20).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('লাইভ পরীক্ষা'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFF97316)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.timer, color: Colors.white, size: 36),
                  const SizedBox(height: 12),
                  const Text(
                    'SSC ২০২৭ মডেল টেস্ট',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'সকল বিষয় থেকে মিশ্র ${questionSet.length}টি প্রশ্ন • সময়সীমা ১৫ মিনিট',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'নিয়মাবলী',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const _RuleRow(text: 'পরীক্ষা শুরু হলে টাইমার চালু হয়ে যাবে।'),
            const _RuleRow(text: 'সময় শেষ হলে পরীক্ষা স্বয়ংক্রিয়ভাবে জমা হবে।'),
            const _RuleRow(text: 'প্রতিটি প্রশ্নের জন্য একটি মাত্র উত্তর বাছাই করা যাবে।'),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: questionSet.isEmpty
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(
                            title: 'লাইভ পরীক্ষা',
                            questions: questionSet,
                            timeLimit: const Duration(minutes: 15),
                          ),
                        ),
                      );
                    },
              icon: const Icon(Icons.play_arrow),
              label: const Text('পরীক্ষা শুরু করুন'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  final String text;
  const _RuleRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
