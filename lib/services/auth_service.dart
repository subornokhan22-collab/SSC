import 'package:supabase_flutter/supabase_flutter.dart';

import 'paper_license.dart';
import 'supabase_config.dart';

/// ইমেইল OTP লগইন + Pro লাইসেন্স সিংক (Supabase)
///
/// ধারা:
///  ১) শিক্ষার্থী/শিক্ষক ইমেইল দেয় → ইমেইলে ৬-সংখ্যার OTP যায় (Supabase
///     নিজেই পাঠায় — কোনো নিজস্ব সার্ভার লাগে না)।
///  ২) কোড দিয়ে যাচাই → সেশন ফোনে সংরক্ষিত থাকে (পরেরবার আর লগইন লাগে না)।
///  ৩) প্রথম লগইনে profiles টেবিলে সারি তৈরি হয় (শিক্ষক/শিক্ষার্থী ভূমিকা)।
///  ৪) profiles.is_pro = true থাকলে এই ডিভাইসে PaperLicense Pro চালু হয় —
///     টিউটর ড্যাশবোর্ড থেকে is_pro সত্য করে দিলেই শিক্ষার্থীর Pro চালু!
///
/// Supabase এখনো কনফিগ না হলে ([SupabaseConfig] ফাঁকা) সব ফাংশন নিরাপদে
/// কিছুই করে না — অ্যাপ আগের মতোই অফলাইনে চলে।
class AuthService {
  /// লগইন ফিচার ব্যবহারযোগ্য কিনা (URL + anon key পূরণ করা)
  static bool get ready => SupabaseConfig.isConfigured;

  /// অ্যাপ চালুর সময় একবার ডাকো (main.dart থেকে)।
  static Future<void> init() async {
    if (!ready) return;
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
    } catch (_) {
      // নেট না থাকলে/কনফিগ ভুল হলে অ্যাপ ক্র্যাশ করবে না
    }
  }

  static SupabaseClient get _c => Supabase.instance.client;

  static bool get isLoggedIn => ready && _c.auth.currentSession != null;

  static String? get email => isLoggedIn ? _c.auth.currentUser?.email : null;

  // ── ধাপ ১: OTP পাঠাও ──────────────────────────────────────────────
  static Future<void> sendOtp(String email) async {
    final e = email.trim();
    if (e.isEmpty || !e.contains('@')) {
      throw const AuthException('সঠিক ইমেইল ঠিকানা লেখো');
    }
    await _c.auth.signInWithOtp(email: e);
  }

  // ── ধাপ ২: OTP যাচাই ─────────────────────────────────────────────
  static Future<void> verifyOtp(String email, String code) async {
    final res = await _c.auth.verifyOTP(
      type: OtpType.email,
      token: code.trim(),
      email: email.trim(),
    );
    if (res.session == null) {
      throw const AuthException('কোড মেলেনি — আবার চেষ্টা করো');
    }
  }

  // ── প্রোফাইল পড়া ────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> fetchProfile() async {
    final u = _c.auth.currentUser;
    if (u == null) return null;
    try {
      return await _c.from('profiles').select().eq('id', u.id).maybeSingle();
    } catch (_) {
      return null;
    }
  }

  /// প্রথম লগইনে প্রোফাইল সারি তৈরি করে; আগে থেকে থাকলে পুরনোটাই ফেরত দেয়।
  static Future<Map<String, dynamic>> ensureProfile(String role) async {
    final u = _c.auth.currentUser;
    if (u == null) throw const AuthException('লগইন নেই');
    final existing = await fetchProfile();
    if (existing != null) return existing;
    try {
      await _c.from('profiles').upsert(
        {'id': u.id, 'email': u.email ?? '', 'role': role},
        onConflict: 'id',
        ignoreDuplicates: true,
      );
    } catch (_) {}
    return await fetchProfile() ??
        {'email': u.email ?? '', 'role': role, 'is_pro': false};
  }

  /// সার্ভারে is_pro থাকলে এই ডিভাইসে Pro চালু করে true ফেরত দেয়।
  /// (false হলে কিছু বন্ধ করে না — অফলাইনে আনলক করা লাইসেন্স থেকে যেতে পারে)
  static Future<bool> syncProFromServer() async {
    final p = await fetchProfile();
    if (p != null && p['is_pro'] == true) {
      await PaperLicense.markProFromServer();
      return true;
    }
    return false;
  }

  static Future<void> signOut() async {
    try {
      await _c.auth.signOut();
    } catch (_) {}
  }
}
