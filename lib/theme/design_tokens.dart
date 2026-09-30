import 'package:flutter/material.dart';

/// Tutor's Desk — a richer classroom palette.
///
/// Deep navy anchors the workspace, indigo gives the product its identity,
/// cyan keeps actions energetic, and coral adds a warm human touch. Long-form
/// content remains on white cards for comfortable reading. OMR keeps its
/// exact pink pair because the printed-sheet workflow depends on it.
abstract final class AppColors {
  static const onColor = Colors.white;

  // Brand: midnight navy, electric indigo, cyan and a warm coral spark.
  static const primary = Color(0xFF5B4BDB);
  static const primaryDark = Color(0xFF312E81);
  static const secondary = Color(0xFF0EA5E9);
  static const accent = Color(0xFFF97360);
  static const gradientEnd = Color(0xFF14B8A6);
  static const light = Color(0xFFB9B2FF);

  // Calm reading surfaces with enough contrast against the saturated brand.
  static const canvas = Color(0xFFF6F7FC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFEEF1FF);
  static const heroSurface = Color(0xFFEAE8FF);
  static const warmSurface = Color(0xFFFFF1E8);
  static const cyanSurface = Color(0xFFE3F8FC);
  static const border = Color(0xFFD9E1F0);
  static const text = Color(0xFF17213C);
  static const muted = Color(0xFF65718C);
  static const disabled = Color(0xFFB8C3D8);
  static const progressTrack = Color(0xFFDDE6F5);
  static const appBar = Color(0xFF172554);

  // OMR uses the requested pink pair exactly; never replace these with blue.
  static const omr = Color(0xFFEB3897);
  static const omrSoft = Color(0xFFFCDEEE);

  // Feature colors make the home dashboard easier to scan at a glance.
  static const ai = Color(0xFF7C3AED);
  static const writing = Color(0xFFF97360);
  static const science = Color(0xFF0891B2);

  // Real status semantics are more useful than painting every state blue.
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFE5484D);

  // Preserve this order: the workspace preset index is saved on the device.
  // Presets intentionally share one visible base palette; the picker remains
  // hidden while the saved indices stay compatible with existing devices.
  static const workspaceBackgrounds = <Color>[
    canvas,
    canvas,
    canvas,
    canvas,
    canvas,
    canvas,
    canvas,
    canvas,
  ];
  static const workspaceAccents = <Color>[
    primary,
    primary,
    primary,
    primary,
    primary,
    primary,
    primary,
    primary,
  ];
}

abstract final class AppTypography {
  static const uiFont = 'Hind Siliguri';
  static const paperFont = 'Noto Serif Bengali';

  static const titleLarge = TextStyle(
    fontFamily: uiFont,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: .2,
    color: AppColors.text,
  );
  static const titleMedium = TextStyle(
    fontFamily: uiFont,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: .1,
    color: AppColors.text,
  );
  static const body = TextStyle(
    fontFamily: uiFont,
    fontSize: 13.5,
    height: 1.5,
    color: AppColors.text,
  );
  static const caption = TextStyle(
    fontFamily: uiFont,
    fontSize: 12.2,
    height: 1.5,
    color: AppColors.muted,
  );
  static const label = TextStyle(
    fontFamily: uiFont,
    fontSize: 14.5,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
  );
  static const button = TextStyle(
    fontFamily: uiFont,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );
  static const appBarTitle = TextStyle(
    fontFamily: uiFont,
    fontSize: 18.5,
    fontWeight: FontWeight.w800,
    letterSpacing: .2,
    color: AppColors.onColor,
  );
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const section = 32.0;

  static const buttonPadding = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: 15,
  );
  static const inputPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: 14,
  );
}

abstract final class AppRadii {
  static const tooltip = 10.0;
  static const compact = 12.0;
  static const segment = 13.0;
  static const control = 14.0;
  static const action = 15.0;
  static const card = 20.0;
  static const dialog = 24.0;
  static const sheet = 26.0;
}
