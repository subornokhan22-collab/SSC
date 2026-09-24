import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth_service.dart';
import '../supabase_config.dart';

/// A schema-forced server path only. Never falls back to unverified device-key
/// generation. SSE phase messages reflect completed/running server stages.
class TeacherAiClient {
  final http.Client _client;
  TeacherAiClient({http.Client? client}) : _client = client ?? http.Client();
  void close() => _client.close();
  Future<Map<String, dynamic>> request(
    Map<String, dynamic> payload,
    void Function(String) progress,
  ) async {
    final token = AuthService.currentUserToken;
    if (token == null)
      throw StateError(
        'Sign in to use AI Tools. Your offline papers are still available.',
      );
    final req = http.Request(
      'POST',
      Uri.parse('${SupabaseConfig.url}/functions/v1/mimi'),
    )
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'apikey': SupabaseConfig.anonKey,
      })
      ..body = jsonEncode(payload);
    final response =
        await _client.send(req).timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      final raw = await response.stream.bytesToString().timeout(
            const Duration(seconds: 30),
          );
      String message = 'AI server error (${response.statusCode}). Try again.';
      try {
        final j = jsonDecode(raw) as Map;
        message = j['error'] as String? ?? message;
      } catch (_) {}
      throw StateError(message);
    }
    Map<String, dynamic>? result;
    var event = '';
    await for (final line in response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .timeout(const Duration(seconds: 100))) {
      if (line.startsWith('event:')) {
        event = line.substring(6).trim();
        continue;
      }
      if (!line.startsWith('data:')) continue;
      final data = jsonDecode(line.substring(5).trim()) as Map<String, dynamic>;
      if (event == 'phase') progress(data['message'] as String);
      if (event == 'error')
        throw StateError(data['message'] as String? ?? 'AI request failed.');
      if (event == 'result') result = data;
    }
    if (result == null)
      throw StateError(
        'The server returned no complete result. The teacher-tools function may need deployment.',
      );
    return result;
  }
}
