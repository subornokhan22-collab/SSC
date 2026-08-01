import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/subjects_screen.dart';
import 'screens/ai_tutor_screen.dart';
import 'screens/pdf_resource_screen.dart';

void main() {
  runApp(const ALearningApp());
}

class ALearningApp extends StatelessWidget {
  const ALearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A-Learning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A82BB)), useMaterial3: true),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;
  final Set<int> _visitedTabs = {0};

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _visitedTabs.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onNavigate: _onTabTapped),
          _visitedTabs.contains(1) ? const SubjectsScreen() : const SizedBox.shrink(),
          _visitedTabs.contains(2) ? const PdfResourceScreen() : const SizedBox.shrink(),
          _visitedTabs.contains(3) ? const AITutorScreen() : const SizedBox.shrink(),
          const Center(child: Text('User Profile & Settings')),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A82BB),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Subjects'),
          BottomNavigationBarItem(icon: Icon(Icons.picture_as_pdf), label: 'Resources'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'AI Tutor'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
