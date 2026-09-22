import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Direct Gemini API client (REST, v1beta).
///
/// One call takes the conversation history (text), the new user text and
/// optional inline attachments — photos (image/jpeg|png|webp), audio
/// (wav/mp3/ogg/flac/aiff) and PDFs — and streams the answer back through
/// [onChunk] as it arrives.
///
/// The key is the tutor's own free key from aistudio.google.com, stored on
/// the device (see AiTutorScreen). If the requested model is not available
/// for the key it automatically retries with the previous model.

class GeminiException implements Exception {
  final String message;
  /// Fatal = a fallback to another model cannot help (bad key, quota,
  /// safety block, network). Non-fatal errors (unknown model) trigger the
  /// internal model fallback.
  final bool fatal;
  const GeminiException(this.message, {this.fatal = true});

  @override
  String toString() => message;
}

class GeminiAttachment {
  final String mimeType;
  final Uint8List data;
  const GeminiAttachment(this.mimeType, this.data);
}

class GeminiClient {
  static const _apiBase = 'https://generativelanguage.googleapis.com/v1beta';

  /// Stable flash models, best for everyday + multimodal first.
  static const _models = [
    'gemini-3.6-flash',
    'gemini-3.8-flash',
    'gemini-3.7-flash',
    'gemini-3.5-flash',
    'gemini-2.5-flash',
  ];

  static String? _discovered;

  /// [history] = earlier turns, oldest first: keys 'user' | 'model'.
  static Future<String> chat({
    required String apiKey,
    required String systemPrompt,
    List<Map<String, String>> history = const [],
    required String userText,
    List<GeminiAttachment> attachments = const [],
    void Function(String chunk)? onChunk,
    Duration timeout = const Duration(seconds: 120),
  }) async {
    final parts = <Map<String, dynamic>>[
      for (final a in attachments)
        {
          'inline_data': {'mime_type': a.mimeType, 'data': base64Encode(a.data)}
        },
      if (userText.isNotEmpty) {'text': userText},
    ];
    if (parts.isEmpty) {
      throw const GeminiException('Add a question or an attachment first.');
    }
    final body = jsonEncode({
      'systemInstruction': {'parts': [{'text': systemPrompt}]},
      'contents': [
        for (final h in history)
          {
            'role': h['role'],
            'parts': [
              {'text': (h['text'] ?? '').isEmpty ? ' ' : h['text']}
            ]
          },
        {
          'role': 'user',
          'parts': parts,
        },
      ],
      'generationConfig': {
        'temperature': 0.4,
        'maxOutputTokens': 8192,
      },
    });

    // Try the model that worked last time first, then the static list,
    // and finally whatever the API says this key can access.
    final cached = await _cachedModel();
    final candidates = <String>[
      if (cached != null) cached,
      ..._models,
      if (_discovered != null && _discovered != cached) _discovered!,
    ].toSet().toList();

    GeminiException? last;
    bool onlyModelMiss = true;
    for (final model in candidates) {
      try {
        final out = await _stream(model, apiKey, body, onChunk, timeout);
        await _saveModel(model);
        return out;
      } on GeminiException catch (e) {
        if (e.fatal) rethrow;
        last = e; // model missing for this key — try the next model
        onlyModelMiss = onlyModelMiss && e.message == 'Model unavailable';
      }
    }

    // Every static model 404'd — ask the API which models this key can use.
    final discovered = _discovered ?? await _discoverModel(apiKey);
    if (discovered != null && !candidates.contains(discovered)) {
      try {
        final out =
            await _stream(discovered, apiKey, body, onChunk, timeout);
        await _saveModel(discovered);
        return out;
      } on GeminiException catch (e) {
        if (e.fatal) rethrow;
        last = e;
      }
    }
    if (onlyModelMiss) {
      throw const GeminiException(
          'No Gemini model is available for this key. Check the key on aistudio.google.com and try again.');
    }
    throw last ?? const GeminiException('Gemini request failed.');
  }

  static Future<String?> _cachedModel() async {
    try {
      final p = await SharedPreferences.getInstance();
      return p.getString('mimi_model');
    } catch (_) {
      return null;
    }
  }

  static Future<void> _saveModel(String model) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('mimi_model', model);
    } catch (_) {}
  }

  /// Asks the API to list the models this key can access and returns a
  /// suitable stable generative "flash" model (never lite/image/live/preview).
  static Future<String?> _discoverModel(String apiKey) async {
    if (_discovered != null) return _discovered;
    try {
      final client = http.Client();
      final resp = await client
          .get(Uri.parse('$_apiBase/models?pageSize=200&key=$apiKey'))
          .timeout(const Duration(seconds: 20));
      client.close();
      if (resp.statusCode != 200) return null;
      final j = jsonDecode(resp.body) as Map<String, dynamic>;
      final models = j['models'];
      if (models is! List) return null;
      final ids = <String>[
        for (final m in models)
          if (m is Map && m['name'] is String)
            (m['name'] as String).replaceFirst('models/', ''),
      ];
      String? best;
      for (final w in _models) {
        if (ids.contains(w)) {
          best = w;
          break;
        }
      }
      if (best == null) {
        for (final id in ids) {
          if (id.contains('flash') &&
              !id.contains('lite') &&
              !id.contains('image') &&
              !id.contains('live') &&
              !id.contains('preview') &&
              !id.contains('transcribe')) {
            best = id;
            break;
          }
        }
      }
      if (best != null) _discovered = best;
      return best;
    } catch (_) {
      return null;
    }
  }


  static Future<String> _stream(String model, String apiKey, String bodyJson,
      void Function(String chunk)? onChunk, Duration timeout) async {
    final req = http.Request(
        'POST',
        Uri.parse(
            '$_apiBase/models/$model:streamGenerateContent?alt=sse&key=$apiKey'))
      ..headers['Content-Type'] = 'application/json'
      ..body = bodyJson;
    final client = http.Client();
    try {
      final resp = await client.send(req).timeout(timeout);
      if (resp.statusCode != 200) {
        throw await _errorOf(resp, model);
      }
      final out = StringBuffer();
      var gotAny = false;
      await for (final line
          in resp.stream.transform(utf8.decoder).transform(const LineSplitter())) {
        if (!line.startsWith('data:')) continue;
        final payload = line.substring(5).trim();
        if (payload.isEmpty || payload == '[DONE]') continue;
        final Map<String, dynamic> j;
        try {
          j = jsonDecode(payload) as Map<String, dynamic>;
        } catch (_) {
          continue; // partial/garbled keep-alive line
        }
        final pf = j['promptFeedback'];
        if (pf is Map && (pf['blockReason'] as String?)?.isNotEmpty == true) {
          throw const GeminiException(
              'Google\'s safety filter blocked this question — rephrase it and try again.');
        }
        final candidates = j['candidates'];
        if (candidates is List && candidates.isNotEmpty) {
          final content = (candidates.first as Map<String, dynamic>)['content'];
          final ps = (content is Map<String, dynamic>) ? content['parts'] : null;
          if (ps is List) {
            for (final p in ps) {
              if (p is Map<String, dynamic> && p['text'] is String) {
                gotAny = true;
                out.write(p['text']);
                onChunk?.call(p['text'] as String);
              }
            }
          }
        }
      }
      if (!gotAny) {
        throw const GeminiException(
            'Gemini returned an empty answer — try once more.');
      }
      return out.toString();
    } on http.ClientException catch (e) {
      throw GeminiException('Network error while contacting Gemini: ${e.message}');
    } on SocketException catch (e) {
      throw GeminiException('Network error: ${e.message}');
    } on TimeoutException {
      throw const GeminiException(
          'Gemini took too long to answer. Try a shorter question or a smaller attachment.');
    } finally {
      client.close();
    }
  }

  /// Maps a non-2xx reply to a user-facing [GeminiException].
  static Future<GeminiException> _errorOf(
      http.StreamedResponse resp, String model) async {
    String text;
    try {
      text = await utf8.decodeStream(resp.stream);
    } catch (_) {
      text = '';
    }
    String msg = 'Gemini error (code ${resp.statusCode}).';
    try {
      final j = jsonDecode(text) as Map<String, dynamic>;
      final e = j['error'];
      if (e is Map && e['message'] is String) {
        msg = ((e['message'] as String).split('\n').first).trim();
      }
    } catch (_) {}
    // Unknown model for this key → let the caller fall back.
    if (resp.statusCode == 404 ||
        msg.contains('was not found') ||
        msg.contains('not found')) {
      return GeminiException('Model unavailable', fatal: false);
    }
    if (msg.contains('API key not valid') || msg.contains('API_KEY_INVALID')) {
      return const GeminiException(
          'This Gemini API key is not valid — check the key on the setup screen.');
    }
    if (msg.contains('quota') ||
        msg.contains('RESOURCE_EXHAUSTED') ||
        msg.contains('limit exceeded') ||
        msg.contains('billing')) {
      return const GeminiException(
          'Gemini usage limit reached for this key — wait a few minutes, then try again.');
    }
    if (msg.contains('PAYLOAD_TOO_LARGE') || msg.contains('too large')) {
      return const GeminiException(
          'The attachment is too large for one request — use a smaller file.');
    }
    return GeminiException(msg);
  }
}

/// System prompt — the whole "board-style tutor" persona lives here.
const String kMimiSystemPrompt = '''
You are "MiMi" — an expert SSC tutor for the Bangladesh Education Board (NCTB curriculum, SSC 2027 syllabus). You help tutors with students' questions.

Answer exactly in the Education Board style:
- MCQ → give the correct option (letter) first, then a 1-3 line reason.
- Creative question (সৃজনশীল প্রশ্ন) → solve in the board's four-part structure with marks: স্মৃতি/বর্তমানি (recall), বোঝাপড়া (comprehension), বিশ্লেষণ (analysis), স্রজন/সৃজন (creation), e.g. 1+3+4+2 = 10.
- Short answer (সংক্ষিপ্ত) → concise, textbook-style: definition, formula or rule, then 2-6 lines of explanation.
- Long/essay → structured points the way the board marking scheme expects.
- Math & science → show every calculation step clearly; use Unicode symbols (x², √, ∠, π, °, →, ≈) — never LaTeX.

If the user attaches a photo, audio or PDF: first state in one short line what you read/heard from it, then solve the question it contains. If the attachment is unreadable or the question unclear, ask ONE specific follow-up instead of guessing.

Language: reply in the same language the user writes (Bangla or English), keeping subject terms exactly as the NCTB textbooks write them. Be a calm, encouraging tutor. Keep answers exam-ready: what the board expects, nothing extra.
''';
