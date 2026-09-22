import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// Pure-Flutter photo cropper — ZERO native code, so it can never trigger
/// the "app has a bug" native crash dialog that killed the app when a
/// native cropper plugin was used.
///
/// The photo fills the whole screen (cover fit). The crop window is a
/// fixed square in the exact centre — the dimmed overlay and the frame are
/// drawn from the same numbers the crop math uses, so what you see is
/// exactly what gets sent. Pinch to zoom, drag to position.
/// "Use as is" (or the back arrow) returns null = the caller keeps the
/// original (resized) photo.
class ImageCropScreen extends StatefulWidget {
  final ui.Image image; // for fast preview
  final Uint8List bytes; // the real pixels, for the crop output

  const ImageCropScreen({super.key, required this.image, required this.bytes});

  /// Opens the cropper. Returns the 1024px square JPEG, or null when the
  /// user chose "Use as is" / went back.
  static Future<Uint8List?> open(
      BuildContext context, ui.Image image, Uint8List bytes) {
    return Navigator.push<Uint8List?>(
        context,
        MaterialPageRoute(
            builder: (_) => ImageCropScreen(image: image, bytes: bytes)));
  }

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  static const double _maxZoom = 6.0;
  static const int _outSize = 1024;
  static const double _frameMargin = 32; // gap between frame and screen edge

  double _zoom = 1.0;
  Offset _off = Offset.zero;
  double _zoomStart = 1.0;

  /// The image area = the body (everything below the app bar). Captured
  /// every build; the crop math reuses exactly these numbers.
  Size _view = Size.zero;

  ui.Image get _img => widget.image;

  double _side(double w, double h) =>
      (math.min(w, h) - _frameMargin).clamp(180.0, 1200.0).toDouble();

  /// Cover-fit scale: image pixels per screen pixel at zoom 1.
  double _coverBase(double w, double h) =>
      math.max(w / _img.width, h / _img.height);

  void _clamp() {
    final base = _coverBase(_view.width, _view.height) * _zoom;
    final maxX = math.max(0.0, (_img.width * base) - _view.width) / 2;
    final maxY = math.max(0.0, (_img.height * base) - _view.height) / 2;
    _off = Offset(_off.dx.clamp(-maxX, maxX), _off.dy.clamp(-maxY, maxY));
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Crop photo',
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
        actions: [
          // "Use as is" — keep the original photo, skip the crop.
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Use as is',
                style: TextStyle(
                    color: Color(0xFF7FE7DC), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;
        _view = Size(w, h);
        final side = _side(w, h);
        final base = _coverBase(w, h);
        final dw = _img.width * base;
        final dh = _img.height * base;

        return Stack(fit: StackFit.expand, children: [
          // The photo: one recognizer drives BOTH pinch (d.scale) and
          // one-finger drag (d.focalPointDelta). A second pan recognizer
          // would fight this one and eat the drag — never add one.
          GestureDetector(
            onScaleStart: (_) => _zoomStart = _zoom,
            onScaleUpdate: (d) {
              _zoom = (_zoomStart * d.scale).clamp(1.0, _maxZoom).toDouble();
              _off = _off + d.focalPointDelta;
              _clamp();
            },
            child: Center(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..translate(_off.dx, _off.dy)
                  ..scale(_zoom),
                child: RawImage(image: _img, width: dw, height: dh, filterQuality: FilterQuality.high),
              ),
            ),
          ),
          // Dimmed outside + white frame + corner ticks. Drawn with the
          // SAME side/centre as the crop math, so visible == output.
          Positioned.fill(
            child: IgnorePointer(
                child: CustomPaint(painter: _CropOverlay(side: side))),
          ),
          // Floating controls at the bottom of the photo.
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Column(children: [
              const Text(
                'Pinch to zoom • then drag to position the question',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.white70,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                    ),
                    onPressed: () {
                      setState(() {
                        _zoom = 1.0;
                        _off = Offset.zero;
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
                        foregroundColor: Colors.white),
                    onPressed: _crop,
                    icon: const Icon(Icons.crop_rounded, size: 18),
                    label: const Text('Crop'),
                  ),
                ),
              ]),
            ]),
          ),
        ]);
      }),
    );
  }

  Future<void> _crop() async {
    // Geometry: image centre maps to (screen centre + _off). The frame
    // centre is the screen centre, at zoom `base` image px per screen px.
    final w = _view.width;
    final h = _view.height;
    if (w <= 0 || h <= 0) return;
    final side = _side(w, h);
    final base = _coverBase(w, h) * _zoom;
    final half = (side / 2) / base;
    final cx = _img.width / 2 - _off.dx / base;
    final cy = _img.height / 2 - _off.dy / base;

    try {
      final source = img.decodeImage(widget.bytes);
      if (source == null) {
        Navigator.pop(context);
        return;
      }
      final x = (cx - half).clamp(0.0, source.width.toDouble() - 1).round();
      final y = (cy - half).clamp(0.0, source.height.toDouble() - 1).round();
      final rw = (half * 2).round().clamp(1, source.width - x);
      final rh = (half * 2).round().clamp(1, source.height - y);
      final cropped = img.copyCrop(source, x: x, y: y, width: rw, height: rh);
      // The frame is square in screen space → square in image space too.
      final out = img.copyResize(cropped,
          width: _outSize, height: _outSize, interpolation: img.Interpolation.cubic);
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
  final double side;
  const _CropOverlay({required this.side});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final left = cx - side / 2;
    final top = cy - side / 2;
    final right = cx + side / 2;
    final bottom = cy + side / 2;

    final dim = Paint()..color = const Color(0xB3000000);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, top), dim);
    canvas.drawRect(
        Rect.fromLTWH(0, bottom, size.width, size.height - bottom), dim);
    canvas.drawRect(Rect.fromLTWH(0, top, left, side), dim);
    canvas.drawRect(
        Rect.fromLTWH(right, top, size.width - right, side), dim);

    final frame = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(left, top, side, side), frame);

    final tick = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFFFC93C);
    const L = 22.0;
    canvas.drawLine(Offset(left, top + L), Offset(left, top), tick);
    canvas.drawLine(Offset(left, top), Offset(left + L, top), tick);
    canvas.drawLine(Offset(right - L, top), Offset(right, top), tick);
    canvas.drawLine(Offset(right, top), Offset(right, top + L), tick);
    canvas.drawLine(Offset(left, bottom - L), Offset(left, bottom), tick);
    canvas.drawLine(Offset(left, bottom), Offset(left + L, bottom), tick);
    canvas.drawLine(Offset(right - L, bottom), Offset(right, bottom), tick);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - L), tick);
  }

  @override
  bool shouldRepaint(_CropOverlay old) => old.side != side;
}
