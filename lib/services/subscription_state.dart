import '../view_models/subscription_view_model.dart';

/// Process-wide state object shared by screens. It is intentionally a plain
/// ChangeNotifier rather than a UI framework dependency so services and tests
/// can use the same repository.
class SubscriptionState {
  SubscriptionState._();
  static final SubscriptionViewModel instance = SubscriptionViewModel();

  static void clear({String? accountId}) => instance.clear(accountId: accountId);
}
