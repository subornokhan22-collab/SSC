// lib/screens/subjects_screen.dart

import 'package:flutter/material.dart';
import '../data/questions_data.dart';
import 'quiz_screen.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('সকল বিষয়'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: subjects.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final questionCount = questionsFor(subject.name).length;

          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 26,
                backgroundColor: subject.color.withOpacity(0.12),
                child: Icon(subject.icon, color: subject.color),
              ),
              title: Text(
                subject.bengaliName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text('${subject.name} • $questionCount টি প্রশ্ন'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(
                      title: subject.bengaliName,
                      questions: questionsFor(subject.name),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
