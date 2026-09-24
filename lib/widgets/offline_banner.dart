import 'dart:async';

import 'package:flutter/material.dart';

import '../services/connectivity_service.dart';
import '../theme/app_theme.dart';

/// A global, animated "offline" bar pinned to the top of every screen
/// (below the status bar).
///
/// Wraps the whole app (MaterialApp.builder): when the device loses
/// internet the red gradient bar slides down above whatever screen is
/// open, and slides back up when the connection returns.
///
/// The banner is a `Positioned` child of the stack (top/left/right fixed,
/// no bottom) so it sizes to its own content height — a non-positioned
/// stack child would be stretched over the whole screen.
class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  const ConnectivityBanner({super.key, required this.child});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner>
    with SingleTickerProviderStateMixin {
  bool _offline = false;
  StreamSubscription<bool>? _sub;

  /// 0 = hidden (slid up), 1 = visible. Driven by plain core animation
  /// APIs so it behaves identically on every Flutter version.
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
    reverseDuration: const Duration(milliseconds: 320),
  );

  @override
  void initState() {
    super.initState();
    _offline = !ConnectivityService.instance.isOnline;
    if (_offline) _ctrl.value = 1; // already offline on startup: show at once
    ConnectivityService.instance.start();
    _sub = ConnectivityService.instance.changes.listen(_onConnectivity);
    // The first real check lands asynchronously — sync up when it does.
    ConnectivityService.instance.refresh().then(_onConnectivity);
  }

  void _onConnectivity(bool online) {
    if (!mounted) return;
    final next = !online;
    if (next == _offline) return;
    setState(() => _offline = next);
    if (next) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBar = MediaQuery.of(context).padding.top;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: widget.child),
        Positioned(
          top: statusBar,
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              final t = Curves.easeOutCubic.transform(_ctrl.value);
              return Transform.translate(
                offset: Offset(0, -1.6 * (1 - t)),
                child: _offline
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(14, 7, 14, 9),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFE5484D), Color(0xFFA81F26)],
                            stops: [0, .85],
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Color(0x33E5484D),
                                blurRadius: 14,
                                offset: Offset(0, 4)),
                          ],
                        ),
                        child: Row(children: [
                          const _PulsingOfflineIcon(),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Offline — no internet connection',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 1),
                                Text(
                                  'AI question generation unavailable — '
                                  'everything else works',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Color(0xE6FFE3E4),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      )
                    : const SizedBox(width: double.infinity),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// The cloud-off icon with a gentle breathing pulse so the bar reads as
/// "live" while offline.
class _PulsingOfflineIcon extends StatefulWidget {
  const _PulsingOfflineIcon();

  @override
  State<_PulsingOfflineIcon> createState() => _PulsingOfflineIconState();
}

class _PulsingOfflineIconState extends State<_PulsingOfflineIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Transform.scale(
          scale: 1 + .14 * _c.value,
          child: const Icon(Icons.cloud_off_rounded,
              color: Colors.white, size: 18)),
    );
  }
}
