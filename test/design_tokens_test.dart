import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutors_desk/services/app_style.dart';
import 'package:tutors_desk/theme/app_theme.dart';
import 'package:tutors_desk/theme/design_tokens.dart';

void main() {
  test('existing theme API delegates to semantic palette tokens', () {
    expect(AppTheme.primary, AppColors.primary);
    expect(AppTheme.canvas, AppColors.canvas);
    expect(AppTheme.textDark, AppColors.text);
    expect(AppTheme.danger, AppColors.danger);
    expect(AppTheme.brandGradient.colors, [
      AppColors.primary,
      AppColors.gradientEnd,
    ]);
  });

  test('workspace preset indices and default colors remain stable', () {
    expect(AppStyle.colors, AppColors.workspaceBackgrounds);
    expect(AppStyle.accents, AppColors.workspaceAccents);
    expect(AppStyle.colors.length, 8);
    expect(AppStyle.colors.first, const Color(0xFFF4F6FB));
    expect(AppStyle.accents.first, const Color(0xFF3D5AFE));
    expect(AppStyle.labels.length, AppStyle.colors.length);
  });

  test('theme typography uses the registered Bengali UI family', () {
    final theme = AppTheme.light();
    for (final style in [
      theme.textTheme.titleLarge,
      theme.textTheme.titleMedium,
      theme.textTheme.bodyMedium,
      theme.textTheme.bodySmall,
      theme.textTheme.labelLarge,
      theme.appBarTheme.titleTextStyle,
    ]) {
      expect(style?.fontFamily, AppTypography.uiFont);
    }
    expect(theme.textTheme.titleMedium?.color, AppColors.text);
    expect(theme.textTheme.bodyMedium?.color, AppColors.text);
  });

  test('font families are declared and their assets exist', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('family: ${AppTypography.uiFont}'));
    expect(pubspec, contains('family: ${AppTypography.paperFont}'));
    for (final font in [
      'HindSiliguri-Regular.ttf',
      'NotoSerifBengali-Regular.ttf',
      'NotoSerifBengali-Bold.ttf',
    ]) {
      expect(File('assets/fonts/$font').existsSync(), isTrue);
    }
  });

  test('shared controls consume padding and radius tokens', () {
    final theme = AppTheme.light();
    expect(theme.inputDecorationTheme.contentPadding, AppSpacing.inputPadding);
    final padding = theme.filledButtonTheme.style?.padding?.resolve({});
    expect(padding, AppSpacing.buttonPadding);
    final border = theme.inputDecorationTheme.border as OutlineInputBorder;
    expect(border.borderRadius, BorderRadius.circular(AppRadii.control));
  });
}
