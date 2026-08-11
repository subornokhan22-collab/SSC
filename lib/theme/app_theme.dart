import 'package:flutter/material.dart';
import '../widgets/animations.dart';

/// Premium dark + gold system used consistently across the app.
class AppTheme {
  static const Color primary = Color(0xFFD4A72C); // gold
  static const Color secondary = Color(0xFF7B5A14); // antique gold
  static const Color accent = Color(0xFFFFD86B); // bright highlight
  static const Color surface = Color(0xFF12151D);
  static const Color textDark = Color(0xFFF5F0E5);
  static const Color canvas = Color(0xFF080A0F);
  static const Color card = Color(0xFF171B25);
  static const Color muted = Color(0xFF9EA7B8);

  static ThemeData light() {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: const Color(0xFF201806),
      secondary: accent,
      surface: surface,
      onSurface: textDark,
      error: const Color(0xFFFF7B7B),
    );
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: canvas,
      splashColor: primary.withOpacity(.14),
      highlightColor: primary.withOpacity(.08),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: SmoothPageTransitionsBuilder(),
        TargetPlatform.iOS: SmoothPageTransitionsBuilder(),
        TargetPlatform.linux: SmoothPageTransitionsBuilder(),
        TargetPlatform.macOS: SmoothPageTransitionsBuilder(),
        TargetPlatform.windows: SmoothPageTransitionsBuilder(),
      }),
      textTheme: base.textTheme.apply(
        bodyColor: textDark,
        displayColor: textDark,
        fontFamily: 'Hind Siliguri',
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xEE10131B),
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: card,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(.35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(.07)),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFF211806),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: primary.withOpacity(.65), width: 1.2),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1B202B),
        hintStyle: const TextStyle(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: DividerThemeData(color: Colors.white.withOpacity(.09)),
      tabBarTheme: const TabBarThemeData(
        labelColor: accent,
        unselectedLabelColor: muted,
        indicatorColor: primary,
        labelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF242B38),
        contentTextStyle: const TextStyle(color: textDark),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: Color(0xFF2A303C),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF10131B),
        selectedItemColor: accent,
        unselectedItemColor: muted,
        elevation: 16,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
