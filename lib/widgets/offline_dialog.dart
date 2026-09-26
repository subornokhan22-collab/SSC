import 'package:flutter/material.dart';

import '../services/connectivity_service.dart';
import '../theme/app_theme.dart';
import 'motion_policy.dart';

/// A dramatic "offline" alert for the app-open page: dark card, glowing
/// red frame, pulsing signal rings around the cloud-off icon, and a live
/// "Check connection" action that re-tests the network. Returns `true` if
/// the connection came back while the dialog was open.
Future<bool> showOfflineDialog(BuildContext context) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Offline',
    barrierColor: const Color(0xB3070B16),
    transitionDuration: MotionPolicy.duration(context, 200),
    transitionBuilder: (c, enter, _, child) {
      if (MotionPolicy.reduce(c)) return child;
      final curved = CurvedAnimation(
        parent: enter,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final scale = Tween<double>(begin: .86, end: 1).animate(curved);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(scale: scale, child: child),
      );
    },
    pageBuilder: (c, _, __) => const _OfflineCard(),
  ).then((v) => v ?? false);
}

class _OfflineCard extends StatefulWidget {
  const _OfflineCard();

  @override
  State<_OfflineCard> createState() => _OfflineCardState();
}

class _OfflineCardState extends State<_OfflineCard> {
  static const _pulse = AlwaysStoppedAnimation<double>(0);

  bool _checking = false;
  String? _status;

  Future<void> _check() async {
    if (_checking) return;
    setState(() => _checking = true);
    final online = await ConnectivityService.instance.refresh();
    if (!mounted) return;
    if (online) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _checking = false;
        _status = 'Still offline — check wifi or mobile data, then try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep errors still and readable; the retry result supplies feedback.
    const dx = 0.0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Material(
          color: Colors.transparent,
          child: Transform.translate(
            offset: Offset(dx, 0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 360),
              decoration: BoxDecoration(
                color: const Color(0xFF0E1830),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppTheme.danger.withOpacity(.8),
                  width: 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.danger.withOpacity(.35),
                    blurRadius: 22,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: AppTheme.danger.withOpacity(.18),
                    blurRadius: 52,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cloud-off icon with expanding signal rings.
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, _) {
                      return SizedBox(
                        width: 104,
                        height: 104,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            for (var i = 0; i < 2; i++)
                              Builder(
                                builder: (c) {
                                  final v = (_pulse.value - i * 0.45).clamp(
                                    0.0,
                                    1.0,
                                  );
                                  if (v <= 0) return const SizedBox.shrink();
                                  return Transform.scale(
                                    scale: 0.55 + 0.8 * v,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppTheme.danger.withOpacity(
                                            0.55 * (1 - v),
                                          ),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0x2AE5484D),
                              ),
                              child: const Icon(
                                Icons.cloud_off_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'OFFLINE MODE',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No internet connection',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFF9A9D),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Papers, printing, saving and OMR scanning still work. '
                    'AI question generation needs internet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.5,
                      color: Color(0xFF9AA7C7),
                    ),
                  ),
                  if (_status != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _status!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF9A9D),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF16203A),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _checking ? null : _check,
                          icon: _checking
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.wifi_tethering_rounded,
                                  size: 17,
                                ),
                          label: Text(
                            _checking ? 'Checking…' : 'Check connection',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFFB3B5),
                            side: const BorderSide(
                              color: Color(0xFFE5484D),
                              width: 1.3,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text(
                            'Continue offline',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
