import 'package:flutter/material.dart';

/// Tutor's Desk — a richer classroom palette.
///
/// Neutral grey controls and borders keep every screen on a solid white page.
/// Long-form content remains on white cards for comfortable reading. The
/// printed OMR template retains its separate drop-out signature for scanning.
abstract final class AppColors {
  static const onColor = Colors.white;

  // Neutral grey brand scale for all app controls and accents.
  static const primary = Color(0xFF5A5A5A);
  static const primaryDark = Color(0xFF303030);
  static const secondary = Color(0xFF777777);
  static const accent = Color(0xFF666666);
  static const gradientEnd = Color(0xFF909090);
  static const light = Color(0xFFD9D9D9);

  // Calm reading surfaces with enough contrast against the saturated brand.
  static const canvas = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF2F2F2);
  static const heroSurface = Color(0xFFFFFFFF);
  static const warmSurface = Color(0xFFF2F2F2);
  static const cyanSurface = Color(0xFFF2F2F2);
  static const border = Color(0xFFD6D6D6);
  static const text = Color(0xFF111111);
  static const muted = Color(0xFF666666);
  static const disabled = Color(0xFFBDBDBD);
  static const progressTrack = Color(0xFFE0E0E0);
  static const appBar = Color(0xFFFFFFFF);

  // OMR screen controls are neutral black and grey, not pink.
  static const omr = Color(0xFF000000);
  static const omrSoft = Color(0xFFE5E5E5);

  // Keep the printed template's drop-out signature separate from the screen
  // palette; the scanner uses this pink hue to distinguish template ink from
  // a student's neutral pen marks.
  static const omrTemplateInk = Color(0xFFEB3897);
  static const omrTemplateSoft = Color(0xFFFCDEEE);

  // Feature colors make the home dashboard easier to scan at a glance.
  static const ai = Color(0xFF555555);
  static const writing = Color(0xFF707070);
  static const science = Color(0xFF858585);

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
    color: AppColors.text,
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
  static const card = 16.0;
  static const dialog = 24.0;
  static const sheet = 26.0;
}
