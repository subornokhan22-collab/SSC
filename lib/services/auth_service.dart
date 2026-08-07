import 'package:supabase_flutter/supabase_flutter.dart';

import 'paper_license.dart';
import 'supabase_config.dart';

/// ইমেইল OTP লগইন + প্রোফাইল (নাম/ফোন/ভূমিকা) + Pro সিংক (Supabase)
///
/// ধারা:
///  ১) সাইন-আপ: নাম, ভূমিকা (শিক্ষক/শিক্ষার্থী), +880 ফোন, ইমেইল → OTP →
///     profiles টেবিলে সব তথ্যসহ সারি তৈরি।
///  ২) সাইন-ইন: ইমেইল → OTP → আগের প্রোফাইল লোড।
///  ৩) profiles.is_pro = true হলে সিংকে এই ডিভাইসে Pro চালু হয়।
///
/// Supabase কনফিগ না হলে ([SupabaseConfig] ফাঁকা) সব নিরাপদে skip হয়।
class AuthService {
  static bool get ready => SupabaseConfig.isConfigured;

  static Future<void> init() async {
    if (!ready) return;
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
    } catch (_) {}
  }

  static SupabaseClient get _c => Supabase.instance.client;

  static bool get isLoggedIn => ready && _c.auth.currentSession != null;

  static String? get email => isLoggedIn ? _c.auth.currentUser?.email : null;

  // ── ভূমিকা ক্যাশ (শিক্ষক/শিক্ষার্থী) ────────────────────────────
  static String? _roleCache;

  /// লগইন করা ব্যবহারকারীর ভূমিকা ('teacher'/'student'/null)।
  static Future<String?> role({bool refresh = false}) async {
    if (!isLoggedIn) return null;
    if (_roleCache != null && !refresh) return _roleCache;
    final p = await fetchProfile();
    _roleCache = p?['role']?.toString();
    return _roleCache;
  }

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

  /// প্রথম লগইনে প্রোফাইল সারি তৈরি করে (নাম/ফোন/ভূমিকা-সহ)।
  /// আগে থেকে সারি থাকলে শুধু **ফাঁকা** ঘরগুলো (নাম/ফোন) পূরণ করে —
  /// পুরনো তথ্য কখনো মুছে ফেলে না।
  static Future<Map<String, dynamic>> ensureProfile({
    required String role,
    String name = '',
    String phone = '',
  }) async {
    final u = _c.auth.currentUser;
    if (u == null) throw const AuthException('লগইন নেই');
    final existing = await fetchProfile();
    try {
      if (existing == null) {
        // একদম নতুন — পুরো সারি তৈরি করো
        await _c.from('profiles').insert({
          'id': u.id,
          'email': u.email ?? '',
          'role': role,
          'name': name,
          'phone': phone,
        });
      } else {
        // আগের সারি আছে — শুধু ফাঁকা ঘরগুলো পূরণ করো
        final patch = <String, dynamic>{};
        if ((existing['name']?.toString() ?? '').isEmpty && name.isNotEmpty) {
          patch['name'] = name;
        }
        if ((existing['phone']?.toString() ?? '').isEmpty && phone.isNotEmpty) {
          patch['phone'] = phone;
        }
        if ((existing['role']?.toString() ?? '').isEmpty && role.isNotEmpty) {
          patch['role'] = role;
        }
        if (patch.isNotEmpty) {
          await _c.from('profiles').update(patch).eq('id', u.id);
        }
      }
    } catch (_) {}
    final p = await fetchProfile() ??
        {
          'email': u.email ?? '',
          'role': role,
          'name': name,
          'phone': phone,
          'is_pro': false,
        };
    _roleCache = p['role']?.toString();
    return p;
  }

  /// নাম/ফোন পরে বদলানো (প্রোফাইল সম্পাদনা) — শুধু দেওয়া ঘরগুলো আপডেট হয়।
  /// (email/role/is_pro এখানে ছোঁয়া হয় না)
  static Future<void> updateProfile({String? name, String? phone}) async {
    final u = _c.auth.currentUser;
    if (u == null) throw const AuthException('লগইন নেই');
    final patch = <String, dynamic>{};
    if (name != null) patch['name'] = name.trim();
    if (phone != null) patch['phone'] = phone;
    if (patch.isEmpty) return;
    await _c.from('profiles').update(patch).eq('id', u.id);
  }

  /// সার্ভারে is_pro থাকলে এই ডিভাইসে Pro চালু করে true ফেরত দেয়।
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
    _roleCache = null;
  }
}
