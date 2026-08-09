import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader, rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/english_board_data.dart';
import '../data/english_first_data.dart';

/// English Second Paper (Board Questions 2024) → PDF / printer.
///
/// Reproduces the board-paper layout exactly:
///  • dark serial banner ("51  DHAKA BOARD–2024")
///  • the Bengali বিদ্র note rendered via Skia (perfect conjuncts)
///  • Part–A / Part–B headers, numbered questions, right-aligned marks
///  • Q1/Q3 word boxes as bordered one-row tables (columns)
///  • Q2 matching items as a bordered 3-column table (rows)
///  • Q6 root words bold + underlined
/// Free users get a big faint "DEMO" watermark; Pro prints clean.
class EnglishBoardPdf {
  EnglishBoardPdf._();

  static pw.Font? _reg;
  static pw.Font? _bold;
  static pw.Font? _dv; // symbol fallback (×, – etc.)
  static bool _fontsTried = false;

  static const _letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'];

  static Future<void> _loadFonts() async {
    if (_fontsTried) return;
    _fontsTried = true;
    try {
      _reg = pw.Font.ttf(
          await rootBundle.load('assets/fonts/NotoSerifBengali-Regular.ttf'));
    } catch (_) {}
    try {
      _bold = pw.Font.ttf(
          await rootBundle.load('assets/fonts/NotoSerifBengali-Bold.ttf'));
    } catch (_) {}
    try {
      _dv = pw.Font.ttf(await rootBundle.load('assets/fonts/DejaVuSans.ttf'));
    } catch (_) {}
  }

  static pw.TextStyle _style(double size,
          {bool bold = false, bool italic = false}) =>
      pw.TextStyle(
        font: bold ? _bold : _reg,
        fontFallback: [if (_dv != null) _dv!],
        fontSize: size,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        fontStyle: italic ? pw.FontStyle.italic : pw.FontStyle.normal,
        height: 1.33,
      );

  /// Render one line of Bengali text to a transparent PNG (Skia shapes the
  /// conjuncts correctly — the pdf package itself cannot).
  static Future<pw.MemoryImage?> _bengaliLine(String text) async {
    try {
      final loader = FontLoader('EBNote')
        ..addFont(
            rootBundle.load('assets/fonts/NotoSerifBengali-Regular.ttf'));
      await loader.load();
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontFamily: 'EBNote',
            fontStyle: FontStyle.italic,
            fontSize: 26,
            color: Color(0xFF000000),
          ),
        ),
        textDirection: ui.TextDirection.ltr,
        textScaler: const TextScaler.linear(1.0),
      )..layout();
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      tp.paint(canvas, Offset.zero);
      final img = await recorder
          .endRecording()
          .toImage(tp.width.ceil() + 2, tp.height.ceil() + 2);
      final bd = await img.toByteData(format: ui.ImageByteFormat.png);
      final bytes = bd?.buffer.asUint8List();
      return bytes == null ? null : pw.MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }

  // ── building blocks ─────────────────────────────────────────────────────

  static pw.Widget _banner(EnglishBoardSet s) {
    return pw.Container(
      color: PdfColors.black,
      padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      child: pw.Center(
        child: pw.Text(
          '${s.serial}   ${s.board.toUpperCase()}',
          style: pw.TextStyle(
            font: _bold,
            fontFallback: [if (_dv != null) _dv!],
            fontSize: 13,
            color: PdfColors.white,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }

  static pw.Widget _partHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 7, bottom: 5),
      child: pw.Center(child: pw.Text(text, style: _style(11.5, bold: true))),
    );
  }

  /// "1.  <instruction>                                        1 × 10 = 10"
  static pw.Widget _qHead(String num, String instruction, String marks) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
              width: 16, child: pw.Text(num, style: _style(10, bold: true))),
          pw.Expanded(
              child: pw.Text(instruction, style: _style(9.8, bold: true))),
          pw.SizedBox(width: 8),
          pw.Text(marks, style: _style(9.8, bold: true)),
        ],
      ),
    );
  }

  static pw.Widget _body(String text,
          {double size = 10, double indent = 16}) =>
      pw.Padding(
        padding: pw.EdgeInsets.only(left: indent),
        child: pw.Text(text,
            style: _style(size), textAlign: pw.TextAlign.justify),
      );

  /// The bordered one-row word box (Q1 / Q3).
  static pw.Widget _wordBox(List<String> words) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 16, top: 3),
      child: pw.Table(
        border: pw.TableBorder.all(width: 0.9),
        columnWidths: {
          for (var i = 0; i < words.length; i++)
            i: const pw.FlexColumnWidth(1),
        },
        children: [
          pw.TableRow(
            children: [
              for (final w in words)
                pw.Padding(
                  padding:
                      const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 1),
                  child: pw.Center(child: pw.Text(w, style: _style(9.2))),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// The bordered 3-column matching table (Q2).
  static pw.Widget _matchTable(List<EBMatchRow> rows) {
    pw.Widget cell(String t,
            {bool center = false, double pad = 3.2}) =>
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(vertical: pad, horizontal: 4),
          child: center
              ? pw.Center(child: pw.Text(t, style: _style(9.5)))
              : pw.Text(t, style: _style(9.5)),
        );
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 16, top: 3),
      child: pw.Table(
        border: pw.TableBorder.all(width: 0.9),
        columnWidths: const {
          0: pw.FlexColumnWidth(4.3),
          1: pw.FlexColumnWidth(2.1),
          2: pw.FlexColumnWidth(4.0),
        },
        children: [
          for (final r in rows)
            pw.TableRow(
                children: [cell(r.a), cell(r.b, center: true), cell(r.c)]),
        ],
      ),
    );
  }

  /// (a)–(j) transformation items with direction in parenthesis.
  static pw.Widget _transformItems(List<EBTransformItem> items) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 16, top: 2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 1.2),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                      width: 18,
                      child: pw.Text('(${_letters[i]})',
                          style: _style(9.8, bold: true))),
                  pw.Expanded(
                    child: pw.RichText(
                      text: pw.TextSpan(
                        style: _style(9.8),
                        children: [
                          pw.TextSpan(text: items[i].sentence),
                          pw.TextSpan(
                              text: ' (${items[i].direction})',
                              style: _style(9.8)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// (a)–(e) tag-question lines with a trailing blank and "?".
  static pw.Widget _tagItems(List<String> items) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 16, top: 2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 1.2),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                      width: 18,
                      child: pw.Text('(${_letters[i]})',
                          style: _style(9.8, bold: true))),
                  pw.Expanded(
                      child: pw.Text('${items[i]} ____________?',
                          style: _style(9.8))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Q6 passage — {root} words become bold + underlined.
  static pw.Widget _rootPassage(String text) {
    final spans = <pw.TextSpan>[];
    var rest = text;
    while (true) {
      final i = rest.indexOf('{');
      if (i < 0) {
        if (rest.isNotEmpty) spans.add(pw.TextSpan(text: rest));
        break;
      }
      if (i > 0) spans.add(pw.TextSpan(text: rest.substring(0, i)));
      final j = rest.indexOf('}', i);
      if (j < 0) {
        spans.add(pw.TextSpan(text: rest.substring(i)));
        break;
      }
      spans.add(pw.TextSpan(
        text: rest.substring(i + 1, j),
        style: _style(10, bold: true)
            .copyWith(decoration: pw.TextDecoration.underline),
      ));
      rest = rest.substring(j + 1);
    }
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 16),
      child: pw.RichText(
        text: pw.TextSpan(style: _style(10), children: spans),
        textAlign: pw.TextAlign.justify,
      ),
    );
  }

  /// Part–B items (10–12): bold prompt, marks at right edge.
  static pw.Widget _compositionItem(String num, String text, String marks) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
              width: 22, child: pw.Text(num, style: _style(10, bold: true))),
          pw.Expanded(child: pw.Text(text, style: _style(10, bold: true))),
          pw.SizedBox(width: 8),
          pw.Text(marks, style: _style(10)),
        ],
      ),
    );
  }

  // ── document ────────────────────────────────────────────────────────────

  /// Build + open the system print/share dialog for one board set.
  static Future<void> printSet(EnglishBoardSet s, {required bool isPro}) async {
    await _loadFonts();
    final noteImg = await _bengaliLine(ebBengaliNote);
    final Uint8List bytes = await _build(s, isPro: isPro, noteImg: noteImg);
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }

  static Future<Uint8List> _build(EnglishBoardSet s,
      {required bool isPro, pw.MemoryImage? noteImg}) async {
    final doc = pw.Document();
    final w = <pw.Widget>[];

    w.add(_banner(s));
    for (final line in s.headerExtra) {
      w.add(pw.Padding(
          padding: const pw.EdgeInsets.only(top: 2),
          child: pw.Center(child: pw.Text(line, style: _style(10.5)))));
    }
    if (noteImg != null) {
      w.add(pw.Padding(
          padding: const pw.EdgeInsets.only(top: 2),
          child: pw.Center(child: pw.Image(noteImg, height: 13))));
    }

    // ── Part–A ──
    w.add(_partHeader(ebPartAHeader));

    w.add(_qHead('1.', ebInstrQ1, '1 × 10 = 10'));
    w.add(_wordBox(s.q1Box));
    w.add(pw.SizedBox(height: 2));
    w.add(_body(s.q1Passage));

    w.add(_qHead('2.', ebInstrQ2, '1 × 5 = 5'));
    w.add(_matchTable(s.q2));

    w.add(_qHead('3.', ebInstrQ3, '1 × 10 = 10'));
    w.add(_wordBox(s.q3Box));
    w.add(pw.SizedBox(height: 2));
    w.add(_body(s.q3Passage));

    w.add(_qHead('4.', ebInstrQ4, '1 × 10 = 10'));
    w.add(_transformItems(s.q4));

    w.add(_qHead('5.', ebInstrQ5, '1 × 5 = 5'));
    w.add(_tagItems(s.q5));

    w.add(_qHead('6.', ebInstrQ6, '1 × 5 = 5'));
    w.add(_rootPassage(s.q6Passage));

    w.add(_qHead('7.', ebInstrQ7, '1 × 5 = 5'));
    w.add(_body(s.q7Passage));

    w.add(_qHead('8.', ebInstrQ8, '1 × 5 = 5'));
    w.add(_body(s.q8Passage));

    w.add(_qHead('9.', ebInstrQ9, '5'));
    w.add(_body(s.q9Text));

    // ── Part–B ──
    w.add(_partHeader(ebPartBHeader));
    w.add(_compositionItem('10.', s.q10, '10'));
    w.add(_compositionItem('11.', s.q11, '10'));
    w.add(_compositionItem('12.', s.q12, '20'));

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 36),
          buildBackground: isPro
              ? null
              : (context) => pw.Center(
                    child: pw.Opacity(
                      opacity: 0.06,
                      child: pw.Transform.rotate(
                        angle: -0.55,
                        child: pw.Text('DEMO',
                            style: pw.TextStyle(
                                fontSize: 160,
                                fontWeight: pw.FontWeight.bold)),
                      ),
                    ),
                  ),
        ),
        build: (context) => w,
      ),
    );
    return doc.save();
  }
}

/// English First Paper (Board Questions 2024) → PDF / printer.
///
/// Reproduces the printed board-paper layout:
///  • dark serial banner + বিদ্র note image
///  • Part–A Reading (intro + unit tag, passages, MCQ option grid,
///    gap-fill passage, Q4 information table with caption/bold rows,
///    Q6 three-column matching with header row, story/poem/story items,
///    Bengali hints rendered via Skia images)
///  • Part–B Writing (story completion + dialogue prompts)
/// Free users get a big faint "DEMO" watermark; Pro prints clean.
class EnglishFirstPaperPdf {
  EnglishFirstPaperPdf._();

  static const _letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'];
  static const _romans = ['i.', 'ii.', 'iii.', 'iv.', 'v.', 'vi.'];
  static final _bengaliRx = RegExp(r'[\u0980-\u09FF]');

  // Reuse the second-paper loader/styles (same library).
  static pw.TextStyle _style(double size,
          {bool bold = false, bool italic = false}) =>
      EnglishBoardPdf._style(size, bold: bold, italic: italic);

  /// Render one line of text either as plain text (English) or a Skia
  /// image (Bengali). [images] maps source line → pre-rendered image+size.
  static pw.Widget _bnLine(String text,
      {double size = 9.5,
      bool bold = false,
      pw.TextAlign align = pw.TextAlign.left}) {
    if (!_bengaliRx.hasMatch(text)) {
      return pw.Text(text, style: _style(size, bold: bold), textAlign: align);
    }
    final im = _imgCache[text];
    if (im == null) {
      return pw.Text(text, style: _style(size, bold: bold), textAlign: align);
    }
    return pw.Image(im.image, width: im.width, height: im.height);
  }

  /// Multi-line block of Bengali / English mixed text.
  static pw.Widget _bnBlock(String text,
          {double size = 10,
          double indent = 16,
          pw.TextAlign align = pw.TextAlign.justify}) =>
      pw.Padding(
        padding: pw.EdgeInsets.only(left: indent),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            for (final line in text.split('\n'))
              _bnLine(line, size: size, align: align),
          ],
        ),
      );

  // ── pre-rendered Bengali images ─────────────────────────────────────────
  static final Map<String, _LineImg> _imgCache = {};

  static Future<void> _prerender(String text, {double size = 24}) async {
    if (text.isEmpty || _imgCache.containsKey(text)) return;
    try {
      final loader = FontLoader('EBLine')
        ..addFont(
            rootBundle.load('assets/fonts/NotoSerifBengali-Regular.ttf'));
      await loader.load();
      const maxPx = 1120.0; // ≈ page text width at 24 px font
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
              fontFamily: 'EBLine', fontSize: 24, color: Color(0xFF000000)),
        ),
        textDirection: ui.TextDirection.ltr,
        textScaler: const TextScaler.linear(1.0),
      )..layout(maxWidth: maxPx);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      tp.paint(canvas, Offset.zero);
      final img = await recorder
          .endRecording()
          .toImage(tp.width.ceil() + 2, tp.height.ceil() + 2);
      final bd = await img.toByteData(format: ui.ImageByteFormat.png);
      final bytes = bd?.buffer.asUint8List();
      if (bytes != null) {
        // Scale so the rendered line matches a 10 pt text line.
        const k = 10 / 24;
        _imgCache[text] = _LineImg(pw.MemoryImage(bytes),
            tp.width * k + 1, tp.height * k + 1);
      }
    } catch (_) {}
  }

  static Future<void> _prerenderSet(EnglishFirstSet s) async {
    _imgCache.clear();
    final lines = <String>{ef1BengaliNote};
    if (_bengaliRx.hasMatch(s.q3Unit)) lines.add(s.q3Unit);
    for (final it in s.q8) {
      for (final l in it.split('\n')) {
        if (_bengaliRx.hasMatch(l)) lines.add(l);
      }
    }
    for (final it in s.q9) {
      for (final l in it.split('\n')) {
        if (_bengaliRx.hasMatch(l)) lines.add(l);
      }
    }
    for (final l in lines) {
      await _prerender(l);
    }
  }

  // ── pieces ──────────────────────────────────────────────────────────────

  static pw.Widget _banner(EnglishFirstSet s) {
    return pw.Container(
      color: PdfColors.black,
      padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      child: pw.Center(
        child: pw.Text(
          '${s.serial}   ${s.board.toUpperCase()}',
          style: pw.TextStyle(
            font: EnglishBoardPdf._bold,
            fontFallback: [
              if (EnglishBoardPdf._dv != null) EnglishBoardPdf._dv!
            ],
            fontSize: 13,
            color: PdfColors.white,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }

  /// Intro line: bold instruction left, unit tag right.
  static pw.Widget _introLine(String intro, String unit) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: pw.Text(intro, style: _style(9.8, bold: true))),
        pw.SizedBox(width: 8),
        pw.Text(unit, style: _style(9.5)),
      ],
    );
  }

  /// One MCQ item: bold stem + smart option grid (4 / 2 / 1 per row).
  static pw.Widget _mcqItem(String letter, EF1McqItem item) {
    final opts = item.options;
    final longest =
        opts.fold<int>(0, (m, o) => o.length > m ? o.length : m);
    final perRow = longest <= 16 ? 4 : (longest <= 42 ? 2 : 1);
    final rows = <pw.Widget>[];
    for (var r = 0; r < opts.length; r += perRow) {
      final slice = opts.sublist(r, r + perRow > opts.length ? opts.length : r + perRow);
      rows.add(pw.Row(
        children: [
          for (var k = 0; k < slice.length; k++)
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.only(right: 6, top: 0.6),
                child: pw.Text('${_romans[r + k]}  ${slice[k]}',
                    style: _style(9.2)),
              ),
            ),
          for (var k = slice.length; k < perRow; k++) pw.Expanded(child: pw.SizedBox()),
        ],
      ));
    }
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 2.2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
              width: 22,
              child: pw.Text('($letter)', style: _style(9.8, bold: true))),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(item.stem, style: _style(9.8, bold: true)),
                pw.SizedBox(height: 0.5),
                ...rows,
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Lettered items (a)–(h) possibly with Bengali hint lines.
  static pw.Widget _letteredItems(List<String> items,
      {double size = 9.5}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 16, top: 2),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < items.length; i++)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 1.4),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                      width: 20,
                      child: pw.Text('(${_letters[i]})',
                          style: _style(size, bold: true))),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        for (final line in items[i].split('\n'))
                          _bnLine(line, size: size),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Q4 information table: 1-cell rows merge full width, 2-cell rows use
  /// [1, N-1] flex, >2 cells equal; q4BoldRows rendered bold.
  /// (Built by hand — pw.Table has no colspan support.)
  static pw.Widget _freeTable(List<List<String>> rows, Set<int> boldRows) {
    final cols = rows.fold<int>(1, (m, r) => r.length > m ? r.length : m);

    pw.Widget cell(String t,
        {bool bold = false, bool center = false, bool last = false}) {
      final tx = pw.Text(t,
          style: _style(9.3, bold: bold), textAlign: pw.TextAlign.center);
      return pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border(
            right: last
                ? pw.BorderSide.none
                : const pw.BorderSide(width: 0.9),
          ),
        ),
        padding: const pw.EdgeInsets.symmetric(vertical: 2.6, horizontal: 4),
        child: center ? pw.Center(child: tx) : tx,
      );
    }

    final rowWidgets = <pw.Widget>[];
    for (var r = 0; r < rows.length; r++) {
      final row = rows[r];
      final bold = boldRows.contains(r);
      final isLastRow = r == rows.length - 1;
      rowWidgets.add(pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border(
            bottom: isLastRow
                ? pw.BorderSide.none
                : const pw.BorderSide(width: 0.9),
          ),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            if (row.length == 1)
              pw.Expanded(
                child: cell(row[0], bold: bold, center: bold, last: true),
              )
            else if (row.length == 2) ...[
              pw.Expanded(
                flex: 1,
                child: cell(row[0], bold: bold),
              ),
              pw.Expanded(
                flex: cols > 2 ? cols - 1 : 2,
                child: cell(row[1], bold: bold, last: true),
              ),
            ] else ...[
              for (var c = 0; c < row.length; c++)
                pw.Expanded(
                  child: cell(row[c], bold: bold,
                      center: bold, last: c == row.length - 1),
                ),
            ],
          ],
        ),
      ));
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 16, top: 3),
      child: pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(width: 0.9),
        ),
        child: pw.Column(children: rowWidgets),
      ),
    );
  }

  /// Q6 three-column matching table with the header row.
  static pw.Widget _match3(EnglishFirstSet s) {
    pw.Widget cell(String t,
            {bool bold = false, bool center = false, double pad = 2.6}) =>
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(vertical: pad, horizontal: 4),
          child: center
              ? pw.Center(child: pw.Text(t, style: _style(9.5, bold: bold)))
              : pw.Text(t, style: _style(9.5, bold: bold)),
        );
    final rows = <pw.TableRow>[
      pw.TableRow(children: [
        cell("Column 'A'", bold: true, center: true),
        cell("Column 'B'", bold: true, center: true),
        cell("Column 'C'", bold: true, center: true),
      ]),
    ];
    for (var i = 0; i < s.q6A.length; i++) {
      rows.add(pw.TableRow(children: [
        cell(s.q6A[i]),
        cell('${_romans[i]}  ${s.q6B[i]}'),
        cell('${_romans[i]}  ${s.q6C[i]}'),
      ]));
    }
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 16, top: 3),
      child: pw.Table(
        border: pw.TableBorder.all(width: 0.9),
        columnWidths: const {
          0: pw.FlexColumnWidth(4.0),
          1: pw.FlexColumnWidth(3.2),
          2: pw.FlexColumnWidth(3.8),
        },
        children: rows,
      ),
    );
  }

  // ── document ────────────────────────────────────────────────────────────

  /// Build + open the system print/share dialog for one first-paper set.
  static Future<void> printSet(EnglishFirstSet s,
      {required bool isPro}) async {
    await EnglishBoardPdf._loadFonts();
    await _prerenderSet(s);
    final noteImg = _imgCache[ef1BengaliNote];
    final Uint8List bytes = await _build(s, isPro: isPro, noteImg: noteImg);
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }

  static Future<Uint8List> _build(EnglishFirstSet s,
      {required bool isPro, _LineImg? noteImg}) async {
    final doc = pw.Document();
    final w = <pw.Widget>[];

    w.add(_banner(s));
    if (noteImg != null) {
      w.add(pw.Padding(
          padding: const pw.EdgeInsets.only(top: 2),
          child:
              pw.Center(child: pw.Image(noteImg.image, height: 13))));
    }

    // ══ Part–A : Reading ══
    w.add(EnglishBoardPdf._partHeader(ef1PartA));

    w.add(_introLine(s.passage1Intro, s.passage1Unit));
    w.add(pw.SizedBox(height: 2));
    w.add(EnglishBoardPdf._body(s.passage1, size: 9.8, indent: 0));

    w.add(EnglishBoardPdf._qHead('1.', s.q1Instr, '1 × 7 = 7'));
    w.add(pw.Padding(
      padding: const pw.EdgeInsets.only(left: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < s.q1.length; i++)
            _mcqItem(_letters[i], s.q1[i]),
        ],
      ),
    ));

    w.add(EnglishBoardPdf._qHead(
        '2.', 'Answer the following questions.', '2 × 5 = 10'));
    w.add(_letteredItems(s.q2));

    w.add(EnglishBoardPdf._qHead('3.', s.q3Instr, '1 × 5 = 5'));
    w.add(EnglishBoardPdf._body(s.q3Source, size: 9.8, indent: 0));
    // unit tag / Bengali outside-note, right aligned
    if (_bengaliRx.hasMatch(s.q3Unit)) {
      final im = _imgCache[s.q3Unit];
      w.add(pw.Align(
        alignment: pw.Alignment.centerRight,
        child: im != null
            ? pw.Image(im.image, height: im.height)
            : pw.SizedBox(),
      ));
    } else {
      w.add(pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(s.q3Unit, style: _style(9.3)),
      ));
    }
    w.add(pw.SizedBox(height: 2));
    w.add(EnglishBoardPdf._body(s.q3Cloze, size: 9.8, indent: 0));

    w.add(pw.SizedBox(height: 4));
    w.add(pw.Text(s.passage2Intro, style: _style(9.8, bold: true)));
    w.add(pw.SizedBox(height: 2));
    w.add(EnglishBoardPdf._body(s.passage2, size: 9.8, indent: 0));

    w.add(EnglishBoardPdf._qHead('4.', s.q4Instr, '1 × 5 = 5'));
    w.add(_freeTable(s.q4Table, s.q4BoldRows));

    w.add(EnglishBoardPdf._qHead('5.', ef1Q5Instr, '10'));

    w.add(EnglishBoardPdf._qHead('6.', ef1Q6Instr, '1 × 5 = 5'));
    w.add(_match3(s));

    w.add(EnglishBoardPdf._qHead('7.', ef1Q7Instr, '1 × 8 = 8'));
    w.add(_letteredItems(s.q7));

    w.add(EnglishBoardPdf._qHead('8.', ef1Q8Instr, '2 × 5 = 10'));
    w.add(_letteredItems(s.q8));

    w.add(EnglishBoardPdf._qHead('9.', ef1Q9Instr, '2 × 5 = 10'));
    w.add(_letteredItems(s.q9));

    // ══ Part–B : Writing ══
    w.add(EnglishBoardPdf._partHeader(ef1PartB));
    w.add(EnglishBoardPdf._qHead('10.', s.q10Instr, '15'));
    w.add(pw.Padding(
      padding: const pw.EdgeInsets.only(left: 22, top: 2),
      child: pw.Text(s.q10Starter, style: _style(9.8)),
    ));
    w.add(EnglishBoardPdf._qHead('11.', s.q11, '15'));

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 36),
          buildBackground: isPro
              ? null
              : (context) => pw.Center(
                    child: pw.Opacity(
                      opacity: 0.06,
                      child: pw.Transform.rotate(
                        angle: -0.55,
                        child: pw.Text('DEMO',
                            style: pw.TextStyle(
                                fontSize: 160,
                                fontWeight: pw.FontWeight.bold)),
                      ),
                    ),
                  ),
        ),
        build: (context) => w,
      ),
    );
    return doc.save();
  }
}

/// A pre-rendered line image with its display size.
class _LineImg {
  final pw.MemoryImage image;
  final double width, height;
  const _LineImg(this.image, this.width, this.height);
}
