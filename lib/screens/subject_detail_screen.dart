import 'package:flutter/material.dart';
import '../data/questions_data.dart';
import 'subjects_screen.dart';
import 'quiz_screen.dart';
import 'cq_screen.dart';

class SubjectDetailScreen extends StatelessWidget {
  final SubjectInfo subject;
  const SubjectDetailScreen({super.key, required this.subject});

  List<String> get _chapters {
    final chapters = <String>{
      ...allMCQs.where((q) => q.subjectId == subject.id).map((q) => q.chapter),
      ...allCQs.where((q) => q.subjectId == subject.id).map((q) => q.chapter),
    };
    return chapters.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final chapters = _chapters;
    return Scaffold(
      appBar: AppBar(title: Text(subject.name)),
      body: chapters.isEmpty
          ? const Center(child: Text('এই বিষয়ে এখনও প্রশ্ন যোগ করা হয়নি।'))
          : ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                final mcqCount = allMCQs.where((q) => q.subjectId == subject.id && q.chapter == chapter).length;
                final cqCount = allCQs.where((q) => q.subjectId == subject.id && q.chapter == chapter).length;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(chapter, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (mcqCount > 0)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(
                                    builder: (_) => QuizScreen(subjectId: subject.id, chapter: chapter),
                                  )),
                                  child: Text('MCQ ($mcqCount)'),
                                ),
                              ),
                            if (mcqCount > 0 && cqCount > 0) const SizedBox(width: 8),
                            if (cqCount > 0)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(
                                    builder: (_) => CQScreen(subjectId: subject.id, chapter: chapter),
                                  )),
                                  child: Text('CQ ($cqCount)'),
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
