import 'package:flutter/material.dart';

/// Tutor's Desk blue theme. White is the foreground on brand surfaces;
/// the OMR pink pair remains reserved for the printed-sheet workflow.
abstract final class AppColors {
  static const onColor = Colors.white;
  static const light = Color(0xFF90CAF9);
  static const primary = Color(0xFF2196F3);
  static const primaryDark = Color(0xFF2196F3);
  static const secondary = Color(0xFF2196F3);
  static const accent = Color(0xFF2196F3);
  static const gradientEnd = Color(0xFF90CAF9);

  static const canvas = Color(0xFFE3F2FD);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFE3F2FD);
  static const border = Color(0xFF90CAF9);
  static const text = Color(0xFF2196F3);
  static const muted = Color(0xFF2196F3);
  static const disabled = Color(0xFF90CAF9);
  static const progressTrack = Color(0xFF90CAF9);
  static const appBar = Color(0xFF2196F3);

  // Workspace roles share the blue theme; do not change persisted preset ordering.
  // OMR uses the same pink as the printed sheet so the scanner workflow has
  // one recognizable visual identity. The soft tint is reserved for the
  // sheet's bands/backgrounds.
  static const omr = Color(0xFFEB3897);
  static const omrSoft = Color(0xFFFCDEEE);
  static const ai = Color(0xFF2196F3);
  static const writing = Color(0xFF2196F3);
  static const science = Color(0xFF2196F3);

  static const success = Color(0xFF2196F3);
  static const warning = Color(0xFF2196F3);
  static const danger = Color(0xFF2196F3);

  // Preserve this order: the workspace preset index is saved on the device.
  // Presets intentionally share one visible palette; the picker is hidden.
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
