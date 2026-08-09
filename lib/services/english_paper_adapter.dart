import '../data/english_board_data.dart';
import '../data/english_first_data.dart';
import '../data/questions_data.dart';
import 'paper_pdf.dart';

/// English board-set → "সাধারণ পেপার" সেকশন।
///
/// প্রশ্নের লেখা একটুও বদলায় না — শুধু প্রিন্ট/প্রিভিউ অন্য সব বিষয়ের
/// মতো একই (PaperPdf) পাইপলাইনে যায়, যাতে সব ফোনে কাজ করে।
class EnglishPaperAdapter {
  EnglishPaperAdapter._();

  static const _ltr = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

  // ═══════════ English Second Paper (Grammar 60 + Composition 40) ═══════════
  static List<EnglishSection> second(EnglishBoardSet s) {
    String strip(String t) => t.replaceAll('{', '').replaceAll('}', '');
    return [
      const EnglishSection(ebPartAHeader, []),
      const EnglishSection(ebBengaliNote, []),
      EnglishSection('1. $ebInstrQ1   —   [1 × 10 = 10]', [
        s.q1Box.join('      '),
        '',
        s.q1Passage,
      ]),
      EnglishSection('2. $ebInstrQ2   —   [1 × 5 = 5]',
          s.q2.isEmpty ? const ['(Table data missing in this set)'] : const [],
          table:
              s.q2.isEmpty ? null : [for (final r in s.q2) [r.a, r.b, r.c]]),
      EnglishSection('3. $ebInstrQ3   —   [1 × 10 = 10]', [
        s.q3Box.join('      '),
        '',
        s.q3Passage,
      ]),
      EnglishSection('4. $ebInstrQ4   —   [1 × 10 = 10]', [
        for (var i = 0; i < s.q4.length; i++)
          '${i + 1}. ${s.q4[i].sentence}   (${s.q4[i].direction})',
      ]),
      EnglishSection('5. $ebInstrQ5   —   [1 × 5 = 5]', [...s.q5]),
      EnglishSection('6. $ebInstrQ6   —   [1 × 5 = 5]', [strip(s.q6Passage)]),
      EnglishSection('7. $ebInstrQ7   —   [1 × 5 = 5]', [s.q7Passage]),
      EnglishSection('8. $ebInstrQ8   —   [1 × 5 = 5]', [s.q8Passage]),
      EnglishSection('9. $ebInstrQ9   —   [5]', [s.q9Text]),
      const EnglishSection(ebPartBHeader, []),
      EnglishSection('10.   —   [10]', [s.q10]),
      EnglishSection('11.   —   [10]', [s.q11]),
      EnglishSection('12.   —   [20]', [s.q12]),
    ];
  }

  // ═══════════ English First Paper (Reading 70 + Writing 30) ═══════════
  static List<EnglishSection> first(EnglishFirstSet s) {
    final q6Empty = s.q6A.isEmpty && s.q6B.isEmpty && s.q6C.isEmpty;
    return [
      const EnglishSection('Part–A : Reading [70 Marks]', []),
      const EnglishSection(ef1BengaliNote, []),
      EnglishSection('1. ${s.q1Instr}   —   [1 × 7 = 7]', [
        s.passage1Intro,
        s.passage1Unit,
        '',
        s.passage1,
        '',
        for (var i = 0; i < s.q1.length; i++) ...[
          '${_ltr[i]}) ${s.q1[i].stem}',
          '    ${s.q1[i].options.join('        ')}',
        ],
      ]),
      EnglishSection('2. Answer the following questions.   —   [2 × 5 = 10]', [
        for (var i = 0; i < s.q2.length; i++) '${_ltr[i]}) ${s.q2[i]}',
      ]),
      EnglishSection('3. ${s.q3Instr}   —   [1 × 5 = 5]', [
        if (s.q3Source.trim().isNotEmpty) s.q3Source,
        if (s.q3Unit.trim().isNotEmpty) s.q3Unit,
        s.q3Cloze,
      ]),
      EnglishSection(s.passage2Intro, [s.passage2]),
      EnglishSection('4. ${s.q4Instr}   —   [1 × 5 = 5]',
          s.q4Table.isEmpty
              ? const ['(Table data missing in this set)']
              : const [],
          table: s.q4Table.isEmpty ? null : s.q4Table),
      const EnglishSection('5. $ef1Q5Instr   —   [10]', [' ']),
      EnglishSection('6. $ef1Q6Instr   —   [1 × 5 = 5]',
          q6Empty ? const ['(Table data missing in this set)'] : const [],
          table: q6Empty ? null : _matchTable(s.q6A, s.q6B, s.q6C)),
      EnglishSection('7. $ef1Q7Instr   —   [1 × 8 = 8]', [
        for (var i = 0; i < s.q7.length; i++) '${_ltr[i]}) ${s.q7[i]}',
      ]),
      EnglishSection('8. $ef1Q8Instr   —   [2 × 5 = 10]', [...s.q8]),
      EnglishSection('9. $ef1Q9Instr   —   [2 × 5 = 10]', [...s.q9]),
      const EnglishSection('Part–B : Writing [30 Marks]', []),
      EnglishSection('10. ${s.q10Instr}   —   [15]', [s.q10Starter]),
      EnglishSection('11. ${s.q11}   —   [15]', [' ']),
    ];
  }

  /// তিন কলামের ম্যাচিং-টেবিল (হেডার A | B | C)।
  static List<List<String>> _matchTable(
      List<String> a, List<String> b, List<String> c) {
    var n = a.length;
    if (b.length > n) n = b.length;
    if (c.length > n) n = c.length;
    String cell(List<String> col, int i) => i < col.length ? col[i] : '';
    return [
      const ['A', 'B', 'C'],
      for (var i = 0; i < n; i++) [cell(a, i), cell(b, i), cell(c, i)],
    ];
  }

  // ═══════════ 🤖 AI Extra Practice (শুধু AI-mix ON হলে) ═══════════
  static EnglishSection aiSection(List<Question> mcqs,
      {String head =
          'AI Extra Practice — fresh AI questions  (উত্তরো পেতে উত্তরমালা দেখুন)'}) {
    final lines = <String>[];
    for (var i = 0; i < mcqs.length; i++) {
      final q = mcqs[i];
      lines.add('${i + 1}. ${q.questionText}');
      for (var o = 0; o < q.options.length; o++) {
        lines.add('    ${_ltr[o]}) ${q.options[o]}');
      }
      lines.add('');
    }
    return EnglishSection(head, lines);
  }
}
