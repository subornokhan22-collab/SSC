import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/subscription_entitlement.dart';
import '../services/auth_service.dart';

/// Single source of truth for a teacher's subscription entitlement.
///
/// The repository owns persistence and Supabase reads. Widgets and feature
/// services should consume [current] rather than querying `profiles` or
/// interpreting legacy `is_pro` values themselves.
class SubscriptionRepository {
  SubscriptionRepository({SupabaseClient? client}) : _client = client;

  SupabaseClient? _client;
  SubscriptionEntitlement _current = SubscriptionEntitlement.free();
  Map<String, dynamic>? _profile;
  DateTime? _lastRefresh;

  static const _cachePrefix = 'subscription_entitlement_v2_';
  static const _usageCachePrefix = 'subscription_ai_usage_v2_';

  SupabaseClient? get _supabase {
    if (_client != null) return _client;
    if (!AuthService.ready) return null;
    try {
      _client = Supabase.instance.client;
      return _client;
    } catch (_) {
      return null;
    }
  }

  SubscriptionEntitlement get current => _current.effective;
  SubscriptionEntitlement get rawCurrent => _current;
  Map<String, dynamic>? get profile => _profile;
  DateTime? get lastRefresh => _lastRefresh;

  String? get userId {
    try {
      return AuthService.userId;
    } catch (_) {
      return null;
    }
  }

  String _key(String prefix) => '$prefix${userId ?? 'offline'}';

  /// Loads the last verified entitlement immediately. Call [refresh] after
  /// this to reconcile it with the server without blocking first paint.
  Future<SubscriptionEntitlement> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(_cachePrefix));
    if (raw != null) {
      try {
        _current = SubscriptionEntitlement.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {
        _current = SubscriptionEntitlement.free();
      }
    } else {
      _current = SubscriptionEntitlement.free();
    }
    return current;
  }

  /// Reads the profile and plan row. Prices and entitlements come from the
  /// server-side table; built-in defaults are only an offline/error fallback.
  Future<SubscriptionEntitlement> refresh() async {
    final client = _supabase;
    final id = userId;
    if (client == null || id == null) return current;

    try {
      final row = await client
          .from('profiles')
          .select()
          .eq('id', id)
          .maybeSingle()
          .timeout(const Duration(seconds: 8));
      if (row == null) return current;
      _profile = Map<String, dynamic>.from(row);
      final profile = _profile!;
      // The new subscription columns are authoritative. Legacy is_pro,
      // pro_plan, and pro_until are migrated by SQL only; an old or malformed
      // profile with no new plan value must fail safe to Free rather than
      // accidentally receiving paid capabilities.
      final planValue = profile['subscription_plan']?.toString();
      final effectivePlan = planValue == null
          ? SubscriptionPlan.free
          : subscriptionPlanFromString(planValue);

      Map<String, dynamic>? planRow;
      if (effectivePlan != SubscriptionPlan.free) {
        try {
          final result = await client
              .from('subscription_plans')
              .select()
              .eq('id', effectivePlan.id)
              .eq('is_active', true)
              .maybeSingle()
              .timeout(const Duration(seconds: 5));
          if (result != null) planRow = Map<String, dynamic>.from(result);
        } catch (_) {
          // A migration may not have reached this project yet. Use the safe
          // built-in matrix while retaining the legacy profile read.
        }
      }

      final startedAt = _date(profile['subscription_started_at']);
      final expiresAt = _date(
        profile['subscription_expires_at'] ?? profile['pro_until'],
      );
      final statusRaw = profile['subscription_status']?.toString();
      final status = statusRaw == null
          ? SubscriptionStatus.active
          : subscriptionStatusFromString(statusRaw);
      final next = planRow == null
          ? SubscriptionEntitlement.defaults(
              effectivePlan,
              status: status,
              startedAt: startedAt,
              expiresAt: expiresAt,
              provider: profile['subscription_provider']?.toString(),
              transactionId: profile['subscription_transaction_id']?.toString(),
              lastVerifiedAt: DateTime.now().toUtc(),
            )
          : SubscriptionEntitlement.fromPlanRow(
              planRow,
              requestedPlan: effectivePlan,
              status: status,
              startedAt: startedAt,
              expiresAt: expiresAt,
              provider: profile['subscription_provider']?.toString(),
              transactionId: profile['subscription_transaction_id']?.toString(),
              lastVerifiedAt: DateTime.now().toUtc(),
            );
      _current = next;
      _lastRefresh = DateTime.now().toUtc();
      await _save();
      await refreshAiUsage();
      return current;
    } catch (_) {
      return current;
    }
  }

  static DateTime? _date(Object? value) =>
      value == null ? null : DateTime.tryParse(value.toString())?.toUtc();

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(_cachePrefix), jsonEncode(_current.toJson()));
  }

  /// Refreshes the user's display-only AI counter. The server remains
  /// authoritative and the AI edge function performs the atomic claim.
  Future<int> refreshAiUsage() async {
    final client = _supabase;
    final id = userId;
    if (client == null || id == null) return cachedAiUsedToday;
    final date = dhakaDateString();
    try {
      final row = await client
          .from('ai_usage_daily')
          .select('request_count')
          .eq('user_id', id)
          .eq('usage_date', date)
          .maybeSingle()
          .timeout(const Duration(seconds: 5));
      final used = (row?['request_count'] as num?)?.toInt() ?? 0;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key(_usageCachePrefix), used);
      return used;
    } catch (_) {
      return cachedAiUsedToday;
    }
  }

  Future<int> get cachedAiUsedToday async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key(_usageCachePrefix)) ?? 0;
  }

  /// Bangladesh has no DST. This is only for display/cache lookup; the server
  /// RPC also computes the date itself and never trusts this client value.
  static String dhakaDateString([DateTime? now]) {
    final local = (now ?? DateTime.now()).toUtc().add(const Duration(hours: 6));
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  Future<void> clear({String? accountId}) async {
    final prefs = await SharedPreferences.getInstance();
    final suffix = accountId ?? userId ?? 'offline';
    await prefs.remove('$_cachePrefix$suffix');
    await prefs.remove('$_usageCachePrefix$suffix');
    _profile = null;
    _current = SubscriptionEntitlement.free();
    _lastRefresh = null;
  }
}
