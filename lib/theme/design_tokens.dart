import 'package:flutter/material.dart';

/// Paper + Ink + Indigo. Semantic colors shared across the teacher workspace.
abstract final class AppColors {
  static const primary = Color(0xFF3157D5);
  static const primaryDark = Color(0xFF3157D5);
  static const secondary = Color(0xFF16845B);
  static const accent = Color(0xFF16845B);
  static const gradientEnd = Color(0xFF3157D5);

  static const canvas = Color(0xFFF7F8FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF7F8FA);
  static const border = Color(0xFFE4E7EC);
  static const text = Color(0xFF172033);
  static const muted = Color(0xFF667085);
  static const disabled = Color(0xFFC9D0E2);
  static const progressTrack = Color(0xFFE4E7EC);
  static const appBar = Color(0xFFFFFFFF);

  static const success = Color(0xFF16845B);
  static const warning = Color(0xFFC27A00);
  static const danger = Color(0xFFD64545);

  // Preserve this order: the workspace preset index is saved on the device.
  static const workspaceBackgrounds = <Color>[
    canvas,
    Color(0xFFF1F7F3),
    Color(0xFFEFF5FC),
    Color(0xFFFDF2F4),
    Color(0xFFF4F1FC),
    Color(0xFFFDF6EC),
    Color(0xFFEFF8F7),
    Color(0xFFF5F6F8),
  ];
  static const workspaceAccents = <Color>[
    primary,
    success,
    Color(0xFF0B84D9),
    Color(0xFFE05A78),
    Color(0xFF7C5CE0),
    warning,
    secondary,
    Color(0xFF5B6B8C),
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
  static const card = 20.0;
  static const dialog = 24.0;
  static const sheet = 26.0;
}
