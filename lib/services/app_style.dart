import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🎨 Workspace theme — the accent/backdrop tone the teacher picks for the
/// paper-building screens. Every preset is a light, paper-friendly palette so
/// dark text stays crisp and the app keeps one consistent, printable look.
class AppStyle {
  AppStyle._();

  static const _prefKey = 'app_bg_index';

  /// Current selection (also a notifier so screens repaint instantly).
  static final ValueNotifier<int> bgIndex = ValueNotifier<int>(0);

  /// Light backdrop colours (base layer behind the frosted cards).
  static const List<Color> colors = [
    Color(0xFFF4F6FB), // Daylight (default)
    Color(0xFFF1F7F3), // Mint Paper
    Color(0xFFEFF5FC), // Sky
    Color(0xFFFDF2F4), // Blush
    Color(0xFFF4F1FC), // Lavender
    Color(0xFFFDF6EC), // Sand
    Color(0xFFEFF8F7), // Seafoam
    Color(0xFFF5F6F8), // Slate Mist
  ];

  /// Matching accent used for glows/edges of the selected preset.
  static const List<Color> accents = [
    Color(0xFF3D5AFE),
    Color(0xFF12A150),
    Color(0xFF0B84D9),
    Color(0xFFE05A78),
    Color(0xFF7C5CE0),
    Color(0xFFE08700),
    Color(0xFF00897B),
    Color(0xFF5B6B8C),
  ];

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
