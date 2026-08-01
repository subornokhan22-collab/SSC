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
    final cqs = QuestionsData.cqs
        .where((q) => q.subject == subjectId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('$subjectName - সৃজনশীল (CQ)'),
        backgroundColor: const Color(0xFF1A82BB),
        foregroundColor: Colors.white,
      ),
      body: cqs.isEmpty
          ? const Center(child: Text('এই বিষয়ে কোনো সৃজনশীল প্রশ্ন নেই।'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cqs.length,
              itemBuilder: (context, index) {
                final cq = cqs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'অধ্যায়: ${cq.chapter}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A82BB)),
                            ),
                            Chip(
                              label: Text(cq.sourceLabel, style: const TextStyle(fontSize: 11, color: Colors.white)),
                              backgroundColor: Colors.teal.shade700,
                            ),
                          ],
                        ),
                        const Divider(),

                        // Stem (উদ্দীপক)
                        const Text(
                          'উদ্দীপক:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            cq.stem,
                            style: const TextStyle(fontSize: 16, height: 1.4),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Sub Parts (ক, খ, গ, ঘ)
                        ...cq.subParts.map((sub) => _buildSubPartWidget(sub)).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSubPartWidget(CQSubPart sub) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool showAnswer = false;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ExpansionTile(
            title: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xFF1A82BB),
                  child: Text(
                    sub.label,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    sub.prompt,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  '[${sub.marks}]',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ],
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.teal.shade50,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'নমুনা উত্তর (Model Answer):',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sub.modelAnswer.isNotEmpty ? sub.modelAnswer : 'উত্তর প্রস্তুত করা হচ্ছে...',
                      style: const TextStyle(fontSize: 14, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
