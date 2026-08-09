import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🎨 App Background — Options থেকে বেছে নেওয়া ব্যাকগ্রাউন্ড।
///
/// ব্যবহার: যে স্ক্রিনে বদলাতে চান সেটার body/Scaffold-এ
///   backgroundColor: AppStyle.colorOf(AppStyle.bgIndex.value)
/// অথবা পুরো body-কে AnimatedBuilder দিয়ে মুড়ে দিন, যেমন:
///   AnimatedBuilder(
///     animation: AppStyle.bgIndex,
///     builder: (context, _) => Container(color: AppStyle.bg, child: ...),
///   )
class AppStyle {
  AppStyle._();

  static const _prefKey = 'app_bg_index';

  /// বর্তমান নির্বাচন (ও নোটিফায়ার) — প্রাথমিক অবস্থা ডিফল্ট।
  static final ValueNotifier<int> bgIndex = ValueNotifier<int>(0);

  /// ব্যাকগ্রাউন্ড প্রিসেট (label + soft রঙ)।
  static const List<Color> colors = [
    Color(0xFFF7F3EA), // Soft Cream — ডিফল্ট
    Color(0xFFEAF6EF), // Mint
    Color(0xFFEAF1FB), // Sky
    Color(0xFFFBEDEA), // Rose
    Color(0xFFF1ECFA), // Lavender
    Color(0xFFFFF8E1), // Lemon
    Color(0xFFE8F9F6), // Teal Mist
    Color(0xFFEDEDED), // Grey
  ];
  static const labels = [
    'Cream (default)',
    'Mint',
    'Sky',
    'Rose',
    'Lavender',
    'Lemon',
    'Teal Mist',
    'Grey',
  ];

  static Color get bg => colors[bgIndex.value % colors.length];

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    bgIndex.value = (p.getInt(_prefKey) ?? 0) % colors.length;
  }

  static Future<void> set(int i) async {
    bgIndex.value = i % colors.length;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_prefKey, bgIndex.value);
  }
}
