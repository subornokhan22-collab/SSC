// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/subjects_screen.dart';
import 'screens/exam_screen.dart';
import 'screens/ai_tutor_screen.dart';
import 'screens/pdf_resource_screen.dart';

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
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3B4CE0),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F8FA),
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// ==========================================
// MAIN NAVIGATION (5-tab bottom bar)
// ==========================================
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final Set<int> _visitedTabs = {0};

  void _goToTab(int index) {
    setState(() {
      _visitedTabs.add(index);
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Only build a tab's screen once it has actually been visited. This
    // matters most for the PDF tab: building its WebView while off-screen
    // (as a plain IndexedStack would do for every tab immediately) is what
    // triggers Android's net::ERR_CACHE_MISS WebView bug.
    final screens = [
      HomeScreen(onNavigate: _goToTab),
      _visitedTabs.contains(1) ? const SubjectsScreen() : const SizedBox.shrink(),
      _visitedTabs.contains(2) ? const ExamScreen() : const SizedBox.shrink(),
      _visitedTabs.contains(3) ? const AITutorScreen() : const SizedBox.shrink(),
      _visitedTabs.contains(4) ? const PDFResourceScreen() : const SizedBox.shrink(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _goToTab,
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
