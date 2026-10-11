import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';

class PaperUsageClaim {
  final bool allowed;
  final String? reservationId;
  final int? paperCount;
  final int? monthlyLimit;
  final bool offline;
  final String reason;
  // Stable queue identity for an offline allowance. It lets a failed local
  // composition refund the exact queued paper when several are pending.
  final String? offlineRequestId;

  const PaperUsageClaim({
    required this.allowed,
    required this.reservationId,
    required this.paperCount,
    required this.monthlyLimit,
    required this.offline,
    required this.reason,
    this.offlineRequestId,
  });

  String get message => switch (reason) {
    'monthly_limit' =>
      'You have used this month\'s 2 Free papers. Upgrade for unlimited paper creation.',
    'format_locked' =>
      'Free plan paper generation is limited to Model Test. Upgrade to unlock other formats.',
    'server_required' =>
      'Connect to verify your Free paper allowance before creating a new paper.',
    'safety_limit' =>
      'This paper exceeds the system question limits. Reduce the MCQ, SAQ, CQ, or total count.',
    _ => 'Paper creation is not available on the current account.',
  };
}

/// Coordinates the server monthly Free-paper reservation and its safe local
/// allowance cache. The cache is a UX fallback only: online claims always go
/// through the authenticated SQL function.
class PaperUsageService {
  PaperUsageService({SupabaseClient? client}) : _client = client;

  SupabaseClient? _client;
  // Versioned when the policy changed from three legacy papers to two Model
  // Tests. Stale v1 caches must not extend the new server allowance offline.
  static const _cachePrefix = 'paper_allowance_v2_';
  static const _cacheMonthSuffix = '_month';
  static const _pendingPrefix = 'paper_allowance_pending_v1_';
  static const _pendingIdsPrefix = 'paper_allowance_pending_ids_v1_';
  final _random = Random();

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

  String get _suffix => AuthService.userId ?? 'offline';
  String get _cacheKey => '$_cachePrefix$_suffix';
  String get _cacheMonthKey => '$_cacheKey$_cacheMonthSuffix';
  String get _pendingKey => '$_pendingPrefix$_suffix';
  String get _pendingIdsKey => '$_pendingIdsPrefix$_suffix';

  String get _currentMonth {
    final date = DateTime.now().toUtc().add(const Duration(hours: 6));
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  Future<PaperUsageClaim> claim({
    required int mcqCount,
    required int saqCount,
    required int cqCount,
    String examFormat = 'model_test',
  }) async {
    final requestId =
        '${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1 << 20)}';
    final c = client;
    if (AuthService.isLoggedIn && c != null) {
      try {
        await _reconcilePending(c);
        final data = await c.rpc(
          'claim_paper_creation',
          params: {
            'p_request_id': requestId,
            'p_exam_format': examFormat,
            'p_mcq_count': mcqCount,
            'p_saq_count': saqCount,
            'p_cq_count': cqCount,
          },
        );
        final row = _row(data);
        final claim = _parse(row);
        await _saveRemaining(claim);
        return claim;
      } catch (_) {
        // A previously server-issued allowance may be used once offline. Do
        // not invent a fresh allowance when no verified cache exists.
      }
    }
    return _claimFromCachedAllowance();
  }

  Future<void> complete(PaperUsageClaim claim) async {
    final id = claim.reservationId;
    final c = client;
    if (id == null || claim.offline || !AuthService.isLoggedIn || c == null) {
      return;
    }
    try {
      await c.rpc('complete_paper_creation', params: {'p_reservation_id': id});
    } catch (_) {
      // The reservation lease prevents a permanent count if the completion
      // acknowledgement is lost. The paper was already successfully created.
    }
  }

  Future<void> refund(PaperUsageClaim claim) async {
    final id = claim.reservationId;
    final c = client;
    if (id != null && !claim.offline && AuthService.isLoggedIn && c != null) {
      try {
        await c.rpc('refund_paper_creation', params: {'p_reservation_id': id});
        await _increaseCachedAllowance();
        return;
      } catch (_) {}
    }
    if (claim.offline) {
      final prefs = await SharedPreferences.getInstance();
      final pendingIds = await _loadPendingIds(prefs);
      final queuedId = claim.offlineRequestId;
      if (queuedId != null) {
        pendingIds.remove(queuedId);
      } else if (pendingIds.isNotEmpty) {
        // Claims created by older app versions had no queue identity.
        pendingIds.removeLast();
      }
      await prefs.setStringList(_pendingIdsKey, pendingIds);
      if (pendingIds.isEmpty) {
        await prefs.remove(_pendingKey);
      } else {
        await prefs.setInt(_pendingKey, pendingIds.length);
      }
      await prefs.setInt(_cacheKey, (prefs.getInt(_cacheKey) ?? 0) + 1);
    }
  }

  Future<void> reconcile() async {
    final c = client;
    if (!AuthService.isLoggedIn || c == null) return;
    try {
      await _reconcilePending(c);
    } catch (_) {}
  }

  Future<void> _reconcilePending(SupabaseClient c) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingIds = await _loadPendingIds(prefs);
    while (pendingIds.isNotEmpty) {
      // Keep this id until both the idempotent server claim and completion have
      // returned. If the app dies between either call and local cleanup, the
      // same id resolves to the original reservation instead of consuming a
      // second monthly allowance.
      final requestId = pendingIds.first;
      final data = await c.rpc(
        'claim_paper_creation',
        params: {
          'p_request_id': requestId,
          'p_exam_format': 'model_test',
          // Offline papers were checked by PaperLimits before being queued.
          'p_mcq_count': 0,
          'p_saq_count': 0,
          'p_cq_count': 0,
        },
      );
      final row = _row(data);
      final claim = _parse(row);
      if (!claim.allowed) throw StateError('Offline paper allowance expired.');
      await _saveRemaining(claim);
      if (claim.reservationId != null) {
        await c.rpc(
          'complete_paper_creation',
          params: {'p_reservation_id': claim.reservationId},
        );
      }
      pendingIds.removeAt(0);
      await prefs.setStringList(_pendingIdsKey, pendingIds);
      await prefs.setInt(_pendingKey, pendingIds.length);
    }
    await prefs.remove(_pendingKey);
  }

  Future<List<String>> _loadPendingIds(SharedPreferences prefs) async {
    final existing = prefs.getStringList(_pendingIdsKey);
    if (existing != null) {
      return existing.where((id) => id.trim().isNotEmpty).toList();
    }
    // Migrate the old count-only queue. The generated ids are persisted before
    // reconciliation starts, so even an interrupted migration is retryable.
    final count = max(0, prefs.getInt(_pendingKey) ?? 0);
    if (count == 0) return <String>[];
    final ids = [
      for (var i = 0; i < count; i++)
        'offline_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1 << 20)}_$i',
    ];
    await prefs.setStringList(_pendingIdsKey, ids);
    return ids;
  }

  Future<PaperUsageClaim> _claimFromCachedAllowance() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_cacheMonthKey) != _currentMonth) {
      return const PaperUsageClaim(
        allowed: false,
        reservationId: null,
        paperCount: null,
        monthlyLimit: 2,
        offline: true,
        reason: 'server_required',
      );
    }
    final remaining = prefs.getInt(_cacheKey) ?? 0;
    if (remaining <= 0) {
      return const PaperUsageClaim(
        allowed: false,
        reservationId: null,
        paperCount: null,
        monthlyLimit: 2,
        offline: true,
        reason: 'server_required',
      );
    }
    await prefs.setInt(_cacheKey, remaining - 1);
    final pendingIds = await _loadPendingIds(prefs);
    final requestId =
        'offline_${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1 << 20)}';
    pendingIds.add(requestId);
    await prefs.setStringList(_pendingIdsKey, pendingIds);
    await prefs.setInt(_pendingKey, pendingIds.length);
    return PaperUsageClaim(
      allowed: true,
      reservationId: null,
      paperCount: null,
      monthlyLimit: 2,
      offline: true,
      reason: 'offline_cache',
      offlineRequestId: requestId,
    );
  }

  Future<void> _saveRemaining(PaperUsageClaim claim) async {
    final prefs = await SharedPreferences.getInstance();
    if (claim.monthlyLimit == null) {
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheMonthKey);
      return;
    }
    if (claim.paperCount == null) return;
    await prefs.setInt(
      _cacheKey,
      max(0, claim.monthlyLimit! - claim.paperCount!),
    );
    await prefs.setString(_cacheMonthKey, _currentMonth);
  }

  Future<void> _increaseCachedAllowance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cacheKey, (prefs.getInt(_cacheKey) ?? 0) + 1);
    await prefs.setString(_cacheMonthKey, _currentMonth);
  }

  static Map<String, dynamic> _row(Object? data) {
    if (data is List && data.isNotEmpty && data.first is Map) {
      return Map<String, dynamic>.from(data.first as Map);
    }
    if (data is Map) return Map<String, dynamic>.from(data);
    throw StateError('The paper allowance service returned no result.');
  }

  static PaperUsageClaim _parse(Map<String, dynamic> row) {
    return PaperUsageClaim(
      allowed: row['allowed'] == true,
      reservationId: row['reservation_id']?.toString(),
      paperCount: (row['paper_count'] as num?)?.toInt(),
      monthlyLimit: (row['monthly_limit'] as num?)?.toInt(),
      offline: false,
      reason: row['reason']?.toString() ?? 'unknown',
    );
  }
}
