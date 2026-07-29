import 'package:flutter/material.dart';

void main() {
  runApp(const SSCPrepApp());
}

class SSCPrepApp extends StatelessWidget {
  const SSCPrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SSC Prep 2027',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const FlashcardsScreen(),
    const AnalyticsScreen(),
    const BookmarksScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'হোম'),
          NavigationDestination(icon: Icon(Icons.style_outlined), selectedIcon: Icon(Icons.style), label: 'সূত্র/কার্ড'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'অ্যানালিটিক্স'),
          NavigationDestination(icon: Icon(Icons.bookmark_border), selectedIcon: Icon(Icons.bookmark), label: 'বুকমার্ক'),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// 1. MAIN HOME SCREEN (Includes textbook features + PDF/Offline downloads)
/// ---------------------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSC Math Prep 2027', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_for_offline, color: Colors.teal),
            tooltip: 'অফলাইন ডেটা',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.psychology, color: Colors.deepPurple),
            tooltip: 'টিউটর গাইডলাইন',
            onPressed: () => _showTutorDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Smart Tutor Banner
            Card(
              color: Colors.teal.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.smart_toy, color: Colors.white),
                ),
                title: const Text('টিউটর (Smart Assistant)', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('প্রতিটি অনুশীলনের সঠিক দিকনির্দেশনা পেতে এখানে ট্যাপ করো।'),
                onTap: () => _showTutorDialog(context),
              ),
            ),
            const SizedBox(height: 20),

            const Text('মডিউল ও প্রস্তুতি', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Feature Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildCard(context, 'অধ্যায়ভিত্তিক প্রস্তুতি', Icons.menu_book, Colors.blue),
                _buildCard(context, 'বোর্ড প্রশ্ন ও সমাধান', Icons.assignment, Colors.orange),
                _buildCard(context, 'নির্বাচনি পরীক্ষার প্রশ্ন', Icons.school, Colors.purple),
                _buildCard(context, 'শিখনফলভিত্তিক প্রশ্ন', Icons.center_focus_strong, Colors.green),
                _buildCard(context, 'অধ্যায়ভিত্তিক মডেল টেস্ট', Icons.timer, Colors.red),
                _buildCard(context, 'সমন্বিত অধ্যায়ের প্রশ্ন', Icons.extension, Colors.indigo),
                _buildCard(context, 'সুপার সাজেশন ২০২৭', Icons.stars, Colors.amber),
                _buildCard(context, 'এক্সক্লুসিভ মডেল টেস্ট', Icons.quiz, Colors.teal),
              ],
            ),
            const SizedBox(height: 24),

            // PDF Download Section (Offline Mode Enabled)
            const Text('প্রশ্নপত্র ও অফলাইন ডাউনলোড', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            _buildDownloadTile('বোর্ড পরীক্ষার প্রশ্নপত্র (২০২৬ ও ২০২৫)', 'PDF • 12.5 MB'),
            const SizedBox(height: 8),
            _buildDownloadTile('শীর্ষস্থানীয় স্কুল টেস্ট পেপার (২০২৫)', 'PDF • 18.2 MB'),
          ],
        ),
      ),
    );
  }

  void _showTutorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [Icon(Icons.psychology, color: Colors.teal), SizedBox(width: 8), Text('টিউটর নির্দেশনা')],
        ),
        content: const Text('১. অধ্যায়ভিত্তিক শিখনফল বিশ্লেষণ ভালো করে দেখে নাও।\n২. প্রথমে বোর্ড প্রশ্ন সমাধান করো, তারপর টেস্ট পেপার দেখুন।\n৩. মডেল টেস্ট দিয়ে তোমার দুর্বলতা চিহ্নিত করো।'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ঠিক আছে'))],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadTile(String title, String subtitle) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.download_for_offline_outlined, color: Colors.teal),
          onPressed: () {},
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// 2. FORMULA FLASHCARDS SCREEN 🆕
/// ---------------------------------------------------------------------------
class FlashcardsScreen extends StatelessWidget {
  const FlashcardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('সূত্র ও ফ্ল্যাশকার্ড')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFlashcard('বীজগণিতীয় সূত্রাবলী', '(a + b)² = a² + 2ab + b²', 'অধ্যায় ৩: বীজগণিতীয় রাশি'),
          _buildFlashcard('ত্রিকোণমিতি', 'sin²θ + cos²θ = 1', 'অধ্যায় ৯: ত্রিকোণমিতিক অনুপাত'),
          _buildFlashcard('পরিমিতি', 'বৃত্তের ক্ষেত্রফল = πr²', 'অধ্যায় ১৬: পরিমিতি'),
        ],
      ),
    );
  }

  Widget _buildFlashcard(String topic, String formula, String chapter) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(chapter, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 6),
            Text(topic, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            Center(
              child: Text(
                formula,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// 3. ANALYTICS DASHBOARD SCREEN 🆕
/// ---------------------------------------------------------------------------
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('আপনার অগ্রগতি ও অ্যানালিটিক্স')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Card(
              color: Colors.teal,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('সর্বমোট প্রস্তুতি', style: TextStyle(color: Colors.white70)),
                        Text('৬৪%', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Icon(Icons.pie_chart, color: Colors.white, size: 48),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('অধ্যায়ভিত্তিক দক্ষতা', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildProgressBar('বাস্তব সংখ্যা', 0.85, Colors.green),
            _buildProgressBar('বীজগণিতীয় রাশি', 0.60, Colors.orange),
            _buildProgressBar('ত্রিকোণমিতি', 0.40, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String title, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('${(value * 100).toInt()}%'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: value, color: color, backgroundColor: Colors.grey.shade300, minHeight: 8),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// 4. BOOKMARKS & NOTES SCREEN 🆕
/// ---------------------------------------------------------------------------
class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('সংরক্ষিত প্রশ্ন ও নোটস')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.bookmark, color: Colors.amber),
              title: Text('ঢাকা বোর্ড ২০২৬ - সৃজনশীল ৩ (খ)'),
              subtitle: Text('নোট: এই জ্যামিতিক প্রমাণটিতে বিকল্প পদ্ধতি প্রযোজ্য।'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
