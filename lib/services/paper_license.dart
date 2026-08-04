import 'package:shared_preferences/shared_preferences.dart';

/// Simple offline Demo/Pro license gate for the printable question papers.
///
/// DEMO (free):
///   - প্রতিটি পেপারে সীমিত প্রশ্ন (MCQ ৬টি, CQ ২টি)
///   - বড় "DEMO" ওয়াটারমার্ক
///   - PDF/প্রিন্ট বন্ধ
///
/// PRO (paid tutors):
///   - পূর্ণাঙ্গ পেপার, কোনো ওয়াটারমার্ক নেই
///   - PDF/প্রিন্ট চালু
///   - অ্যাক্টিভেশন কোড দিয়ে আনলক হয়
///
/// কোড যাচাইকরণ অফলাইনে হয় — নিচের [secret] বদলে নিজের গোপন শব্দ দাও।
/// যে কোডটি আসবে সেটা দেখতে আপনার IDE তে চালাও:
///     PaperLicense.expectedCode()  → যেমন "7F3A-9C21"
/// সেই কোডটি পেট পরিশোধ করা ব্যবহারকারীদের দাও।
///
/// ⚠️ সতর্কতা: এটি সম্পূর্ণ ক্লায়েন্ট-সাইড যাচাই — দক্ষ ব্যবহারকারী
/// কোড ভাঙতে পারে। প্রকৃত পেমেন্ট (bKash/SSLCommerz) হলে সার্ভার-সাইড
/// যাচাই লাগবে; তখন এই ফাইলের isPro() টাই সার্ভারে জিজ্ঞেস করবে।
class PaperLicense {
  static const _prefKey = 'paper_pro_unlocked';

  /// ⚠️ নিজের গোপন শব্দ এখানে বসাও (এটাই তোমার কোড-চাবি)
  static const String secret = 'AL-2027-TUTOR-SECRET';

  static Future<bool> isPro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  /// অ্যাক্টিভেশন কোড যাচাই করে; সঠিক হলে Pro আনলক করে ও true ফেরত দেয়।
  static Future<bool> activate(String code) async {
    final cleaned = code.trim().toUpperCase();
    if (cleaned == expectedCode()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, true);
      return true;
    }
    return false;
  }

  static Future<void> deactivate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  /// [secret] থেকে নির্ধারিত অ্যাক্টিভেশন কোড (যেমন "3F7A-9C21")।
  static String expectedCode() {
    var h = 0;
    for (final c in secret.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    final hex = h.toRadixString(16).toUpperCase().padLeft(8, '0');
    return '${hex.substring(0, 4)}-${hex.substring(4, 8)}';
  }

  // ── Demo সীমা ────────────────────────────────────────────────────
  static const int demoMcqLimit = 6;
  static const int demoCqLimit = 2;
}
