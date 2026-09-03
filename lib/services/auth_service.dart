import 'package:supabase_flutter/supabase_flutter.dart';

import 'paper_license.dart';
import 'supabase_config.dart';

/// Email + password sign-in, tutor profile (name / phone), Pro sync (Supabase).
///
/// Flow:
///  1) Sign up — name, +880 phone, email + password. Supabase emails a
///     one-time code to confirm the address, then a `profiles` row is created
///     with role `teacher`. This is the ONLY time a code is sent.
///  2) Sign in — email + password. No code, no email round-trip.
///  3) If `profiles.is_pro` is true, syncing turns Pro on for this device.
///
/// Mentor's Companion is a tutor-only product, so every account is a teacher account.
/// When Supabase is not configured ([SupabaseConfig] empty) every call degrades
/// gracefully instead of throwing, and the offline features keep working.
class AuthService {
  AuthService._();

  /// Role stored for every account created by this app.
  static const String teacherRole = 'teacher';

  static bool _initialised = false;

  static bool get ready => SupabaseConfig.isConfigured && _initialised;

  static Future<void> init() async {
    if (!SupabaseConfig.isConfigured) return;
    if (_initialised) return;
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      _initialised = true;
    } catch (_) {
      _initialised = false;
    }
  }

  static SupabaseClient get _c => Supabase.instance.client;

  static bool get isLoggedIn {
    if (!ready) return false;
    try {
      return _c.auth.currentSession != null;
    } catch (_) {
      return false;
    }
  }

  static String? get email => isLoggedIn ? _c.auth.currentUser?.email : null;

  static Map<String, dynamic>? _profileCache;

  /// Cached profile, if one has already been fetched this session.
  static Map<String, dynamic>? get cachedProfile => _profileCache;

  /// Display name for headers/greetings; falls back to the email handle.
  static String get displayName {
    final n = _profileCache?['name']?.toString().trim() ?? '';
    if (n.isNotEmpty) return n;
    final e = email ?? '';
    return e.contains('@') ? e.split('@').first : e;
  }

  /// Minimum length enforced on new passwords (Supabase default is 6).
  static const int minPasswordLength = 8;

  static String _validEmail(String email) {
    final e = email.trim();
    if (e.isEmpty || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e)) {
      throw const AuthException('Enter a valid email address');
    }
    return e;
  }

  // ── Sign up: create the account, Supabase emails a one-time code ──
  //
  // The verification code is only ever sent here, at sign-up. Afterwards the
  // tutor signs in with their email + password and receives no further codes.
  static Future<void> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    _requireReady();
    final e = _validEmail(email);
    if (password.length < minPasswordLength) {
      throw AuthException(
          'Password must be at least $minPasswordLength characters');
    }
    final res = await _c.auth.signUp(email: e, password: password);
    // When email confirmation is disabled in the Supabase project the session
    // arrives immediately and no code needs to be entered.
    if (res.session != null) _profileCache = null;
  }

  /// True when sign-up returned a usable session (no email confirmation step).
  static bool get hasSession => isLoggedIn;

  // ── Verify the sign-up code (only used once, right after sign-up) ──
  static Future<void> verifySignUpCode({
    required String email,
    required String code,
  }) async {
    _requireReady();
    final c = code.trim();
    if (c.isEmpty) throw const AuthException('Enter the code from your email');
    final e = email.trim();
    AuthResponse? res;
    // Newer projects issue a `signup` token; older ones fall back to `email`.
    try {
      res = await _c.auth
          .verifyOTP(type: OtpType.signup, token: c, email: e);
    } on AuthException {
      res = await _c.auth.verifyOTP(type: OtpType.email, token: c, email: e);
    }
    if (res.session == null) {
      throw const AuthException('The code did not match — please try again');
    }
    _profileCache = null;
  }

  // ── Sign in: email + password only, never a code ──────────────────
  static Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    _requireReady();
    final e = _validEmail(email);
    if (password.isEmpty) throw const AuthException('Enter your password');
    final res = await _c.auth.signInWithPassword(email: e, password: password);
    if (res.session == null) {
      throw const AuthException('Could not sign in — please try again');
    }
    _profileCache = null;
  }

  /// Sets a password on the signed-in account (used right after sign-up when
  /// the account was confirmed by code, and by "change password").
  static Future<void> setPassword(String password) async {
    _requireReady();
    if (password.length < minPasswordLength) {
      throw AuthException(
          'Password must be at least $minPasswordLength characters');
    }
    await _c.auth.updateUser(UserAttributes(password: password));
  }

  /// Emails a password-reset link/code for tutors who forgot their password.
  static Future<void> sendPasswordReset(String email) async {
    _requireReady();
    await _c.auth.resetPasswordForEmail(_validEmail(email));
  }

  // ── Reading the profile ───────────────────────────────────────────
  static Future<Map<String, dynamic>?> fetchProfile({bool refresh = true}) async {
    if (!isLoggedIn) return null;
    if (!refresh && _profileCache != null) return _profileCache;
    final u = _c.auth.currentUser;
    if (u == null) return null;
    try {
      final row =
          await _c.from('profiles').select().eq('id', u.id).maybeSingle();
      if (row != null) _profileCache = Map<String, dynamic>.from(row);
      return _profileCache;
    } catch (_) {
      return _profileCache;
    }
  }

  /// Creates the tutor profile row on first sign-in, filling only the blanks
  /// on an existing row so nothing the teacher already saved is overwritten.
  static Future<Map<String, dynamic>> ensureTeacherProfile({
    String name = '',
    String phone = '',
  }) async {
    final u = _c.auth.currentUser;
    if (u == null) throw const AuthException('You are not signed in');
    final existing = await fetchProfile();
    try {
      if (existing == null) {
        await _c.from('profiles').insert({
          'id': u.id,
          'email': u.email ?? '',
          'role': teacherRole,
          'name': name,
          'phone': phone,
        });
      } else {
        final patch = <String, dynamic>{};
        if ((existing['name']?.toString() ?? '').isEmpty && name.isNotEmpty) {
          patch['name'] = name;
        }
        if ((existing['phone']?.toString() ?? '').isEmpty && phone.isNotEmpty) {
          patch['phone'] = phone;
        }
        if ((existing['role']?.toString() ?? '') != teacherRole) {
          patch['role'] = teacherRole;
        }
        if (patch.isNotEmpty) {
          await _c.from('profiles').update(patch).eq('id', u.id);
        }
      }
    } catch (_) {
      // Offline / RLS issue — fall through to whatever we can read back.
    }
    final p = await fetchProfile() ??
        <String, dynamic>{
          'email': u.email ?? '',
          'role': teacherRole,
          'name': name,
          'phone': phone,
          'is_pro': false,
        };
    _profileCache = p;
    return p;
  }

  /// Updates name / phone only — email, role and is_pro are never touched.
  static Future<void> updateProfile({String? name, String? phone}) async {
    _requireReady();
    final u = _c.auth.currentUser;
    if (u == null) throw const AuthException('You are not signed in');
    final patch = <String, dynamic>{};
    if (name != null) patch['name'] = name.trim();
    if (phone != null) patch['phone'] = phone.trim();
    if (patch.isEmpty) return;
    await _c.from('profiles').update(patch).eq('id', u.id);
    await fetchProfile();
  }

  /// Turns Pro on for this device when the server has it enabled.
  static Future<bool> syncProFromServer() async {
    if (!isLoggedIn) return false;
    final p = await fetchProfile();
    if (p != null && p['is_pro'] == true) {
      await PaperLicense.markProFromServer();
      return true;
    }
    return false;
  }

  static Future<void> signOut() async {
    try {
      if (ready) await _c.auth.signOut();
    } catch (_) {}
    _profileCache = null;
  }

  static void _requireReady() {
    if (!ready) {
      throw const AuthException(
          'Sign-in is not configured yet — offline features still work');
    }
  }

  /// Turns any auth/network failure into a short, human message.
  static String friendlyError(Object e) {
    if (e is AuthException && e.message.trim().isNotEmpty) return e.message;
    final s = e.toString().toLowerCase();
    if (s.contains('rate') || s.contains('429') || s.contains('too many')) {
      return 'Too many attempts — please wait a moment and try again.';
    }
    if (s.contains('socketexception') ||
        s.contains('failed host lookup') ||
        s.contains('network') ||
        s.contains('timeout')) {
      return 'No internet — check your connection and try again.';
    }
    if (s.contains('invalid login credentials') ||
        s.contains('invalid_credentials')) {
      return 'Wrong email or password — please try again.';
    }
    if (s.contains('email not confirmed')) {
      return 'Please confirm your email first, then sign in.';
    }
    if (s.contains('user already registered') ||
        s.contains('already been registered')) {
      return 'That email already has an account — sign in instead.';
    }
    if (s.contains('expired') || s.contains('invalid') || s.contains('token')) {
      return 'That code is wrong or expired — request a new one.';
    }
    return 'Something went wrong — please try again.';
  }
}
