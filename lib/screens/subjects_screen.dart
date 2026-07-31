// lib/screens/subjects_screen.dart

import 'package:flutter/material.dart';
import '../data/questions_data.dart';
import 'quiz_screen.dart';
import 'cq_screen.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('সকল বিষয়'), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: subjects.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final mcqCount = questionsFor(subject.name).length;
          final cqCount = cqsFor(subject.name).length;

          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: subject.color.withOpacity(0.12),
                        child: Icon(subject.icon, color: subject.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          subject.bengaliName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.quiz_outlined, size: 18),
                          label: Text('MCQ ($mcqCount)'),
                          onPressed: mcqCount == 0
                              ? null
                              : () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => QuizScreen(
                                        title: subject.bengaliName,
                                        questions: questionsFor(subject.name),
                                      ),
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.edit_note, size: 18),
                          label: Text('CQ ($cqCount)'),
                          onPressed: cqCount == 0
                              ? null
                              : () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CQScreen(
                                        subjectName: subject.name,
                                        title: subject.bengaliName,
                                      ),
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
