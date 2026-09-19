import 'dart:async';

import 'package:flutter/material.dart';

import '../services/connectivity_service.dart';
import '../theme/app_theme.dart';

/// A global, animated "offline" bar pinned to the top of every screen.
///
/// Wraps the whole app (MaterialApp.builder): when the device loses
/// internet the red bar slides down above whatever screen is open, and
/// slides back up when the connection returns.
class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  const ConnectivityBanner({super.key, required this.child});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  bool _offline = false;
  StreamSubscription<bool>? _sub;

  @override
  void initState() {
    super.initState();
    _offline = !ConnectivityService.instance.isOnline;
    ConnectivityService.instance.start();
    _sub = ConnectivityService.instance.changes.listen((online) {
      if (!mounted) return;
      setState(() => _offline = !online);
    });
    // The first real check lands asynchronously — sync up when it does.
    ConnectivityService.instance.refresh().then((online) {
      if (!mounted) return;
      final next = !online;
      if (next != _offline) setState(() => _offline = next);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: widget.child),
        AnimatedSlide(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          position: _offline ? Offset.zero : const Offset(0, -1.2),
          child: _offline
              ? Container(
                  width: double.infinity,
                  color: AppTheme.danger,
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
                  child: Row(children: [
                    const Icon(Icons.cloud_off_rounded,
                        color: Colors.white, size: 17),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Offline — no internet connection. AI question '
                        'generation is unavailable; the rest of the app '
                        'works normally.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ]),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
