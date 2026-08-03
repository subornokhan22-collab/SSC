import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'subjects_screen.dart';
import 'ai_tutor_screen.dart';
import 'pdf_resource_screen.dart';

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
