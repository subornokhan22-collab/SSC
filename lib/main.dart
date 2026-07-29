import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const ALearningApp());
}

class ALearningApp extends StatelessWidget {
  const ALearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'A-Learning',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// ==========================================
// 1. MAIN NAVIGATION SCREEN (Bottom Nav Bar)
// ==========================================
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MCQScreen(),
    PDFResourceScreen(),
    AITutorScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz),
            label: 'MCQs',
          ),
          NavigationDestination(
            icon: Icon(Icons.picture_as_pdf_outlined),
            selectedIcon: Icon(Icons.picture_as_pdf),
            label: 'PDF Resources',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology),
            label: 'AI Tutor',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. HOME SCREEN DASHBOARD
// ==========================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('A-Learning'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Prepare for your SSC exams with organized MCQs, study notes, and AI assistance.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildDashboardCard(
                    context,
                    title: 'MCQ Practice',
                    icon: Icons.quiz,
                    color: Colors.blue,
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'PDF Library',
                    icon: Icons.picture_as_pdf,
                    color: Colors.red,
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'AI Tutor',
                    icon: Icons.psychology,
                    color: Colors.purple,
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Analytics',
                    icon: Icons.bar_chart,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                radius: 28,
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. MCQ PRACTICE SCREEN
// ==========================================
class Question {
  final int id;
  final String subject;
  final String chapter;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;

  Question({
    required this.id,
    required this.subject,
    required this.chapter,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });
}

class MCQScreen extends StatefulWidget {
  const MCQScreen({super.key});

  @override
  State<MCQScreen> createState() => _MCQScreenState();
}

class _MCQScreenState extends State<MCQScreen> {
  final List<Question> _rawQuestions = [
    Question(
      id: 3,
      subject: 'Physics',
      chapter: 'Motion',
      questionText: 'What is the SI unit of velocity?',
      options: ['m/s²', 'm/s', 'kg', 'N'],
      correctOptionIndex: 1,
    ),
    Question(
      id: 1,
      subject: 'Physics',
      chapter: 'Motion',
      questionText: 'Which of the following is a vector quantity?',
      options: ['Speed', 'Distance', 'Displacement', 'Mass'],
      correctOptionIndex: 2,
    ),
    Question(
      id: 2,
      subject: 'Physics',
      chapter: 'Motion',
      questionText: 'What is the acceleration due to gravity on Earth?',
      options: ['9.8 m/s²', '10.5 m/s²', '8.9 m/s²', '9.8 cm/s²'],
      correctOptionIndex: 0,
    ),
  ];

  late List<Question> organizedQuestions;
  int? selectedOption;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    organizedQuestions = List.from(_rawQuestions);
    organizedQuestions.sort((a, b) => a.id.compareTo(b.id));
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = organizedQuestions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${currentIndex + 1} of ${organizedQuestions.length}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text('${currentQ.subject} • ${currentQ.chapter}'),
                backgroundColor: Colors.blue.shade50,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Q${currentQ.id}. ${currentQ.questionText}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...List.generate(currentQ.options.length, (index) {
              final isSelected = selectedOption == index;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected ? Colors.blue.shade50 : Colors.white,
                ),
                child: ListTile(
                  title: Text(currentQ.options[index]),
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: isSelected ? Colors.blue : Colors.grey.shade200,
                    child: Text(
                      String.fromCharCode(65 + index),
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selectedOption = index;
                    });
                  },
                ),
              );
            }),
            const Spacer(),
            ElevatedButton(
              onPressed: selectedOption == null
                  ? null
                  : () {
                      if (currentIndex < organizedQuestions.length - 1) {
                        setState(() {
                          currentIndex++;
                          selectedOption = null;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Quiz Completed!')),
                        );
                      }
                    },
              child: Text(
                currentIndex == organizedQuestions.length - 1 ? 'Finish' : 'Next Question',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. PDF RESOURCE SCREEN
// ==========================================
class PDFResourceScreen extends StatelessWidget {
  const PDFResourceScreen({super.key});

  final String googleDriveFolderUrl =
      'https://drive.google.com/drive/folders/19UW5mGKcBgorLSmO-joBer0HBodGA65G';

  Future<void> _openDriveFolder() async {
    final Uri url = Uri.parse(googleDriveFolderUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Resources'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.folder, color: Colors.amber, size: 40),
                title: const Text('SSC Master Notes Drive'),
                subtitle: const Text('Access external chapter PDFs, suggestions, and sheets.'),
                trailing: const Icon(Icons.open_in_new),
                onTap: _openDriveFolder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. AI TUTOR SCREEN
// ==========================================
class AITutorScreen extends StatelessWidget {
  const AITutorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Study Assistant'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.psychology, size: 80, color: Colors.purple),
            SizedBox(height: 16),
            Text(
              'AI Tutor Integration',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Ask physics formulas, math shortcuts, or conceptual questions.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
