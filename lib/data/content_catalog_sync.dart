import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subject_info.dart';
import '../services/chapter_catalog.dart';
import '../services/supabase_config.dart';

class ContentCatalogSync {
  static const _key = 'content_catalog_v1';
  static void _apply(List rows) {
    final subjects = <SubjectInfo>[], chapters = <String, List<String>>{};
    for (final r in rows) {
      try {
        final id = r['id'] as String, name = r['name'] as String;
        final list = List<String>.from(r['chapters'] as List);
        if (id.isEmpty || name.isEmpty) continue;
        final existing = bundledSubjects.where((s) => s.id == id);
        final old = existing.isEmpty ? null : existing.first;
        subjects.add(SubjectInfo(
            id: id,
            name: name,
            bengaliName: name,
            icon: old?.icon ?? '📘',
            colorHex: old?.colorHex ?? 0xFF3157D5,
            group: old?.group ?? SubjectGroup.general));
        chapters[id] = list;
      } catch (e) {
        debugPrint('Invalid catalog row: $e');
      }
    }
    remoteSubjects = List.unmodifiable(subjects);
    ChapterCatalog.remote = chapters;
  }

  static Future<void> loadCache() async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_key);
      if (raw != null) _apply(jsonDecode(raw) as List);
    } catch (e) {
      debugPrint('Catalog cache: $e');
    }
  }

  static Future<void> refresh() async {
    if (!SupabaseConfig.isConfigured) return;
    try {
      final rows = <dynamic>[];
      for (var offset = 0;; offset += 500) {
        final page = await Supabase.instance.client
            .from('content_subjects')
            .select()
            .order('id')
            .range(offset, offset + 499);
        rows.addAll(page);
        if (page.length < 500) break;
      }
      final prefs = await SharedPreferences.getInstance();
      if (await prefs.setString(_key, jsonEncode(rows))) _apply(rows);
    } catch (e) {
      debugPrint('Catalog offline: $e');
    }
  }
}
