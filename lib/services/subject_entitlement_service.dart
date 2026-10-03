import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/subscription_entitlement.dart';
import '../repositories/subscription_repository.dart';
import 'auth_service.dart';
import 'subscription_state.dart';

class SubjectLimitResult {
  final bool allowed;
  final bool alreadySelected;
  final int? limit;
  final int selectedCount;
  final UpgradeReason? reason;
  final SubscriptionPlan plan;

  const SubjectLimitResult({
    required this.allowed,
    required this.alreadySelected,
    required this.limit,
    required this.selectedCount,
    required this.plan,
    this.reason,
  });

  String get message {
    if (allowed) return '';
    return 'Your ${plan.displayName} plan allows up to $limit subjects.';
  }
}

/// Persists the teacher's selected subjects separately from open papers.
class SubjectEntitlementService {
  SubjectEntitlementService({
    SubscriptionRepository? subscriptions,
    SupabaseClient? client,
  })  : subscriptions = subscriptions ?? SubscriptionState.instance.repository,
        _client = client;

  final SubscriptionRepository subscriptions;
  SupabaseClient? _client;
  Set<String> _selected = <String>{};
  bool _loaded = false;

  SupabaseClient? get client {
    if (_client != null) return _client;
    if (!AuthService.ready) return null;
    try {
      _client = Supabase.instance.client;
      return _client;
    } catch (_) {
      return null;
    }
  }

  Set<String> get selectedSubjects => Set.unmodifiable(_selected);

  String get _cacheKey =>
      'selected_subjects_v1_${AuthService.userId ?? 'offline'}';

  Future<Set<String>> load() async {
    if (_loaded) return selectedSubjects;
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getStringList(_cacheKey) ?? const <String>[];
    _selected = local.toSet();
    final id = AuthService.userId;
    final c = client;
    if (id != null && c != null) {
      try {
        final rows = await c
            .from('user_subjects')
            .select('subject_id')
            .eq('user_id', id)
            .timeout(const Duration(seconds: 6));
        _selected = {
          ..._selected,
          for (final row in rows)
            if (row['subject_id'] != null) row['subject_id'].toString(),
        };
        await _persist();
      } catch (_) {
        // Keep the last verified local selection while offline.
      }
    }
    _loaded = true;
    return selectedSubjects;
  }

  Future<SubjectLimitResult> check(String subjectId) async {
    await load();
    final entitlement = subscriptions.current;
    final already = _selected.contains(subjectId);
    final allowed = already ||
        entitlement.subjectLimit == null ||
        _selected.length < entitlement.subjectLimit!;
    return SubjectLimitResult(
      allowed: allowed,
      alreadySelected: already,
      limit: entitlement.subjectLimit,
      selectedCount: _selected.length,
      plan: entitlement.plan,
      reason: allowed ? null : UpgradeReason.subjectLimit,
    );
  }

  Future<SubjectLimitResult> canUseSubject(String subjectId) =>
      check(subjectId);

  Future<SubjectLimitResult> select(String subjectId) async {
    final result = await check(subjectId);
    if (!result.allowed || result.alreadySelected) return result;
    final id = AuthService.userId;
    final c = client;
    if (id != null && c != null) {
      try {
        final data = await c.rpc(
          'select_user_subject',
          params: {'p_subject_id': subjectId},
        );
        final row = _rpcRow(data);
        final serverPlan = subscriptionPlanFromString(row['plan_id']?.toString());
        final allowed = row['allowed'] == true;
        if (!allowed) {
          return SubjectLimitResult(
            allowed: false,
            alreadySelected: false,
            limit: (row['subject_limit'] as num?)?.toInt() ?? result.limit,
            selectedCount:
                (row['subject_count'] as num?)?.toInt() ?? result.selectedCount,
            plan: serverPlan,
            reason: UpgradeReason.subjectLimit,
          );
        }
        _selected.add(subjectId);
        await _persist();
        return SubjectLimitResult(
          allowed: true,
          alreadySelected: row['already_selected'] == true,
          limit: (row['subject_limit'] as num?)?.toInt() ?? result.limit,
          selectedCount:
              (row['subject_count'] as num?)?.toInt() ?? result.selectedCount,
          plan: serverPlan,
        );
      } catch (_) {
        // Offline selection is still allowed against the last verified local
        // entitlement. The next online selection is rechecked by SQL.
      }
    }
    _selected.add(subjectId);
    await _persist();
    return SubjectLimitResult(
      allowed: true,
      alreadySelected: false,
      limit: result.limit,
      selectedCount: _selected.length,
      plan: subscriptions.current.plan,
    );
  }

  Future<void> remove(String subjectId) async {
    final id = AuthService.userId;
    final c = client;
    if (id != null && c != null) {
      try {
        await c.rpc(
          'remove_user_subject',
          params: {'p_subject_id': subjectId},
        );
      } catch (_) {
        // Keep the local selection usable if the account is temporarily offline.
      }
    }
    _selected.remove(subjectId);
    await _persist();
  }

  static Map<String, dynamic> _rpcRow(Object? data) {
    if (data is List && data.isNotEmpty && data.first is Map) {
      return Map<String, dynamic>.from(data.first as Map);
    }
    if (data is Map) return Map<String, dynamic>.from(data);
    throw StateError('Subject entitlement service returned no result.');
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_cacheKey, _selected.toList()..sort());
  }

  void clear() {
    _selected = <String>{};
    _loaded = false;
  }
}
