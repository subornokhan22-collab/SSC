import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/animations.dart';
import 'design_tokens.dart';

/// Tutor's Desk rich classroom system. Navy anchors the chrome, saturated
/// accents identify actions, and white cards keep long reading sessions clear.
class AppTheme {
  // ── Brand ────────────────────────────────────────────────────────
  static const Color onColor = AppColors.onColor;
  static const Color primary = AppColors.primary; // indigo
  static const Color primaryDark = AppColors.primaryDark;
  static const Color secondary = AppColors.secondary; // cyan
  static const Color accent = AppColors.accent; // coral highlight

  // ── Surfaces ─────────────────────────────────────────────────────
  static const Color canvas = AppColors.canvas; // page background
  static const Color surface = AppColors.surface; // cards / sheets
  static const Color card = AppColors.surface;
  static const Color surfaceAlt = AppColors.surfaceAlt; // subtle fills
  static const Color border = AppColors.border;

  // ── Text ─────────────────────────────────────────────────────────
  static const Color textDark = AppColors.text; // primary text
  static const Color muted = AppColors.muted; // secondary text

  // ── Status ───────────────────────────────────────────────────────
  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;
  static const Color danger = AppColors.danger;

  /// Brand gradient reused by buttons, chips and headings.
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, secondary, AppColors.gradientEnd],
    stops: [0, .56, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Navy status-bar / nav-bar styling with white system icons.
  static const SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
    statusBarColor: surface,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: surface,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static ThemeData light() {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onColor,
      secondary: secondary,
      onSecondary: onColor,
      surface: surface,
      onSurface: textDark,
      error: danger,
      onError: onColor,
    );
    return base.copyWith(
      colorScheme: scheme,
      // Transparent so AliveBackground paints the chosen workspace paper;
      // an opaque scaffold would hide it and waste the accent washes.
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: canvas,
      splashColor: primary.withOpacity(.08),
      highlightColor: primary.withOpacity(.04),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SmoothPageTransitionsBuilder(),
          TargetPlatform.iOS: SmoothPageTransitionsBuilder(),
          TargetPlatform.linux: SmoothPageTransitionsBuilder(),
          TargetPlatform.macOS: SmoothPageTransitionsBuilder(),
          TargetPlatform.windows: SmoothPageTransitionsBuilder(),
        },
      ),
      textTheme: base.textTheme
          .apply(
            bodyColor: textDark,
            displayColor: textDark,
            fontFamily: AppTypography.uiFont,
          )
          // These replace the styles `.apply` just coloured, so each one has
          // to name its colour again. Without it `titleMedium` (dropdown menu
          // items) and `bodyMedium` fell back to a default that rendered
          // near-white, making subject and chapter names unreadable against
          // the light menu.
          .copyWith(
            titleLarge: AppTypography.titleLarge,
            titleMedium: AppTypography.titleMedium,
            bodyMedium: AppTypography.body,
            bodySmall: AppTypography.caption,
            labelLarge: AppTypography.label,
          ),
      iconTheme: const IconThemeData(color: Colors.black, size: 22),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.appBar,
        foregroundColor: textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: overlayStyle,
        iconTheme: IconThemeData(color: textDark, size: 22),
        titleTextStyle: AppTypography.appBarTitle,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: card,
        surfaceTintColor: Colors.transparent,
        shadowColor: primary.withOpacity(.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: const BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: AppSpacing.buttonPadding,
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: onColor,
          padding: AppSpacing.buttonPadding,
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.black,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.compact),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.black, width: 1.2),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.control),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          side: const WidgetStatePropertyAll(BorderSide(color: border)),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? Colors.white : muted,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? primary : Colors.white,
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.segment),
            ),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(color: muted, fontSize: 13.5),
        labelStyle: const TextStyle(color: muted, fontSize: 13.5),
        floatingLabelStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
        prefixIconColor: Colors.black54,
        suffixIconColor: Colors.black54,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: const BorderSide(color: primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: const BorderSide(color: danger, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
          borderSide: const BorderSide(color: danger, width: 1.6),
        ),
        contentPadding: AppSpacing.inputPadding,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        // Pin the item colour too — menu entries are drawn outside the normal
        // page, so they must not rely on inheriting it.
        textStyle: const TextStyle(color: textDark, fontSize: 15),
        menuStyle: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
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
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        subtitleTextStyle: TextStyle(fontSize: 12.3, color: muted, height: 1.4),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : Colors.white,
        ),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: const BorderSide(color: Color(0xFFB8C1D9), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? primary
              : const Color(0xFFAEB7CC),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? primary.withOpacity(.28)
              : AppColors.progressTrack,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: AppColors.border,
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
        labelColor: Colors.black,
        unselectedLabelColor: muted,
        indicatorColor: Colors.black,
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.dialog),
          side: const BorderSide(color: border),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: textDark,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 13.5,
          height: 1.55,
          color: muted,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.sheet),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textDark,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13.2),
        actionTextColor: accent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.control),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        circularTrackColor: AppColors.progressTrack,
        linearTrackColor: AppColors.progressTrack,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: textDark,
          borderRadius: BorderRadius.circular(AppRadii.tooltip),
        ),
        textStyle: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: Colors.black,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            size: 23,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
