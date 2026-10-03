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

  const PaperUsageClaim({
    required this.allowed,
    required this.reservationId,
    required this.paperCount,
    required this.monthlyLimit,
    required this.offline,
    required this.reason,
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
      await c.rpc(
        'complete_paper_creation',
        params: {'p_reservation_id': id},
      );
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
        await c.rpc(
          'refund_paper_creation',
          params: {'p_reservation_id': id},
        );
        await _increaseCachedAllowance();
        return;
      } catch (_) {}
    }
    if (claim.offline) {
      final prefs = await SharedPreferences.getInstance();
      final pending = max(0, prefs.getInt(_pendingKey) ?? 0);
      await prefs.setInt(_pendingKey, max(0, pending - 1));
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
    var pending = max(0, prefs.getInt(_pendingKey) ?? 0);
    while (pending > 0) {
      final requestId =
          'offline_${DateTime.now().microsecondsSinceEpoch}_$pending';
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
      pending--;
      await prefs.setInt(_pendingKey, pending);
    }
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
    await prefs.setInt(_pendingKey, (prefs.getInt(_pendingKey) ?? 0) + 1);
    return PaperUsageClaim(
      allowed: true,
      reservationId: null,
      paperCount: null,
      monthlyLimit: 2,
      offline: true,
      reason: 'offline_cache',
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
