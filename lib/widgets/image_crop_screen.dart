import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// Pure-Flutter photo cropper — ZERO native code, so it can never trigger
/// the native "app has a bug" crash dialog that killed the app when a
/// native cropper plugin was used.
///
/// The photo fills the whole screen (cover fit) and stays still. The crop
/// window has freely draggable CORNERS and EDGES, and the whole window can
/// be moved by dragging its centre — exactly like a camera app's crop tool.
/// Whatever is inside the white frame is exactly what gets sent.
/// "Use as is" (or the back arrow) returns null = the caller keeps the
/// original (resized) photo.
class ImageCropScreen extends StatefulWidget {
  final ui.Image image; // for fast preview
  final Uint8List bytes; // the real pixels, for the crop output

  const ImageCropScreen({super.key, required this.image, required this.bytes});

  /// Opens the cropper. Returns a JPEG (longest side ≤ 1024px) of the area
  /// inside the frame, or null when the user chose "Use as is" / went back.
  static Future<Uint8List?> open(
    BuildContext context,
    ui.Image image,
    Uint8List bytes,
  ) {
    return Navigator.push<Uint8List?>(
      context,
      MaterialPageRoute(
        builder: (_) => ImageCropScreen(image: image, bytes: bytes),
      ),
    );
  }

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

enum _Grab {
  none,
  move,
  topLeft,
  topRight,
  botLeft,
  botRight,
  left,
  right,
  top,
  bottom,
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  static const int _maxOut = 1024;
  static const double _minSize = 44.0; // smallest crop window (screen px)
  static const double _cornerHit = 46.0; // finger zone around a corner
  static const double _edgeHit = 26.0; // finger zone around an edge

  /// The image area = the body (everything below the app bar). Captured
  /// every build; the crop math reuses exactly these numbers.
  Size _view = Size.zero;

  /// The crop window in screen coordinates, always inside [ _view ].
  Rect _rect = Rect.zero;
  Rect _startRect = Rect.zero;
  Offset _startPos = Offset.zero;
  _Grab _grab = _Grab.none;

  ui.Image get _img => widget.image;

  void _initRect() {
    final w = _view.width, h = _view.height;
    if (w <= 0 || h <= 0) return;
    final s = math.min(w, h) * 0.82;
    _rect = Rect.fromCenter(center: Offset(w / 2, h / 2), width: s, height: s);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Crop photo',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        actions: [
          // "Use as is" — keep the original photo, skip the crop.
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Use as is',
              style: TextStyle(
                color: Color(0xFF7FE7DC),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, box) {
          _view = box.biggest;
          if (_rect.isEmpty) _initRect();
          final w = _view.width, h = _view.height;
          final base = math.max(w / _img.width, h / _img.height);
          final dw = _img.width * base;
          final dh = _img.height * base;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (d) => _onPanStart(d.localPosition),
            onPanUpdate: (d) => _onPanUpdate(d.localPosition),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // The photo, still — the frame moves, not the photo.
                Center(
                  child: RawImage(
                    image: _img,
                    width: dw,
                    height: dh,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                // Dimmed outside + white frame + grid + drag handles. Drawn
                // from the same [ _rect ] the crop math uses: visible == out.
                IgnorePointer(
                  child: CustomPaint(painter: _CropOverlay(rect: _rect)),
                ),
                // Floating controls at the bottom of the photo.
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: Column(
                    children: [
                      const Text(
                        'Drag the corners or edges to fit the question • drag inside to move',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.white70,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white70,
                                side: const BorderSide(color: Colors.white24),
                              ),
                              onPressed: () {
                                setState(() {
                                  _initRect();
                                });
                              },
                              child: const Text('Reset'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF3D5AFE),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _crop,
                              icon: const Icon(Icons.crop_rounded, size: 18),
                              label: const Text('Crop'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── gestures: one pan recognizer drives corners, edges AND move ──

  void _onPanStart(Offset p) {
    final r = _rect;
    _startRect = r;
    _startPos = p;
    // Corners first (they sit on the edge hit-zones).
    final corners = [
      MapEntry(_Grab.topLeft, Offset(r.left, r.top)),
      MapEntry(_Grab.topRight, Offset(r.right, r.top)),
      MapEntry(_Grab.botLeft, Offset(r.left, r.bottom)),
      MapEntry(_Grab.botRight, Offset(r.right, r.bottom)),
    ];
    for (final e in corners) {
      if ((p - e.value).distance <= _cornerHit) {
        _grab = e.key;
        return;
      }
    }
    if (p.dx >= r.left - _edgeHit && p.dx <= r.right + _edgeHit) {
      if (p.dy >= r.top - _edgeHit && p.dy <= r.top + _edgeHit) {
        _grab = _Grab.top;
        return;
      }
      if (p.dy >= r.bottom - _edgeHit && p.dy <= r.bottom + _edgeHit) {
        _grab = _Grab.bottom;
        return;
      }
    }
    if (p.dy >= r.top - _edgeHit && p.dy <= r.bottom + _edgeHit) {
      if (p.dx >= r.left - _edgeHit && p.dx <= r.left + _edgeHit) {
        _grab = _Grab.left;
        return;
      }
      if (p.dx >= r.right - _edgeHit && p.dx <= r.right + _edgeHit) {
        _grab = _Grab.right;
        return;
      }
    }
    _grab = r.contains(p) ? _Grab.move : _Grab.none;
  }

  void _onPanUpdate(Offset p) {
    if (_grab == _Grab.none) return;
    final dx = p.dx - _startPos.dx;
    final dy = p.dy - _startPos.dy;
    final r = _startRect;
    final W = _view.width, H = _view.height;
    var left = r.left, top = r.top, right = r.right, bottom = r.bottom;
    switch (_grab) {
      case _Grab.move:
        left = (r.left + dx).clamp(0.0, W - r.width).toDouble();
        top = (r.top + dy).clamp(0.0, H - r.height).toDouble();
        right = left + r.width;
        bottom = top + r.height;
      case _Grab.topLeft:
        left = (r.left + dx).clamp(0.0, r.right - _minSize).toDouble();
        top = (r.top + dy).clamp(0.0, r.bottom - _minSize).toDouble();
      case _Grab.topRight:
        right = (r.right + dx).clamp(r.left + _minSize, W).toDouble();
        top = (r.top + dy).clamp(0.0, r.bottom - _minSize).toDouble();
      case _Grab.botLeft:
        left = (r.left + dx).clamp(0.0, r.right - _minSize).toDouble();
        bottom = (r.bottom + dy).clamp(r.top + _minSize, H).toDouble();
      case _Grab.botRight:
        right = (r.right + dx).clamp(r.left + _minSize, W).toDouble();
        bottom = (r.bottom + dy).clamp(r.top + _minSize, H).toDouble();
      case _Grab.left:
        left = (r.left + dx).clamp(0.0, r.right - _minSize).toDouble();
      case _Grab.right:
        right = (r.right + dx).clamp(r.left + _minSize, W).toDouble();
      case _Grab.top:
        top = (r.top + dy).clamp(0.0, r.bottom - _minSize).toDouble();
      case _Grab.bottom:
        bottom = (r.bottom + dy).clamp(r.top + _minSize, H).toDouble();
      case _Grab.none:
        return;
    }
    setState(() => _rect = Rect.fromLTRB(left, top, right, bottom));
  }

  Future<void> _crop() async {
    // Geometry: cover fit. Image pixel of screen point (sx, sy) is
    // ((sx - ox)/base, (sy - oy)/base) — the same numbers the preview
    // uses, so what you see framed is exactly what gets sent.
    final w = _view.width, h = _view.height;
    if (w <= 0 || h <= 0) return;
    final base = math.max(w / _img.width, h / _img.height);
    final ox = (w - _img.width * base) / 2;
    final oy = (h - _img.height * base) / 2;

    try {
      final source = img.decodeImage(widget.bytes);
      if (source == null) {
        if (mounted) Navigator.pop(context);
        return;
      }
      final iw = source.width.toDouble();
      final ih = source.height.toDouble();
      final x1 = ((_rect.left - ox) / base).clamp(0.0, iw);
      final y1 = ((_rect.top - oy) / base).clamp(0.0, ih);
      var x2 = ((_rect.right - ox) / base).clamp(0.0, iw);
      var y2 = ((_rect.bottom - oy) / base).clamp(0.0, ih);
      if (x2 - x1 < 2) x2 = math.min(iw, x1 + 2);
      if (y2 - y1 < 2) y2 = math.min(ih, y1 + 2);
      final x = x1.round(), y = y1.round();
      final rw = (x2.round() - x).clamp(1, source.width - x);
      final rh = (y2.round() - y).clamp(1, source.height - y);
      final cropped = img.copyCrop(source, x: x, y: y, width: rw, height: rh);
      var out = cropped;
      final longest = math.max(cropped.width, cropped.height);
      if (longest > _maxOut) {
        out = img.copyResize(
          cropped,
          width: (cropped.width * _maxOut / longest).round(),
          height: (cropped.height * _maxOut / longest).round(),
          interpolation: img.Interpolation.cubic,
        );
      }
      final data = Uint8List.fromList(img.encodeJpg(out, quality: 85));
      if (!mounted) return;
      Navigator.pop(context, data);
    } catch (_) {
      if (!mounted) return;
      Navigator.pop(context);
    }
  }
}

class _CropOverlay extends CustomPainter {
  final Rect rect;
  const _CropOverlay({required this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    final r = rect;

    // Dim everything outside the window.
    final dim = Paint()..color = const Color(0xB3000000);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, r.top), dim);
    canvas.drawRect(
      Rect.fromLTWH(0, r.bottom, size.width, size.height - r.bottom),
      dim,
    );
    canvas.drawRect(Rect.fromLTWH(0, r.top, r.left, r.height), dim);
    canvas.drawRect(
      Rect.fromLTWH(r.right, r.top, size.width - r.right, r.height),
      dim,
    );

    // Rule-of-thirds grid inside the window.
    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(0.45);
    for (final f in const [1.0 / 3, 2.0 / 3]) {
      canvas.drawLine(
        Offset(r.left + r.width * f, r.top),
        Offset(r.left + r.width * f, r.bottom),
        grid,
      );
      canvas.drawLine(
        Offset(r.left, r.top + r.height * f),
        Offset(r.right, r.top + r.height * f),
        grid,
      );
    }

    // White frame.
    final frame = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = Colors.white;
    canvas.drawRect(r, frame);

    // Amber corner brackets.
    final tick = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFFFC93C);
    const L = 26.0;
    canvas.drawLine(Offset(r.left, r.top + L), Offset(r.left, r.top), tick);
    canvas.drawLine(Offset(r.left, r.top), Offset(r.left + L, r.top), tick);
    canvas.drawLine(Offset(r.right - L, r.top), Offset(r.right, r.top), tick);
    canvas.drawLine(Offset(r.right, r.top), Offset(r.right, r.top + L), tick);
    canvas.drawLine(
      Offset(r.left, r.bottom - L),
      Offset(r.left, r.bottom),
      tick,
    );
    canvas.drawLine(
      Offset(r.left, r.bottom),
      Offset(r.left + L, r.bottom),
      tick,
    );
    canvas.drawLine(
      Offset(r.right - L, r.bottom),
      Offset(r.right, r.bottom),
      tick,
    );
    canvas.drawLine(
      Offset(r.right, r.bottom),
      Offset(r.right, r.bottom - L),
      tick,
    );

    // Drag handles: white squares at the 4 corners + 4 edge midpoints.
    final pts = <Offset>[
      Offset(r.left, r.top),
      Offset(r.right, r.top),
      Offset(r.left, r.bottom),
      Offset(r.right, r.bottom),
      Offset(r.center.dx, r.top),
      Offset(r.center.dx, r.bottom),
      Offset(r.left, r.center.dy),
      Offset(r.right, r.center.dy),
    ];
    const hs = 15.0;
    final halo = Paint()..color = Colors.black.withOpacity(.35);
    final white = Paint()..color = Colors.white;
    for (final p in pts) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: p, width: hs + 5, height: hs + 5),
          const Radius.circular(6),
        ),
        halo,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: p, width: hs, height: hs),
          const Radius.circular(4),
        ),
        white,
      );
    }
  }

  @override
  bool shouldRepaint(_CropOverlay old) => old.rect != rect;
}
