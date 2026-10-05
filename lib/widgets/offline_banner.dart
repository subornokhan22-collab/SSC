import 'dart:async';

import 'package:flutter/material.dart';

import '../services/connectivity_service.dart';
import 'offline_dialog.dart';

/// The banner is built above the app Navigator by MaterialApp.builder. Use a
/// key for the actual Navigator so the blocking dialog is pushed on its
/// overlay rather than looking for a Navigator in the banner's context.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Keeps the app-level connectivity listener alive and presents the blocking
/// offline dialog. The former non-blocking upper banner is intentionally not
/// rendered; the full-screen offline state is the only offline UI surface.
class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  const ConnectivityBanner({super.key, required this.child});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  bool _offline = false;
  bool _dialogOpen = false;
  StreamSubscription<bool>? _sub;

  @override
  void initState() {
    super.initState();
    _offline = !ConnectivityService.instance.isOnline;
    // Subscribe before the first check so an offline result cannot be missed.
    _sub = ConnectivityService.instance.changes.listen(_onConnectivity);
    ConnectivityService.instance.start();
    // The first real check lands asynchronously — sync up when it does.
    ConnectivityService.instance.refresh().then(_onConnectivity);
    if (_offline) unawaited(_blockOffline());
  }

  Future<void> _blockOffline() async {
    if (!mounted || _dialogOpen || ConnectivityService.instance.isOnline) {
      return;
    }
    final overlayContext = rootNavigatorKey.currentState?.overlay?.context;
    if (overlayContext == null) {
      // The initial connectivity result can arrive before the Navigator's
      // overlay has mounted. Retry after the first frame rather than leaving
      // the app without its blocking offline state.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !ConnectivityService.instance.isOnline) {
          unawaited(_blockOffline());
        }
      });
      return;
    }
    _dialogOpen = true;
    await showOfflineDialog(overlayContext);
    _dialogOpen = false;
    if (mounted && !ConnectivityService.instance.isOnline) {
      unawaited(_blockOffline());
    }
  }

  void _onConnectivity(bool online) {
    if (!mounted) return;
    final next = !online;
    if (next == _offline) {
      if (next) unawaited(_blockOffline());
      return;
    }
    _offline = next;
    if (next) unawaited(_blockOffline());
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
