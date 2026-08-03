import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'model_test_screen.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int) onNavigate;
  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.primary, Color(0xFF0D4F73)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.school, color: AppTheme.primary, size: 32),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text('A-Learning\nSSC 2027 প্রস্তুতি', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.3)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ModelTestScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppTheme.accent, Color(0xFFFFA000)]),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: AppTheme.accent.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 6))],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.white, size: 34),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'ফুল মডেল টেস্ট\nMCQ + সংক্ষিপ্ত প্রশ্ন + সৃজনশীল',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, height: 1.3),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.15,
                    children: [
                      _featureCard(context, 'বিষয়সমূহ', Icons.menu_book, AppTheme.primary, () => onNavigate(1)),
                      _featureCard(context, 'রিসোর্স/PDF', Icons.picture_as_pdf, const Color(0xFFD84315), () => onNavigate(2)),
                      _featureCard(context, 'AI টিউটর', Icons.psychology, const Color(0xFF6A1B9A), () => onNavigate(3)),
                      _featureCard(context, 'প্রোফাইল', Icons.person, const Color(0xFF2E7D32), () => onNavigate(4)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureCard(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withOpacity(0.2))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 34),
            const SizedBox(height: 10),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
