import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
            label: 'বিষয়সমূহ',
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

class DrivePdfItem {
  final String title;
  final String category;
  final String driveFileId;
  final String fileSize;

  DrivePdfItem({
    required this.title,
    required this.category,
    required this.driveFileId,
    required this.fileSize,
  });

  String get viewUrl => 'https://drive.google.com/file/d/$driveFileId/view?usp=sharing';
  String get downloadUrl => 'https://drive.google.com/uc?export=download&id=$driveFileId';
}

/// ---------------------------------------------------------------------------
/// SUBJECTS DATA
/// ---------------------------------------------------------------------------
final List<Subject> sscSubjects = [
  Subject(
    name: 'বাংলা ১ম পত্র',
    code: '101',
    icon: Icons.menu_book,
    color: Colors.red,
    chapters: [
      'শুভা',
      'বই পড়া',
      'আম আঁটির ভেঁপু',
      'মানুষ মুহম্মদ (স.)',
      'নিমগাছ',
      'শিক্ষা ও মনুষ্যত্ব',
      'প্রবাস বন্ধু',
      'মমতাদি',
      'একাত্তরের দিনগুলি',
      'কপোতাক্ষ নদ',
      'রানার',
      'তোমাকে পাওয়ার জন্য, হে স্বাধীনতা'
    ],
  ),
  Subject(
    name: 'বাংলা ২য় পত্র',
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
      'বাগধারা'
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
      'World Heritage'
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
      'Changing Sentences',
      'Tag Questions',
      'Connectors',
      'Punctuation'
    ],
  ),
  Subject(
    name: 'সাধারণ গণিত',
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
      'বৃত্ত',
      'ত্রিকোণমিতিক অনুপাত',
      'পরিমিতি',
      'পরিসংখ্যান'
    ],
  ),
  Subject(
    name: 'উচ্চতর গণিত',
    code: '126',
    icon: Icons.functions,
    color: Colors.purple,
    chapters: [
      'সেট ও ফাংশন',
      'বীজগণিতীয় রাশি',
      'দ্বিপদী বিস্তৃতি',
      'স্থানাঙ্ক জ্যামিতি',
      'অসীম ধারা',
      'ত্রিকোণমিতি',
      'সম্ভাবনা'
    ],
  ),
  Subject(
    name: 'পদার্থবিজ্ঞান',
    code: '136',
    icon: Icons.science,
    color: Colors.deepOrange,
    chapters: [
      'ভৌত রাশি ও পরিমাপ',
      'গতি',
      'বল',
      'কাজ, ক্ষমতা ও শক্তি',
      'পদার্থের অবস্থা ও চাপ',
      'শব্দ ও তরঙ্গ',
      'আলোর প্রতিফলন',
      'স্থির বিদ্যুৎ',
      'চল বিদ্যুৎ'
    ],
  ),
  Subject(
    name: 'রসায়ন',
    code: '137',
    icon: Icons.biotech,
    color: Colors.teal,
    chapters: [
      'রসায়নের ধারণা',
      'পদার্থের অবস্থা',
      'পদার্থের গঠন',
      'পর্যায় সারণি',
      'রাসায়নিক বন্ধন',
      'মোলের ধারণা',
      'রাসায়নিক বিক্রিয়া'
    ],
  ),
  Subject(
    name: 'জীববিজ্ঞান',
    code: '138',
    icon: Icons.eco,
    color: Colors.green,
    chapters: [
      'জীবন পাঠ',
      'জীবকোষ ও টিস্যু',
      'কোষ বিভাজন',
      'জীবনীশক্তি',
      'জীব পরিবহন',
      'রেচন প্রক্রিয়া',
      'জীবের প্রজনন'
    ],
  ),
  Subject(
    name: 'ICT',
    code: '154',
    icon: Icons.computer,
    color: Colors.cyan,
    chapters: [
      'তথ্য ও যোগাযোগ প্রযুক্তি',
      'কম্পিউটার নিরাপত্তা',
      'আমার শিক্ষায় ইন্টারনেট',
      'আমার লেখালেখি ও হিসাব',
      'মাল্টিমিডিয়া ও গ্রাফিক্স'
    ],
  ),
];

/// ---------------------------------------------------------------------------
/// QUESTION BANK
/// ---------------------------------------------------------------------------
final Map<String, List<Question>> staticQuestionBank = {
  'বাংলা ১ম পত্র': [
    Question(
      questionText: '‘শুভা’ গল্পে শুভার প্রকৃত নাম কী ছিল?',
      options: ['A) সুভাষিণী', 'B) সুকেশিনী', 'C) সুহাসিনী', 'D) সুচরিতা'],
      correctAnswerIndex: 0,
      explanation: 'শুভার বড় দুই বোনের নাম সুকেশিনী ও সুহাসিনী, আর তার নাম সুভাষিণী।',
    ),
    Question(
      questionText: '‘বই পড়া’ প্রবন্ধ অনুযায়ী মানুষের সর্বশ্রেষ্ঠ শখ কোনটি হওয়া উচিত?',
      options: ['A) গান শোনা', 'B) ভ্রমণ করা', 'C) বই পড়া', 'D) খেলাধুলা করা'],
      correctAnswerIndex: 2,
      explanation: 'প্রমথ চৌধুরীর মতে, বই পড়াই মানুষের সর্বশ্রেষ্ঠ শখ হওয়া উচিত।',
    ),
  ],
  'বাংলা ২য় পত্র': [
    Question(
      questionText: '‘সন্ধি’ ব্যাকরণের কোন অংশে আলোচিত হয়?',
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
  'English 1st Paper': [
    Question(
      questionText: 'Who is known as the Father of the Nation in Bangladesh?',
      options: ['A) Kazi Nazrul Islam', 'B) Bangabandhu Sheikh Mujibur Rahman', 'C) Rabindranath Tagore', 'D) Sher-e-Bangla'],
      correctAnswerIndex: 1,
      explanation: 'Bangabandhu Sheikh Mujibur Rahman is the Father of the Nation.',
    ),
  ],
  'English 2nd Paper': [
    Question(
      questionText: 'Choose the correct article: He is ___ M.A. in English.',
      options: ['A) a', 'B) an', 'C) the', 'D) no article'],
      correctAnswerIndex: 1,
      explanation: 'Abbreviation "M.A." starts with a vowel sound /em/, so "an" is used.',
    ),
  ],
  'সাধারণ গণিত': [
    Question(
      questionText: r'যদি log_x (25) = 2 হয়, তবে x এর মান কত?',
      options: ['A) 5', 'B) 10', 'C) 25', 'D) ±5'],
      correctAnswerIndex: 0,
      explanation: r'log_x (25) = 2 => x² = 25 => x = 5 (ভিত্তি ঋণাত্মক হতে পারে না)।',
    ),
  ],
  'পদার্থবিজ্ঞান': [
    Question(
      questionText: 'স্থির অবস্থান থেকে বিনামূল্যে পড়ন্ত বস্তুর ৩ সেকেন্ডে অতিক্রান্ত দূরত্ব কত?',
      options: ['A) 14.7 m', 'B) 29.4 m', 'C) 44.1 m', 'D) 88.2 m'],
      correctAnswerIndex: 2,
      explanation: r'h = (1/2) × g × t² = 0.5 × 9.8 × 9 = 44.1 মিটার।',
    ),
  ],
};

List<Question> generateDynamicMcqs(String subjectName, String? chapterName, int count) {
  List<Question> questions = [];
  if (staticQuestionBank.containsKey(subjectName)) {
    questions.addAll(staticQuestionBank[subjectName]!);
  }

  int id = questions.length + 1;
  while (questions.length < count) {
    String chapterTag = chapterName != null ? '[$chapterName]' : '';
    questions.add(
      Question(
        questionText: '$chapterTag $subjectName বিষয়ভিত্তিক গুরুত্বপূর্ণ নমুনা প্রশ্ন #$id',
        options: [
          'A) সঠিক উত্তর বিকল্প A',
          'B) বিকল্প উত্তর B',
          'C) বিকল্প উত্তর C',
          'D) বিকল্প উত্তর D'
        ],
        correctAnswerIndex: 0,
        explanation: '$subjectName বিষয়ের $chapterName অধ্যায়ের সংজ্ঞামূলত ও এনসিটিবি কারিকুলাম ভিত্তিক প্রশ্ন।',
      ),
    );
    id++;
  }
  return questions;
}

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
                        Text('সকল বিষয়ের অধ্যায়ভিত্তিক MCQ, লাইভ পরীক্ষা ও গুগল ড্রাইভ নোটস।', style: TextStyle(color: Colors.white70, fontSize: 13)),
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
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveMcqExamScreen(subjectName: 'সাধারণ গণিত')));
                }),
                _buildQuickCard(context, 'সকল বিষয়', Icons.menu_book, Colors.indigo, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AllSubjectsScreen()));
                }),
                _buildQuickCard(context, 'AI শিক্ষক', Icons.smart_toy, Colors.purple, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AiTutorScreen()));
                }),
                _buildQuickCard(context, 'Drive PDF', Icons.picture_as_pdf, Colors.orange, () {
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
/// ALL SUBJECTS SCREEN
/// ---------------------------------------------------------------------------
class AllSubjectsScreen extends StatelessWidget {
  const AllSubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('বিষয় তালিকা (SSC Subjects)')),
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
          final chapterName = subject.chapters[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: subject.color.withOpacity(0.15),
                child: Text('${index + 1}', style: TextStyle(color: subject.color, fontWeight: FontWeight.bold)),
              ),
              title: Text(chapterName, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('অধ্যায়ভিত্তিক MCQ প্র্যাকটিস পরীক্ষা'),
              trailing: const Icon(Icons.play_circle_fill, color: Colors.indigo),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LiveMcqExamScreen(
                      subjectName: subject.name,
                      chapterName: chapterName,
                    ),
                  ),
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
                  const Text('সময়: ১৫ মিনিট | প্রশ্নভিত্তিক অটোমেটিক রেজাল্ট'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveMcqExamScreen(subjectName: 'সাধারণ গণিত')));
                    },
                    child: const Text('পরীক্ষা শুরু করুন'),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('বিষয়ভিত্তিক পরীক্ষা', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...sscSubjects.map((subject) => Card(
            child: ListTile(
              leading: Icon(subject.icon, color: subject.color),
              title: Text(subject.name),
              subtitle: Text('${subject.chapters.length} টি অধ্যায় পরীক্ষা'),
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
/// DYNAMIC INTERACTIVE EXAM ENGINE
/// ---------------------------------------------------------------------------
class LiveMcqExamScreen extends StatefulWidget {
  final String subjectName;
  final String? chapterName;

  const LiveMcqExamScreen({
    super.key,
    required this.subjectName,
    this.chapterName,
  });

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
    _questions = generateDynamicMcqs(widget.subjectName, widget.chapterName, 10);
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
        title: Text(widget.chapterName != null ? '${widget.subjectName} (${widget.chapterName})' : widget.subjectName),
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
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
/// SMART RESPONSIVE AI TUTOR SCREEN
/// ---------------------------------------------------------------------------
class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'sender': 'ai', 'text': 'হ্যালো! আমি তোমার SSC AI শিক্ষক। যেকোনো পড়া বা গাণিতিক সমস্যায় আমাকে প্রশ্ন করো!'}
  ];

  String _processAiResponse(String query) {
    String cleanQuery = query.trim().replaceAll(' ', '');

    try {
      if (cleanQuery.contains('+')) {
        var parts = cleanQuery.split('+');
        double res = double.parse(parts[0]) + double.parse(parts[1]);
        return 'গাণিতিক হিসাবের ফলাফল: ${parts[0]} + ${parts[1]} = ${res % 1 == 0 ? res.toInt() : res}';
      } else if (cleanQuery.contains('-')) {
        var parts = cleanQuery.split('-');
        double res = double.parse(parts[0]) - double.parse(parts[1]);
        return 'গাণিতিক হিসাবের ফলাফল: ${parts[0]} - ${parts[1]} = ${res % 1 == 0 ? res.toInt() : res}';
      } else if (cleanQuery.contains('*') || cleanQuery.toLowerCase().contains('x')) {
        var parts = cleanQuery.contains('*') ? cleanQuery.split('*') : cleanQuery.toLowerCase().split('x');
        double res = double.parse(parts[0]) * double.parse(parts[1]);
        return 'গাণিতিক হিসাবের ফলাফল: ${parts[0]} × ${parts[1]} = ${res % 1 == 0 ? res.toInt() : res}';
      } else if (cleanQuery.contains('/') || cleanQuery.contains('\\')) {
        var parts = cleanQuery.contains('/') ? cleanQuery.split('/') : cleanQuery.split('\\');
        double res = double.parse(parts[0]) / double.parse(parts[1]);
        return 'গাণিতিক হিসাবের সমাধান:\n${parts[0]} ÷ ${parts[1]} = ${res % 1 == 0 ? res.toInt() : res}';
      }
    } catch (_) {}

    String qLower = query.toLowerCase();
    if (qLower.contains('শুভা') || qLower.contains('subha')) {
      return '‘শুভা’ রবীন্দ্রনাথ ঠাকুরের একটি বিখ্যাত ছোটগল্প। গল্পের প্রধান চরিত্র একটি বাকপ্রতিবন্ধী মেয়ে যার নাম সুভাষিণী।';
    } else if (qLower.contains('সন্ধি') || qLower.contains('sondhi')) {
      return 'সন্ধি হলো পাশাপাশি দুটি ধ্বনির মিলন। যেমন: বিদ্যা + আলয় = বিদ্যালয়। এটি ধ্বনিতত্ত্বে আলোচিত হয়।';
    } else if (qLower.contains('গতি') || qLower.contains('v=u+at')) {
      return 'গতির ১ম সমীকরণ: v = u + at\nএখানে v = শেষ বেগ, u = আদি বেগ, a = ত্বরণ, t = সময়।';
    } else if (qLower.contains('নিউটনের') || qLower.contains('newton')) {
      return 'নিউটনের ২য় সূত্র: বস্তুর ভরবেগের পরিবর্তনের হার তার ওপর প্রযুক্ত বলের সমানুপাতিক। (F = ma)';
    }

    return 'তোমার প্রশ্নটি পেয়েছি: "$query"\n\nএটি SSC কারিকুলামের অন্তর্ভুক্ত একটি বিষয়। আরও সঠিক ফলাফলের জন্য প্রশ্নটি স্পষ্ট করে লিখুন বা কোনো বিশেষ গাণিতিক সমস্যা হলে সমীকরণ আকারে দিন।';
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    final userText = _controller.text;
    setState(() {
      _messages.add({'sender': 'user', 'text': userText});
      _controller.clear();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _messages.add({
          'sender': 'ai',
          'text': _processAiResponse(userText)
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
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'আপনার প্রশ্ন লিখুন (যেমন: 10/5=)...',
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
/// GOOGLE DRIVE INTEGRATED PDF LIBRARY SCREEN (OPTION B)
/// ---------------------------------------------------------------------------
class PdfLibraryScreen extends StatefulWidget {
  const PdfLibraryScreen({super.key});

  @override
  State<PdfLibraryScreen> createState() => _PdfLibraryScreenState();
}

class _PdfLibraryScreenState extends State<PdfLibraryScreen> {
  String _selectedCategory = 'সব';
  final String _driveFolderUrl = 'https://drive.google.com/drive/folders/19UW5mGKcBgorLSmO-joBer0HBodGA65G';

  /// 📌 Google Drive File Database mapped to your Drive folder.
  /// Replace 'YOUR_DRIVE_FILE_ID_X' with individual File IDs from inside your Google Drive folder.
  final List<DrivePdfItem> _pdfList = [
    DrivePdfItem(
      title: 'বাংলা ১ম পত্র সংক্ষিপ্ত নোট ও সাজেশন',
      category: 'বাংলা',
      driveFileId: 'YOUR_DRIVE_FILE_ID_1',
      fileSize: '4.2 MB',
    ),
    DrivePdfItem(
      title: 'পদার্থবিজ্ঞান সকল অধ্যায়ের সূত্র ও গাণিতিক সমাধান',
      category: 'পদার্থবিজ্ঞান',
      driveFileId: 'YOUR_DRIVE_FILE_ID_2',
      fileSize: '6.8 MB',
    ),
    DrivePdfItem(
      title: 'সাধারণ গণিত শর্টকাট টেকনিক ও বোর্ড প্রশ্ন',
      category: 'গণিত',
      driveFileId: 'YOUR_DRIVE_FILE_ID_3',
      fileSize: '12.1 MB',
    ),
    DrivePdfItem(
      title: 'English 2nd Paper Grammar Rules & CV Format',
      category: 'English',
      driveFileId: 'YOUR_DRIVE_FILE_ID_4',
      fileSize: '3.5 MB',
    ),
  ];

  Future<void> _openUrl(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('লিংকটি খোলা সম্ভব হয়নি! Check your internet connection.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['সব', 'বাংলা', 'গণিত', 'পদার্থবিজ্ঞান', 'English'];

    final filteredList = _selectedCategory == 'সব'
        ? _pdfList
        : _pdfList.where((pdf) => pdf.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Drive PDF লাইব্রেরি'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Drive Folder Launcher Banner
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.folder_shared, color: Colors.white, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('অফিসিয়াল গুগল ড্রাইভ ফোল্ডার', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 2),
                      Text('সকল ফাইল একসাথে ড্রাইভে দেখতে নিচের বাটনে চাপ দিন।', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue.shade900),
                  onPressed: () => _openUrl(_driveFolderUrl),
                  child: const Text('খুলুন'),
                )
              ],
            ),
          ),

          // Subject Category Filters
          Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: Colors.indigo,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),

          // File List View
          Expanded(
            child: filteredList.isEmpty
                ? const Center(child: Text('এই বিভাগে কোনো PDF পাওয়া যায়নি'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final pdf = filteredList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.picture_as_pdf, color: Colors.red, size: 36),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pdf.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'বিভাগ: ${pdf.category}  •  সাইজ: ${pdf.fileSize}',
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.indigo,
                                      side: const BorderSide(color: Colors.indigo),
                                    ),
                                    icon: const Icon(Icons.remove_red_eye, size: 18),
                                    label: const Text('পড়ুন (View)'),
                                    onPressed: () => _openUrl(pdf.viewUrl),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigo,
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(Icons.download, size: 18),
                                    label: const Text('ডাউনলোড'),
                                    onPressed: () => _openUrl(pdf.downloadUrl),
                                  ),
                                ],
                              )
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
}
