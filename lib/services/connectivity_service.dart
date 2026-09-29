import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Tracks whether the device actually has internet.
///
/// OS connectivity events (wifi/cellular state) alone are not enough: a
/// connected wifi with no internet must still count as offline — so each
/// event is confirmed with a quick real reachability check (DNS lookup with
/// a short timeout). State changes are broadcast to listeners; the last
/// known state is cached so the UI can read it synchronously.
class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _changes = StreamController<bool>.broadcast();

  /// Assume online until the first check proves otherwise.
  bool _online = true;
  bool _checking = false;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  /// Emits `true` (online) / `false` (offline) whenever the state flips.
  Stream<bool> get changes => _changes.stream;

  /// Last known connectivity state — safe to read synchronously.
  bool get isOnline => _online;

  /// Starts listening to OS connectivity events and runs the first check.
  /// Idempotent — safe to call from several widgets.
  Future<void> start() async {
    _sub ??= _connectivity.onConnectivityChanged.listen((_) => refresh());
    await refresh();
  }

  /// Re-checks now and returns the current state.
  Future<bool> refresh() async {
    if (_checking) return _online;
    _checking = true;
    try {
      final results = await _connectivity.checkConnectivity();
      final hasNetwork = results.any(
        (r) => r != ConnectivityResult.none && r != ConnectivityResult.vpn,
      );
      final reallyOnline = hasNetwork ? await _canReachInternet() : false;
      _setOnline(reallyOnline);
    } catch (_) {
      // Check failed (e.g. DNS unavailable) — keep the last known state.
    } finally {
      _checking = false;
    }
    return _online;
  }

  void _setOnline(bool online) {
    if (online != _online) {
      _online = online;
      if (!_changes.isClosed) _changes.add(online);
    }
  }

  /// Real reachability check: a quick DNS lookup with a short timeout.
  Future<bool> _canReachInternet() async {
    try {
      final addresses = await InternetAddress.lookup('clients3.google.com')
          .timeout(const Duration(seconds: 4));
      return addresses.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
