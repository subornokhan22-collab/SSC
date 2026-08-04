import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Shared Gemini API client for the whole app.
///
/// Fixes the "API ত্রুটি" problem in three ways:
///  1. Uses the managed alias [model], which always points to a valid
///     current Flash model — no more 404 when Google renames versions.
///  2. Automatically retries with a short wait when Google reports
///     rate-limit / server-busy (429/503/500).
///  3. Reads Google's actual error message and shows a friendly Bangla
///     explanation (bad key vs quota over vs busy) instead of a bare code.
class GeminiClient {
  /// Managed alias → always a valid, current Flash model.
  /// If you hit free-tier quota (429) often, switch to the lighter model:
  ///   static const String model = 'gemini-flash-lite-latest';
  static const String model = 'gemini-flash-latest';

  static Uri _url(String apiKey) => Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
      );

  /// Sends [prompt] and returns the model's reply text.
  /// Throws an [Exception] with a friendly Bangla message on failure.
  static Future<String> generate({
    required String apiKey,
    required String prompt,
    double temperature = 0.7,
    int maxAttempts = 3,
  }) async {
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      http.Response response;

      // ── Network phase ────────────────────────────────────────────
      try {
        response = await http
            .post(
              _url(apiKey),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': prompt}
                    ]
                  }
                ],
                'generationConfig': {'temperature': temperature},
              }),
            )
            .timeout(const Duration(seconds: 60));
      } catch (_) {
        // Socket error / timeout / no internet
        if (attempt < maxAttempts) {
          await Future.delayed(const Duration(seconds: 3));
          continue;
        }
        throw Exception('সংযোগে সমস্যা হয়েছে। ইন্টারনেট চেক করে আবার চেষ্টা করো।');
      }

      // ── Success ──────────────────────────────────────────────────
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
      }

      // ── Transient errors (rate limit / busy): wait & retry ───────
      final code = response.statusCode;
      if ((code == 429 || code == 503 || code == 500) && attempt < maxAttempts) {
        await Future.delayed(Duration(seconds: attempt == 1 ? 5 : 12));
        continue;
      }

      throw Exception(_friendlyError(response));
    }

    throw Exception('সার্ভার ব্যস্ত আছে। কিছুক্ষণ পর আবার চেষ্টা করো।');
  }

  /// Turns Google's error response into a clear Bangla explanation.
  static String _friendlyError(http.Response res) {
    String googleMsg = '';
    try {
      final body = jsonDecode(res.body);
      googleMsg = body['error']?['message']?.toString() ?? '';
    } catch (_) {}
    final lower = googleMsg.toLowerCase();

    switch (res.statusCode) {
      case 400:
        if (lower.contains('api key') || lower.contains('key not valid')) {
          return 'API Key টি সঠিক নয়। 🔑 আইকনে গিয়ে সঠিক Key আবার সংরক্ষণ করো।';
        }
        return 'অনুরোধে সমস্যা হয়েছে (400)।${googleMsg.isNotEmpty ? '\n$googleMsg' : ''}';
      case 401:
      case 403:
        return 'এই API Key দিয়ে Gemini ব্যবহারের অনুমতি নেই।\n'
            'aistudio.google.com থেকে নতুন ফ্রি Key তৈরি করে দাও।';
      case 404:
        return 'AI মডেলটি পাওয়া যায়নি। অ্যাপটি সর্বশেষ সংস্করণে আপডেট করো।';
      case 429:
        if (lower.contains('quota') || lower.contains('daily') ||
            lower.contains('per_day')) {
          return 'আজকের ফ্রি কোটা শেষ! আগামীকাল আবার ব্যবহার করা যাবে, '
              'অথবা Google AI Studio থেকে নতুন Key নাও।';
        }
        return 'একসাথে অনেক অনুরোধ গেছে (rate limit)। ১ মিনিট অপেক্ষা করে আবার চেষ্টা করো।';
      case 500:
      case 503:
        return 'Google সার্ভার এই মুহূর্তে ব্যস্ত। কিছুক্ষণ পর আবার চেষ্টা করো।';
      default:
        return 'API ত্রুটি: ${res.statusCode}'
            '${googleMsg.isNotEmpty ? '\n$googleMsg' : ''}';
    }
  }
}
