import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/subscription_entitlement.dart';
import '../services/auth_service.dart';

class RupantorPlan {
  final SubscriptionPlan plan;
  final int priceBdt;
  final int durationDays;
  final int? subjectLimit;
  final bool noWatermark;
  final bool aiAssistant;
  final int aiDailyLimit;
  final bool omrScanner;
  final String label;

  const RupantorPlan({
    required this.plan,
    required this.priceBdt,
    required this.durationDays,
    required this.subjectLimit,
    required this.noWatermark,
    required this.aiAssistant,
    required this.aiDailyLimit,
    required this.omrScanner,
    required this.label,
  });

  factory RupantorPlan.fromJson(Map<String, dynamic> json) {
    final plan = subscriptionPlanFromString(json['id']?.toString());
    final defaults = SubscriptionEntitlement.defaults(plan);
    return RupantorPlan(
      plan: plan,
      priceBdt: (json['price_bdt'] as num?)?.toInt() ?? 0,
      durationDays: (json['duration_days'] as num?)?.toInt() ?? 30,
      subjectLimit: (json['subject_limit'] as num?)?.toInt(),
      noWatermark: json['no_watermark'] as bool? ?? defaults.noWatermark,
      aiAssistant: json['ai_assistant'] as bool? ?? defaults.aiAssistant,
      aiDailyLimit:
          (json['ai_daily_limit'] as num?)?.toInt() ?? defaults.aiDailyLimit,
      omrScanner: json['omr_scanner'] as bool? ?? defaults.omrScanner,
      label: json['name']?.toString() ?? plan.displayName,
    );
  }

  String get id => plan.id;
  int get amount => priceBdt;
  String get periodText => '$durationDays days';

  /// Used only to keep the pricing screen useful while the server plan table
  /// is temporarily unreachable. Payment initiation still goes through the
  /// Edge Function, which reloads and validates the authoritative row before
  /// creating a transaction.
  static const fallbackPlans = <RupantorPlan>[
    RupantorPlan(
      plan: SubscriptionPlan.basic,
      priceBdt: 100,
      durationDays: 30,
      subjectLimit: 3,
      noWatermark: false,
      aiAssistant: false,
      aiDailyLimit: 0,
      omrScanner: false,
      label: 'Basic',
    ),
    RupantorPlan(
      plan: SubscriptionPlan.pro,
      priceBdt: 200,
      durationDays: 30,
      subjectLimit: 5,
      noWatermark: true,
      aiAssistant: true,
      aiDailyLimit: 20,
      omrScanner: false,
      label: 'Pro',
    ),
    RupantorPlan(
      plan: SubscriptionPlan.professional,
      priceBdt: 400,
      durationDays: 30,
      subjectLimit: null,
      noWatermark: true,
      aiAssistant: true,
      aiDailyLimit: 50,
      omrScanner: true,
      label: 'Professional',
    ),
  ];
}

class RupantorPayError implements Exception {
  final String message;
  final String? code;
  const RupantorPayError(this.message, {this.code});
  @override
  String toString() => message;
}

/// Client for the Rupantor Pay gateway adapter. All prices, credentials,
/// verification, and activation remain in the `rupantor-pay` Edge Function.
class RupantorPayService {
  RupantorPayService({SupabaseClient? client}) : _client = client;
  final SupabaseClient? _client;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  Future<List<RupantorPlan>> plans() async {
    try {
      final rows = await _supabase
          .from('subscription_plans')
          .select()
          .eq('is_active', true)
          .neq('id', 'free')
          .order('sort_order');
      final plans = [
        for (final row in rows)
          RupantorPlan.fromJson(Map<String, dynamic>.from(row))
      ]..removeWhere((plan) => plan.plan == SubscriptionPlan.free);
      return plans.isEmpty ? RupantorPlan.fallbackPlans : plans;
    } catch (_) {
      // Keep the pricing screen usable during a transient outage or before
      // the migration has reached the configured Supabase project. The
      // server remains authoritative: initiate() never sends a client price
      // and the Edge Function rejects unknown/unconfigured plans.
      return RupantorPlan.fallbackPlans;
    }
  }

  Future<RupantorPayment> initiate({required SubscriptionPlan plan}) async {
    final j = await _invoke({'action': 'initiate', 'plan': plan.id});
    final orderId = (j['orderId'] ?? j['transactionId'])?.toString();
    final checkoutUrl = j['checkoutUrl']?.toString();
    if (orderId == null || checkoutUrl == null || checkoutUrl.isEmpty) {
      throw const RupantorPayError(
          'Rupantor Pay returned an incomplete payment link.');
    }
    return RupantorPayment(
      orderId: orderId,
      checkoutUrl: checkoutUrl,
      status: j['status']?.toString() ?? 'pending',
    );
  }

  Future<String> verify(String orderId) async {
    final j = await _invoke({
      'action': 'verify',
      'orderId': orderId,
    });
    return j['status']?.toString() ?? 'pending';
  }

  Future<Map<String, dynamic>> _invoke(Map<String, Object?> body) async {
    if (!AuthService.isLoggedIn) {
      throw const RupantorPayError('Sign in before starting a subscription.');
    }
    try {
      final response = await _supabase.functions.invoke(
        'rupantor-pay',
        body: body,
      );
      if (response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        if (data['ok'] == false) {
          throw RupantorPayError(
            data['error']?.toString() ?? 'Rupantor Pay request failed.',
            code: data['code']?.toString(),
          );
        }
        return data;
      }
      throw const RupantorPayError('Unexpected payment response.');
    } on RupantorPayError {
      rethrow;
    } catch (error) {
      final details = _details(error);
      if (details is Map && details['error'] is String) {
        throw RupantorPayError(details['error'] as String);
      }
      throw const RupantorPayError(
        'Could not reach the payment server. Check your connection and try again.',
      );
    }
  }

  static Object? _details(Object error) {
    try {
      return (error as dynamic).details;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> openCheckout(String checkoutUrl) async {
    final uri = Uri.tryParse(checkoutUrl);
    if (uri == null) return false;
    try {
      if (await canLaunchUrl(uri)) {
        return launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    return false;
  }
}

class RupantorPayment {
  /// Internal Tutor's Desk order id. Rupantor's transaction id is supplied
  /// later by the completion redirect/webhook.
  final String orderId;
  final String checkoutUrl;
  final String status;
  const RupantorPayment({
    required this.orderId,
    required this.checkoutUrl,
    required this.status,
  });
}
