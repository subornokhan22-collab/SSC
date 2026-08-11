import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'subjects_screen.dart';
import 'ai_tutor_screen.dart';
import 'pdf_resource_screen.dart';
import 'profile_screen.dart';

/// Keeps each tab alive while giving the main app a premium, compact navigation bar.
class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});
  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;
  final Set<int> _visitedTabs = {0};
  void _go(int index) => setState(() { _currentIndex = index; _visitedTabs.add(index); });

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onNavigate: _go),
      _visitedTabs.contains(1) ? const SubjectsScreen() : const SizedBox.shrink(),
      _visitedTabs.contains(2) ? const PdfResourceScreen() : const SizedBox.shrink(),
      _visitedTabs.contains(3) ? const AITutorScreen() : const SizedBox.shrink(),
      _visitedTabs.contains(4) ? const ProfileScreen() : const SizedBox.shrink(),
    ];
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          decoration: BoxDecoration(
            color: const Color(0xF0141822),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(.08)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.35), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: NavigationBar(
            height: 66,
            elevation: 0,
            backgroundColor: Colors.transparent,
            indicatorColor: AppTheme.primary.withOpacity(.18),
            selectedIndex: _currentIndex,
            onDestinationSelected: _go,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book_rounded), label: 'Subjects'),
              NavigationDestination(icon: Icon(Icons.folder_copy_outlined), selectedIcon: Icon(Icons.folder_copy_rounded), label: 'Resources'),
              NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome_rounded), label: 'AI Tutor'),
              NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
