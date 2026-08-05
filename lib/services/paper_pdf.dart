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
    } catch (_) {}
    try {
      final ls = FontLoader('HSPDF-Sym')
        ..addFont(rootBundle.load('assets/fonts/HindSiliguri-Regular.ttf'));
      await ls.load();
      _sym = 'HSPDF-Sym';
    } catch (_) {}
    // কোনো ফাইল না পেলে সেই স্তর বাদ পড়বে — প্রিন্ট তবু কাজ করবে
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
    String headerLine1 = 'মডেল টেস্ট পরীক্ষা — ২০২৭',
    String headerLine2 = 'দশম শ্রেণি',
    String time = '৩ ঘণ্টা',
    String marks = '১০০',
    int cqAnswerCount = 7,
    List<Question> saqs = const [],
    int saqAnswerCount = 10,
    String? cqNote,
    String? writtenTime,
    String? writtenMarks,
    String? mcqTime,
    String? mcqMarks,
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
      saqs: saqs,
      saqAnswerCount: saqAnswerCount,
      cqNote: cqNote,
      writtenTime: writtenTime,
      writtenMarks: writtenMarks,
      mcqTime: mcqTime,
      mcqMarks: mcqMarks,
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

  // ── স্কুল-স্টাইল পেজ রেন্ডারিং ইঞ্জিন ─────────────────────────
  // ১ম অংশ (লিখিত পত্র): সৃজনশীল + সংক্ষিপ্ত-উত্তর, মান ডান কলামে।
  // ২য় অংশ (বহুনির্বাচনি পত্র): স্কুল-বোর্ড স্টাইল হেডার (প্রাপ্ত নম্বর ও
  // কোড বাক্স, নাম/রোল/শাখা লাইন, দ্রষ্টব্য বাক্স) + দুই কলাম MCQ।
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
    required List<Question> saqs,
    required int saqAnswerCount,
    String? cqNote,
    String? writtenTime,
    String? writtenMarks,
    String? mcqTime,
    String? mcqMarks,
  }) async {
    final pages = <Uint8List>[];
    const double sw = 1654.0;
    const double sh = 2339.0;
    final double bottomY = sh - _margin;
    final double contentW = sw - 2 * _margin;

    final wt = _safe(writtenTime ?? time);
    final wm = _safe(writtenMarks ?? marks);
    final mt = _safe(mcqTime ?? '৩০ মিনিট');
    final mm = _safe(mcqMarks ?? _bn(mcqs.length));

    late ui.PictureRecorder rec;
    late Canvas canvas;
    late double y;

    void begin() {
      rec = ui.PictureRecorder();
      canvas = Canvas(rec, Rect.fromLTWH(0, 0, sw, sh));
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
            fontFamilyFallback: _sym != null ? const ['HSPDF-Sym'] : null,
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

    double mx(double a, double b) => a > b ? a : b;

    void strokeRect(Rect r, {double thick = 1.2}) {
      canvas.drawRect(
        r,
        Paint()
          ..color = const Color(0xFF000000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = thick * _k,
      );
    }

    // ── বেসিক প্যারাগ্রাফ ──
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

    // ── মান ডান কলামে এমন প্যারাগ্রাফ (স্কুল-স্টাইল) ──
    Future<void> paraMark(
      String text,
      double size,
      String mark, {
      bool isBold = false,
      double gapBefore = 0,
      double indent = 0,
    }) async {
      final markW = 26 * _k; // মান কলাম ≈ ৯ মিমি
      final tp = makePainter(_safe(text), size, isBold: isBold);
      tp.layout(maxWidth: contentW - indent * _k - markW);
      final tm = makePainter(_safe(mark), size);
      tm.layout(maxWidth: markW);
      final h = mx(tp.height, tm.height);
      if (y + gapBefore * _k + h > bottomY + 1) {
        await commit();
        begin();
      }
      y += gapBefore * _k;
      tp.paint(canvas, Offset(_margin + indent * _k, y));
      tm.paint(canvas, Offset(_margin + contentW - tm.width, y));
      y += h;
    }

    // ── অনুভূমিক রেখা ──
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

    Future<void> doubleRule({double gapBefore = 8}) async {
      await rule(gapBefore: gapBefore);
      await rule(gapBefore: 2);
    }

    // ── বাম-ডান দুই টেক্সট এক লাইনে ──
    Future<void> row2(String left, String right, double size,
        {double gapBefore = 0, bool isBold = false}) async {
      final tl = makePainter(_safe(left), size, isBold: isBold);
      tl.layout(maxWidth: contentW / 2);
      final tr = makePainter(_safe(right), size, isBold: isBold);
      tr.layout(maxWidth: contentW / 2);
      final h = mx(tl.height, tr.height);
      if (y + gapBefore * _k + h > bottomY + 1) {
        await commit();
        begin();
      }
      y += gapBefore * _k;
      tl.paint(canvas, Offset(_margin, y));
      tr.paint(canvas, Offset(sw - _margin - tr.width, y));
      y += h;
    }

    // ── প্রাপ্ত নম্বর + বিষয়/সেট কোড বাক্স ──
    Future<void> codeBoxes() async {
      final h = 2 * 9.0 * 1.4 * _k + 8 * _k; // দুই লাইনের উচ্চতা
      if (y + 5 * _k + h > bottomY + 1) {
        await commit();
        begin();
      }
      y += 5 * _k;
      // বামে: প্রাপ্ত নম্বর বাক্স
      final leftW = 62 * _k;
      strokeRect(Rect.fromLTWH(_margin, y, leftW, h), thick: 1.0);
      final t1 = makePainter('প্রাপ্ত নম্বর ঃ', 9);
      t1.layout(maxWidth: leftW - 6 * _k);
      t1.paint(canvas, Offset(_margin + 4 * _k, y + (h - t1.height) / 2));
      // ডানে: বিষয় কোড / সেট কোড বাক্স
      final rightW = 62 * _k;
      final rx = sw - _margin - rightW;
      strokeRect(Rect.fromLTWH(rx, y, rightW, h), thick: 1.0);
      final t2 = makePainter('বিষয় কোড ঃ', 9);
      t2.layout(maxWidth: rightW - 6 * _k);
      t2.paint(canvas, Offset(rx + 4 * _k, y + 4 * _k));
      final t3 = makePainter('সেট কোড ঃ', 9);
      t3.layout(maxWidth: rightW - 6 * _k);
      t3.paint(canvas, Offset(rx + 4 * _k, y + h - t3.height - 4 * _k));
      y += h;
    }

    // ── নাম / রোল নং / শাখা লাইন ──
    Future<void> nameRollLine() async {
      const size = 10.0;
      final ln = makePainter('নাম ঃ', size);
      ln.layout(maxWidth: contentW * 0.2);
      final lr = makePainter('রোল নং ঃ', size);
      lr.layout(maxWidth: contentW * 0.2);
      final ls = makePainter('শাখা ঃ', size);
      ls.layout(maxWidth: contentW * 0.15);
      final h = ln.height;
      if (y + 5 * _k + h > bottomY + 1) {
        await commit();
        begin();
      }
      y += 5 * _k;
      final lineY = y + h - 1.5 * _k;
      void ul(double x1, double x2) => canvas.drawLine(
            Offset(x1, lineY),
            Offset(x2, lineY),
            Paint()
              ..color = const Color(0xFF000000)
              ..strokeWidth = 0.8 * _k,
          );
      ln.paint(canvas, Offset(_margin, y));
      final nameEnd = _margin + contentW * 0.52;
      ul(_margin + ln.width + 2 * _k, nameEnd);
      final rx = nameEnd + 6 * _k;
      lr.paint(canvas, Offset(rx, y));
      final rollEnd = rx + lr.width + 20 * _k;
      ul(rx + lr.width + 2 * _k, rollEnd);
      final sx = rollEnd + 6 * _k;
      ls.paint(canvas, Offset(sx, y));
      ul(sx + ls.width + 2 * _k, sw - _margin);
      y += h;
    }

    // ── দ্রষ্টব্য বাক্স ──
    Future<void> noteBox(String text) async {
      final tp = makePainter(_safe(text), 9.5);
      tp.layout(maxWidth: contentW - 10 * _k);
      final h = tp.height + 6 * _k;
      if (y + 4 * _k + h > bottomY + 1) {
        await commit();
        begin();
      }
      y += 4 * _k;
      strokeRect(Rect.fromLTWH(_margin, y, contentW, h), thick: 1.0);
      tp.paint(canvas, Offset(_margin + 5 * _k, y + 3 * _k));
      y += h;
    }

    // ── অংশের হেডার (লিখিত / বহুনির্বাচনি) ──
    Future<void> partHeader({
      required String subjLine,
      required String tLeft,
      required String tRight,
      bool mcqStyle = false,
    }) async {
      await para(headerLine1, 17, isBold: true, align: TextAlign.center);
      await para(headerLine2, 12, align: TextAlign.center, gapBefore: 1);
      await para(subjLine, 11.5,
          isBold: true, align: TextAlign.center, gapBefore: 3);
      if (mcqStyle) await codeBoxes();
      await row2(tLeft, tRight, 10.5, gapBefore: 5, isBold: true);
      if (mcqStyle) await nameRollLine();
      await doubleRule(gapBefore: 6);
    }

    // ── সেকশন টাইটেল ──
    Future<void> sectionTitle(String title2, String? note,
        {double gapBefore = 8}) async {
      await para(title2, 12.5,
          isBold: true, align: TextAlign.center, gapBefore: gapBefore);
      if (note != null) {
        await para(note, 9.5, align: TextAlign.center, gapBefore: 2);
      }
    }

    // ══════════════ ১ম অংশ: লিখিত পত্র ══════════════
    begin();
    final subj =
        'বিষয় ঃ $title${modeLine.isNotEmpty ? '  —  $modeLine' : ''}';
    await partHeader(subjLine: subj, tLeft: 'সময় ঃ $wt', tRight: 'পূর্ণমান ঃ $wm');

    if (cqs.isNotEmpty) {
      await sectionTitle('সৃজনশীল প্রশ্ন', cqNote ??
          '(যেকোনো ${_bn(cqAnswerCount)}টি প্রশ্নের উত্তর দাও। প্রতিটি প্রশ্নের মান ১০)');
      for (int i = 0; i < cqs.length; i++) {
        final cq = cqs[i];
        await para('${_bn(i + 1)}। ${cq.stem}', 11, gapBefore: 9);
        await paraMark(
            'ক) ${cq.questionK}', 10.5, _bn(cq.marks.isNotEmpty ? cq.marks[0] : 1),
            indent: 10, gapBefore: 2.5);
        await paraMark(
            'খ) ${cq.questionKh}', 10.5, _bn(cq.marks.length > 1 ? cq.marks[1] : 2),
            indent: 10, gapBefore: 1.5);
        await paraMark(
            'গ) ${cq.questionG}', 10.5, _bn(cq.marks.length > 2 ? cq.marks[2] : 3),
            indent: 10, gapBefore: 1.5);
        await paraMark(
            'ঘ) ${cq.questionGh}', 10.5, _bn(cq.marks.length > 3 ? cq.marks[3] : 4),
            indent: 10, gapBefore: 1.5);
      }
    }

    if (saqs.isNotEmpty) {
      await sectionTitle(
        'সংক্ষিপ্ত-উত্তর প্রশ্ন',
        '(যেকোনো ${_bn(saqAnswerCount)}টি প্রশ্নের উত্তর দাও। প্রতিটি প্রশ্নের মান ২)',
        gapBefore: 12,
      );
      for (int i = 0; i < saqs.length; i++) {
        await paraMark(
          '${_bn(cqs.length + i + 1)}। ${saqs[i].questionText}',
          11,
          _bn(2),
          gapBefore: 7,
        );
      }
    }

    // ══════════════ ২য় অংশ: বহুনির্বাচনি পত্র (দুই কলাম) ══════════════
    if (mcqs.isNotEmpty) {
      await commit();
      begin();
      await partHeader(
        subjLine: '$subj (বহুনির্বাচনি)',
        tLeft: 'সময় ঃ $mt',
        tRight: 'পূর্ণমান ঃ $mm',
        mcqStyle: true,
      );
      await noteBox(
          'বিশেষ দ্রষ্টব্য ঃ সবগুলো প্রশ্নের উত্তর দিতে হবে। প্রতিটি প্রশ্নের মান ১। উত্তরপত্রে প্রশ্নের ক্রমিক নম্বরের বিপরীতে প্রদত্ত বর্ণ সন্নিবেশিত বৃত্তসমূহ ভরাট করতে হবে।');
      y += 6 * _k;

      final double gutter = 16 * _k;
      final double colW = (contentW - gutter) / 2;
      final colX = [_margin, _margin + colW + gutter];
      final colY = [y, y];
      int cur = 0;

      Future<void> placeMcq(int no, Question q) async {
        final qt = makePainter(
            _safe('${_bn(no)}। ${q.questionText}'), 10.5);
        qt.layout(maxWidth: colW);
        final optP = <TextPainter>[];
        for (int o = 0; o < q.options.length; o++) {
          final tp = makePainter(
              _safe('${_optionLetters[o]}) ${q.options[o]}', preserveSpaces: true),
              10);
          tp.layout(maxWidth: colW - 7 * _k);
          optP.add(tp);
        }
        final half = (colW - 7 * _k) / 2;
        bool grid = q.options.length == 4 &&
            optP.every((o) => o.width <= half - 2 * _k);
        double optH;
        double rowA = 0, rowB = 0;
        if (grid) {
          rowA = mx(optP[0].height, optP[1].height);
          rowB = mx(optP[2].height, optP[3].height);
          optH = rowA + rowB + 1.5 * _k;
        } else {
          optH = optP.fold<double>(0, (a, o) => a + o.height + 0.6 * _k);
        }
        final need = qt.height + 2 * _k + optH + 4 * _k;
        if (colY[cur] + need > bottomY) {
          if (cur == 0) {
            cur = 1;
          } else {
            await commit();
            begin();
            colY[0] = colY[1] = _margin;
            cur = 0;
          }
        }
        final x = colX[cur];
        double yy = colY[cur];
        qt.paint(canvas, Offset(x, yy));
        yy += qt.height + 2 * _k;
        if (grid) {
          optP[0].paint(canvas, Offset(x + 7 * _k, yy));
          optP[1].paint(canvas, Offset(x + 7 * _k + half, yy));
          yy += rowA + 1.5 * _k;
          optP[2].paint(canvas, Offset(x + 7 * _k, yy));
          optP[3].paint(canvas, Offset(x + 7 * _k + half, yy));
          yy += rowB;
        } else {
          for (final o in optP) {
            o.paint(canvas, Offset(x + 7 * _k, yy));
            yy += o.height + 0.6 * _k;
          }
        }
        colY[cur] = yy + 4 * _k;
      }

      for (int i = 0; i < mcqs.length; i++) {
        await placeMcq(i + 1, mcqs[i]);
      }
      y = mx(colY[0], colY[1]);
    }

    await doubleRule(gapBefore: 10);
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
