import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_config.dart';
import 'question_bank.dart';
import 'questions_data.dart';

/// Pulls questions published from the web admin panel.
///
/// The 15,392 bundled questions still ship inside the APK and load instantly
/// offline. This adds anything written since the last release, so new
/// material reaches tutors **without an app update**.
///
/// Design notes:
/// * Only rows newer than the last sync are fetched, so the usual cost is one
///   small request returning nothing.
/// * The result is cached, so the extra questions survive being offline.
/// * Every failure is silent. A paper must never fail to generate because the
///   network is down.
class QuestionSync {
  QuestionSync._();

  static const _cacheKey = 'remote_questions_v1';
  static const _stampKey = 'remote_questions_since_v1';

  /// Rows pulled from the server, already merged into [QuestionBank].
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

  /// Asks the server for anything added since the last successful sync.
  ///
  /// Safe to call in the background — it returns the number of new questions
  /// and swallows every error.
  static Future<int> refresh() async {
    if (!SupabaseConfig.isConfigured) return 0;
    try {
      final prefs = await SharedPreferences.getInstance();
      final since = prefs.getString(_stampKey);

      var query = _c.from('questions').select().eq('is_active', true);
      if (since != null && since.isNotEmpty) {
        query = query.gt('updated_at', since);
      }
      final rows = await query.order('updated_at').limit(2000);

      if (rows.isEmpty) return 0;

      // Merge the delta into whatever is already cached, keyed by id so an
      // edited question replaces its older copy rather than duplicating it.
      final cachedRaw = prefs.getString(_cacheKey);
      final byId = <String, Map<String, dynamic>>{};
      if (cachedRaw != null && cachedRaw.isNotEmpty) {
        for (final r in json.decode(cachedRaw) as List) {
          final m = (r as Map).cast<String, dynamic>();
          byId[m['id'] as String] = m;
        }
      }
      String newest = since ?? '';
      for (final r in rows) {
        final m = Map<String, dynamic>.from(r as Map);
        byId[m['id'] as String] = m;
        final u = (m['updated_at'] ?? '').toString();
        if (u.compareTo(newest) > 0) newest = u;
      }

      final merged = byId.values.toList();
      await prefs.setString(_cacheKey, json.encode(merged));
      if (newest.isNotEmpty) await prefs.setString(_stampKey, newest);

      _merge(merged);
      return rows.length;
    } catch (e) {
      // Offline, table missing, RLS denial — none of it should surface.
      debugPrint('QuestionSync: refresh skipped ($e)');
      return 0;
    }
  }

  /// Forgets everything pulled from the server and starts over next sync.
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_stampKey);
  }

  /// Turns server rows into model objects and hands them to [QuestionBank].
  static void _merge(List rows) {
    final mcqs = <Question>[];
    final saqs = <ShortQuestion>[];
    final cqs = <CreativeQuestion>[];

    for (final row in rows) {
      try {
        final m = Map<String, dynamic>.from(row as Map);
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
    if (_added > 0) QuestionBank.addRemote(mcqs: mcqs, saqs: saqs, cqs: cqs);
  }
}
