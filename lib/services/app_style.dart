import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/design_tokens.dart';

/// Which area of the workspace is on screen.
///
/// Colour is part of the navigation language: the backdrop tint follows the
/// area, so moving between tabs reads as a change of place instead of a jump
/// cut, and a teacher learns what each hue means.
enum WorkspaceMood { home, papers, omr, ai, english }

/// 🎨 Workspace theme — the accent/backdrop tone the teacher picks for the
/// paper-building screens. Every preset is a light, paper-friendly palette so
/// dark text stays crisp and the app keeps one consistent, printable look.
class AppStyle {
  AppStyle._();

  static const _prefKey = 'app_bg_index';

  /// Current selection (also a notifier so screens repaint instantly).
  static final ValueNotifier<int> bgIndex = ValueNotifier<int>(0);

  /// Light backdrop colours (base layer behind the frosted cards).
  static const List<Color> colors = AppColors.workspaceBackgrounds;

  /// Matching accent used for glows/edges of the selected preset.
  static const List<Color> accents = AppColors.workspaceAccents;

  static const labels = [
    'Daylight (default)',
    'Mint Paper',
    'Sky',
    'Blush',
    'Lavender',
    'Sand',
    'Seafoam',
    'Slate Mist',
  ];

  static Color get bg => colors[bgIndex.value % colors.length];
  static Color get accent => accents[bgIndex.value % accents.length];
  static String get label => labels[bgIndex.value % labels.length];

  /// Area currently on screen. Not a notifier of its own: the backdrop listens
  /// to this and animates towards [moodColor].
  static final ValueNotifier<WorkspaceMood> mood =
      ValueNotifier<WorkspaceMood>(WorkspaceMood.home);

  /// Accent for the area on screen. Home keeps the preset accent so the
  /// chosen workspace stays visible; every other area owns a fixed hue from
  /// the design tokens, so the palette does real work instead of sitting
  /// unused in [AppColors].
  static Color get moodColor {
    switch (mood.value) {
      case WorkspaceMood.papers:
        return AppColors.science;
      case WorkspaceMood.omr:
        return AppColors.omr;
      case WorkspaceMood.ai:
        return AppColors.ai;
      case WorkspaceMood.english:
        return AppColors.writing;
      case WorkspaceMood.home:
        return accent;
    }
  }

  /// Soft vertical gradient for screen backdrops.
  static LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [bg, Color.alphaBlend(accent.withOpacity(.06), bg), bg],
      );

  static Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      bgIndex.value = (p.getInt(_prefKey) ?? 0) % colors.length;
    } catch (_) {
      // Preferences unavailable — keep the default preset.
    }
  }

  static Future<void> set(int i) async {
    bgIndex.value = i % colors.length;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt(_prefKey, bgIndex.value);
    } catch (_) {}
  }
}
