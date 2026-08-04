import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/questions_data.dart';

/// বাংলা প্রশ্নপত্র → PDF / প্রিন্ট।
///
/// ফন্ট: Hind Siliguri (Regular + Bold) — assets/fonts/ এ থাকতে হবে।
/// Noto Sans Bengali ব্যবহার করা যাবে না: সেটিতে ইংরেজি অক্ষর, অপরেটর
/// ও গাণিতিক চিহ্ন নেই বলে PDF এ □□□ বাক্স দেখায়।
class PaperPdf {
  static const _optionLetters = ['ক', 'খ', 'গ', 'ঘ'];

  // Hind Siliguri তে যেসব অক্ষর নেই সেগুলো নিরাপদ রূপে বদলে দেওয়া হয়,
  // যাতে PDF এ কখনো □ (টোফু) না দেখায়।
  static String _safe(String s) {
    const repl = {
      '⁻¹': '^-1', '⁻²': '^-2', '⁻³': '^-3',
      '⁰': '^0', '⁴': '^4', '⁵': '^5', '⁶': '^6',
      '⁷': '^7', '⁸': '^8', '⁹': '^9', 'ⁿ': '^n',
      '₀': '_0', '₁': '_1', '₂': '_2', '₃': '_3', '₄': '_4',
      '₅': '_5', '₆': '_6', '₇': '_7', '₈': '_8', '₉': '_9',
      'Ω': 'ওম', 'μ': 'মাইক্রো', 'θ': 'থেটা', 'α': 'আলফা',
      'β': 'বিটা', 'γ': 'গামা', 'Δ': 'ডেল্টা', 'δ': 'ডেল্টা',
      'λ': 'ল্যামডা', 'ω': 'ওমেগা', 'ρ': 'রো', 'σ': 'সিগমা', 'φ': 'ফাই',
      '→': '->', '∴': 'অতএব', '∠': 'কোণ ',
      '‘': '\'', '’': '\'', '“': '"', '”': '"',
      '−': '-', '–': '-', '—': '-',
    };
    repl.forEach((k, v) => s = s.replaceAll(k, v));
    return s;
  }

  static Future<void> printPaper({
    required String title,
    required String modeLine,
    required List<Question> mcqs,
    required List<CreativeQuestion> cqs,
    String headerLine1 = 'মডেল টেস্ট পেপার - SSC 2027',
    String headerLine2 = '(বাংলাদেশ শিক্ষাবোর্ড প্রশ্ন-কাঠামো অনুপ্রাণিত)',
    String time = '৩ ঘণ্টা',
    String marks = '১০০',
    int cqAnswerCount = 7,
  }) async {
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/HindSiliguri-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/HindSiliguri-Bold.ttf'),
    );
    pw.TextStyle base(double size, {bool isBold = false}) => pw.TextStyle(
          font: isBold ? bold : regular,
          fontSize: size,
          lineSpacing: 4,
        );

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => [
