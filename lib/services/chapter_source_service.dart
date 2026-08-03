import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Reads author-provided source material for AI question generation from
/// a JSON file hosted in the app's own GitHub repo. Only the repo owner
/// (you) can edit that file, so this is the "author-only upload" gate —
/// no extra auth code needed, and updates go live for every user
/// instantly without an app rebuild.
class ChapterSourceService {
  // Update this if you ever rename the repo or default branch.
  static const String _sourceUrl =
      'https://raw.githubusercontent.com/subornokhan22-collab/SSC/main/chapter_sources.json';

  static const String _cacheKey = 'chapter_sources_cache';
  static Map<String, dynamic>? _memoryCache;

  static String _key(String subjectId, String chapter) => '$subjectId|$chapter';

  static Future<Map<String, dynamic>> _load() async {
    if (_memoryCache != null) return _memoryCache!;
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await http.get(Uri.parse(_sourceUrl)).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _memoryCache = data;
        await prefs.setString(_cacheKey, response.body);
        return data;
      }
    } catch (_) {
      // network failed — fall back to last cached copy below
    }
    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      final data = jsonDecode(cached) as Map<String, dynamic>;
      _memoryCache = data;
      return data;
    }
    return {};
  }

  static Future<String> getSource(String subjectId, String chapter) async {
    final data = await _load();
    return (data[_key(subjectId, chapter)] as String?) ?? '';
  }

  static void invalidateCache() => _memoryCache = null;
}
