import 'package:flutter/material.dart';

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
                gradient: LinearGradient(colors: [Color(0xFF1A82BB), Color(0xFF0D4F73)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.school, color: Color(0xFF1A82BB), size: 32),
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
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.15,
                children: [
                  _featureCard(context, 'বিষয়সমূহ', Icons.menu_book, const Color(0xFF1A82BB), () => onNavigate(1)),
                  _featureCard(context, 'রিসোর্স/PDF', Icons.picture_as_pdf, const Color(0xFFD84315), () => onNavigate(2)),
                  _featureCard(context, 'AI টিউটর', Icons.psychology, const Color(0xFF6A1B9A), () => onNavigate(3)),
                  _featureCard(context, 'প্রোফাইল', Icons.person, const Color(0xFF2E7D32), () => onNavigate(4)),
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
