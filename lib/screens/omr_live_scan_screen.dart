import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show PathFillType;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/omr/omr_quality.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../services/local_diagnostics.dart';
import '../widgets/motion_policy.dart';

/// Full-screen guided OMR capture.
///
/// Shows the live camera with an auto-bounding box that tracks the sheet's
/// detected edges (four corner handles; green when ready), live
/// "sheet / marks / sharp" indicators, and auto-captures when the frame
/// stays good for a short streak. Before the sheet is detected it shows a
/// static A4 guide for framing. Pops with the captured photo path,
/// 'system' (fall back to the system camera) or null (cancelled).
class OmLiveScanScreen extends StatefulWidget {
  const OmLiveScanScreen({super.key});

  @override
  State<OmLiveScanScreen> createState() => _OmLiveScanScreenState();
}

class _OmLiveScanScreenState extends State<OmLiveScanScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _starting = true;
  bool _foreground = true;
  int _cameraGeneration = 0;
  Future<void> _cameraWork = Future.value();
  String? _error;
  bool _capturing = false;

  OmFrameQuality? _quality;

  /// Leaky-bucket confidence toward auto-capture: +1 on a ready frame,
  /// -[_confidenceLoss] on a not-ready one (clamped to 0). A single
  /// tremor/blur frame no longer wipes all progress; a genuinely shaky
  /// or blurry hold still can't reach the target (it leaks faster than
  /// it fills).
  int _confidence = 0;
  DateTime _lastAnalyzed = DateTime.fromMillisecondsSinceEpoch(0);

  /// Auto-capture on/off. When off, the box still shows readiness (green =
  /// locked) but the user presses the shutter to capture.
  bool _autoCapture = true;

  /// Stream health: some phones deliver no image-stream frames at all
  /// (preview works, analysis doesn't). A watchdog flips [_streamDead] so
  /// the guide stops pretending to be live and tells the user to frame
  /// manually and use the shutter.
  int _framesSeen = 0;
  bool _streamDead = false;
  Timer? _streamWatchdog;

  // At the ~15 fps analysis rate an uninterrupted run to target takes
  // ~0.55 s; the leak lets a real capture land in roughly 0.6-1.2 s of
  // "mostly good" framing instead of demanding 15 perfect frames.
  static const _confidenceTarget = 8;
  static const _confidenceLoss = 3;
  static const _minFrameGap = Duration(milliseconds: 66);
  static const _minFrameGapHunt = Duration(milliseconds: 90);
  static const _streamDeadline = Duration(milliseconds: 2500);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  Future<void> _start() {
    final generation = ++_cameraGeneration;
    // Serialize open/dispose so a fast background/resume cannot create two
    // controllers or dispose the replacement while its stream is starting.
    _cameraWork = _cameraWork.then((_) => _open(generation));
    return _cameraWork;
  }

  bool _current(int generation) =>
      mounted && _foreground && generation == _cameraGeneration;

  Future<void> _open(int generation) async {
    if (!_current(generation)) return;
    setState(() {
      _starting = true;
      _error = null;
      _framesSeen = 0;
      _streamDead = false;
      _capturing = false;
      _quality = null;
      _confidence = 0;
    });
    _streamWatchdog?.cancel();
    CameraController? opening;
    try {
      final cameras = await availableCameras();
      if (!_current(generation)) return;
      if (cameras.isEmpty) throw CameraException('CameraUnavailable', '');
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller =
          CameraController(back, ResolutionPreset.high, enableAudio: false);
      opening = controller;
      await controller.initialize();
      if (!_current(generation)) {
        await _teardown(controller);
        return;
      }
      _controller = controller;
      if (controller.supportsImageStreaming()) {
        try {
          await controller.startImageStream((frame) {
            if (_current(generation)) _onFrame(frame);
          });
        } catch (_) {
          // Actual stream absence is shown by the watchdog, not a fake scan.
        }
        if (!_current(generation)) return; // lifecycle queued teardown
        _streamWatchdog = Timer(_streamDeadline, () {
          if (!_current(generation) || _framesSeen > 0) return;
          setState(() => _streamDead = true);
        });
      } else {
        _streamDead = true;
      }
      if (_current(generation)) setState(() => _starting = false);
    } catch (error, stack) {
      unawaited(LocalDiagnostics.record(error, stack, scope: 'camera'));
      if (opening != null) {
        if (identical(_controller, opening)) _controller = null;
        await _teardown(opening);
      }
      if (!_current(generation)) return;
      final denied =
          error is CameraException && error.code == 'CameraAccessDenied';
      setState(() {
        _starting = false;
        _error = denied
            ? 'Camera permission is off. Allow it in settings, or use the system camera.'
            : 'Camera could not start. Use the system camera instead.';
      });
    }
  }

  DateTime _lastUi = DateTime.fromMillisecondsSinceEpoch(0);

  void _onFrame(CameraImage frame) {
    // While a capture is being processed the guidance can't change the
    // outcome — skip the analysis instead of burning CPU on every frame.
    if (!mounted || !_foreground || _capturing) return;
    final now = DateTime.now();
    // Analyse every 66 ms while the sheet is locked (the capture streak
    // needs the cadence) and every ~90 ms while hunting (the box is a
    // static guide then, so coarser updates are invisible).
    final gap = _quality?.ready == true ? _minFrameGap : _minFrameGapHunt;
    if (now.difference(_lastAnalyzed) < gap) return;
    _lastAnalyzed = now;
    OmFrameQuality q;
    try {
      q = OmQuality.analyze(frame);
    } catch (_) {
      return; // skip a malformed frame; keep the last guidance
    }
    if (_framesSeen == 0) {
      _streamWatchdog?.cancel();
      if (mounted && _streamDead) setState(() => _streamDead = false);
    }
    _framesSeen++;
    final prev = _quality;
    _quality = q;
    _confidence = q.ready
        ? (_confidence + 1 > _confidenceTarget
            ? _confidenceTarget
            : _confidence + 1)
        : (_confidence - _confidenceLoss < 0
            ? 0
            : _confidence - _confidenceLoss);
    if (_autoCapture && _confidence >= _confidenceTarget && !_capturing) {
      _confidence = 0;
      _capture();
      return;
    }
    // Rebuild only when the guidance visibly changes, or at most every
    // ~0.4 s while the metrics keep moving.
    final changed = prev == null ||
        prev.ready != q.ready ||
        prev.marks != q.marks ||
        (prev.quad == null) != (q.quad == null) ||
        (prev.sharpness >= 40) != (q.sharpness >= 40) ||
        now.difference(_lastUi) > const Duration(milliseconds: 400);
    if (changed && mounted) {
      _lastUi = now;
      setState(() {});
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (!_foreground ||
        _capturing ||
        controller == null ||
        !controller.value.isInitialized) return;
    final generation = _cameraGeneration;
    setState(() => _capturing = true);
    try {
      final file = await controller.takePicture();
      if (_current(generation)) Navigator.of(context).pop(file.path);
    } catch (_) {
      if (_current(generation)) {
        setState(() => _capturing = false);
        HapticFeedback.mediumImpact();
      }
    }
  }

  void _close() {
    if (_capturing) return;
    Navigator.of(context).pop();
  }

  void _useSystem() {
    if (_capturing) return;
    Navigator.of(context).pop('system');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final resumed = state == AppLifecycleState.resumed;
    if (resumed == _foreground) return;
    _foreground = resumed;
    if (resumed) {
      // Restart even when pause cleared the controller.
      unawaited(_start());
    } else {
      _cameraGeneration++;
      _streamWatchdog?.cancel();
      final controller = _controller;
      _controller = null;
      if (mounted) setState(() => _starting = true);
      if (controller != null) {
        _cameraWork = _cameraWork.then((_) => _teardown(controller));
      }
    }
  }

  Future<void> _teardown(CameraController controller) async {
    try {
      await controller.stopImageStream();
    } catch (_) {}
    try {
      await controller.dispose();
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _foreground = false;
    _cameraGeneration++;
    _streamWatchdog?.cancel();
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      _cameraWork = _cameraWork.then((_) => _teardown(controller));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_starting)
              const Center(
                child: ActivityIndicator(size: 26, color: Colors.white70),
              )
            else if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.no_photography_outlined,
                        size: 44,
                        color: Colors.white70,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (controller != null && controller.value.isInitialized) ...[
              CameraPreview(controller),
              Positioned.fill(
                child: CustomPaint(
                  painter: _GuidePainter(
                    quality: _quality,
                    streak: _confidence,
                    readyStreak: _confidenceTarget,
                    streamDead: _streamDead,
                    autoCapture: _autoCapture,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
            // Top bar.
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                children: [
                  _round(Icons.close_rounded, _close),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'OMR live scan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom controls.
            if (!_starting && _error == null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 18,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _useSystem,
                      child: const Text(
                        'System camera',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    GestureDetector(
                      onTap: _capturing ? null : _capture,
                      child: Container(
                        width: 74,
                        height: 74,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: _capturing
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.omr,
                                ),
                              )
                            : const Icon(
                                Icons.photo_camera_outlined,
                                color: AppColors.omr,
                                size: 34,
                              ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    GestureDetector(
                      onTap: () => setState(() => _autoCapture = !_autoCapture),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _autoCapture ? AppColors.omr : Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _autoCapture
                                ? AppColors.omr
                                : Colors.white54,
                          ),
                        ),
                        child: Text(
                          _autoCapture ? 'Auto: ON' : 'Auto: OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_capturing)
              const Positioned.fill(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _round(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      );
}

/// Draws the dimmed area outside the centred A4 guide, the guide frame with
/// corner brackets, and the readiness progress arc.
class _GuidePainter extends CustomPainter {
  final OmFrameQuality? quality;
  final int streak;
  final int readyStreak;
  final bool streamDead;
  final bool autoCapture;

  _GuidePainter({
    required this.quality,
    required this.streak,
    required this.readyStreak,
    required this.streamDead,
    this.autoCapture = true,
  });

  static const double _aspect = 1654 / 2339; // A4 (page width / height)

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final q = quality;
    final quad = q?.quad;

    // ── Detected sheet: draw the live bounding box on its edges ──
    if (quad != null && (q?.frameW ?? 0) > 0 && (q?.frameH ?? 0) > 0) {
      final s = math.max(w / q!.frameW, h / q!.frameH);
      final offX = (w - q!.frameW * s) / 2;
      final offY = (h - q!.frameH * s) / 2;
      final pts = <Offset>[
        for (final p in quad) Offset(offX + p.dx * s, offY + p.dy * s),
      ];
      // Dim everything outside the detected sheet.
      final path = Path()
        ..addRect(Rect.fromLTWH(0, 0, w, h))
        ..addPolygon(pts, true);
      path.fillType = PathFillType.evenOdd;
      canvas.drawPath(path, Paint()..color = const Color(0x73000000));
      // Teal = a real OMR sheet is detected and readable, amber = it is still
      // being aligned. Red stays reserved for a genuine fault, so the colour
      // alone tells the teacher whether to hold still or stop.
      final color =
          q!.ready ? const Color(0xFF087F8C) : const Color(0xFFE8B23A);
      final edge = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..color = color;
      for (var i = 0; i < 4; i++) {
        canvas.drawLine(pts[i], pts[(i + 1) % 4], edge);
      }
      final dot = Paint()..color = color;
      for (final p in pts) {
        canvas.drawCircle(p, 7, dot);
      }
      // Status above the sheet (its bottom edge is usually near the
      // screen bottom).
      final topY = math.min(
        math.min(pts[0].dy, pts[1].dy),
        math.min(pts[2].dy, pts[3].dy),
      );
      final textY = topY - 46;
      if (textY > 70) {
        _statusRow(canvas, w, q, textY);
      }
      return;
    }

    // ── No sheet yet: static A4 guide for framing ──
    // Largest A4-portrait guide that fits inside 82% of the *constraining*
    // side (on a portrait phone that's the width, on a short landscape
    // screen it's the height) — so the frame always fits on screen.
    final gw = math.min(w, h * _aspect) * 0.82;
    final gh = gw / _aspect;
    final gx = (w - gw) / 2;
    final gy = (h - gh) / 2;
    final guide = Rect.fromLTWH(gx, gy, gw, gh);
    final r = 14.0;

    // Dim outside the guide.
    final dim = Paint()..color = const Color(0x73000000);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, gy), dim);
    canvas.drawRect(Rect.fromLTWH(0, gy, gx, gh), dim);
    canvas.drawRect(Rect.fromLTWH(gx + gw, gy, w - gx - gw, gh), dim);
    canvas.drawRect(Rect.fromLTWH(0, gy + gh, w, h - gy - gh), dim);

    // Guide border — red: no OMR sheet detected yet.
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = streamDead
          ? const Color(0xD9FF5252)
          : AppColors.omr.withOpacity(.85);
    canvas.drawRRect(
      RRect.fromRectAndRadius(guide, Radius.circular(r)),
      border,
    );

    // Corner brackets.
    final bracket = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    bracket.color =
        streamDead ? const Color(0xFFFF5252) : AppColors.omr;
    final L = gw * 0.10;
    final tl = Offset(gx, gy);
    final tr = Offset(gx + gw, gy);
    final bl = Offset(gx, gy + gh);
    final br = Offset(gx + gw, gy + gh);
    canvas.drawLine(tl + Offset(L, 0), tl, bracket);
    canvas.drawLine(tl + Offset(0, L), tl, bracket);
    canvas.drawLine(tr - Offset(L, 0), tr, bracket);
    canvas.drawLine(tr + Offset(0, L), tr, bracket);
    canvas.drawLine(bl + Offset(L, 0), bl, bracket);
    canvas.drawLine(bl - Offset(0, L), bl, bracket);
    canvas.drawLine(br - Offset(L, 0), br, bracket);
    canvas.drawLine(br + Offset(0, L), br, bracket);

    // Status row under the guide.
    final textY = gy + gh + 26;
    if (textY < h - 120) {
      if (streamDead) {
        // The phone isn't delivering analysis frames — be honest about
        // it and fall back to manual framing with the static guide.
        final tp = TextPainter(
          text: const TextSpan(
            text:
                'Live detection is unavailable on this phone — line the sheet up inside the guide, then press the shutter.',
            style: TextStyle(color: Colors.white, fontSize: 12.5, height: 1.35),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: w - 24);
        tp.paint(canvas, Offset((w - tp.width) / 2, textY));
        return;
      }
      _statusRow(canvas, w, q, textY);
    }
  }

  /// Shared status row: Sheet / Marks / Sharp indicators plus either the
  /// fix-hint line or the auto-capture progress bar, centred on screen.
  void _statusRow(Canvas canvas, double w, OmFrameQuality? q, double textY) {
    final sheetOk = q?.quad != null;
    final marks = q?.marks ?? 0;
    final sharpOk = (q?.sharpness ?? 0) >= 40;
    final ty = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${sheetOk ? '✓' : '•'} Sheet',
            style: TextStyle(
              color: sheetOk ? const Color(0xFF57D9A3) : Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: '      ${marks >= 2 ? '✓' : '•'} Marks $marks/4',
            style: TextStyle(
              color: marks >= 2 ? const Color(0xFF57D9A3) : Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: '      ${sharpOk ? '✓' : '•'} Sharp',
            style: TextStyle(
              color: sharpOk ? const Color(0xFF57D9A3) : Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w - 16);
    ty.paint(canvas, Offset((w - ty.width) / 2, textY));

    // Reason / progress line.
    final reason = q?.reason;
    final progress = (streak / readyStreak).clamp(0.0, 1.0);
    if (reason != null) {
      final tp = TextPainter(
        text: TextSpan(
          text: reason,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            height: 1.3,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: w - 32);
      tp.paint(canvas, Offset((w - tp.width) / 2, textY + 26));
    } else {
      // Ready: show the capture-progress bar.
      final barW = (w - 32) * 0.5;
      final barX = (w - barW) / 2;
      final barY = textY + 30.0;
      final bg = Paint()..color = Colors.white24;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, barY, barW, 6),
          const Radius.circular(3),
        ),
        bg,
      );
      final fg = Paint()..color = const Color(0xFF57D9A3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(barX, barY, barW * progress, 6),
          const Radius.circular(3),
        ),
        fg,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: autoCapture ? 'Capturing when ready…' : 'Sheet locked',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            height: 1.3,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: w - 32);
      tp.paint(canvas, Offset((w - tp.width) / 2, barY + 12));
    }
  }

  @override
  bool shouldRepaint(_GuidePainter old) =>
      old.quality != quality ||
      old.streak != streak ||
      old.streamDead != streamDead ||
      old.autoCapture != autoCapture;
}
