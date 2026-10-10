import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';

/// App-facing promotion data managed from the Content Studio.
///
/// Offers, prizes and popup ads are public active content. Notifications are
/// filtered by Supabase RLS for the signed-in tutor's audience. All methods
/// fail closed for offline/signed-out use so the teaching workspace remains
/// usable without a network.
class PromotionOffer {
  final String id;
  final String planId;
  final String title;
  final String description;
  final int price;
  final String currency;
  final int? periodDays;
  final String badge;

  const PromotionOffer({
    required this.id,
    required this.planId,
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    required this.periodDays,
    required this.badge,
  });

  factory PromotionOffer.fromMap(Map<String, dynamic> row) => PromotionOffer(
        id: row['id']?.toString() ?? '',
        planId: row['plan_id']?.toString() ?? '',
        title: row['title']?.toString() ?? '',
        description: row['description']?.toString() ?? '',
        price: ((row['price'] as num?)?.round() ?? 0),
        currency: row['currency']?.toString() ?? 'BDT',
        periodDays: (row['period_days'] as num?)?.toInt(),
        badge: row['badge']?.toString() ?? '',
      );

  String get periodText {
    if (periodDays == null) return 'One-time payment';
    if (periodDays == 365) return 'Per year';
    if (periodDays == 30) return 'Per month';
    return 'Every $periodDays days';
  }
}

class PromotionPrize {
  final String id;
  final String title;
  final String description;
  final String valueText;
  final String imageUrl;

  const PromotionPrize({
    required this.id,
    required this.title,
    required this.description,
    required this.valueText,
    required this.imageUrl,
  });

  factory PromotionPrize.fromMap(Map<String, dynamic> row) => PromotionPrize(
        id: row['id']?.toString() ?? '',
        title: row['title']?.toString() ?? '',
        description: row['description']?.toString() ?? '',
        valueText: row['value_text']?.toString() ?? '',
        imageUrl: row['image_url']?.toString() ?? '',
      );
}

class AppNotificationItem {
  final String id;
  final String title;
  final String message;
  final String actionLabel;
  final String actionUrl;
  final DateTime? sentAt;

  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.actionUrl,
    required this.sentAt,
  });

  factory AppNotificationItem.fromMap(Map<String, dynamic> row) =>
      AppNotificationItem(
        id: row['id']?.toString() ?? '',
        title: row['title']?.toString() ?? '',
        message: row['message']?.toString() ?? '',
        actionLabel: row['action_label']?.toString() ?? '',
        actionUrl: row['action_url']?.toString() ?? '',
        sentAt: DateTime.tryParse(row['sent_at']?.toString() ?? ''),
      );
}

class PopupOfferAd {
  final String id;
  final String title;
  final String body;
  final String imageUrl;
  final String buttonText;
  final String buttonUrl;

  const PopupOfferAd({
    required this.id,
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.buttonText,
    required this.buttonUrl,
  });

  factory PopupOfferAd.fromMap(Map<String, dynamic> row) => PopupOfferAd(
        id: row['id']?.toString() ?? '',
        title: row['title']?.toString() ?? '',
        body: row['body']?.toString() ?? '',
        imageUrl: row['image_url']?.toString() ?? '',
        buttonText: row['button_text']?.toString() ?? 'View offer',
        buttonUrl: row['button_url']?.toString() ?? '/plans',
      );
}

class PromotionFeed {
  final List<PromotionOffer> offers;
  final List<PromotionPrize> prizes;
  final List<AppNotificationItem> notifications;
  final List<PopupOfferAd> ads;

  const PromotionFeed({
    this.offers = const [],
    this.prizes = const [],
    this.notifications = const [],
    this.ads = const [],
  });
}

class PromotionService {
  PromotionService._();

  static SupabaseClient get _client => Supabase.instance.client;

  static bool _isLiveWindow(Map<String, dynamic> row) {
    if (row['is_active'] != true) return false;
    final now = DateTime.now().toUtc();
    final starts = DateTime.tryParse(row['starts_at']?.toString() ?? '');
    final ends = DateTime.tryParse(row['ends_at']?.toString() ?? '');
    return (starts == null || !starts.isAfter(now)) &&
        (ends == null || ends.isAfter(now));
  }

  static bool _isSentNotification(Map<String, dynamic> row) {
    if (!_isLiveWindow(row)) return false;
    final now = DateTime.now().toUtc();
    final sent = DateTime.tryParse(row['sent_at']?.toString() ?? '');
    final scheduled = DateTime.tryParse(row['scheduled_at']?.toString() ?? '');
    return sent != null &&
        !sent.isAfter(now) &&
        (scheduled == null || !scheduled.isAfter(now));
  }

  static Future<List<PromotionOffer>> loadOffers() async {
    if (!AuthService.ready) return const [];
    try {
      final rows = await _client
          .from('paid_plan_offers')
          .select()
          .eq('is_active', true)
          .order('sort_order')
          .limit(20);
      return rows
          .map((row) => Map<String, dynamic>.from(row))
          .where(_isLiveWindow)
          .map(PromotionOffer.fromMap)
          .where((row) => row.planId.isNotEmpty && row.price > 0)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<List<PromotionPrize>> loadPrizes() async {
    if (!AuthService.ready) return const [];
    try {
      final rows = await _client
          .from('prizes')
          .select()
          .eq('is_active', true)
          .order('sort_order')
          .limit(10);
      return rows
          .map((row) => Map<String, dynamic>.from(row))
          .where(_isLiveWindow)
          .map(PromotionPrize.fromMap)
          .where((row) => row.title.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<List<AppNotificationItem>> loadNotifications() async {
    if (!AuthService.isLoggedIn) return const [];
    try {
      final rows = await _client
          .from('app_notifications')
          .select()
          .eq('is_active', true)
          .not('sent_at', 'is', null)
          .order('sent_at', ascending: false)
          .limit(10);
      return rows
          .map((row) => Map<String, dynamic>.from(row))
          .where(_isSentNotification)
          .map(AppNotificationItem.fromMap)
          .where((row) => row.id.isNotEmpty && row.title.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<List<PopupOfferAd>> loadAds() async {
    if (!AuthService.ready) return const [];
    try {
      final rows = await _client
          .from('app_offer_ads')
          .select()
          .eq('is_active', true)
          .order('priority')
          .limit(5);
      return rows
          .map((row) => Map<String, dynamic>.from(row))
          .where(_isLiveWindow)
          .map(PopupOfferAd.fromMap)
          .where((row) => row.id.isNotEmpty && row.title.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<PromotionFeed> load() async {
    final results = await Future.wait<dynamic>([
      loadOffers(),
      loadPrizes(),
      loadNotifications(),
      loadAds(),
    ]);
    return PromotionFeed(
      offers: results[0] as List<PromotionOffer>,
      prizes: results[1] as List<PromotionPrize>,
      notifications: results[2] as List<AppNotificationItem>,
      ads: results[3] as List<PopupOfferAd>,
    );
  }
}
