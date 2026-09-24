import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global app settings, persisted across launches.
///
///  • [omrPrefillCodes] — whether generated OMR sheets print the set &
///    subject code pre-filled (and whether scan results use the codes
///    read from the sheet) (default ON).
///  • [defaultPaperName] — default title for generated question papers and
///    OMR tests (empty = the built-in defaults).
class AppSettings {
  AppSettings._();

  static const _kPrefill = 'omr_prefill_codes';
  static const _kName = 'default_paper_name';

  /// Live notifier so the Settings switch repaints instantly.
  static final ValueNotifier<bool> omrPrefillCodes = ValueNotifier<bool>(true);

  /// Live notifier for the default name field.
  static final ValueNotifier<String> defaultPaperName = ValueNotifier<String>(
    '',
  );

  static bool get omrPrefill => omrPrefillCodes.value;
  static String get defaultName => defaultPaperName.value;

  /// Must be awaited before screens read the values (called in main).
  static Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      omrPrefillCodes.value = p.getBool(_kPrefill) ?? true;
      defaultPaperName.value = (p.getString(_kName) ?? '').trim();
    } catch (_) {
      // Preferences unavailable — keep the defaults.
    }
  }

  static Future<void> setOmriPrefill(bool on) async {
    omrPrefillCodes.value = on;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kPrefill, on);
    } catch (_) {}
  }

  static Future<void> setDefaultPaperName(String name) async {
    final t = name.trim();
    defaultPaperName.value = t;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kName, t);
    } catch (_) {}
  }
}
