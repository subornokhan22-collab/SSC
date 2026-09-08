import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A question paper the tutor saved from the app ("My Papers").
class MyPaper {
  final String id;
  final String title;
  final String subject;
  final String dateIso;
  final int mcqs;
  final int saqs;
  final int cqs;
  final int sizeBytes;
  /// FNV-1a of the PDF bytes — re-saving the same paper updates the entry
  /// instead of creating a duplicate.
  final int contentHash;

  const MyPaper({
    required this.id,
    required this.title,
    required this.subject,
    required this.dateIso,
    required this.mcqs,
    required this.saqs,
    required this.cqs,

    required this.sizeBytes,
    required this.contentHash,
  });

  factory MyPaper.fromJson(Map<String, dynamic> m) => MyPaper(
        id: m['id'] as String,
        title: (m['title'] ?? '') as String,
        subject: (m['subject'] ?? '') as String,
        dateIso: (m['dateIso'] ?? '') as String,
        mcqs: (m['mcqs'] ?? 0) as int,
        saqs: (m['saqs'] ?? 0) as int,
        cqs: (m['cqs'] ?? 0) as int,
        sizeBytes: (m['sizeBytes'] ?? 0) as int,
        contentHash: (m['contentHash'] ?? 0) as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subject': subject,
        'dateIso': dateIso,
        'mcqs': mcqs,
        'saqs': saqs,
        'cqs': cqs,
        'sizeBytes': sizeBytes,
        'contentHash': contentHash,
      };
}

/// Stores saved papers as PDF files in the app's documents directory, with a
/// small JSON index in SharedPreferences.
class MyPaperStore {
  MyPaperStore._();

  static const _prefsKey = 'my_papers_v1';
  static const _maxPapers = 60;

  static int hashBytes(Uint8List bytes) {
    var h = 0xcbf29ce484222325;
    for (final b in bytes) {
      h ^= b & 0xff;
      h = (h * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
    }
    return h;
  }

  static Future<Directory> _dir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'my_papers'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  static Future<List<MyPaper>> list() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      return (json.decode(raw) as List)
          .cast<Map<String, dynamic>>()
          .map(MyPaper.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Saves [bytes]; returns the stored entry (new or refreshed).
  static Future<MyPaper> save({
    required Uint8List bytes,
    required String title,
    String subject = '',
    int mcqs = 0,
    int saqs = 0,
    int cqs = 0,
  }) async {
    final dir = await _dir();
    final prefs = await SharedPreferences.getInstance();
    final papers = await list();
    final hash = hashBytes(bytes);
    final existing = papers.where((m) => m.contentHash == hash).toList();

    MyPaper entry;
    final file = File(p.join(dir.path, '${existing.isNotEmpty ? existing.first.id : _newId()}.pdf'));
    if (existing.isEmpty) {
      entry = MyPaper(
        id: p.basenameWithoutExtension(file.path),
        title: title,
        subject: subject,
        dateIso: DateTime.now().toIso8601String(),
        mcqs: mcqs,
        saqs: saqs,
        cqs: cqs,
        sizeBytes: bytes.length,
        contentHash: hash,
      );
    } else {
      entry = existing.first;
    }
    await file.writeAsBytes(bytes);
    if (existing.isNotEmpty) {
      papers.removeWhere((m) => m.id == entry.id);
    }
    papers.insert(0, entry);
    while (papers.length > _maxPapers) {
      final dropped = papers.removeLast();
      try {
        final f = File(p.join(dir.path, '${dropped.id}.pdf'));
        if (f.existsSync()) f.deleteSync();
      } catch (_) {}
    }
    await prefs.setString(
        _prefsKey, json.encode(papers.map((m) => m.toJson()).toList()));
    return entry;
  }

  static Future<Uint8List?> bytesOf(String id) async {
    final dir = await _dir();
    final file = File(p.join(dir.path, '$_id.pdf'));
    if (!file.existsSync()) return null;
    return file.readAsBytesSync();
  }

  static Future<void> delete(String id) async {
    final dir = await _dir();
    final prefs = await SharedPreferences.getInstance();
    final papers = (await list()).where((m) => m.id != id).toList();
    await prefs.setString(
        _prefsKey, json.encode(papers.map((m) => m.toJson()).toList()));
    try {
      final f = File(p.join(dir.path, '$_id.pdf'));
      if (f.existsSync()) f.deleteSync();
    } catch (_) {}
  }

  static String _newId() {
    final t = DateTime.now();
    final stamp =
        t.millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    final rand = (t.microsecond % 46656).toRadixString(36).padLeft(3, '0');
    return '${stamp}_$rand';
  }
}
