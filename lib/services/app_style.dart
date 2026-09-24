import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/design_tokens.dart';

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

  /// Soft vertical gradient for screen backdrops.
  static LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          bg,
          Color.alphaBlend(accent.withOpacity(.06), bg),
          bg,
        ],
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
