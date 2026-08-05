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
      '⁰': '^0', '⁴': '^4', '⁵': '^5', '⁶': '^6', '⁷': '^7', '⁸': '^8',
      '⁹': '^9', '⁻': '^-', 'ⁿ': '^n', 'ᵐ': '^m',
      '₀': '_0', '₁': '_1', '₂': '_2', '₃': '_3', '₄': '_4', '₅': '_5',
      '₆': '_6', '₇': '_7', '₈': '_8', '₉': '_9', 'ₐ': '_a',
      'Δ': 'ডেল্টা ', 'θ': 'থেটা', 'λ': 'ল্যামডা', 'ρ': 'রো',
      '′': "'", '″': '"',
      '∈': ' সদস্য ', '∉': ' সদস্য নয় ', '∅': ' ফাঁকা সেট ',
      '∩': ' ছেদ ', '∪': ' সংযোগ ',
      '⊆': ' উপসেট ', '⊂': ' প্রকৃত উপসেট ', '⊄': ' উপসেট নয় ',
      '∠': 'কোণ ', '∥': ' সমান্তরাল ', '⊥': ' লম্ব ', '⟂': ' লম্ব ',
      '∝': ' সমানুপাতিক ',
      '→': ' -> ', '∴': ' অতএব ',
    };
    multi.forEach((k, v) => s = s.replaceAll(k, v));
    single.forEach((k, v) => s = s.replaceAll(k, v));
    // রিপ্লেসমেন্টে বাড়তি স্পেস এলে এক ঘর করে দেই
    // (অপশন-লাইনে পাঁচ স্পেসের দূরত্ব বজায় রাখতে preserveSpaces ব্যবহার হয়)
    return preserveSpaces ? s : s.replaceAll(RegExp(' +'), ' ');
  }

  /// মূল এন্ট্রি পয়েন্ট — আগের মতোই। question_paper_screen থেকে
  /// একইভাবে কল করা যায়, কোনো পরিবর্তন লাগে না।
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
    await _loadFonts();

    final pages = await _renderPages(
      title: title,
      modeLine: modeLine,
      mcqs: mcqs,
      cqs: cqs,
      headerLine1: headerLine1,
      headerLine2: headerLine2,
      time: time,
      marks: marks,
      cqAnswerCount: cqAnswerCount,
    );

    // রাস্টার পেজগুলো PDF এ বসাও
    final doc = pw.Document();
    for (final png in pages) {
      final img = pw.MemoryImage(png);
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.Image(
            img,
            width: PdfPageFormat.a4.width,
            height: PdfPageFormat.a4.height,
            fit: pw.BoxFit.fill,
          ),
        ),
      );
    }
    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  // ── পেজ রেন্ডারিং ইঞ্জিন ──────────────────────────────────────
  static Future<List<Uint8List>> _renderPages({
    required String title,
    required String modeLine,
    required List<Question> mcqs,
    required List<CreativeQuestion> cqs,
    required String headerLine1,
    required String headerLine2,
    required String time,
    required String marks,
    required int cqAnswerCount,
  }) async {
    final pages = <Uint8List>[];
    const double sw = 1654.0;
    const double sh = 2339.0;
    final double bottomY = sh - _margin;
    final double contentW = sw - 2 * _margin;

    late ui.PictureRecorder rec;
    late Canvas canvas;
    late double y;

    void begin() {
      rec = ui.PictureRecorder();
      canvas = Canvas(rec, Rect.fromLTWH(0, 0, sw, sh));
      // সাদা ব্যাকগ্রাউন্ড (PDF এ ছবি হিসেবে যাবে)
      canvas.drawRect(
        Rect.fromLTWH(0, 0, sw, sh),
        Paint()..color = const Color(0xFFFFFFFF),
      );
      y = _margin;
    }

    Future<void> commit() async {
      final img = await rec.endRecording().toImage(_W, _H);
      final bd = await img.toByteData(format: ui.ImageByteFormat.png);
      pages.add(bd!.buffer.asUint8List());
    }

    TextPainter makePainter(String text, double size,
        {bool isBold = false,
        TextAlign align = TextAlign.left,
        double lineHeight = 1.4}) {
      return TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: isBold ? (_bold ?? _regular) : _regular,
            fontWeight:
                (isBold && _bold == null) ? FontWeight.w700 : FontWeight.w400,
            fontSize: size * _k,
            height: lineHeight,
            color: const Color(0xFF000000),
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: align,
      );
    }

    /// একটি প্যারাগ্রাফ আঁকে; পেজে জায়গা না থাকলে নতুন পেজে যায়।
    Future<void> para(
      String text,
      double size, {
      bool isBold = false,
      TextAlign align = TextAlign.left,
      double gapBefore = 0,
      double indent = 0,
      bool preserveSpaces = false,
    }) async {
      final tp = makePainter(_safe(text, preserveSpaces: preserveSpaces), size,
          isBold: isBold, align: align);
      tp.layout(maxWidth: contentW - indent * _k);
      if (y + gapBefore * _k + tp.height > bottomY + 1) {
        await commit();
        begin();
      }
      y += gapBefore * _k;
      tp.paint(canvas, Offset(_margin + indent * _k, y));
      y += tp.height;
    }

    /// অনুভূমিক রেখা
    Future<void> rule(
        {double gapBefore = 0, double gapAfter = 0, double thick = 1.2}) async {
      final need = (gapBefore + gapAfter + 4) * _k;
      if (y + need > bottomY + 1) {
        await commit();
        begin();
      }
      y += (gapBefore + 2) * _k;
      canvas.drawLine(
        Offset(_margin, y),
        Offset(sw - _margin, y),
        Paint()
          ..color = const Color(0xFF000000)
          ..strokeWidth = thick * _k,
      );
      y += (gapAfter + 2) * _k;
    }

    /// একই লাইনে বাম-ডান দুই টেক্সট (সময় / পূর্ণমান)
    Future<void> row2(String left, String right, double size,
        {double gapBefore = 0}) async {
      final tl = makePainter(_safe(left), size);
      tl.layout(maxWidth: contentW / 2);
      final tr = makePainter(_safe(right), size);
      tr.layout(maxWidth: contentW / 2);
      final h = tl.height > tr.height ? tl.height : tr.height;
      if (y + gapBefore * _k + h > bottomY + 1) {
        await commit();
        begin();
      }
      y += gapBefore * _k;
      tl.paint(canvas, Offset(_margin, y));
      tr.paint(canvas, Offset(sw - _margin - tr.width, y));
      y += h;
    }

    // ─────── কনটেন্ট বিন্যাস (আগের লেআউন্টের মতোই) ───────
    begin();

    await para(headerLine1, 16, isBold: true, align: TextAlign.center);
    await para(headerLine2, 10, align: TextAlign.center, gapBefore: 2);
    await para(
      'বিষয়: $title${modeLine.isNotEmpty ? '  -  $modeLine' : ''}',
      11,
      align: TextAlign.center,
      gapBefore: 4,
    );
    await rule(gapBefore: 8);
    await rule(gapBefore: 2);
    await row2('সময়: $time', 'পূর্ণমান: $marks', 10, gapBefore: 4);

    if (mcqs.isNotEmpty) {
      await para('বিভাগ - ক', 12,
          isBold: true, align: TextAlign.center, gapBefore: 10);
      await para('বহুনির্বাচনি প্রশ্ন (MCQ)', 12,
          isBold: true, align: TextAlign.center, gapBefore: 2);
      for (int i = 0; i < mcqs.length; i++) {
        final q = mcqs[i];
        await para('${_bn(i + 1)}। ${q.questionText}', 11, gapBefore: 7);
        // অপশনগুলো ৫ স্পেস দিয়ে জোড়া (preserveSpaces তাই দূরত্ব বজায় থাকে)
        final opts = List.generate(
          q.options.length,
          (o) => '${_optionLetters[o]}) ${q.options[o]}',
        ).join('     ');
        await para(opts, 10.5, indent: 16, gapBefore: 1, preserveSpaces: true);
      }
    }

    if (cqs.isNotEmpty) {
      await rule(gapBefore: 10);
      await para('বিভাগ - খ', 12,
          isBold: true, align: TextAlign.center, gapBefore: 8);
      await para('সৃজনশীল প্রশ্ন', 12,
          isBold: true, align: TextAlign.center, gapBefore: 2);
      await para(
        '(যেকোনো ${_bn(cqAnswerCount)}টি প্রশ্নের উত্তর দাও। প্রতিটি প্রশ্নের মান ১০)',
        9.5,
        align: TextAlign.center,
        gapBefore: 2,
      );
      for (int i = 0; i < cqs.length; i++) {
        final cq = cqs[i];
        String part(String l, String t, int m) => '$l) $t  -  ${_bn(m)}';
        await para('${_bn(i + 1)}। ${cq.stem}', 11, gapBefore: 8);
        await para(part('ক', cq.questionK, cq.marks.isNotEmpty ? cq.marks[0] : 1),
            10.5, indent: 16, gapBefore: 2);
        await para(part('খ', cq.questionKh, cq.marks.length > 1 ? cq.marks[1] : 2),
            10.5, indent: 16, gapBefore: 1.5);
        await para(part('গ', cq.questionG, cq.marks.length > 2 ? cq.marks[2] : 3),
            10.5, indent: 16, gapBefore: 1.5);
        await para(part('ঘ', cq.questionGh, cq.marks.length > 3 ? cq.marks[3] : 4),
            10.5, indent: 16, gapBefore: 1.5);
      }
    }

    await rule(gapBefore: 12);
    await rule(gapBefore: 2);
    await para('- শেষ -', 10, align: TextAlign.center, gapBefore: 4);

    await commit();
    return pages;
  }

  static String _bn(int n) {
    const d = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return n.toString().split('').map((c) {
      final code = c.codeUnitAt(0);
      return (code >= 48 && code <= 57) ? d[code - 48] : c;
    }).join();
  }
}
