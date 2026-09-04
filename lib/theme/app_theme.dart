import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/animations.dart';

/// Light "Indigo & Teal" design system for Tutor's Desk.
///
/// The palette is built for long reading sessions and for screens that sit
/// next to printed paper: a soft paper-white canvas, deep indigo as the
/// primary brand colour and a teal accent for confirmation states.
class AppTheme {
  // ── Brand ────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF3D5AFE); // indigo
  static const Color primaryDark = Color(0xFF2A3EB1);
  static const Color secondary = Color(0xFF00897B); // teal
  static const Color accent = Color(0xFF00B8A9); // bright teal highlight

  // ── Surfaces ─────────────────────────────────────────────────────
  static const Color canvas = Color(0xFFF4F6FB); // page background
  static const Color surface = Color(0xFFFFFFFF); // cards / sheets
  static const Color card = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFEDF1F9); // subtle fills
  static const Color border = Color(0xFFDDE3EF);

  // ── Text ─────────────────────────────────────────────────────────
  static const Color textDark = Color(0xFF16203A); // primary text
  static const Color muted = Color(0xFF66739A); // secondary text

  // ── Status ───────────────────────────────────────────────────────
  static const Color success = Color(0xFF12A150);
  static const Color warning = Color(0xFFE08700);
  static const Color danger = Color(0xFFE5484D);

  /// Brand gradient reused by buttons, chips and headings.
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, Color(0xFF6B7BFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Status-bar / nav-bar styling for a light UI.
  static const SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: canvas,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static ThemeData light() {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: textDark,
      error: danger,
      onError: Colors.white,
    );
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: canvas,
      splashColor: primary.withOpacity(.08),
      highlightColor: primary.withOpacity(.04),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: SmoothPageTransitionsBuilder(),
        TargetPlatform.iOS: SmoothPageTransitionsBuilder(),
        TargetPlatform.linux: SmoothPageTransitionsBuilder(),
        TargetPlatform.macOS: SmoothPageTransitionsBuilder(),
        TargetPlatform.windows: SmoothPageTransitionsBuilder(),
      }),
      textTheme: base.textTheme
          .apply(
            bodyColor: textDark,
            displayColor: textDark,
            fontFamily: 'Hind Siliguri',
          )
          .copyWith(
            titleLarge: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: .2),
            titleMedium: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: .1),
            bodyMedium: const TextStyle(fontSize: 13.5, height: 1.5),
            bodySmall: const TextStyle(fontSize: 12.2, height: 1.5, color: muted),
            labelLarge:
                const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xF2FFFFFF),
        foregroundColor: textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: overlayStyle,
        iconTheme: IconThemeData(color: primary, size: 22),
        titleTextStyle: TextStyle(
          fontSize: 18.5,
          fontWeight: FontWeight.w800,
          color: textDark,
          fontFamily: 'Hind Siliguri',
          letterSpacing: .2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: card,
        surfaceTintColor: Colors.transparent,
        shadowColor: primary.withOpacity(.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFC9D0E2),
          disabledForegroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withOpacity(.42), width: 1.2),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: const WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          side: const WidgetStatePropertyAll(BorderSide(color: border)),
          foregroundColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected) ? Colors.white : muted),
          backgroundColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected) ? primary : Colors.white),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13))),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        hintStyle: const TextStyle(color: muted, fontSize: 13.5),
        labelStyle: const TextStyle(color: muted, fontSize: 13.5),
        floatingLabelStyle:
            const TextStyle(color: primary, fontWeight: FontWeight.w700),
        prefixIconColor: muted,
        suffixIconColor: muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: danger, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: danger, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16))),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: primary,
        textColor: textDark,
        titleTextStyle: TextStyle(
            fontSize: 14.5, fontWeight: FontWeight.w700, color: textDark),
        subtitleTextStyle: TextStyle(fontSize: 12.3, color: muted, height: 1.4),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? primary : Colors.white),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: const BorderSide(color: Color(0xFFB8C1D9), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primary : const Color(0xFFAEB7CC)),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? primary.withOpacity(.28)
                : const Color(0xFFE1E6F0)),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: const Color(0xFFDDE3EF),
        thumbColor: primary,
        overlayColor: primary.withOpacity(.12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceAlt,
        selectedColor: primary.withOpacity(.14),
        side: const BorderSide(color: border),
        labelStyle: const TextStyle(fontSize: 12.5, color: textDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      dividerTheme: const DividerThemeData(color: border, space: 24),
      tabBarTheme: const TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: muted,
        indicatorColor: primary,
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: border),
        ),
        titleTextStyle: const TextStyle(
            fontSize: 17, fontWeight: FontWeight.w800, color: textDark),
        contentTextStyle:
            const TextStyle(fontSize: 13.5, height: 1.55, color: muted),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textDark,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13.2),
        actionTextColor: accent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        circularTrackColor: Color(0xFFE1E6F0),
        linearTrackColor: Color(0xFFE1E6F0),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: textDark,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withOpacity(.12),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: s.contains(WidgetState.selected) ? primary : muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 23,
            color: s.contains(WidgetState.selected) ? primary : muted,
          ),
        ),
      ),
    );
  }
}
