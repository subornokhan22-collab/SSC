import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/questions_data.dart';

/// The answer key of one generated paper, remembered so the OMR scanner can
/// mark sheets without the tutor retyping the key.
class PaperKey {
  final String id;
  final String title;
  final String subject;
  final String dateIso;
  final int questionCount;
  /// 0-3 (ক/খ/গ/ঘ), or -1 when the paper had no set code.
  final int setCode;
  final List<int> key;

  const PaperKey({
    required this.id,
    required this.title,
    required this.subject,
    required this.dateIso,
    required this.questionCount,
    required this.setCode,
    required this.key,
  });

  factory PaperKey.fromJson(Map<String, dynamic> m) => PaperKey(
        id: m['id'] as String,
        title: (m['title'] ?? '') as String,
        subject: (m['subject'] ?? '') as String,
        dateIso: (m['dateIso'] ?? '') as String,
        questionCount: (m['questionCount'] ?? 0) as int,
        setCode: (m['setCode'] ?? -1) as int,
        key: (m['key'] as List).cast<num>().map((e) => e.toInt()).toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subject': subject,
        'dateIso': dateIso,
        'questionCount': questionCount,
        'setCode': setCode,
        'key': key,
      };

  static int parseSetLetter(String? letter) {
    const letters = ['ক', 'খ', 'গ', 'ঘ'];
    final i = letter == null ? -1 : letters.indexOf(letter.trim());
    return i;
  }

  /// Builds a key from the MCQs of a freshly generated paper.
  factory PaperKey.fromMcqs({
    required String title,
    required String subject,
    required List<Question> mcqs,
    String? setLetter,
  }) {
    final key = mcqs.map((q) => q.correctIndex).toList(growable: false);
    final id = _hash('$title|${mcqs.length}|${key.join(',')}');
    return PaperKey(
      id: id,
      title: title,
      subject: subject,
      dateIso: DateTime.now().toIso8601String(),
      questionCount: key.length,
      setCode: parseSetLetter(setLetter),
      key: key,
    );
  }
}

/// Small FNV-1a 64-bit hash — good enough for idempotent key ids, no
/// crypto dependency needed.
int _hash(String s) {
  var h = 0xcbf29ce484222325;
  for (final b in s.codeUnits) {
    h ^= b & 0xff;
    h = (h * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
  }
  return h;
}

class PaperKeyStore {
  PaperKeyStore._();

  static const _prefsKey = 'paper_keys_v1';
  static const _maxKeys = 25;

  static Future<List<PaperKey>> list() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = (json.decode(raw) as List)
          .cast<Map<String, dynamic>>()
          .map(PaperKey.fromJson)
          .toList();
      return list;
    } catch (_) {
      return const [];
    }
  }

  /// Adds a key, replacing an identical one (same paper content) so that
  /// re-printing the same paper does not pile up duplicates.
  static Future<void> save(PaperKey key) async {
    if (key.key.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final list = await list();
    list.removeWhere((k) => k.id == key.id);
    list.insert(0, key);
    if (list.length > _maxKeys) list.removeRange(_maxKeys, list.length);
    await prefs.setString(
        _prefsKey, json.encode(list.map((k) => k.toJson()).toList()));
  }

  static Future<void> remove(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = (await list()).where((k) => k.id != id).toList();
    await prefs.setString(
        _prefsKey, json.encode(list.map((k) => k.toJson()).toList()));
  }
}
