/// Paper-specific limits kept for compatibility with older integrations.
///
/// Subscription access and entitlements belong to SubscriptionEntitlement and
/// SubscriptionState; this class must never decide whether a teacher is paid.
@Deprecated('Use SubscriptionEntitlement for subscription access.')
class PaperLicense {
  static const int demoMcqLimit = 6;
  static const int demoCqLimit = 2;
}
