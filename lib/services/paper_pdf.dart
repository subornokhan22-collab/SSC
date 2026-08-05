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
/// ফন্ট: assets/fonts/HindSiliguri-Regular.ttf ও HindSiliguri-Bold.ttf
/// (rootBundle থেকে লোড হয়; না পেলে সিস্টেম ফন্টে চলে যায় — প্রিন্ট তবু হবে)
class PaperPdf {
  static const _optionLetters = ['ক', 'খ', 'গ', 'ঘ'];

  // ── রেন্ডার সেটিং ─────────────────────────────────────────────
  static const double _dpi = 200; // প্রিন্টের জন্য যথেষ্ট
  static const double _k = _dpi / 72; // pt → px গুণক
  static const int _W = 1654; // A4 প্রস্থ @200dpi (px)
  static const int _H = 2339; // A4 উচ্চতা @200dpi (px)
  static const double _margin = 40 * _k; // মার্জিন ≈ 14 মিমি

  // ফন্ট ফ্যামিলি (FontLoader দিয়ে রেজিস্টার করা নাম)
  static String? _regular;
  static String? _bold;

  static Future<void> _loadFonts() async {
    if (_regular != null) return; // একবার হলেই যথেষ্ট
    try {
      final lr = FontLoader('HSPDF-Regular')
        ..addFont(rootBundle.load('assets/fonts/HindSiliguri-Regular.ttf'));
      await lr.load();
      final lb = FontLoader('HSPDF-Bold')
        ..addFont(rootBundle.load('assets/fonts/HindSiliguri-Bold.ttf'));
      await lb.load();
      _regular = 'HSPDF-Regular';
      _bold = 'HSPDF-Bold';
    } catch (_) {
      // ফন্ট ফাইল না পেলে সিস্টেম ফন্ট ব্যবহার হবে — প্রিন্ট তবু কাজ করবে
      _regular = null;
      _bold = null;
    }
  }

  // Hind Siliguri তে নেই এমন গাণিতিক/বিশেষ চিহ্নগুলো নিরাপদ বাংলা/ASCII
  // রূপে বদলে দেওয়া হয়, যাতে কোনো ফোনে □ (টোফু) না আসে।
  static String _safe(String s, {bool preserveSpaces = false}) {
    const multi = <String, String>{
      '⁻¹': '^-1', '⁻²': '^-2', '⁻³': '^-3', '⁻⁴': '^-4', '⁻⁵': '^-5',
      '⁻⁶': '^-6', '⁻⁷': '^-7', '⁻⁸': '^-8', '⁻⁹': '^-9', '⁻ⁿ': '^-n',
    };
    const single = <String, String>{