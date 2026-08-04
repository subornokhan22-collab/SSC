// ─────────────────────────────────────────────────────────────────────────
// OPTIONAL — প্রিন্ট/PDF এক্সপোর্ট। এটি চালু করতে ৩টি ধাপ লাগবে:
//
// ১) pubspec.yaml এ যোগ করো (টার্মিনালে):  flutter pub add pdf printing
//    অথবা হাতে dependencies এ লেখো:
//        pdf: ^3.11.0
//        printing: ^5.13.0
//
// ২) বাংলা ফন্ট: https://fonts.google.com/noto/specimen/Noto+Sans+Bengali
//    থেকে NotoSansBengali-Regular.ttf ডাউনলোড করে রাখো:
//        assets/fonts/NotoSansBengali-Regular.ttf
//    এবং pubspec.yaml এ:
//        flutter:
//          assets:
//            - assets/icon/
//            - assets/fonts/
//
// ৩) question_paper_screen.dart এর _onPrintTap() এ (Pro ইউজারের জন্য)
//    এই ডায়ালগের জায়গায় নিচের কলটি বসাও:
//        await PaperPdf.printPaper(
//          title: 'মডেল টেস্ট — ${_subject!.name}',
//          modeLine: _mode == 'chapter' ? (_chapter ?? '') : 'ফুল মডেল টেস্ট',
//          mcqs: _mcqs, cqs: _cqs,
//        );
//
// এই ফাইলটি প্যাকেজ যোগ করার আগে পর্যন্ত project এ রাখো না
// (pdf/printing ইমপোর্ট থাকলে pubspec আপডেট ছাড়া বিল্ড হবে না)।
// ─────────────────────────────────────────────────────────────────────────

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/questions_data.dart';

class PaperPdf {
  static const _optionLetters = ['ক', 'খ', 'গ', 'ঘ'];

  static Future<void> printPaper({
    required String title,
    required String modeLine,
    required List<Question> mcqs,
    required List<CreativeQuestion> cqs,
    String headerLine1 = 'মডেল টেস্ট পেপার — SSC 2027',
    String headerLine2 = '(বাংলাদেশ শিক্ষাবোর্ড প্রশ্ন-কাঠামো অনুপ্রাণিত)',
    String time = '৩ ঘণ্টা',
    String marks = '১০০',
    int cqAnswerCount = 7,
  }) async {
    final font = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSansBengali-Regular.ttf'),
    );
    pw.TextStyle base(double size, {bool bold = false}) => pw.TextStyle(
          font: font,
          fontSize: size,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
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
              pw.Text(headerLine1, style: base(16, bold: true)),
              pw.SizedBox(height: 2),
              pw.Text(headerLine2, style: base(10)),
              pw.SizedBox(height: 4),
              pw.Text('বিষয়: $title  ${modeLine.isNotEmpty ? '•  $modeLine' : ''}',
                  style: base(11)),
            ]),
          ),
          pw.SizedBox(height: 8),
          pw.Divider(thickness: 1.2),
          pw.SizedBox(height: 2),
          pw.Divider(thickness: 1.2),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('সময়: $time', style: base(10)),
              pw.Text('পূর্ণমান: $marks', style: base(10)),
            ],
          ),
          if (mcqs.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Center(child: pw.Text('বিভাগ — ক\nবহুনির্বাচনি প্রশ্ন (MCQ)',
                textAlign: pw.TextAlign.center, style: base(12, bold: true))),
            pw.SizedBox(height: 6),
            ...List.generate(mcqs.length, (i) {
              final q = mcqs[i];
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('${_bn(i + 1)}। ${q.questionText}', style: base(11)),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 16, top: 2),
                      child: pw.Text(
                        List.generate(q.options.length,
                                (o) => '${_optionLetters[o]}) ${q.options[o]}')
                            .join('     '),
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
            pw.Center(child: pw.Text('বিভাগ — খ\nসৃজনশীল প্রশ্ন',
                textAlign: pw.TextAlign.center, style: base(12, bold: true))),
            pw.Center(
                child: pw.Text(
                    '(যেকোনো ${_bn(cqAnswerCount)}টি প্রশ্নের উত্তর দাও। প্রতিটি প্রশ্নের মান ১০)',
                    style: base(9.5))),
            pw.SizedBox(height: 6),
            ...List.generate(cqs.length, (i) {
              final cq = cqs[i];
              String part(String l, String t, int m) => '$l) $t — ${_bn(m)}';
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 9),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('${_bn(i + 1)}। ${cq.stem}', style: base(11)),
                    for (final line in [
                      part('ক', cq.questionK, cq.marks.isNotEmpty ? cq.marks[0] : 1),
                      part('খ', cq.questionKh, cq.marks.length > 1 ? cq.marks[1] : 2),
                      part('গ', cq.questionG, cq.marks.length > 2 ? cq.marks[2] : 3),
                      part('ঘ', cq.questionGh, cq.marks.length > 3 ? cq.marks[3] : 4),
                    ])
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 16, top: 1.5),
                        child: pw.Text(line, style: base(10.5)),
                      ),
                  ],
                ),
              );
            }),
          ],
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

