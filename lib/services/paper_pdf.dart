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
          pw.Center(
            child: pw.Column(children: [
              pw.Text(_safe(headerLine1), style: base(16, isBold: true)),
              pw.SizedBox(height: 2),
              pw.Text(_safe(headerLine2), style: base(10)),
              pw.SizedBox(height: 4),
              pw.Text(
                _safe('বিষয়: $title${modeLine.isNotEmpty ? '  -  $modeLine' : ''}'),
                style: base(11),
              ),
            ]),
          ),
          pw.SizedBox(height: 8),
          pw.Divider(thickness: 1.2),
          pw.SizedBox(height: 2),
          pw.Divider(thickness: 1.2),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(_safe('সময়: $time'), style: base(10)),
              pw.Text(_safe('পূর্ণমান: $marks'), style: base(10)),
            ],
          ),
          if (mcqs.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                _safe('বিভাগ - ক\nবহুনির্বাচনি প্রশ্ন (MCQ)'),
                textAlign: pw.TextAlign.center,
                style: base(12, isBold: true),
              ),
            ),
            pw.SizedBox(height: 6),
            ...List.generate(mcqs.length, (i) {
              final q = mcqs[i];
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(_safe('${_bn(i + 1)}। ${q.questionText}'),
                        style: base(11)),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 16, top: 2),
                      child: pw.Text(
                        _safe(List.generate(q.options.length,
                                (o) => '${_optionLetters[o]}) ${q.options[o]}')
                            .join('     ')),
                        style: base(10.5),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (cqs.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 1.2),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                _safe('বিভাগ - খ\nসৃজনশীল প্রশ্ন'),
                textAlign: pw.TextAlign.center,
                style: base(12, isBold: true),
              ),
            ),
            pw.Center(
              child: pw.Text(
                _safe('(যেকোনো ${_bn(cqAnswerCount)}টি প্রশ্নের উত্তর দাও। প্রতিটি প্রশ্নের মান ১০)'),
                style: base(9.5),
              ),
            ),
            pw.SizedBox(height: 6),
            ...List.generate(cqs.length, (i) {
              final cq = cqs[i];
              String part(String l, String t, int m) =>
                  '$l) $t - ${_bn(m)}';
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 9),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(_safe('${_bn(i + 1)}। ${cq.stem}'),
                        style: base(11)),
                    for (final line in [
                      part('ক', cq.questionK,
                          cq.marks.isNotEmpty ? cq.marks[0] : 1),
                      part('খ', cq.questionKh,
                          cq.marks.length > 1 ? cq.marks[1] : 2),
                      part('গ', cq.questionG,
                          cq.marks.length > 2 ? cq.marks[2] : 3),
                      part('ঘ', cq.questionGh,
                          cq.marks.length > 3 ? cq.marks[3] : 4),
                    ])
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 16, top: 1.5),
                        child: pw.Text(_safe(line), style: base(10.5)),
                      ),
                  ],
                ),
              );
            }),
          ],
          pw.SizedBox(height: 12),
          pw.Divider(thickness: 1.2),
          pw.SizedBox(height: 2),
          pw.Divider(thickness: 1.2),
          pw.Center(child: pw.Text(_safe('- শেষ -'), style: base(10))),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  static String _bn(int n) {
    const d = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return n.toString().split('').map((c) {
      final code = c.codeUnitAt(0);
      return (code >= 48 && code <= 57) ? d[code - 48] : c;
    }).join();
  }
}
