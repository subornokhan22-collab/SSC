import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/questions_data.dart';

/// বাংলা প্রশ্নপত্র → PDF / প্রিন্ট (v2 - সম্পূর্ণ নতুন ইঞ্জিন)
///
/// সমস্যা যেটা ঠিক করা হয়েছে:
/// pub.dev এর `pdf` প্যাকেজে OpenType shaping নেই — তাই বাংলা যুক্তাক্ষর
/// (শ্চ, ক্ষ, ত্র, র্ব ইত্যাদি), হসন্ত, মাত্রা ভেঙে ছিল ও □ বাক্স আসছিল।
///
/// সমাধান: প্রতিটি A4 পেজ আগে Flutter-এর নিজের TextPainter (Skia/Harfbuzz)
/// দিয়ে আঁকা হয় — এতে বাংলা লিখি ১০০% ঠিকমতো বসে। তারপর পেজটি PNG ছবি
/// হিসেবে PDF এ বসানো হয়। অর্থাৎ PDF এ টেক্সট নয়, ছবি থাকে — প্রিন্টে
/// কোনো ফন্ট/শেপিং সমস্যা আসার সুযোগই থাকে না।
///
/// ফন্ট (assets/fonts/): NotoSerifBengali-Regular.ttf + NotoSerifBengali-Bold.ttf
/// (ঐতিহ্যবাহী বাংলা সংখ্যার প্রধান ফন্ট) এবং HindSiliguri-Regular.ttf
/// (গাণিতিক চিহ্নের ফলব্যাক)। rootBundle থেকে লোড হয়; কোনোটি না পেলে সেই
/// স্তরটুকু বাদ পড়ে — প্রিন্ট তবু হবে।
class PaperPdf {
  static const _optionLetters = ['ক', 'খ', 'গ', 'ঘ'];

  // ── রেন্ডার সেটিং ─────────────────────────────────────────────
  static const double _dpi = 200; // প্রিন্টের জন্য যথেষ্ট
  static const double _k = _dpi / 72; // pt → px গুণক
  static const int _W = 1654; // A4 প্রস্থ @200dpi (px)
  static const int _H = 2339; // A4 উচ্চতা @200dpi (px)
  static const double _margin = 40 * _k; // মার্জিন ≈ 14 মিমি

  // ফন্ট ফ্যামিলি (FontLoader দিয়ে রেজিস্টার করা নাম)
  //
  // ১) HSPDF-Regular/Bold = Noto Serif Bengali — বাংলা অক্ষর ও
  //    ঐতিহ্যবাহী বাংলা সংখ্যা (১২৩…) এই ফন্ট থেকে আসে।
  // ২) HSPDF-Sym = Hind Siliguri — ² ³ √ π × ÷ ± ≤ ≥ ≈ ≠ ইত্যাদি গাণিতিক
  //    চিহ্ন Noto তে নেই, তাই সেগুলো ফলব্যাক হিসেবে এই ফন্ট থেকে আসে।
  //    (Hind Siliguri-র বাংলা সংখ্যা অদ্ভুদ আকৃতির — তাই এটি প্রাথমিক
  //    ফন্ট নয়, শুধু চিহ্নের ফলব্যাক)
  static String? _regular;
  static String? _bold;
  static String? _sym;
  static bool _fontsTried = false;

  static Future<void> _loadFonts() async {
    if (_fontsTried) return; // একবার চেষ্টা করলেই যথেষ্ট
    _fontsTried = true;
    try {
      final lr = FontLoader('HSPDF-Regular')
        ..addFont(
            rootBundle.load('assets/fonts/NotoSerifBengali-Regular.ttf'));
      await lr.load();
      _regular = 'HSPDF-Regular';
    } catch (_) {}
    try {
      final lb = FontLoader('HSPDF-Bold')
        ..addFont(rootBundle.load('assets/fonts/NotoSerifBengali-Bold.ttf'));
      await lb.load();
      _bold = 'HSPDF-Bold';