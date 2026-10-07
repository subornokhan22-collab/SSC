import 'package:flutter/foundation.dart';

import 'auth_service.dart';

/// Stable namespace for data that belongs to one signed-in tutor.
///
/// Device preferences and files survive account switches, so every piece of
/// teacher-created content must include this scope instead of using a global
/// key/path. The signed-out namespace is intentionally separate.
abstract final class LocalAccountScope {
  @visibleForTesting
  static String? debugId;

  static String get id {
    final override = debugId;
    if (override != null) return override;
    final raw = AuthService.userId?.trim();
    if (raw == null || raw.isEmpty) return 'signed_out';
    return raw.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
  }

  static String key(String base) => '${base}_$id';
}
