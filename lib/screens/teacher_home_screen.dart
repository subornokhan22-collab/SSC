import 'package:flutter/material.dart';

import '../services/app_style.dart';
import '../services/auth_service.dart';
import 'custom_paper_screen.dart';
import 'profile_screen.dart';
import 'question_paper_screen.dart';
import 'subscription_screen.dart';

/// টিউটর (শিক্ষক) হোম — কালো + সোনালি থিম, চলমান অ্যানিমেটেড গ্লোসহ।
/// বোতামগুলো: অধ্যায়ভিত্তিক প্রিন্ট, ফুল মডেল টেস্ট, কাস্টম পেপার,
/// প্রোফাইল, সাবস্ক্রিপশন।
class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen>
    with SingleTickerProviderStateMixin {
  static const gold = Color(0xFFF7C948);
  static const goldDeep = Color(0xFFB98A1B);

  late final AnimationController _ctrl;
  String _name = '';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 9))
      ..repeat(reverse: true);
    _load();
  }

  Future<void> _load() async {
    await AppStyle.load();
    final p = await AuthService.fetchProfile();
    if (mounted) setState(() => _name = (p?['name'] ?? '').toString());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;
          return Container(
            // অস্বচ্ছ কালো-সোনালি আবহ — নিচের ডিফল্ট ব্যাকগ্রাউন্ড ঢেকে যায়
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1 + t, -1),
                end: Alignment(1 - t, 1),
                colors: const [
                  Color(0xFF0B0B0F),
                  Color(0xFF17130A),
                  Color(0xFF0B0B0F),
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  _glow(t, 1.0, -0.9, 240, gold.withOpacity(0.14)),
                  _glow(1 - t, -1.1, 0.9, 280, const Color(0xFFFFE08A).withOpacity(0.10)),
                  ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: gold, width: 1.6),
                            ),
                            child:
                                const Icon(Icons.school_rounded, color: gold, size: 26),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('A-Learning',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 21,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1)),
                                Text(
                                  _name.isEmpty ? 'Tutor Mode' : 'Welcome, $_name',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.75),
                                      fontSize: 12.5),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: gold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: gold.withOpacity(0.6)),
                            ),
                            child: const Text('Teacher',
                                style: TextStyle(
                                    color: gold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _goldButton(
                        icon: Icons.menu_book_outlined,
                        title: 'Chapter-wise Model Test (Print)',
                        sub: 'Build a paper from a chosen chapter + PDF',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const QuestionPaperScreen(initialMode: 'chapter'),
                          ),
                        ),
                      ),
                      _goldButton(
                        icon: Icons.description_rounded,
                        title: 'Full Model Test Paper (Print)',
                        sub: 'Complete paper in the SSC-2027 format',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const QuestionPaperScreen(initialMode: 'full'),
                          ),
                        ),
                      ),
                      _goldButton(
                        icon: Icons.tune_rounded,
                        title: 'Customised Test Paper',
                        sub: 'Choose chapters & MCQ / short-answer / CQ counts',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CustomPaperScreen()),
                        ),
                      ),
                      _goldButton(
                        icon: Icons.person_outline_rounded,
                        title: 'Profile',
                        sub: 'Account, Pro sync, sign out',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfileScreen()),
                        ),
                      ),
                      _goldButton(
                        icon: Icons.workspace_premium_outlined,
                        title: 'Buy Subscription',
                        sub: 'Unlock all Pro features',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SubscriptionScreen()),
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

  Widget _goldButton({
    required IconData icon,
    required String title,
    required String sub,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [Color(0xFF2A230F), Color(0xFF1B1708)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: gold.withOpacity(0.55), width: 1.4),
              boxShadow: [
                BoxShadow(
                    color: gold.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                        colors: [gold, goldDeep],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                  ),
                  child: Icon(icon, color: Colors.black, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Color(0xFFFFE08A),
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(sub,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 12,
                              height: 1.4)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: gold.withOpacity(0.8), size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _glow(double t, double ax, double ay, double r, Color color) {
    return Align(
      alignment: Alignment(ax, ay),
      child: Transform.scale(
        scale: 0.9 + 0.3 * t,
        child: Container(
          width: r,
          height: r,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}
