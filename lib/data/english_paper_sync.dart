import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_config.dart';
import '../services/english_paper_adapter.dart';
import '../services/paper_pdf.dart';
import 'english_first_data.dart';
import 'english_board_data.dart';

/// Structured board sets are deliberately separate from MCQ/SAQ/CQ sync.
class EnglishPaperDocument {
  final String id;
  final String paperType;
  final String board;
  final int year;
  final EnglishFirstSet? first;
  final EnglishBoardSet? second;
  final Map<String, String?> answers;
  const EnglishPaperDocument(
      {required this.id,
      required this.paperType,
      required this.board,
      required this.year,
      this.first,
      this.second,
      required this.answers});
  String get label =>
      '$board $year • English ${paperType == 'first' ? '1st' : '2nd'}';
  List<EnglishSection> get sections => first != null
      ? EnglishPaperAdapter.first(first!)
      : EnglishPaperAdapter.second(second!);

  factory EnglishPaperDocument.fromJson(Map<String, dynamic> row) {
    final d = Map<String, dynamic>.from(row['data'] as Map);
    final type = row['paper_type'];
    if (d['schema_version'] != 1 || !['first', 'second'].contains(type))
      throw const FormatException('Unsupported English schema');
    final id = row['id'] as String,
        board = row['board'] as String,
        year = row['year'] as int;
    if (id.isEmpty || board.trim().isEmpty || year < 2000 || year > 2100)
      throw const FormatException('Invalid English metadata');
    if (row['subject'] != (type == 'first' ? 'english_1st' : 'english_2nd'))
      throw const FormatException('English subject mismatch');
    String text(String key, {bool optional = false}) {
      final v = d[key];
      if (optional && v == null) return '';
      if (v is! String || !optional && v.trim().isEmpty)
        throw FormatException('Missing English field: $key');
      return v;
    }

    List<String> lines(String key, {bool optional = false}) {
      final v = d[key];
      if (optional && v == null) return [];
      if (v is! List ||
          !optional && v.isEmpty ||
          v.any((x) => x is! String || !optional && x.trim().isEmpty))
        throw FormatException('Invalid English list: $key');
      return List<String>.from(v);
    }

    List<Map<String, dynamic>> objects(String key) {
      final v = d[key];
      if (v is! List || v.isEmpty)
        throw FormatException('Missing English array: $key');
      return v.map((x) => Map<String, dynamic>.from(x as Map)).toList();
    }

    final answers = <String, String?>{};
    final raw = d['answers'];
    if (raw is! Map) throw const FormatException('Missing answer provenance');
    for (var i = 1; i <= (type == 'first' ? 11 : 12); i++) {
      final value = raw['q$i'];
      if (value != null && value is! String)
        throw const FormatException('Invalid source answer');
      answers['q$i'] = value as String?;
    }
    final heading = '$board Board–$year';
    if (type == 'first') {
      final q1 = [
        for (final q in objects('q1'))
          EF1McqItem(
              q['stem'] as String, List<String>.from(q['options'] as List))
      ];
      if (q1.length != 7 ||
          q1.any((q) =>
              q.stem.trim().isEmpty ||
              q.options.length != 4 ||
              q.options.any((s) => s.trim().isEmpty)))
        throw const FormatException('Reading MCQ structure');
      final q2 = lines('q2'), q7 = lines('q7');
      if (q2.length != 5 || q7.length != 8)
        throw const FormatException('First paper item counts');
      final table = (d['q4Table'] as List)
          .map((r) => List<String>.from(r as List))
          .toList();
      if (table.isEmpty ||
          table.first.isEmpty ||
          table.any((r) => r.length != table.first.length) ||
          !table.expand((r) => r).any((s) => s.trim().isNotEmpty))
        throw const FormatException('Invalid information table');
      final bold = Set<int>.from(d['q4BoldRows'] as List? ?? []);
      if (bold.any((i) => i < 0 || i >= table.length))
        throw const FormatException('Invalid table row');
      return EnglishPaperDocument(
          id: id,
          paperType: type,
          board: board,
          year: year,
          answers: Map.unmodifiable(answers),
          first: EnglishFirstSet(
              serial: 0,
              board: heading,
              passage1Intro: text('passage1Intro'),
              passage1Unit: text('passage1Unit', optional: true),
              passage1: text('passage1'),
              q1Instr: text('q1Instr'),
              q1: q1,
              q2: q2,
              q3Instr: text('q3Instr'),
              q3Source: text('q3Source', optional: true),
              q3Unit: text('q3Unit', optional: true),
              q3Cloze: text('q3Cloze'),
              passage2Intro: text('passage2Intro'),
              passage2: text('passage2'),
              q4Instr: text('q4Instr'),
              q4Table: table,
              q4BoldRows: bold,
              q6A: lines('q6A'),
              q6B: lines('q6B'),
              q6C: lines('q6C'),
              q7: q7,
              q8: lines('q8'),
              q9: lines('q9'),
              q10Instr: text('q10Instr'),
              q10Starter: text('q10Starter'),
              q11: text('q11')));
    }
    final matching = [
      for (final r in objects('q2'))
        EBMatchRow(r['a'] as String, r['b'] as String, r['c'] as String)
    ];
    final transformations = [
      for (final r in objects('q4'))
        EBTransformItem(r['sentence'] as String, r['direction'] as String)
    ];
    final tags = lines('q5');
    if (transformations.length != 10 ||
        tags.length != 5 ||
        transformations.any(
            (q) => q.sentence.trim().isEmpty || q.direction.trim().isEmpty))
      throw const FormatException('Grammar item counts');
    return EnglishPaperDocument(
        id: id,
        paperType: type,
        board: board,
        year: year,
        answers: Map.unmodifiable(answers),
        second: EnglishBoardSet(
            serial: 0,
            board: heading,
            headerExtra: lines('headerExtra', optional: true),
            q1Box: lines('q1Box'),
            q1Passage: text('q1Passage'),
            q2: matching,
            q3Box: lines('q3Box'),
            q3Passage: text('q3Passage'),
            q4: transformations,
            q5: tags,
            q6Passage: text('q6Passage'),
            q7Passage: text('q7Passage'),
            q8Passage: text('q8Passage'),
            q9Text: text('q9Text'),
            q10: text('q10'),
            q11: text('q11'),
            q12: text('q12')));
  }
}

class EnglishPaperSync {
  static const cacheKey = 'english_papers_v1';
  static List<EnglishPaperDocument> _papers = [];
  static List<EnglishPaperDocument> get papers => List.unmodifiable(_papers);
  static bool _busy = false;
  static void replaceRows(List rows) {
    final next = <EnglishPaperDocument>[];
    for (final r in rows) {
      try {
        if (r['is_active'] == false || r['review_status'] != 'published')
          continue;
        next.add(
            EnglishPaperDocument.fromJson(Map<String, dynamic>.from(r as Map)));
      } catch (e) {
        debugPrint('English sync skipped invalid paper: $e');
      }
    }
    _papers = next;
  }

  static Future<void> loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(cacheKey);
      if (raw != null) replaceRows(jsonDecode(raw) as List);
    } catch (e) {
      debugPrint('English cache unavailable: $e');
    }
  }

  static Future<void> refresh() async {
    if (_busy || !SupabaseConfig.isConfigured) return;
    _busy = true;
    try {
      final rows = <dynamic>[];
      for (var start = 0;; start += 500) {
        final page = await Supabase.instance.client
            .from('english_papers')
            .select()
            .eq('is_active', true)
            .eq('review_status', 'published')
            .order('id')
            .range(start, start + 499);
        rows.addAll(page);
        if (page.length < 500) break;
        if (rows.length >= 10000) throw StateError('English sync safety limit');
      }
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setString(cacheKey, jsonEncode(rows)))
        throw StateError('Could not cache English papers');
      replaceRows(rows);
    } catch (e) {
      debugPrint('English sync retained offline data: $e');
    } finally {
      _busy = false;
    }
  }

  static Map<String, String> choices(String subjectId) {
    final first = subjectId == 'english_1st';
    return {
      for (final p
          in _papers.where((p) => p.paperType == (first ? 'first' : 'second')))
        p.id: p.label,
      if (first)
        for (final p in englishFirstSets2024)
          'builtin:first:${p.serial}': p.board,
      if (!first)
        for (final p in englishBoardSets2024)
          'builtin:second:${p.serial}': p.board,
    };
  }

  static List<EnglishSection> compose(
      String subjectId, String? id, Random random) {
    if (id != null && id.isNotEmpty) {
      if (id.startsWith('builtin:first:') && subjectId == 'english_1st')
        return EnglishPaperAdapter.first(englishFirstSets2024
            .firstWhere((p) => p.serial.toString() == id.split(':').last));
      if (id.startsWith('builtin:second:') && subjectId == 'english_2nd')
        return EnglishPaperAdapter.second(englishBoardSets2024
            .firstWhere((p) => p.serial.toString() == id.split(':').last));
      final selected = _papers.where((p) =>
          p.id == id &&
          p.paperType == (subjectId == 'english_1st' ? 'first' : 'second'));
      if (selected.isEmpty)
        throw StateError(
            'This English paper is no longer available. Choose another board paper.');
      return selected.first.sections;
    }
    // Whole remote sets are selectable; the mixed mode also includes them.
    if (subjectId == 'english_1st')
      return EnglishPaperAdapter.first(
          EnglishFirstMixer.mix(rng: random, pool: [
        ...englishFirstSets2024,
        ..._papers.where((p) => p.first != null).map((p) => p.first!)
      ]).set);
    return EnglishPaperAdapter.second(EnglishBoardMixer.mix(rng: random, pool: [
      ...englishBoardSets2024,
      ..._papers.where((p) => p.second != null).map((p) => p.second!)
    ]).set);
  }
}
