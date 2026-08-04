import 'package:flutter/material.dart';
import '../widgets/animations.dart';

class AppTheme {
  static const Color primary = Color(0xFF0D4782);
  static const Color secondary = Color(0xFF10828C);
  static const Color accent = Color(0xFFFFC107);
  static const Color surface = Color(0xFFF7F9FC);
  static const Color textDark = Color(0xFF1A2634);

  static ThemeData light() {
    final base = ThemeData(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        surface: surface,
      ),
      // Transparent so the global AnimatedBackground (painted once, behind
      // every route via MaterialApp.builder) shows through every screen.
      scaffoldBackgroundColor: Colors.transparent,
      // Solid canvas so DropdownButton menus (which default to the theme's
      // canvasColor) and Drawers get a readable background.
      canvasColor: Colors.white,
      // Smooth slide+fade transition for EVERY Navigator.push app-wide.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SmoothPageTransitionsBuilder(),
          TargetPlatform.iOS: SmoothPageTransitionsBuilder(),
          TargetPlatform.linux: SmoothPageTransitionsBuilder(),
          TargetPlatform.macOS: SmoothPageTransitionsBuilder(),
          TargetPlatform.windows: SmoothPageTransitionsBuilder(),
        },
      ),
      textTheme: base.textTheme.apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 1.5,
        shadowColor: Colors.black.withOpacity(0.08),
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.6),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: Colors.grey,
        labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle:
            TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: Color(0xFFE3E9F0),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
