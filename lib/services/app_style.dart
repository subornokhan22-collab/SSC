import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🎨 Workspace theme — the accent/backdrop tone the teacher picks for the
/// paper-building screens. Every preset is a dark, print-studio friendly
/// palette so text stays readable and the app keeps one consistent look.
class AppStyle {
  AppStyle._();

  static const _prefKey = 'app_bg_index';

  /// Current selection (also a notifier so screens repaint instantly).
  static final ValueNotifier<int> bgIndex = ValueNotifier<int>(0);

  /// Deep backdrop colours (base layer behind the frosted cards).
  static const List<Color> colors = [
    Color(0xFF0A0D14), // Midnight (default)
    Color(0xFF0B1210), // Forest
    Color(0xFF0A0F1A), // Deep Sea
    Color(0xFF130C10), // Wine
    Color(0xFF100C18), // Violet
    Color(0xFF13100A), // Amber Dusk
    Color(0xFF091413), // Teal Night
    Color(0xFF0E0F11), // Graphite
  ];

  /// Matching accent used for glows/edges of the selected preset.
  static const List<Color> accents = [
    Color(0xFFD4A72C),
    Color(0xFF4ADE80),
    Color(0xFF4C8DFF),
    Color(0xFFFF7B9C),
    Color(0xFFA78BFA),
    Color(0xFFFFB347),
    Color(0xFF2DD4BF),
    Color(0xFFB0BAC9),
  ];

  static const labels = [
    'Midnight (default)',
    'Forest',
    'Deep Sea',
    'Wine',
    'Violet',
    'Amber Dusk',
    'Teal Night',
    'Graphite',
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
          Color.alphaBlend(accent.withOpacity(.05), bg),
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
