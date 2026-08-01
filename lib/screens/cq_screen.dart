import 'package:flutter/material.dart';
import '../data/questions_data.dart';

class CQScreen extends StatelessWidget {
  final String subjectId;
  final String? chapter;
  const CQScreen({super.key, required this.subjectId, this.chapter});

  @override
  Widget build(BuildContext context) {
    final cqs = allCQs.where((q) => q.subjectId == subjectId && (chapter == null || q.chapter == chapter)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('সৃজনশীল প্রশ্ন')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: cqs.length,
        itemBuilder: (context, index) {
          final cq = cqs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cq.chapter, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(cq.stem, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Divider(height: 20),
                  _partRow('ক', cq.questionK, cq.marks[0]),
                  _partRow('খ', cq.questionKh, cq.marks[1]),
                  _partRow('গ', cq.questionG, cq.marks[2]),
                  _partRow('ঘ', cq.questionGh, cq.marks[3]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _partRow(String label, String text, int marks) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label. ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
          Text(' ($marks)', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }
}
