import 'package:flutter/material.dart';
import '../data/questions_data.dart';
import '../widgets/animations.dart';
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
    final color = Color(subject.colorHex);
    final totalMcq = allMCQs.where((q) => q.subjectId == subject.id).length;
    final totalCq = allCQs.where((q) => q.subjectId == subject.id).length;

    return Scaffold(
      appBar: AppBar(title: Text(subject.name)),
      body: Column(
        children: [
          // ── Subject banner ────────────────────────────────────────
          FadeSlideIn(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, Color.lerp(color, Colors.black, 0.28)!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Text(subject.icon,
                        style: const TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subject.bengaliName,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _bannerChip('$totalMcq MCQ'),
                            const SizedBox(width: 6),
                            _bannerChip('$totalCq CQ'),
                            const SizedBox(width: 6),
                            _bannerChip('${chapters.length} অধ্যায়'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Chapter list ──────────────────────────────────────────
          Expanded(
            child: chapters.isEmpty
                ? const Center(
                    child: Text('এই বিষয়ে এখনও প্রশ্ন যোগ করা হয়নি।'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = chapters[index];
                      final mcqCount = allMCQs
                          .where((q) =>
                              q.subjectId == subject.id && q.chapter == chapter)
                          .length;
                      final cqCount = allCQs
                          .where((q) =>
                              q.subjectId == subject.id && q.chapter == chapter)
                          .length;
                      return FadeSlideIn(
                        delay:
                            Duration(milliseconds: 60 * (index > 8 ? 8 : index)),
                        offset: const Offset(0, 18),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: color.withOpacity(0.10)),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.07),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 9,
                                    height: 9,
                                    decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      chapter,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  if (mcqCount > 0)
                                    Expanded(
                                      child: _chapterButton(
                                        label: 'MCQ ($mcqCount)',
                                        icon: Icons.quiz_rounded,
                                        color: color,
                                        filled: true,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => QuizScreen(
                                              subjectId: subject.id,
                                              chapter: chapter,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (mcqCount > 0 && cqCount > 0)
                                    const SizedBox(width: 10),
                                  if (cqCount > 0)
                                    Expanded(
                                      child: _chapterButton(
                                        label: 'CQ ($cqCount)',
                                        icon: Icons.edit_note_rounded,
                                        color: color,
                                        filled: false,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CQScreen(
                                              subjectId: subject.id,
                                              chapter: chapter,
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
          ),
        ],
      ),
    );
  }

  Widget _bannerChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _chapterButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: filled ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: filled ? null : Border.all(color: color.withOpacity(0.4)),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: filled ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: filled ? Colors.white : color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
