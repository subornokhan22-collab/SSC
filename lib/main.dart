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
      title: 'SSC Master Prep 2027',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
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
    const AllSubjectsScreen(),
    const ExamHubScreen(),
    const PdfLibraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'হোম'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'বিষয়সমূহ'),
          NavigationDestination(icon: Icon(Icons.timer_outlined), selectedIcon: Icon(Icons.timer), label: 'পরীক্ষা (Exam)'),
          NavigationDestination(icon: Icon(Icons.picture_as_pdf_outlined), selectedIcon: Icon(Icons.picture_as_pdf), label: 'PDF সংগ্রহ'),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// SUBJECT DATA MODELS
/// ---------------------------------------------------------------------------
class Subject {
  final String name;
  final String code;
  final IconData icon;
  final Color color;
  final List<String> chapters;

  Subject({required this.name, required this.code, required this.icon, required this.color, required this.chapters});
}

final List<Subject> sscSubjects = [
  Subject(
    name: 'গণিত (General Math)',
    code: '109',
    icon: Icons.calculate,
    color: Colors.indigo,
    chapters: ['বাস্তব সংখ্যা', 'সেট ও ফাংশন', 'বীজগণিতীয় রাশি', 'সূচক ও লগারিদম', 'এক চলকবিশিষ্ট সমীকরণ', 'ত্রিকোণমিতিক অনুপাত', 'পরিমিতি', 'পরিসংখ্যান'],
  ),
  Subject(
    name: 'উচ্চতর গণিত (Higher Math)',
    code: '126',
    icon: Icons.functions,
    color: Colors.deepPurple,
    chapters: ['সেট ও ফাংশন', 'বীজগণিতীয় রাশি', 'জ্যামিতি', 'স্থানাঙ্ক জ্যামিতি', 'অসীম ধারা', 'ত্রিকোণমিতি', 'সম্ভাবনা'],
  ),
  Subject(
    name: 'পদার্থবিজ্ঞান (Physics)',
    code: '136',
    icon: Icons.science,
    color: Colors.blue,
    chapters: ['ভৌত রাশি ও পরিমাপ', 'গতি', 'বল', 'কাজ, ক্ষমতা ও শক্তি', 'পদার্থের অবস্থা ও চাপ', 'শব্দ ও তরঙ্গ', 'আলোর প্রতিফলন', 'চল বিদ্যুৎ'],
  ),
  Subject(
    name: 'রসায়ন (Chemistry)',
    code: '137',
    icon: Icons.biotech,
    color: Colors.teal,
    chapters: ['রসায়নের ধারণা', 'পদার্থের অবস্থা', 'পর্যায় সারণি', 'রাসায়নিক বন্ধন', 'এসিড-ক্ষার সমতা', 'খনিজ সম্পদ ও জীবাশ্ম'],
  ),
  Subject(
    name: 'জীববিজ্ঞান (Biology)',
    code: '138',
    icon: Icons.eco,
    color: Colors.green,
    chapters: ['জীবন পাঠ', 'জীবকোষ ও টিস্যু', 'কোষ বিভাজন', 'জীবনীশক্তি', 'উদ্ভিদে পরিবহন', 'মানব রেচন', 'জীবের বংশগতি ও বিবর্তন'],
  ),
  Subject(
    name: 'ইংরেজি (English Prep)',
    code: '107',
    icon: Icons.language,
    color: Colors.orange,
    chapters: ['Grammar: Right Form of Verbs', 'Changing Sentences', 'Tag Questions', 'Paragraph Writing', 'CV Writing'],
  ),
  Subject(
    name: 'তথ্য ও যোগাযোগ প্রযুক্তি (ICT)',
    code: '154',
    icon: Icons.computer,
    color: Colors.cyan,
    chapters: ['তথ্য ও যোগাযোগ প্রযুক্তি এবং আমাদের বাংলাদেশ', 'কম্পিউটার ও কম্পিউটার ব্যবহারকারীর নিরাপত্তা', 'আমার শিক্ষায় ইন্টারনেট'],
  ),
  Subject(
    name: 'বাংলা (Bangla First & Second)',
    code: '101',
    icon: Icons.book,
    color: Colors.crimson,
    chapters: ['গদ্য ও পদ্য বিশ্লেষণ', 'ব্যাকরণ: সমাস ও কারক', 'সন্ধি ও উপসর্গ', 'অনুবাদ ও সারাংশ'],
  ),
];

/// ---------------------------------------------------------------------------
/// HOME SCREEN
/// ---------------------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSC All Subjects 2027', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.amber),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('আজকের স্পেশাল মডেল টেস্ট রাত ৮টায়!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Assistant Card
            Card(
              elevation: 0,
              color: Colors.indigo.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.indigo,
                      child: Icon(Icons.smart_toy, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('স্মার্ট অল-সাবজেক্ট টিউটর', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('সকল বিষয়ের অধ্যায়ভিত্তিক নোট, প্রশ্ন এবং উত্তর এক জায়গায়।'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('সকল বিষয় (Subjects)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AllSubjectsScreen()));
                  },
                  child: const Text('সব দেখুন'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Horizontal Subject Scroll
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: sscSubjects.length,
                itemBuilder: (context, index) {
                  final subject = sscSubjects[index];
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectDetailScreen(subject: subject))),
                      borderRadius: BorderRadius.circular(12),
                      child: Card(
                        color: subject.color.withOpacity(0.1),
                        elevation: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(subject.icon, color: subject.color, size: 32),
                            const SizedBox(height: 8),
                            Text(subject.name.split(' ')[0], textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            const Text('দ্রুত প্রস্তুতি (Quick Shortcuts)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildActionTile(context, 'লাইভ মডেল টেস্ট', Icons.timer, Colors.red, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamHubScreen()));
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(context, 'PDF প্রশ্ন ব্যাংক', Icons.picture_as_pdf, Colors.redAccent, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PdfLibraryScreen()));
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// SUBJECTS LIST SCREEN
/// ---------------------------------------------------------------------------
class AllSubjectsScreen extends StatelessWidget {
  const AllSubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('সকল বিষয় (SSC Curriculum)')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sscSubjects.length,
        itemBuilder: (context, index) {
          final subject = sscSubjects[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: subject.color,
                child: Icon(subject.icon, color: Colors.white),
              ),
              title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${subject.chapters.length} টি অধ্যায় • বিষয় কোড: ${subject.code}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectDetailScreen(subject: subject)));
              },
            ),
          );
        },
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// SUBJECT DETAIL & CHAPTER SCREEN
/// ---------------------------------------------------------------------------
class SubjectDetailScreen extends StatelessWidget {
  final Subject subject;
  const SubjectDetailScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(subject.name)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subject.chapters.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: subject.color.withOpacity(0.2),
                child: Text('${index + 1}', style: TextStyle(color: subject.color, fontWeight: FontWeight.bold)),
              ),
              title: Text(subject.chapters[index], style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('অধ্যায়ভিত্তিক MCQ, সৃজনশীল ও নোটস'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${subject.chapters[index]} ওপেন করা হচ্ছে...')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// EXAM HUB & INTERACTIVE MCQ TEST
/// ---------------------------------------------------------------------------
class ExamHubScreen extends StatelessWidget {
  const ExamHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('অনলাইন পরীক্ষা ও মডেল টেস্ট')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Colors.red.shade50,
              child: ListTile(
                leading: const Icon(Icons.live_tv, color: Colors.red),
                title: const Text('দৈনিক লাইভ MCQ পরীক্ষা', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('সময়: ২০ মিনিট | ২৫ টি প্রশ্ন'),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveMcqExamScreen()));
                  },
                  child: const Text('শুরু করুন'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Align(alignment: Alignment.centerLeft, child: Text('বিষয়ভিত্তিক আর্কাইভ টেস্ট', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: sscSubjects.length,
                itemBuilder: (context, index) {
                  final sub = sscSubjects[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(sub.icon, color: sub.color),
                      title: Text('${sub.name} মডেল টেস্ট'),
                      subtitle: const Text('৩০ মিনিট • ৩০ নম্বর'),
                      trailing: const Icon(Icons.play_circle_fill, color: Colors.indigo, size: 30),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveMcqExamScreen()));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LiveMcqExamScreen extends StatefulWidget {
  const LiveMcqExamScreen({super.key});

  @override
  State<LiveMcqExamScreen> createState() => _LiveMcqExamScreenState();
}

class _LiveMcqExamScreenState extends State<LiveMcqExamScreen> {
  int _selectedAnswer = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('অনলাইন MCQ পরীক্ষা'),
        actions: const [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('⏱️ ১৫:০০', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('প্রশ্ন ১ / ১০', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            const Text(
              'যদি $\\log_x 25 = 2$ হয়, তবে $x$ এর মান কত?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            _buildOption(0, 'A) 5'),
            _buildOption(1, 'B) 10'),
            _buildOption(2, 'C) 25'),
            _buildOption(3, 'D) 50'),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                onPressed: _selectedAnswer == -1
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('উত্তর সফলভাবে জমা হয়েছে!')),
                        );
                        Navigator.pop(context);
                      },
                child: const Text('উত্তর জমা দিন (Submit)', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(int index, String text) {
    final isSelected = _selectedAnswer == index;
    return Card(
      color: isSelected ? Colors.indigo.shade100 : Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: isSelected ? Colors.indigo : Colors.grey.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        onTap: () => setState(() => _selectedAnswer = index),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// PDF HUB & DOWNLOAD MANAGER
/// ---------------------------------------------------------------------------
class PdfLibraryScreen extends StatelessWidget {
  const PdfLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> pdfs = [
      {'title': 'সকল বোর্ড প্রশ্নপত্র ২০২৬ (All Board Questions)', 'size': '24.5 MB'},
      {'title': 'শীর্ষস্থানীয় স্কুল টেস্ট পেপার (Top Schools)', 'size': '32.1 MB'},
      {'title': 'পদার্থবিজ্ঞান ও রসায়ন গুরুত্বপূর্ণ চিত্র নোট', 'size': '8.4 MB'},
      {'title': 'উচ্চতর গণিত সূত্রাবলী ও শর্টকাট শিট', 'size': '4.2 MB'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('PDF বোর্ড প্রশ্ন ও সাজেশন্স')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pdfs.length,
        itemBuilder: (context, index) {
          final pdf = pdfs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 36),
              title: Text(pdf['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(pdf['size']!),
              trailing: IconButton(
                icon: const Icon(Icons.download_for_offline, color: Colors.indigo),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${pdf['title']} ডাউনলোড হচ্ছে...')),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}