import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/animations.dart';

/// Premium dark + gold design system for the A-Learning teacher portal.
class AppTheme {
  static const Color primary = Color(0xFFD4A72C); // gold
  static const Color secondary = Color(0xFF7B5A14); // antique gold
  static const Color accent = Color(0xFFFFD86B); // bright highlight
  static const Color surface = Color(0xFF12151D);
  static const Color textDark = Color(0xFFF5F0E5);
  static const Color canvas = Color(0xFF080A0F);
  static const Color card = Color(0xFF171B25);
  static const Color muted = Color(0xFF9EA7B8);
  static const Color success = Color(0xFF4ADE80);
  static const Color danger = Color(0xFFFF7B7B);

  /// Gold gradient reused by buttons, chips and headings.
  static const LinearGradient goldGradient = LinearGradient(
    colors: [accent, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Status-bar / nav-bar styling so the app looks native and finished.
  static const SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Color(0xFF080A0F),
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static ThemeData dark() {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: const Color(0xFF201806),
      secondary: accent,
      onSecondary: const Color(0xFF201806),
      surface: surface,
      onSurface: textDark,
      error: danger,
      onError: const Color(0xFF2B0B0B),
    );
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: canvas,
      splashColor: primary.withOpacity(.12),
      highlightColor: primary.withOpacity(.06),
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
            bodySmall: TextStyle(fontSize: 12.2, height: 1.5, color: muted),
            labelLarge:
                const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xCC0C0F16),
        foregroundColor: textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: overlayStyle,
        iconTheme: IconThemeData(color: accent, size: 22),
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
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFF211806),
          disabledBackgroundColor: const Color(0xFF2C323D),
          disabledForegroundColor: muted,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: primary.withOpacity(.55), width: 1.2),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: const WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          side: WidgetStatePropertyAll(
              BorderSide(color: Colors.white.withOpacity(.12))),
          foregroundColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected) ? const Color(0xFF211806) : muted),
          backgroundColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected) ? primary : Colors.transparent),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13))),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: accent),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xCC1A1F2A),
        hintStyle: const TextStyle(color: muted, fontSize: 13.5),
        labelStyle: const TextStyle(color: muted, fontSize: 13.5),
        floatingLabelStyle: const TextStyle(color: accent, fontWeight: FontWeight.w700),
        prefixIconColor: muted,
        suffixIconColor: muted,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: danger, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(Color(0xFF161B26)),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16))),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: const Color(0xFF161B26),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: accent,
        textColor: textDark,
        titleTextStyle:
            TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: textDark),
        subtitleTextStyle: TextStyle(fontSize: 12.3, color: muted, height: 1.4),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? primary : Colors.transparent),
        checkColor: const WidgetStatePropertyAll(Color(0xFF211806)),
        side: BorderSide(color: Colors.white.withOpacity(.28), width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? primary : muted),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? primary.withOpacity(.32)
                : const Color(0xFF262C38)),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: const Color(0xFF2A303C),
        thumbColor: accent,
        overlayColor: primary.withOpacity(.16),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1B202B),
        selectedColor: primary.withOpacity(.20),
        side: BorderSide(color: Colors.white.withOpacity(.10)),
        labelStyle: const TextStyle(fontSize: 12.5, color: textDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      dividerTheme: DividerThemeData(color: Colors.white.withOpacity(.08), space: 24),
      tabBarTheme: const TabBarThemeData(
        labelColor: accent,
        unselectedLabelColor: muted,
        indicatorColor: primary,
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF161B26),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(.08)),
        ),
        titleTextStyle: const TextStyle(
            fontSize: 17, fontWeight: FontWeight.w800, color: textDark),
        contentTextStyle:
            const TextStyle(fontSize: 13.5, height: 1.55, color: muted),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF141924),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF232936),
        contentTextStyle: const TextStyle(color: textDark, fontSize: 13.2),
        actionTextColor: accent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        circularTrackColor: Color(0xFF232936),
        linearTrackColor: Color(0xFF232936),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF232936),
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(fontSize: 12, color: textDark),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: primary.withOpacity(.18),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: s.contains(WidgetState.selected) ? accent : muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 23,
            color: s.contains(WidgetState.selected) ? accent : muted,
          ),
        ),
      ),
    );
  }
}
