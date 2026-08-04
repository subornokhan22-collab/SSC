import 'package:flutter/material.dart';
import '../data/questions_data.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import 'model_test_screen.dart';
import 'question_paper_screen.dart';
import 'subjects_screen.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int) onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 11) return 'সুপ্রভাত!';
    if (h < 15) return 'শুভ দুপুর!';
    if (h < 18) return 'শুভ বিকাল!';
    if (h < 20) return 'শুভ সন্ধ্যা!';
    return 'শুভ রাত্রি!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ── Hero header ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 44),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(right: -30, top: -40, child: _decoCircle(140, 0.08)),
                  Positioned(right: 60, bottom: -30, child: _decoCircle(80, 0.06)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideIn(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.18),
                                    blurRadius: 12,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.school,
                                  color: AppTheme.primary, size: 32),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                'A-Learning',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 120),
                        child: Text(
                          _greeting,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const FadeSlideIn(
                        delay: Duration(milliseconds: 200),
                        child: Text(
                          'SSC 2027 প্রস্তুতি — আজকের পড়া শুরু হোক',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Stats strip (overlapping the header) ─────────────────
            Transform.translate(
              offset: const Offset(0, -22),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 260),
                  offset: const Offset(0, 18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _stat(Icons.quiz_rounded, allMCQs.length, 'MCQ প্রশ্ন',
                            AppTheme.primary),
                        _stat(Icons.edit_note_rounded, allCQs.length,
                            'CQ প্রশ্ন', AppTheme.secondary),
                        _stat(Icons.menu_book_rounded, allSubjects.length,
                            'বিষয়', const Color(0xFF6A1B9A)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  // ── Model test banner ───────────────────────────────
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 340),
                    child: PressableScale(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ModelTestScreen()),
                      ),
                      child: ShineSweep(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.accent, Color(0xFFFF9D00)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accent.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 7),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Pulse(
                                max: 1.12,
                                min: 0.94,
                                period: Duration(milliseconds: 1400),
                                child: Icon(Icons.emoji_events,
                                    color: Colors.white, size: 36),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'ফুল মডেল টেস্ট\nMCQ + সংক্ষিপ্ত প্রশ্ন + সৃজনশীল',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white, size: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Tutor question-paper shortcut ───────────────────
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 400),
                    child: PressableScale(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const QuestionPaperScreen()),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: const Color(0xFF00838F)
                                  .withOpacity(0.28)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00838F)
                                  .withOpacity(0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF00838F).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.description_rounded,
                                  color: Color(0xFF00838F), size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'প্রশ্নপত্র',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14.5,
                                      color: Color(0xFF00838F),
                                    ),
                                  ),
                                  SizedBox(height: 1),
                                  Text(
                                    'প্রিন্ট-রেডি পেপার • টিউটর (Demo/Pro)',
                                    style: TextStyle(
                                        fontSize: 11.5,
                                        color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: Color(0xFF00838F)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Feature grid ────────────────────────────────────
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.08,
                    children: [
                      _featureCard(
                        context,
                        0,
                        'বিষয়সমূহ',
                        'সব বিষয়ের প্রশ্নব্যাংক',
                        Icons.menu_book_rounded,
                        AppTheme.primary,
                        () => onNavigate(1),
                      ),
                      _featureCard(
                        context,
                        1,
                        'রিসোর্স/PDF',
                        'নোট ও গাইড ডাউনলোড',
                        Icons.picture_as_pdf_rounded,
                        const Color(0xFFD84315),
                        () => onNavigate(2),
                      ),
                      _featureCard(
                        context,
                        2,
                        'AI টিউটর',
                        'যেকোনো প্রশ্ন জিজ্ঞেস করো',
                        Icons.psychology_rounded,
                        const Color(0xFF6A1B9A),
                        () => onNavigate(3),
                      ),
                      _featureCard(
                        context,
                        3,
                        'প্রোফাইল',
                        'তোমার অগ্রগতি দেখো',
                        Icons.person_rounded,
                        const Color(0xFF2E7D32),
                        () => onNavigate(4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Motivation tip ──────────────────────────────────
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 650),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.secondary.withOpacity(0.12),
                            AppTheme.primary.withOpacity(0.06),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: AppTheme.secondary.withOpacity(0.25)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_rounded,
                              color: AppTheme.secondary.withOpacity(0.9),
                              size: 28),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'আজকের টিপস: প্রতিদিন অন্তত ২০টি MCQ সমাধান করো — ধারাবাহিকতাই সাফল্যের চাবিকাঠি!',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.45,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _decoCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }

  Widget _stat(IconData icon, int value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          CountUp(
            value: value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style:
                  TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _featureCard(BuildContext context, int index, String label,
      String caption, IconData icon, Color color, VoidCallback onTap) {
    return FadeSlideIn(
      delay: Duration(milliseconds: 400 + 80 * index),
      child: PressableScale(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.14)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.10),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.18), color.withOpacity(0.06)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 10),
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                      color: AppTheme.textDark)),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  caption,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
