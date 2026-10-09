import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/questions_data.dart';
import '../models/paper_draft.dart';
import '../models/subject_info.dart';
import '../theme/design_tokens.dart';
import 'paper_composer.dart';
import 'paper_pdf.dart';
import 'subscription_state.dart';

class RenderedPaper {
  final List<Uint8List> pages;
  final Uint8List pdf;
  const RenderedPaper(this.pages, this.pdf);
}

class PaperExport {
  static Future<RenderedPaper> render(
    PaperDraft draft,
    ComposedPaper paper, {
    bool watermark = false,
  }) async {
    final subject = subjectById(draft.subjectId);
    if (subject == null) throw StateError('Subject not found');
    // Never let a stale or modified UI request remove the Free watermark.
    final effectiveWatermark =
        watermark || SubscriptionState.instance.shouldShowWatermark;
    final title =
        draft.title.trim().isEmpty ? 'মডেল পরীক্ষা — ২০২৭' : draft.title.trim();
    final pages = paper.english.isNotEmpty
        ? await PaperPdf.renderEnglishPages(
            paperTitle: title,
            subTitle:
                '${subject.name} • ${PaperComposer.codes[draft.subjectId] ?? ''}',
            sections: paper.english,
            setCode: draft.setCode,
          )
        : await PaperPdf.renderPages(
            title: title,
            headerLine1: title,
            subjectName: subject.bengaliName,
            subjectCode: PaperComposer.codes[draft.subjectId],
            setCode: draft.setCode,
            modeLine: draft.format == PaperFormat.board
                ? 'বোর্ড প্যাটার্ন'
                : 'অনুশীলন প্রশ্নপত্র',
            mcqs: paper.mcqs,
            cqs: paper.cqs,
            saqs: [
              for (final q in paper.saqs)
                Question(
                  id: q.id,
                  subjectId: q.subjectId,
                  chapter: q.chapter,
                  questionText: q.questionText,
                  options: const [],
                  correctIndex: 0,
                  explanation: q.answer,
                  figure: q.figure,
                ),
            ],
            literatureQuestions: paper.literature,
            bangla2WrittenQuestions: paper.written,
            literatureNote: paper.literature.isEmpty
                ? null
                : 'উপন্যাস থেকে ১টি এবং নাটক থেকে ১টি প্রশ্নের উত্তর দাও।',
            cqAnswerCount: paper.cqAnswers,
            saqAnswerCount: paper.saqAnswers,
            cqNote: paper.note,
            marks: '${paper.marks}',
            time: '${paper.minutes} মিনিট',
            mcqMarks: '${paper.mcqs.length}',
            mcqTime: '${paper.mcqs.length} মিনিট',
            writtenMarks: '${paper.marks - paper.mcqs.length}',
            writtenTime: '${paper.minutes - paper.mcqs.length} মিনিট',
            mathCqThreePart: draft.subjectId == 'general_math' ||
                draft.subjectId == 'higher_math',
          );
    final images = List<Uint8List>.of(pages);
    if (draft.answerKey) {
      if (paper.mcqs.isNotEmpty) {
        images.add(await _answerPage(title, draft, paper));
      }
      if (paper.saqs.isNotEmpty ||
          paper.cqs.any((q) => q.answerKey.trim().isNotEmpty)) {
        images.add(await _writtenAnswerPage(title, draft, paper));
      }
    }
    if (images.isEmpty) throw StateError('The paper has no printable pages.');

    // Apply the supplied Logo 2 artwork to the page pixels before exposing the
    // preview or assembling the PDF. This keeps both outputs identical and
    // avoids the old text/blank-box watermark path.
    final outputImages = effectiveWatermark
        ? await Future.wait(images.map(_watermarkPage))
        : images;
    final doc = pw.Document();
    for (final png in outputImages) {
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.Image(
            pw.MemoryImage(png),
            fit: pw.BoxFit.fill,
          ),
        ),
      );
    }
    return RenderedPaper(List.unmodifiable(outputImages), await doc.save());
  }

  static const _watermarkAsset = 'New UI 4.0/Logo 2.png';
  static Future<ui.Image>? _watermarkLogoFuture;

  static Future<ui.Image> _watermarkLogo() {
    return _watermarkLogoFuture ??= () async {
      final data = await rootBundle.load(_watermarkAsset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      codec.dispose();
      return frame.image;
    }();
  }

  static Future<Uint8List> _watermarkPage(Uint8List page) async {
    final pageCodec = await ui.instantiateImageCodec(page);
    final pageFrame = await pageCodec.getNextFrame();
    pageCodec.dispose();
    final pageImage = pageFrame.image;
    final logo = await _watermarkLogo();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final pageSize =
        Size(pageImage.width.toDouble(), pageImage.height.toDouble());
    canvas.drawImage(pageImage, Offset.zero, Paint());

    // Keep the original supplied artwork and proportions. A translucent layer
    // makes it a watermark without drawing a rectangle behind transparent
    // pixels in the PNG.
    // Keep the ownership mark unmistakable on both phone previews and A4
    // printouts. The former 34%/16% bounds made the supplied logo too small.
    final maxWidth = pageSize.width * .58;
    final maxHeight = pageSize.height * .28;
    final aspect = logo.width / logo.height;
    var width = maxWidth;
    var height = width / aspect;
    if (height > maxHeight) {
      height = maxHeight;
      width = height * aspect;
    }
    final destination = Rect.fromCenter(
      center: Offset(pageSize.width / 2, pageSize.height / 2),
      width: width,
      height: height,
    );
    canvas.saveLayer(
      destination,
      Paint()..color = Colors.white.withAlpha(48),
    );
    canvas.drawImageRect(
      logo,
      Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
      destination,
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.restore();

    // The supplied Logo 2 remains the artwork source; the brand name is
    // drawn separately so the watermark is readable even when the logo's
    // transparent text is subtle on a white page.
    final brand = TextPainter(
      text: TextSpan(
        text: "TUTOR'S DESK",
        style: TextStyle(
          color: Colors.black.withAlpha(132),
          fontFamily: AppTypography.uiFont,
          fontSize: (pageSize.width * .034).clamp(38.0, 68.0),
          fontWeight: FontWeight.w900,
          letterSpacing: 3.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: pageSize.width * .82);
    brand.paint(
      canvas,
      Offset(
        (pageSize.width - brand.width) / 2,
        destination.bottom + pageSize.height * .008,
      ),
    );
    brand.dispose();

    final picture = recorder.endRecording();
    final output = await picture.toImage(pageImage.width, pageImage.height);
    final bytes = await output.toByteData(format: ui.ImageByteFormat.png);
    pageImage.dispose();
    output.dispose();
    picture.dispose();
    if (bytes == null)
      throw StateError('Could not render the paper watermark.');
    return bytes.buffer.asUint8List();
  }

  static Future<Uint8List> _writtenAnswerPage(
    String title,
    PaperDraft draft,
    ComposedPaper paper,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawColor(Colors.white, BlendMode.src);
    void text(String value, double x, double y, double size,
        {bool bold = false}) {
      final painter = TextPainter(
        text: TextSpan(
          text: value,
          style: TextStyle(
            color: Colors.black,
            fontFamily: AppTypography.uiFont,
            fontSize: size,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 680);
      painter.paint(canvas, Offset(x, y));
      painter.dispose();
    }

    text(title, 110, 90, 42, bold: true);
    text('Written answer key • উত্তরমালা • সেট ${draft.setCode}', 110, 160, 30,
        bold: true);
    var y = 250.0;
    var column = 0;
    void line(String value, {bool bold = false}) {
      if (y > 2140) {
        column++;
        y = 250;
      }
      text(value, 110 + column * 720.0, y, 25, bold: bold);
      y += 52;
    }

    for (var i = 0; i < paper.saqs.length; i++) {
      final q = paper.saqs[i];
      final isDraft = q.answerKey.trim().isNotEmpty;
      final key = isDraft ? q.answerKey.trim() : q.answer;
      line('SQ ${i + 1}', bold: true);
      if (isDraft)
        line('AI draft • review: $key');
      else
        line(key);
      y += 10;
    }
    for (var i = 0; i < paper.cqs.length; i++) {
      final key = paper.cqs[i].answerKey.trim();
      if (key.isEmpty) continue;
      line('CQ ${i + 1}', bold: true);
      line('AI draft • review: $key');
      y += 10;
    }
    final picture = recorder.endRecording();
    final image = await picture.toImage(1654, 2339);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();
    if (bytes == null)
      throw StateError('Could not render the written answer key.');
    return bytes.buffer.asUint8List();
  }

  static Future<Uint8List> _answerPage(
    String title,
    PaperDraft draft,
    ComposedPaper paper,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawColor(Colors.white, BlendMode.src);
    void text(String value, double x, double y, double size) {
      final painter = TextPainter(
        text: TextSpan(
          text: value,
          style: TextStyle(
            color: Colors.black,
            fontFamily: AppTypography.uiFont,
            fontSize: size,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 1400);
      painter.paint(canvas, Offset(x, y));
      painter.dispose();
    }

    text(title, 110, 90, 42);
    text('Answer Key • উত্তরমালা • সেট ${draft.setCode}', 110, 160, 34);
    const letters = ['ক', 'খ', 'গ', 'ঘ'];
    for (var i = 0; i < paper.mcqs.length; i++) {
      text(
        '${i + 1}.  ${letters[paper.mcqs[i].correctIndex]}',
        110 + (i ~/ 25) * 360.0,
        250 + (i % 25) * 72.0,
        32,
      );
    }
    final picture = recorder.endRecording();
    final image = await picture.toImage(1654, 2339);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();
    if (bytes == null) throw StateError('Could not render the answer key.');
    return bytes.buffer.asUint8List();
  }
}
