import 'dart:async';
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
    const AiTutorScreen(),
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
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'হোম',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'বিষয়সমূহ',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'পরীক্ষা',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'AI টিউটর',
          ),
          NavigationDestination(
            icon: Icon(Icons.picture_as_pdf_outlined),
            selectedIcon: Icon(Icons.picture_as_pdf),
            label: 'PDF',
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// DATA MODELS
/// ---------------------------------------------------------------------------
class Subject {
  final String name;
  final String code;
  final IconData icon;
  final Color color;
  final List<String> chapters;

  Subject({
    required this.name,
    required this.code,
    required this.icon,
    required this.color,
    required this.chapters,
  });
}

class Question {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });
}

/// ---------------------------------------------------------------------------
/// FULL SSC CURRICULUM SUBJECTS & CHAPTERS
/// ---------------------------------------------------------------------------
final List<Subject> sscSubjects = [
  Subject(
    name: 'বাংলা ১ম পত্র (Bangla 1st)',
    code: '101',
    icon: Icons.menu_book,
    color: Colors.red,
    chapters: [
      'শুভা',
      'বই পড়া',
      'আম আঁটির ভেঁপু',
      'মানুষ মুহম্মদ (স.)',
      'নিমগাছ',
      'শিক্ষা ও মনুষ্যত্ব',
      'প্রবাস বন্ধু',
      'মমতাদি',
      'একাত্তরের দিনগুলি',
      'কপোতাক্ষ নদ',
      'সবাই আমি',
      'রানার',
      'তোমাকে পাওয়ার জন্য, হে স্বাধীনতা',
      'স্বাধীনতা, এই শব্দটি কীভাবে আমাদের হলো'
    ],
  ),
  Subject(
    name: 'বাংলা ২য় পত্র (Bangla 2nd)',
    code: '102',
    icon: Icons.history_edu,
    color: Colors.redAccent,
    chapters: [
      'ধ্বনি ও বর্ণ',
      'ধ্বনি পরিবর্তন',
      'সন্ধি',
      'দ্বিরুক্ত শব্দ',
      'সংখ্যাবাচক শব্দ',
      'সমাস',
      'উপসর্গ',
      'প্রত্যয়',
      'কারক ও বিভক্তি',
      'বাক্য প্রকরণ',
      'বাচ্য ও বাচ্য পরিবর্তন',
      'বাগধারা',
      'সমার্থক ও বিপরীতার্থক শব্দ'
    ],
  ),
  Subject(
    name: 'English 1st Paper',
    code: '107',
    icon: Icons.language,
    color: Colors.blue,
    chapters: [
      'Father of the Nation',
      'Pastime',
      'Events and Festivals',
      'Youthful Achievers',
      'Nature and Environment',
      'Our Neighbors',
      'World Heritage',
      'International Mother Language Day'
    ],
  ),
  Subject(
    name: 'English 2nd Paper',
    code: '108',
    icon: Icons.spellcheck,
    color: Colors.lightBlue,
    chapters: [
      'Articles & Determiners',
      'Prepositions',
      'Right Forms of Verbs',
      'Changing Sentences (Voice/Degree/Structure)',
      'Tag Questions',
      'Connectors & Sentence Linkers',
      'Punctuating & Capitalization',
      'Composition & CV Writing'
    ],
  ),
  Subject(
    name: 'সাধারণ গণিত (General Math)',
    code: '109',
    icon: Icons.calculate,
    color: Colors.indigo,
    chapters: [
      'বাস্তব সংখ্যা',
      'সেট ও ফাংশন',
      'বীজগণিতীয় রাশি',
      'সূচক ও লগারিদম',
      'এক চলকবিশিষ্ট সমীকরণ',
      'রেখা, কোণ ও ত্রিভুজ',
      'ব্যবহারিক জ্যামিতি',
      'বৃত্ত',
      'ত্রিকোণমিতিক অনুপাত',
      'দূরত্ব ও উচ্চতা',
      'পরিমিতি',
      'পরিসংখ্যান'
    ],
  ),
  Subject(
    name: 'উচ্চতর গণিত (Higher Math)',
    code: '126',
    icon: Icons.functions,
    color: Colors.purple,
    chapters: [
      'সেট ও ফাংশন',
      'বীজগণিতীয় রাশি',
      'দ্বিপদী বিস্তৃতি',
      'সমতলীয় জ্যামিতি',
      'স্থানাঙ্ক জ্যামিতি',
      'অসীম ধারা',
      'ত্রিকোণমিতি',
      'সম্ভাবনা'
    ],
  ),
  Subject(
    name: 'পদার্থবিজ্ঞান (Physics)',
    code: '136',
    icon: Icons.science,
    color: Colors.deepOrange,
    chapters: [
      'ভৌত রাশি ও পরিমাপ',
      'গতি',
      'বল',
      'কাজ, ক্ষমতা ও শক্তি',
      'পদার্থের অবস্থা ও চাপ',
      'বস্তুর উপর তাপের প্রভাব',
      'শব্দ ও তরঙ্গ',
      'আলোর প্রতিফলন',
      'আলোর প্রতিসরণ',
      'স্থির বিদ্যুৎ',
      'চল বিদ্যুৎ',
      'বিদ্যুতের চৌম্বক ক্রিয়া'
    ],
  ),
  Subject(
    name: 'রসায়ন (Chemistry)',
    code: '137',
    icon: Icons.biotech,
    color: Colors.teal,
    chapters: [
      'রসায়নের ধারণা',
      'পদার্থের অবস্থা',
      'পদার্থের গঠন',
      'পর্যায় সারণি',
      'রাসায়নিক বন্ধন',
      'মোলের ধারণা ও রাসায়নিক গণনা',
      'রাসায়নিক বিক্রিয়া',
      'রসায়ন ও শক্তি',
      'এসিড-ক্ষার সমতা',
      'খনিজ সম্পদ-ধাতু ও অধাতু',
      'খনিজ সম্পদ-জীবাশ্ম'
    ],
  ),
  Subject(
    name: 'জীববিজ্ঞান (Biology)',
    code: '138',
    icon: Icons.eco,
    color: Colors.green,
    chapters: [
      'জীবন পাঠ',
      'জীবকোষ ও টিস্যু',
      'কোষ বিভাজন',
      'জীবনীশক্তি',
      'উদ্ভিদ ও মানুষের খাদ্য ও পুষ্টি',
      'জীব পরিবহন',
      'গ্যাসীয় বিনিময়',
      'রেচন প্রক্রিয়া',
      'দৃঢ়তা প্রদান ও চলন',
      'সমন্বয় ও নিঃসরণ',
      'জীবের প্রজনন',
      'জীবের বংশগতি ও বিবর্তন'
    ],
  ),
  Subject(
    name: 'ICT (তথ্য ও যোগাযোগ প্রযুক্তি)',
    code: '154',
    icon: Icons.computer,
    color: Colors.cyan,
    chapters: [
      'তথ্য ও যোগাযোগ প্রযুক্তি এবং আমাদের বাংলাদেশ',
      'কম্পিউটার ও কম্পিউটার ব্যবহারকারীর নিরাপত্তা',
      'আমার শিক্ষায় ইন্টারনেট',
      'আমার লেখালেখি ও হিসাব',
      'মাল্টিমিডিয়া ও গ্রাফিক্স',
      'ডাটাবেজ এর ব্যবহার'
    ],
  ),
];

/// ---------------------------------------------------------------------------
/// QUESTION BANK FOR EXAMS
/// ---------------------------------------------------------------------------
final Map<String, List<Question>> questionBank = {
  'General Math': [
    Question(
      questionText: r'যদি log_x (25) = 2 হয়, তবে x এর মান কত?',
      options: ['A) 5', 'B) 10', 'C) 25', 'D) ±5'],
      correctAnswerIndex: 0,
      explanation: r'log_x (25) = 2 => x² = 25 => x = 5 (ভিত্তি ঋণাত্মক হতে পারে না)।',
    ),
    Question(
      questionText: r'a + b = 5 এবং a - b = 3 হলে, a² + b² এর মান কত?',
      options: ['A) 17', 'B) 34', 'C) 16', 'D) 8'],
      correctAnswerIndex: 0,
      explanation: r'2(a² + b²) = (a+b)² + (a-b)² = 25 + 9 = 34 => a² + b² = 17।',
    ),
    Question(
      questionText: r'sinθ = 3/5 হলে, tanθ এর মান কত?',
      options: ['A) 4/5', 'B) 3/4', 'C) 4/3', 'D) 5/3'],
      correctAnswerIndex: 1,
      explanation: r'লম্ব = 3, অতিভুজ = 5 => ভূমি = √(25-9) = 4। সুতরাং tanθ = 3/4।',
    ),
    Question(
      questionText: r'একটি সমবাহু ত্রিভুজের বাহুর দৈর্ঘ্য 4 সেমি হলে এর ক্ষেত্রফল কত?',
      options: ['A) 4√3 বর্গ সেমি', 'B) 8√3 বর্গ সেমি', 'C) 16√3 বর্গ সেমি', 'D) 2√3 বর্গ সেমি'],
      correctAnswerIndex: 0,
      explanation: r'ক্ষেত্রফল = (√3 / 4) × a² = (√3 / 4) × 16 = 4√3।',
    ),
    Question(
      questionText: r'2^(x + 2) = 16 হলে, x এর মান কত?',
      options: ['A) 1', 'B) 2', 'C) 3', 'D) 4'],
      correctAnswerIndex: 1,
      explanation: r'2^(x + 2) = 2^4 => x + 2 = 4 => x = 2।',
    ),
  ],
  'Physics': [
    Question(
      questionText: 'স্থির অবস্থান থেকে বিনামূল্যে পড়ন্ত বস্তুর ৩ সেকেন্ডে অতিক্রান্ত দূরত্ব কত?',
      options: ['A) 14.7 m', 'B) 29.4 m', 'C) 44.1 m', 'D) 88.2 m'],
      correctAnswerIndex: 2,
      explanation: r'h = (1/2) × g × t² = 0.5 × 9.8 × 9 = 44.1 মিটার।',
    ),
    Question(
      questionText: 'শব্দের বেগ সবচেয়ে বেশি কোন মাধ্যমে?',
      options: ['A) বায়ুতে', 'B) তরলে', 'C) কঠিন পদার্থে', 'D) শূন্যস্থানে'],
      correctAnswerIndex: 2,
      explanation: 'কঠিন মাধ্যমে অণুগুলো কাছাকাছি থাকায় শব্দের বেগ সবচেয়ে বেশি।',
    ),
    Question(
      questionText: 'বল (F) ও ত্বরণ (a) এর সম্পর্ক প্রকাশ করে নিউটনের কোন গতিসূত্র?',
      options: ['A) প্রথম সূত্র', 'B) দ্বিতীয় সূত্র', 'C) তৃতীয় সূত্র', 'D) মহাকর্ষ সূত্র'],
      correctAnswerIndex: 1,
      explanation: 'নিউটনের দ্বিতীয় সূত্র F = ma নির্দেশ করে।',
    ),
  ],
  'Bangla 1st': [
    Question(
      questionText: '‘শুভা’ গল্পে শুভার প্রকৃত নাম কী ছিল?',
      options: ['A) সুভাষিণী', 'B) সুকেশিনী', 'C) সুহাসিনী', 'D) সুচরিতা'],
      correctAnswerIndex: 0,
      explanation: 'শুভার বড় দুই বোনের নাম সুকেশিনী ও সুহাসিনী, আর তার নাম সুভাষিণী।',
    ),
    Question(
      questionText: '‘বই পড়া’ প্রবন্ধ অনুযায়ী মানুষের সর্বশ্রেষ্ঠ শখ কোনটি হওয়া উচিত?',
      options: ['A) গান শোনা', 'B) ভ্রমণ করা', 'C) বই পড়া', 'D) খেলাধুলা করা'],
      correctAnswerIndex: 2,
      explanation: 'প্রমথ চৌধুরীর মতে, বই পড়াই মানুষের সর্বশ্রেষ্ঠ শখ হওয়া উচিত।',
    ),
  ],
  'Bangla 2nd': [
    Question(
      questionText: '‘সন্ধি’ ব্যাকরণের কোন অংশে আলোচিত হয়?',
      options: ['A) রূপতত্ত্ব', 'B) ধ্বনিতত্ত্ব', 'C) বাক্যতত্ত্ব', 'D) অর্থতত্ত্ব'],
      correctAnswerIndex: 1,
      explanation: 'সন্ধি মূলত ধ্বনির মিলন, তাই এটি ধ্বনিতত্ত্বে আলোচিত হয়।',
    ),
    Question(
      questionText: '‘হাতাহাতি’ কোন সমাসের উদাহরণ?',
      options: ['A) বহুব্রীহি', 'B) ব্যতিহার বহুব্রীহি', 'C) দ্বন্দ্ব', 'D) তৎপুরুষ'],
      correctAnswerIndex: 1,
      explanation: 'ক্রিয়ার পারস্পরিক অর্থ প্রকাশ করলে ব্যতিহার বহুব্রীহি সমাস হয়।',
    ),
  ],
};

/// ---------------------------------------------------------------------------
/// HOME SCREEN
/// ---------------------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSC Prep 2027', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.indigo, Colors.blueAccent]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.school, size: 50, color: Colors.white),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('SSC 2027 সম্পূর্ণ প্রস্তুতি', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('সকল বিষয়ের অধ্যায়ভিত্তিক MCQ, লাইভ পরীক্ষা ও নোটস।', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('মূল ফিচারসমূহ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildQuickCard(context, 'লাইভ পরীক্ষা', Icons.timer, Colors.red, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveMcqExamScreen(subjectName: 'General Math')));
                }),
                _buildQuickCard(context, 'সকল বিষয়', Icons.menu_book, Colors.indigo, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AllSubjectsScreen()));
                }),
                _buildQuickCard(context, 'AI শিক্ষক', Icons.smart_toy, Colors.purple, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AiTutorScreen()));
                }),
                _buildQuickCard(context, 'PDF লাইব্রেরি', Icons.picture_as_pdf, Colors.orange, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PdfLibraryScreen()));
                }),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuickCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        color: color.withOpacity(0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withOpacity(0.3))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
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
      appBar: AppBar(title: const Text('বিষয় তালিকা (SSC Subjects)')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: sscSubjects.length,
        itemBuilder: (context, index) {
          final subject = sscSubjects[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: subject.color,
                child: Icon(subject.icon, color: Colors.white, size: 20),
              ),
              title: Text(subject.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${subject.chapters.length} টি অধ্যায় • বিষয় কোড: ${subject.code}'),
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
/// CHAPTER LIST SCREEN
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
                backgroundColor: subject.color.withOpacity(0.15),
                child: Text('${index + 1}', style: TextStyle(color: subject.color, fontWeight: FontWeight.bold)),
              ),
              title: Text(subject.chapters[index], style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('অধ্যায়ভিত্তিক MCQ ও কুইজ প্র্যাকটিস'),
              trailing: const Icon(Icons.play_circle_fill, color: Colors.indigo),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => LiveMcqExamScreen(subjectName: subject.name)));
              },
            ),
          );
        },
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// EXAM HUB SCREEN
/// ---------------------------------------------------------------------------
class ExamHubScreen extends StatelessWidget {
  const ExamHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('পরীক্ষা ও মডেল টেস্ট')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.red.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.redAccent)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.live_tv, color: Colors.red),
                      SizedBox(width: 8),
                      Text('দৈনিক স্পেশাল মডেল টেস্ট', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('সময়: ১৫ মিনিট | প্রশ্নভিত্তিক অটোমেটিক রেজাল্ট'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveMcqExamScreen(subjectName: 'General Math')));
                    },
                    child: const Text('পরীক্ষা শুরু করুন'),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('বিষয়ভিত্তিক প্র্যাকটিস পরীক্ষা', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...sscSubjects.map((subject) => Card(
            child: ListTile(
              leading: Icon(subject.icon, color: subject.color),
              title: Text(subject.name),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => LiveMcqExamScreen(subjectName: subject.name)));
              },
            ),
          )),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// INTERACTIVE EXAM ENGINE (TIMED & MULTI-QUESTION)
/// ---------------------------------------------------------------------------
class LiveMcqExamScreen extends StatefulWidget {
  final String subjectName;
  const LiveMcqExamScreen({super.key, required this.subjectName});

  @override
  State<LiveMcqExamScreen> createState() => _LiveMcqExamScreenState();
}

class _LiveMcqExamScreenState extends State<LiveMcqExamScreen> {
  late List<Question> _questions;
  int _currentQuestionIndex = 0;
  late List<int> _userAnswers;

  Timer? _timer;
  int _remainingSeconds = 900; // 15 Minutes

  @override
  void initState() {
    super.initState();
    // Match subject questions or fallback to General Math
    String key = 'General Math';
    if (widget.subjectName.contains('Physics')) key = 'Physics';
    if (widget.subjectName.contains('বাংলা ১ম')) key = 'Bangla 1st';
    if (widget.subjectName.contains('বাংলা ২য়')) key = 'Bangla 2nd';

    _questions = questionBank[key] ?? questionBank['General Math']!;
    _userAnswers = List<int>.filled(_questions.length, -1);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        _submitExam();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _submitExam() {
    _timer?.cancel();
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] == _questions[i].correctAnswerIndex) {
        score++;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('পরীক্ষার ফলাফল 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('আপনার প্রাপ্ত নম্বর: $score / ${_questions.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('সঠিক উত্তর: $score টি'),
            Text('ভুল/উত্তরহীন: ${_questions.length - score} টি'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('ঠিক আছে'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectName),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                const Icon(Icons.timer, color: Colors.red, size: 18),
                const SizedBox(width: 4),
                Text(_formattedTime, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.grey.shade300,
              color: Colors.indigo,
            ),
            const SizedBox(height: 16),

            Text('প্রশ্ন ${_currentQuestionIndex + 1} / ${_questions.length}', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Text(
              currentQuestion.questionText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            ...List.generate(currentQuestion.options.length, (index) {
              final isSelected = _userAnswers[_currentQuestionIndex] == index;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.indigo.shade50 : Colors.white,
                    side: BorderSide(color: isSelected ? Colors.indigo : Colors.grey.shade300, width: isSelected ? 2 : 1),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    alignment: Alignment.centerLeft,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    setState(() {
                      _userAnswers[_currentQuestionIndex] = index;
                    });
                  },
                  child: Text(
                    currentQuestion.options[index],
                    style: TextStyle(
                      fontSize: 15,
                      color: isSelected ? Colors.indigo : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: () => setState(() => _currentQuestionIndex--),
                    child: const Text('পূর্ববর্তী'),
                  )
                else
                  const SizedBox.shrink(),

                if (_currentQuestionIndex < _questions.length - 1)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                    onPressed: () => setState(() => _currentQuestionIndex++),
                    child: const Text('পরবর্তী'),
                  )
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    onPressed: _submitExam,
                    child: const Text('জমা দিন (Submit)'),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// AI TUTOR SCREEN
/// ---------------------------------------------------------------------------
class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'sender': 'ai', 'text': 'হ্যালো! আমি তোমার SSC AI শিক্ষক। যেকোনো পড়া বা গণিতের সমস্যায় আমাকে প্রশ্ন করো!'}
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    final userText = _controller.text;
    setState(() {
      _messages.add({'sender': 'user', 'text': userText});
      _controller.clear();
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({
          'sender': 'ai',
          'text': 'ধন্যবাদ! "$userText" প্রশ্নের উত্তর প্রস্তুত করা হচ্ছে। কোনো নির্দিষ্ট বিষয়ের সমাধান জানতে প্রশ্নটি স্পষ্টভাবে লিখুন।'
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI শিক্ষক')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final isUser = _messages[index]['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.indigo : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _messages[index]['text']!,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'আপনার প্রশ্ন লিখুন...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.indigo),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// PDF LIBRARY SCREEN
/// ---------------------------------------------------------------------------
class PdfLibraryScreen extends StatelessWidget {
  const PdfLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> pdfs = [
      {'title': 'সকল বোর্ড প্রশ্নপত্র ২০২৬', 'size': '24.5 MB'},
      {'title': 'বাংলা ১ম ও ২য় পত্র সাজেশন', 'size': '12.3 MB'},
      {'title': 'পদার্থবিজ্ঞান চিত্র ও সূত্রাবলী', 'size': '8.4 MB'},
      {'title': 'উচ্চতর গণিত শর্টকাট টেকনিক', 'size': '5.1 MB'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('PDF নোটস ও প্রশ্ন')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pdfs.length,
        itemBuilder: (context, index) {
          final pdf = pdfs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 36),
              title: Text(pdf['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(pdf['size']!),
              trailing: IconButton(
                icon: const Icon(Icons.download, color: Colors.indigo),
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
