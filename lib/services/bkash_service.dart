import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// bKash payment client — talks to the "bkash" Supabase edge function.
///
/// Flow: [initiate] starts a bKash Collect payment (the function holds the
/// merchant credentials, the app never sees them) → the user pays at the
/// returned checkout URL in the bKash app/browser → [verify] asks the
/// function to run bKash's inquiry API; when bKash reports Success the
/// function marks the user's profile Pro and [verify] returns 'active'.

class BkashError implements Exception {
  final String message;
  const BkashError(this.message);
  @override
  String toString() => message;
}

class BkashPlan {
  final String id; // 'monthly' | 'yearly' | 'lifetime'
  final int amount;
  final String label;
  final String periodText;
  const BkashPlan(this.id, this.amount, this.label, this.periodText);
}

class BkashService {
  // ── ⚠️ EDIT PRICES HERE (must match the plan amounts set in the
  // "bkash" Supabase edge function — see SUPABASE_BKASH_SETUP.md) ──
  static const List<BkashPlan> plans = [
    BkashPlan('monthly', 299, 'Monthly', '৳299 per month'),
    BkashPlan('yearly', 2499, 'Yearly', '৳2,499 per year'),
    BkashPlan('lifetime', 799, 'One-time', '৳799 — Pro forever'),
  ];

  static BkashPlan byId(String id) =>
      plans.firstWhere((p) => p.id == id, orElse: () => plans.last);

  /// Starts the payment. Returns (TrxID, bKash checkout URL).
  static Future<(String, String)> initiate({
    required BkashPlan plan,
    required String phone,
    String name = '',
    String email = '',
  }) async {
    final res = await Supabase.instance.client.functions.invoke('bkash',
        body: {
          'action': 'initiate',
          'plan': plan.id,
          'phone': phone,
          'buyerName': name,
          'buyerEmail': email,
        });
    if (res.error != null) throw BkashError(res.error.message);
    final j = res.data;
    if (j is! Map) throw const BkashError('Unexpected payment response.');
    final trxId = j['trxId'] as String?;
    final url = j['checkoutUrl'] as String?;
    if (trxId == null || url == null || url.isEmpty) {
      throw BkashError('Could not start the bKash payment. Try again.');
    }
    return (trxId, url);
  }

  /// Asks bKash (via the function) what happened to this TrxID.
  /// Returns 'active' (paid + Pro turned on), 'pending', or 'failed'.
  static Future<String> verify(String trxId) async {
    final res = await Supabase.instance.client
        .functions.invoke('bkash', body: {'action': 'verify', 'trxId': trxId});
    if (res.error != null) throw BkashError(res.error.message);
    final j = res.data;
    if (j is Map) {
      return (j['status'] as String?) ?? 'pending';
    }
    return 'pending';
  }

  /// Opens the bKash checkout in the bKash app when available, otherwise
  /// the default browser. Returns false when nothing could be opened.
  static Future<bool> openCheckout(String url) async {
    final u = Uri.tryParse(url);
    if (u == null) return false;
    try {
      if (await canLaunchUrl(u)) {
        return await launchUrl(u, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    return false;
  }
}
