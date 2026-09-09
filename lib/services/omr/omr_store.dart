import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// One graded OMR scan, kept in the device history.
class OmScanRecord {
  final String id;
  final DateTime date;
  final String paperTitle;
  final String subjectName;
  final String roll;
  final String registration;
  final String subjectCode;
  final String setCode; // ক/খ/গ/ঘ or '—'
  final int total;
  final int score;
  final int correct;
  final int wrong;
  final int blank;
  final int ambiguous;
  final List<int> answers;
  final List<int> key;

  /// Scan + grade duration in milliseconds (0 for older records).
  final int durationMs;

  const OmScanRecord({
    required this.id,
    required this.date,
    required this.paperTitle,
    required this.subjectName,
    required this.roll,
    required this.registration,
    required this.subjectCode,
    required this.setCode,
    required this.total,
    required this.score,
    required this.correct,
    required this.wrong,
    required this.blank,
    required this.ambiguous,
    required this.answers,
    required this.key,
    this.durationMs = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'paperTitle': paperTitle,
        'subjectName': subjectName,
        'roll': roll,
        'registration': registration,
        'subjectCode': subjectCode,
        'setCode': setCode,
        'total': total,
        'score': score,
        'correct': correct,
        'wrong': wrong,
        'blank': blank,
        'ambiguous': ambiguous,
        'answers': answers,
        'key': key,
        'durationMs': durationMs,
      };

  static OmScanRecord fromJson(Map<String, dynamic> m) => OmScanRecord(
        id: m['id'] as String,
        date: DateTime.tryParse(m['date'] as String? ?? '') ??
            DateTime.now(),
        paperTitle: m['paperTitle'] as String? ?? '',
        subjectName: m['subjectName'] as String? ?? '',
        roll: m['roll'] as String? ?? '',
        registration: m['registration'] as String? ?? '',
        subjectCode: m['subjectCode'] as String? ?? '',
        setCode: m['setCode'] as String? ?? '—',
        total: m['total'] as int? ?? 0,
        score: m['score'] as int? ?? 0,
        correct: m['correct'] as int? ?? 0,
        wrong: m['wrong'] as int? ?? 0,
        blank: m['blank'] as int? ?? 0,
        ambiguous: m['ambiguous'] as int? ?? 0,
        answers: (m['answers'] as List? ?? const [])
            .map((e) => (e as num).toInt())
            .toList(),
        key: (m['key'] as List? ?? const [])
            .map((e) => (e as num).toInt())
            .toList(),
        durationMs: (m['durationMs'] as num? ?? 0).toInt(),
      );
}

/// An answer key saved so the tutor does not retype it for every student.
class OmKeyDraft {
  final String paperTitle;
  final int total;
  final List<int> key;
  final DateTime savedAt;

  const OmKeyDraft({
    required this.paperTitle,
    required this.total,
    required this.key,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'paperTitle': paperTitle,
        'total': total,
        'key': key,
        'savedAt': savedAt.toIso8601String(),
      };

  static OmKeyDraft fromJson(Map<String, dynamic> m) => OmKeyDraft(
        paperTitle: m['paperTitle'] as String? ?? '',
        total: m['total'] as int? ?? 0,
        key: (m['key'] as List? ?? const [])
            .map((e) => (e as num).toInt())
            .toList(),
        savedAt: DateTime.tryParse(m['savedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class OmrStore {
  OmrStore._();

  static const _historyKey = 'omr_scan_history';
  static const _keyDraftKey = 'omr_key_draft';
  static const _maxHistory = 60;

  static Future<List<OmScanRecord>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = (json.decode(raw) as List)
          .map((e) => OmScanRecord.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
      return list;
    } catch (_) {
      return const [];
    }
  }

  static Future<void> addRecord(OmScanRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final all = [record, ...await loadHistory()];
    final trimmed = all.length > _maxHistory
        ? all.sublist(0, _maxHistory)
        : all;
    await prefs.setString(
      _historyKey,
      json.encode([for (final r in trimmed) r.toJson()]),
    );
  }

  static Future<void> deleteRecord(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = (await loadHistory())..removeWhere((r) => r.id == id);
    await prefs.setString(
      _historyKey,
      json.encode([for (final r in all) r.toJson()]),
    );
  }

  static Future<OmKeyDraft?> loadKeyDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyDraftKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return OmKeyDraft.fromJson((json.decode(raw) as Map).cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveKeyDraft(OmKeyDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDraftKey, json.encode(draft.toJson()));
  }
}
