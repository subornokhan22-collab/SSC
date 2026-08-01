import 'package:flutter/material.dart';
import '../data/questions_data.dart';

class CQScreen extends StatelessWidget {
  final String subjectId;
  final String subjectName;

  const CQScreen({
    Key? key,
    required this.subjectId,
    required this.subjectName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cqs = sampleCreativeQuestions.where((cq) => cq.subject == subjectId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('$subjectName - সৃজনশীল প্রশ্ন (CQ)'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: cqs.isEmpty
          ? const Center(child: Text('এই বিষয়ের কোনো সৃজনশীল প্রশ্ন এখনো যুক্ত করা হয়নি।'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cqs.length,
              itemBuilder: (context, index) {
                final cq = cqs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              label: Text(cq.chapter, style: const TextStyle(fontSize: 12)),
                              backgroundColor: Colors.green.shade50,
                            ),
                            Chip(
                              label: Text(cq.sourceLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              backgroundColor: Colors.amber.shade100,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'উদ্দীপক ${index + 1}:',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2E7D32)),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(cq.stem, style: const TextStyle(fontSize: 15, height: 1.3)),
                        ),
                        const SizedBox(height: 12),
                        ...cq.subParts.map((sub) => _buildSubPartTile(sub)).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSubPartTile(CQSubPart sub) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        '(${sub.label}) ${sub.prompt} [${sub.marks}]',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'নমুনা উত্তর:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(sub.modelAnswer, style: const TextStyle(fontSize: 14, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }
}
