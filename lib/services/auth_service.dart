import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';
import 'subscription_state.dart';

/// Email + password sign-in and tutor profile (name / phone) service.
///
/// Subscription state is refreshed separately through SubscriptionRepository;
/// this class only owns authentication and profile identity.
///
/// Flow:
///  1) Sign up — name, +880 phone, email + password. Supabase emails a
///     one-time code to confirm the address, then a `profiles` row is created
///     with role `teacher`. This is the ONLY time a code is sent.
///  2) Sign in — email + password. No code, no email round-trip.
///
/// Tutor's Desk is a tutor-only product, so every account is a teacher account.
/// When Supabase is not configured ([SupabaseConfig] empty) every call degrades
/// gracefully instead of throwing, while connectivity is required for the workspace.
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

  /// Auth events let the root gate react when Supabase revokes a session on
  /// another device (for example after a newer device signs in).
  static Stream<AuthState> get authChanges => _c.auth.onAuthStateChange;

  static bool get isLoggedIn {
    if (!ready) return false;
    try {
      return _c.auth.currentSession != null;
    } catch (_) {
      return false;
    }
  }

  static String? get email => isLoggedIn ? _c.auth.currentUser?.email : null;

  /// Stable account identity for account-scoped local caches and promotions.
  static String? get userId => isLoggedIn ? _c.auth.currentUser?.id : null;

  /// The signed-in user's Supabase JWT — what the `mimi` edge function
  /// (server-side AI) needs to identify the caller. Null when signed out.
  static String? get currentUserToken {
    if (!isLoggedIn) return null;
    try {
      return _c.auth.currentSession?.accessToken;
    } catch (_) {
      return null;
    }
  }

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
        'Password must be at least $minPasswordLength characters',
      );
    }
    final res = await _c.auth.signUp(email: e, password: password);
    // When email confirmation is disabled in the Supabase project the session
    // arrives immediately and no code needs to be entered.
    if (res.session != null) {
      await _revokeOtherSessions();
      _profileCache = null;
    }
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
      res = await _c.auth.verifyOTP(type: OtpType.signup, token: c, email: e);
    } on AuthException {
      res = await _c.auth.verifyOTP(type: OtpType.email, token: c, email: e);
    }
    if (res.session == null) {
      throw const AuthException('The code did not match — please try again');
    }
    await _revokeOtherSessions();
    _profileCache = null;
  }

  /// Makes the newest verified session the only session allowed to continue.
  /// If the server cannot revoke other sessions, sign out the current session
  /// too instead of leaving multiple active devices.
  static Future<void> _revokeOtherSessions() async {
    final accountId = userId;
    try {
      await _c.auth.signOut(scope: SignOutScope.others);
    } catch (_) {
      try {
        await _c.auth.signOut();
      } catch (_) {}
      _profileCache = null;
      SubscriptionState.clear(accountId: accountId);
      throw const AuthException(
        'Could not enforce the one-device sign-in policy. Please try again.',
      );
    }
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
    // Keep the newly authenticated session and revoke every other refresh
    // token. Fail closed if Supabase cannot enforce the one-device policy.
    await _revokeOtherSessions();
    _profileCache = null;
  }

  /// Sets a password on the signed-in account (used by "change password").
  static Future<void> setPassword(String password) async {
    _requireReady();
    if (password.length < minPasswordLength) {
      throw AuthException(
        'Password must be at least $minPasswordLength characters',
      );
    }
    await _c.auth.updateUser(UserAttributes(password: password));
  }

  /// Makes sure the account carries [password], for use right after sign-up.
  ///
  /// `signUp` already attaches the password, so once the code is verified the
  /// account usually has it. Supabase then rejects re-setting the same value
  /// with "New password should be different from the old password" — which is
  /// a success for our purposes, not a failure. Anything else is rethrown.
  static Future<void> ensurePassword(String password) async {
    try {
      await setPassword(password);
    } on AuthException catch (e) {
      final m = e.message.toLowerCase();
      final alreadySet =
          m.contains('should be different') ||
          m.contains('different from the old password') ||
          m.contains('same as the old password') ||
          m.contains('same_password');
      if (!alreadySet) rethrow;
    }
  }

  /// Emails a password-reset link/code for tutors who forgot their password.
  static Future<void> sendPasswordReset(String email) async {
    _requireReady();
    await _c.auth.resetPasswordForEmail(_validEmail(email));
  }

  /// Sends the sign-up confirmation code again.
  ///
  /// Supabase's built-in mailer is rate limited (a handful of messages per
  /// hour for the whole project) and drops anything over the cap without
  /// reporting an error, so a retry is worth having.
  static Future<void> resendSignUpCode(String email) async {
    _requireReady();
    await _c.auth.resend(type: OtpType.signup, email: _validEmail(email));
  }

  // ── Reading the profile ───────────────────────────────────────────
  static Future<Map<String, dynamic>?> fetchProfile({
    bool refresh = true,
  }) async {
    if (!isLoggedIn) return null;
    if (!refresh && _profileCache != null) return _profileCache;
    final u = _c.auth.currentUser;
    if (u == null) return null;
    try {
      final row = await _c
          .from('profiles')
          .select()
          .eq('id', u.id)
          .maybeSingle()
          .timeout(const Duration(seconds: 6));
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
        await _c
            .from('profiles')
            .insert({
              'id': u.id,
              'email': u.email ?? '',
              'role': teacherRole,
              'name': name,
              'phone': phone,
            })
            .timeout(const Duration(seconds: 6));
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
          await _c
              .from('profiles')
              .update(patch)
              .eq('id', u.id)
              .timeout(const Duration(seconds: 6));
        }
      }
    } catch (_) {
      // Offline / RLS issue — fall through to whatever we can read back.
    }
    final p =
        await fetchProfile() ??
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

  /// Updates name / phone only — email, role and subscription authority are never touched.
  static Future<void> updateProfile({String? name, String? phone}) async {
    _requireReady();
    final u = _c.auth.currentUser;
    if (u == null) throw const AuthException('You are not signed in');
    final patch = <String, dynamic>{};
    if (name != null) patch['name'] = name.trim();
    if (phone != null) patch['phone'] = phone.trim();
    if (patch.isEmpty) return;
    await _c
        .from('profiles')
        .update(patch)
        .eq('id', u.id)
        .timeout(const Duration(seconds: 6));
    await fetchProfile();
  }

  /// Refreshes the centralized server-authoritative entitlement.
  ///
  /// Refreshes the centralized, server-authoritative entitlement after auth
  /// changes. It does not write a local paid flag or read plan rules itself.
  static Future<bool> refreshSubscription() async {
    if (!isLoggedIn) return false;
    await SubscriptionState.instance.refresh();
    return SubscriptionState.instance.entitlement.isPaid;
  }

  /// Confirms the local session is still accepted by Supabase. This is the
  /// startup/API boundary that turns a newer-device revocation into a clean
  /// return to authentication instead of leaving a stale workspace visible.
  static Future<bool> verifyCurrentSession() async {
    if (!ready || !isLoggedIn) return false;
    try {
      final result = await _c.auth.getUser().timeout(
        const Duration(seconds: 8),
      );
      // A successful request with no user is an invalid local session. Unlike
      // a transport failure, it is safe to clear the session here.
      if (result.user != null) return true;
      await signOut();
      return false;
    } on AuthException catch (error) {
      // An access JWT expiring is normal after the app has been idle. Do not
      // destroy the persisted refresh token: refresh once, then reject only
      // when Supabase explicitly says that refresh token is invalid/revoked.
      if (_isAccessTokenExpiry(error)) {
        return _refreshExpiredSession();
      }
      // getUser() also throws for timeouts, DNS failures and other temporary
      // transport problems. Signing out for those failures strands an
      // otherwise valid offline session. Only known auth rejections revoke it;
      // the server remains authoritative for every online operation.
      if (_isRejectedSession(error)) {
        await signOut();
        return false;
      }
      return true;
    } catch (_) {
      // Preserve the locally restored session while the network is unavailable.
      return true;
    }
  }

  static bool _isAccessTokenExpiry(AuthException error) {
    final message = error.message.toLowerCase();
    if (message.contains('refresh token')) return false;
    return message.contains('jwt expired') ||
        message.contains('token is expired') ||
        message.contains('token has expired') ||
        message.contains('access token') && message.contains('expired');
  }

  static Future<bool> _refreshExpiredSession() async {
    try {
      final response = await _c.auth.refreshSession().timeout(
        const Duration(seconds: 8),
      );
      return response.session != null;
    } on AuthException catch (error) {
      if (_isInvalidRefreshToken(error)) {
        await signOut();
        return false;
      }
      // Network/server failures must not erase a restorable local session.
      return true;
    } catch (_) {
      return true;
    }
  }

  static bool _isInvalidRefreshToken(AuthException error) {
    final message = error.message.toLowerCase();
    return message.contains('invalid refresh token') ||
        message.contains('refresh token not found') ||
        message.contains('refresh token has been revoked') ||
        message.contains('refresh_token_not_found');
  }

  static bool _isRejectedSession(AuthException error) {
    final code = error.statusCode?.toString();
    final message = error.message.toLowerCase();
    // A bare 401 can be an ordinary expired access JWT; only reject it when
    // the response also confirms invalid credentials/session. A 403 is a
    // server-authoritative denial (for example a disabled account).
    return code == '403' ||
        message.contains('invalid jwt') ||
        _isInvalidRefreshToken(error) ||
        message.contains('session has expired');
  }

  static Future<void> signOut() async {
    final accountId = userId;
    try {
      if (ready) await _c.auth.signOut();
    } catch (_) {}
    _profileCache = null;
    // Clear the account-scoped in-memory state and cache for the account that
    // just signed out, not the anonymous key after Supabase clears the user.
    SubscriptionState.clear(accountId: accountId);
  }

  static void _requireReady() {
    if (!ready) {
      throw const AuthException(
        'Sign-in is not configured yet — connect to continue.',
      );
    }
  }

  /// Turns any auth/network failure into a short, human message.
  static String friendlyError(Object e) {
    final s = e.toString().toLowerCase();

    // Network problems are checked BEFORE the AuthException shortcut below.
    // supabase_flutter wraps connection failures in
    // AuthRetryableFetchException, which extends AuthException and carries
    // the raw socket text as its message — returning that early dumped
    // "ClientException with SocketException: Failed host lookup ..." straight
    // onto the sign-in screen.
    if (s.contains('socketexception') ||
        s.contains('failed host lookup') ||
        s.contains('no address associated') ||
        s.contains('clientexception') ||
        s.contains('connection closed') ||
        s.contains('connection refused') ||
        s.contains('connection reset') ||
        s.contains('handshake') ||
        s.contains('timeout') ||
        s.contains('timed out') ||
        s.contains('network is unreachable')) {
      return 'Cannot reach the server — check your internet connection '
          '(try switching between Wi-Fi and mobile data) and try again.';
    }
    if (s.contains('rate') || s.contains('429') || s.contains('too many')) {
      return 'Too many attempts — please wait a moment and try again.';
    }
    if (e is AuthException && e.message.trim().isNotEmpty) return e.message;
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
