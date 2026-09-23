import 'package:shared_preferences/shared_preferences.dart';

/// Offline Pro licence state for the printable question papers.
///
/// DEMO (free):
///   - limited questions per paper (MCQ 6, CQ 2)
///   - big "DEMO" watermark
///   - no PDF / print
///
/// PRO (paid via bKash):
///   - full papers, no watermark
///   - PDF / print enabled
///   - subscription expiry when the server sets one (monthly / yearly);
///     a one-time unlock has no expiry.
///
/// Activation happens server-side (the bKash payment is verified on
/// Supabase and `profiles.is_pro` / `profiles.pro_until` are updated);
/// this class only caches the state on the device.
class PaperLicense {
  static const _prefKey = 'paper_pro_unlocked';
  static const _untilKey = 'paper_pro_until';

  /// Pro is active when the device flag is set AND (no expiry stored OR
  /// the expiry is still in the future).
  static Future<bool> isPro() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_prefKey) ?? false) {
      final raw = prefs.getString(_untilKey);
      if (raw != null && raw.isNotEmpty) {
        final until = DateTime.tryParse(raw);
        if (until != null && until.isBefore(DateTime.now())) return false;
      }
      return true;
    }
    return false;
  }

  /// The server confirmed Pro for this account. [until] = subscription
  /// end date (monthly / yearly); null = one-time unlock (forever).
  static Future<void> markProFromServer({DateTime? until}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
    if (until != null) {
      await prefs.setString(_untilKey, until.toUtc().toIso8601String());
    } else {
      await prefs.remove(_untilKey);
    }
  }

  static Future<void> deactivate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    await prefs.remove(_untilKey);
  }

  // ── Demo limits ─────────────────────────────────────────────────
  static const int demoMcqLimit = 6;
  static const int demoCqLimit = 2;
}
