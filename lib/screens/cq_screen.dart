// lib/screens/cq_screen.dart

import 'package:flutter/material.dart';
import '../data/questions_data.dart';

class CQScreen extends StatelessWidget {
  final String subjectName;
  final String title;

  const CQScreen({super.key, required this.subjectName, required this.title});

  @override
  Widget build(BuildContext context) {
    final cqs = cqsFor(subjectName);

    return Scaffold(
      appBar: AppBar(title: Text('$title - সৃজনশীল'), centerTitle: true),
      body: cqs.isEmpty
          ? const Center(child: Text('এই বিষয়ে এখনো কোনো সৃজনশীল প্রশ্ন যোগ করা হয়নি।'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cqs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) => _CQCard(cq: cqs[index], number: index + 1),
            ),
    );
  }
}

class _CQCard extends StatelessWidget {
  final CreativeQuestion cq;
  final int number;

  const _CQCard({required this.cq, required this.number});

  @override
  Widget build(BuildContext context) {
    final isBoard = cq.source == QuestionSource.board;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        title: Text(
          'প্রশ্ন $number  •  ${cq.chapter}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Chip(
            label: Text(
              isBoard ? (cq.sourceLabel ?? 'বোর্ড প্রশ্ন') : 'AI তৈরি',
              style: const TextStyle(fontSize: 11),
            ),
            visualDensity: VisualDensity.compact,
            backgroundColor: isBoard ? Colors.green.shade50 : Colors.blue.shade50,
            padding: EdgeInsets.zero,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(cq.stem, style: const TextStyle(height: 1.5)),
          ),
          const SizedBox(height: 14),
          ...cq.parts.map(
            (part) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.deepPurple.shade50,
                    child: Text(
                      part.label,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(part.prompt, style: const TextStyle(height: 1.4))),
                  const SizedBox(width: 8),
                  Text('${part.marks}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
