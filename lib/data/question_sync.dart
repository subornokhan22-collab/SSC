import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_config.dart';
import 'question_bank.dart';
import 'questions_data.dart';

/// Pulls questions published from the web admin panel.
///
/// Bundled content loads instantly offline. A paginated, complete public
/// snapshot adds published remote content and reconciles archive/deletion.
/// The previous snapshot survives a network failure. Private questions are
/// never put into this device-wide public bank cache.
class QuestionSync {
  QuestionSync._();

  static const _cacheKey = 'remote_questions_v1';
  static const _stampKey = 'remote_questions_since_v1';

  /// Rows pulled from the server, already merged into [QuestionBank].
  static bool _busy = false;
  static int _added = 0;
  static int get added => _added;

  static SupabaseClient get _c => Supabase.instance.client;

  /// Loads the cached remote questions and merges them into the bank.
  ///
  /// Call right after [QuestionBank.load]; it never touches the network, so
  /// startup stays fast and works offline.
  static Future<void> loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null || raw.isEmpty) return;
      _merge(json.decode(raw) as List);
    } catch (e) {
      debugPrint('QuestionSync: cache unreadable ($e)');
    }
  }

  /// Reconciles a complete, paginated published-content snapshot.
  ///
  /// Safe to call in the background — it returns the number of remote rows
  /// and swallows every error.
  static Future<int> refresh() async {
    if (_busy || !SupabaseConfig.isConfigured) return 0;
    _busy = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      // A full paginated official snapshot removes archived/deleted records.
      // The old updated_at > cursor missed removals and equal-timestamp pages.
      final rows = <dynamic>[];
      for (var start = 0;; start += 500) {
        final page = await _c
            .from('questions')
            .select()
            .eq('is_active', true)
            .eq('review_status', 'published')
            .isFilter('owner_id', null)
            .order('id')
            .range(start, start + 499);
        rows.addAll(page);
        if (page.length < 500) break;
        if (rows.length >= 100000)
          throw StateError('Question sync safety limit');
      }
      if (!await prefs.setString(_cacheKey, json.encode(rows)))
        throw StateError('Question cache write failed');
      _merge(rows);
      return rows.length;
    } catch (e) {
      // Offline, table missing, RLS denial — none of it should surface.
      debugPrint('QuestionSync: refresh skipped ($e)');
      return 0;
    } finally {
      _busy = false;
    }
  }

  /// Forgets everything pulled from the server and starts over next sync.
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_stampKey);
    QuestionBank.replaceRemote();
    _added = 0;
  }

  /// Turns server rows into model objects and hands them to [QuestionBank].
  static void _merge(List rows) {
    final mcqs = <Question>[];
    final saqs = <ShortQuestion>[];
    final cqs = <CreativeQuestion>[];

    for (final row in rows) {
      try {
        final m = Map<String, dynamic>.from(row as Map);
        if (m['owner_id'] != null ||
            m['is_active'] == false ||
            (m['review_status'] != null && m['review_status'] != 'published'))
          continue;
        // The server stores the type-specific fields in `payload`, matching
        // the exported JSON, so the existing decoders can be reused as-is.
        final flat = <String, dynamic>{
          'id': m['id'],
          'type': m['type'],
          'subjectId': m['subject_id'] ?? m['subjectId'],
          'chapter': m['chapter'],
          'source': m['source'] ?? 'original',
          'sourceLabel': m['source_label'] ?? m['sourceLabel'],
          'payload': m['payload'] is String
              ? json.decode(m['payload'] as String)
              : m['payload'],
          'figure': m['figure'] is String
              ? json.decode(m['figure'] as String)
              : m['figure'],
        };
        switch (flat['type']) {
          case 'mcq':
            mcqs.add(questionFromJson(flat));
          case 'saq':
            saqs.add(shortQuestionFromJson(flat));
          case 'cq':
            cqs.add(creativeQuestionFromJson(flat));
        }
      } catch (e) {
        // Skip a bad row; never lose the rest.
        debugPrint('QuestionSync: skipped a row ($e)');
      }
    }

    _added = mcqs.length + saqs.length + cqs.length;
    QuestionBank.replaceRemote(mcqs: mcqs, saqs: saqs, cqs: cqs);
  }
}
