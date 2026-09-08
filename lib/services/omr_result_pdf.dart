import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'omr_scanner.dart';

/// Builds the printable result sheet after marking OMR answer sheets.
///
/// Vector PDF (unlike the paper pages, which are raster): one page with the
/// class score table, then the wrong/blank answers per student.
class OmrResultPdf {
  OmrResultPdf._();

  static const _optionLetters = ['ক', 'খ', 'গ', 'ঘ'];

  static Future<Uint8List> build({
    required String title,
    required String subject,
    required List<OmrGradeSheet> sheets,
  }) async {
    final regular = await _font('assets/fonts/NotoSerifBengali-Regular.ttf');
    final bold = await _font('assets/fonts/NotoSerifBengali-Bold.ttf');

    TextStyle ts(double size,
            {bool boldText = false,
            PdfColor color = const PdfColor.fromInt(0xFF16203A)}) =>
        pw.TextStyle(
          fontSize: size,
          color: color,
          // pdf 3.x has no fontFamily lookup — attach the custom fonts
          // directly (regular + bold variants).
          font: boldText ? bold : regular,
          fontNormal: regular,
          fontBold: bold,
          fontItalic: regular,
          fontBoldItalic: bold,
          fontWeight: boldText ? pw.FontWeight.bold : pw.FontWeight.normal,
        );

    pw.Widget cell(String text, {bool boldText = false, bool center = false}) =>
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: pw.Text(
            text,
            textAlign: center ? pw.TextAlign.center : pw.TextAlign.start,
            style: ts(9.5, boldText: boldText),
          ),
        );

    String set(int? code) => code == null ? '—' : _optionLetters[code];
    String two(int n) => n < 10 ? '0$n' : '$n';
    final now = DateTime.now();
    final date =
        '${now.year}-${two(now.month)}-${two(now.day)} ${two(now.hour)}:${two(now.minute)}';

    final ordered = [...sheets]..sort((a, b) => a.roll.compareTo(b.roll));

    final totalScore = ordered.fold<int>(0, (s, e) => s + e.score);
    final avg =
        sheets.isEmpty ? '0' : (totalScore / sheets.length).toStringAsFixed(1);

    final pages = <pw.Widget>[
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('OMR ফলাফল — ${title.isEmpty ? 'Question Paper' : title}',
              style: ts(15, boldText: true)),
          if (subject.isNotEmpty)
            pw.Text(subject, style: ts(11, color: const PdfColor.fromInt(0xFF55607A))),
          pw.Text(
            'তারিখ: $date • শীট: ${sheets.length} • মোট প্রশ্ন: ${sheets.isEmpty ? 0 : sheets.first.total} • গড় স্কোর: $avg',
            style: ts(10, color: const PdfColor.fromInt(0xFF55607A)),
          ),
          const pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: const PdfColor.fromInt(0xFF9AA4BC), width: 0.6),
            headerAlignment: pw.Alignment.center,
            children: [
              pw.TableRow(children: [
                cell('রোল নম্বর', boldText: true, center: true),
                cell('রেজিস্ট্রেশন নম্বর', boldText: true, center: true),
                cell('সেট', boldText: true, center: true),
                cell('সঠিক', boldText: true, center: true),
                cell('ভুল', boldText: true, center: true),
                cell('খালি', boldText: true, center: true),
                cell('স্কোর', boldText: true, center: true),
              ]),
              for (final s in ordered)
                pw.TableRow(children: [
                  cell(s.roll),
                  cell(s.registration),
                  cell(set(s.setCode), center: true),
                  cell('${s.correctCount}', center: true),
                  cell('${s.wrongCount}', center: true),
                  cell('${s.blankCount}', center: true),
                  cell('${s.score}/${s.total}', boldText: true, center: true),
                ]),
            ],
          ),
        ],
      ),
    ];

    // Wrong / blank detail, one compact block per student, chunked per page.
    final lines = <pw.Widget>[];
    for (final s in ordered) {
      if (s.wrongCount == 0 && s.blankCount == 0) continue;
      lines.add(pw.SizedBox(height: 6));
      lines.add(pw.Text(
        'রোল ${s.roll}${s.registration.isNotEmpty ? '  (${s.registration})' : ''} — ভুল ${s.wrongCount}, খালি ${s.blankCount}',
        style: ts(10, boldText: true),
      ));
      for (var i = 0; i < s.key.length; i++) {
        final st = s.statusOf(i);
        if (st == 0) continue;
        final mine = i < s.answers.length && s.answers[i] >= 0
            ? _optionLetters[s.answers[i]]
            : '—';
        final correct = _optionLetters[s.key[i]];
        lines.add(pw.Text(
          st == 2
              ? '  প্রশ্ন ${i + 1}: খালি (সঠিক: $correct)'
              : '  প্রশ্ন ${i + 1}: ছাত্রের উত্তর $mine → সঠিক $correct',
          style: ts(9, color: st == 2 ? const PdfColor.fromInt(0xFFB36A00) : const PdfColor.fromInt(0xFFC0392B)),
        ));
      }
    }
    const perPage = 42;
    for (var i = 0; i < lines.length; i += perPage) {
      final chunk = lines.sublist(i, math_min(i + perPage, lines.length));
      pages.add(pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('ভুল ও খালি উত্তর', style: ts(13, boldText: true)),
          ...chunk,
        ],
      ));
    }
    if (lines.isEmpty) {
      pages.add(pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('ভুল ও খালি উত্তর', style: ts(13, boldText: true)),
          const pw.SizedBox(height: 6),
          pw.Text('সব শীটের সব উত্তর সঠিক — কোনো ভুল বা খালি নেই।',
              style: ts(10)),
        ],
      ));
    }

    final doc = pw.Document();
    for (final body in pages) {
      doc.addPage(
        pw.Page(
          pageFormat: pw.PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(34),
          build: (_) => body,
        ),
      );
    }
    return doc.save();
  }

  static int math_min(int a, int b) => a < b ? a : b;

  static Future<pw.Font> _font(String asset) async {
    // pdf 3.x: Font.ttf takes the raw ByteData from the asset bundle.
    final data = await rootBundle.load(asset);
    return pw.Font.ttf(data);
  }
}
