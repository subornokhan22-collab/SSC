import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/questions_data.dart';
import '../models/paper_draft.dart';
import '../models/subject_info.dart';
import '../theme/design_tokens.dart';
import 'paper_composer.dart';
import 'paper_pdf.dart';

class RenderedPaper {
  final List<Uint8List> pages;
  final Uint8List pdf;
  const RenderedPaper(this.pages, this.pdf);
}

class PaperExport {
  static Future<RenderedPaper> render(PaperDraft draft, ComposedPaper paper) async {
    final subject = subjectById(draft.subjectId);
    if (subject == null) throw StateError('Subject not found');
    final title = draft.title.trim().isEmpty ? 'মডেল পরীক্ষা — ২০২৭' : draft.title.trim();
    final pages = paper.english.isNotEmpty
      ? await PaperPdf.renderEnglishPages(paperTitle:title,
          subTitle:'${subject.name} • ${PaperComposer.codes[draft.subjectId] ?? ''}',
          sections:paper.english, setCode:draft.setCode)
      : await PaperPdf.renderPages(title:title, headerLine1:title,
          subjectName:subject.bengaliName, subjectCode:PaperComposer.codes[draft.subjectId],
          setCode:draft.setCode, modeLine:draft.format == PaperFormat.board ? 'বোর্ড প্যাটার্ন' : 'অনুশীলন প্রশ্নপত্র',
          mcqs:paper.mcqs, cqs:paper.cqs, saqs:[for(final q in paper.saqs) Question(
            id:q.id, subjectId:q.subjectId, chapter:q.chapter, questionText:q.questionText,
            options:const [], correctIndex:0, explanation:q.answer, figure:q.figure)],
          literatureQuestions:paper.literature, bangla2WrittenQuestions:paper.written,
          literatureNote:paper.literature.isEmpty ? null : 'উপন্যাস থেকে ১টি এবং নাটক থেকে ১টি প্রশ্নের উত্তর দাও।',
          cqAnswerCount:paper.cqAnswers, saqAnswerCount:paper.saqAnswers,
          cqNote:paper.note, marks:'${paper.marks}', time:'${paper.minutes} মিনিট',
          mcqMarks:'${paper.mcqs.length}', mcqTime:'${paper.mcqs.length} মিনিট',
          writtenMarks:'${paper.marks - paper.mcqs.length}',
          writtenTime:'${paper.minutes - paper.mcqs.length} মিনিট',
          mathCqThreePart:draft.subjectId == 'general_math' || draft.subjectId == 'higher_math');
    final images = List<Uint8List>.of(pages);
    if (draft.answerKey && paper.mcqs.isNotEmpty) images.add(await _answerPage(title, draft, paper));
    if (images.isEmpty) throw StateError('The paper has no printable pages.');
    final doc = pw.Document();
    for(final png in images) {
      doc.addPage(pw.Page(pageFormat:PdfPageFormat.a4, margin:pw.EdgeInsets.zero,
        build:(_) => pw.Image(pw.MemoryImage(png), width:PdfPageFormat.a4.width,
          height:PdfPageFormat.a4.height, fit:pw.BoxFit.fill)));
    }
    return RenderedPaper(List.unmodifiable(images), await doc.save());
  }

  static Future<Uint8List> _answerPage(String title, PaperDraft draft, ComposedPaper paper) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawColor(Colors.white, BlendMode.src);
    void text(String value, double x, double y, double size) {
      final painter = TextPainter(text:TextSpan(text:value, style:TextStyle(
        color:Colors.black, fontFamily:AppTypography.uiFont, fontSize:size)), textDirection:TextDirection.ltr)
        ..layout(maxWidth:1400);
      painter.paint(canvas, Offset(x,y));
      painter.dispose();
    }
    text(title,110,90,42);
    text('Answer Key • উত্তরমালা • সেট ${draft.setCode}',110,160,34);
    const letters = ['ক','খ','গ','ঘ'];
    for(var i=0;i<paper.mcqs.length;i++) {
      text('${i+1}.  ${letters[paper.mcqs[i].correctIndex]}',110+(i~/25)*360.0,250+(i%25)*72.0,32);
    }
    final picture=recorder.endRecording();
    final image=await picture.toImage(1654,2339);
    final bytes=await image.toByteData(format:ui.ImageByteFormat.png);
    image.dispose(); picture.dispose();
    if(bytes==null) throw StateError('Could not render the answer key.');
    return bytes.buffer.asUint8List();
  }
}
