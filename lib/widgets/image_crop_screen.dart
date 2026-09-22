import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../theme/app_theme.dart';

/// A tiny in-app photo cropper (no native dependency).
///
/// The photo fills a square window; pinch to zoom, drag to move. "Crop"
/// returns the square JPEG; "Use as is" returns null (the caller keeps the
/// original); back also returns null.
class ImageCropScreen extends StatefulWidget {
  final ui.Image image;
  final Uint8List bytes;
  const ImageCropScreen(
      {super.key, required this.image, required this.bytes});

  /// Opens the cropper over [image]. Returns the cropped JPEG bytes, or
  /// null when the user chose "Use as is" / went back.
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
  static const _maxZoom = 8.0;
  static const _outSize = 1024;

  double _zoom = 1.0;
  Offset _off = Offset.zero;
  double _scaleStart = 1.0;

  ui.Image get _img => widget.image;
  Uint8List get _bytes => widget.bytes;

  /// Scale that makes the image COVER the square viewport of side [side].
  double _baseFit(double side) =>
      side / math_min(_img.width.toDouble(), _img.height.toDouble());

  static double math_min(double a, double b) => a < b ? a : b;

  /// How far the image may be moved so it still covers the viewport.
  double _maxOffset(double side) {
    final base = _baseFit(side) * _zoom;
    final dw = _img.width * base - side;
    final dh = _img.height * base - side;
    return math_min(dw, dh).clamp(0.0, 1e9) / 2;
  }

  void _clampOffset(double side) {
    final m = _maxOffset(side);
    _off = Offset(_off.dx.clamp(-m, m), _off.dy.clamp(-m, m));
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10141F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Crop photo',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900,
                color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // "use as is"
            child: const Text('Use as is',
                style: TextStyle(color: Color(0xFF7FE7DC), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, box) {
          final side = (math_min(box.maxWidth, box.maxHeight) - 28).clamp(180.0, 1200.0).toDouble();
          final base = _baseFit(side);
          // The image is drawn at its base (cover) size; the Transform
          // below adds the user zoom, so do NOT pre-multiply here.
          final dw = _img.width * base;
          final dh = _img.height * base;
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: GestureDetector(
                    // ONE recognizer does both jobs: two fingers pinch
                    // (d.scale) AND one finger drags (d.delta). Running a
                    // separate pan recognizer fights the scale one and the
                    // drag never wins, which made the image unmovable.
                    onScaleStart: (_) => _scaleStart = _zoom,
                    onScaleUpdate: (d) {
                      _zoom = (_scaleStart * d.scale).clamp(1.0, _maxZoom).toDouble();
                      _off = _off + d.focalPointDelta;
                      _clampOffset(side);
                    },
                    onScaleEnd: (_) {},
                    child: ClipRect(
                      child: Stack(
                        fit: StackFit.loose,
                        alignment: Alignment.center,
                        children: [
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..translate(_off.dx, _off.dy)
                              ..scale(_zoom),
                            child: RawImage(
                              image: _img,
                              width: dw,
                              height: dh,
                              fit: BoxFit.fill,
                            ),
                          ),
                          // crop window frame
                          Container(
                            width: side,
                            height: side,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2.4),
                            ),
                          ),
                          // subtle corner accents
                          Positioned(
                            left: (box.maxWidth - side) / 2,
                            top: (box.maxHeight - side) / 2,
                            width: side,
                            height: side,
                            child: CustomPaint(
                              painter: _CornerPainter(
                                  const Color(0xFFFFC93C), 26),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: Text(
                  'Pinch to zoom • then drag to position the question',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.5, color: Colors.white70),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Colors.white24),
                        ),
                        onPressed: () => setState(() {
                          _zoom = 1.0;
                          _off = Offset.zero;
                        }),
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _crop,
                        icon: const Icon(Icons.crop_rounded, size: 18),
                        label: const Text('Crop'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _crop() async {
    // Re-derive geometry from the current viewport size.
    final ctx = context;
    final box = ctx.size!;
    final side = (math_min(box.width, box.height) - 28).clamp(180.0, 1200.0).toDouble();
    final base = _baseFit(side) * _zoom;
    final half = (side / 2) / base;
    final cx = _img.width / 2 + _off.dx / base;
    final cy = _img.height / 2 + _off.dy / base;
    var rect = Rect.fromLTWH(cx - half, cy - half, half * 2, half * 2)
        .intersect(Rect.fromLTWH(0, 0, _img.width.toDouble(), _img.height.toDouble()));
    if (rect.width < 8 || rect.height < 8) rect = Rect.fromLTWH(0, 0, _img.width.toDouble(), _img.height.toDouble());

    // Pure-Dart crop + JPEG encode (the engine no longer JPEG-encodes).
    try {
      final source = img.decodeImage(_bytes);
      if (source == null) {
        Navigator.pop(context);
        return;
      }
      final x = rect.left.round().clamp(0, source.width - 1);
      final y = rect.top.round().clamp(0, source.height - 1);
      final w = rect.width.round().clamp(1, source.width - x);
      final h = rect.height.round().clamp(1, source.height - y);
      final cropped = img.copyCrop(source, x: x, y: y, width: w, height: h);
      final out = img.copyResize(
        cropped,
        width: _outSize,
        height: _outSize,
        interpolation: img.Interpolation.cubic,
      );
      final data = Uint8List.fromList(img.encodeJpg(out, quality: 85));
      if (!mounted) return;
      Navigator.pop(context, data);
    } catch (_) {
      if (!mounted) return;
      Navigator.pop(context);
    }
  }
}

/// Draws four L-shaped corner marks on the crop window.
class _CornerPainter extends CustomPainter {
  final Color color;
  final double len;
  const _CornerPainter(this.color, this.len);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final l = len;
    // TL
    canvas.drawLine(Offset(2, 2), Offset(2 + l, 2), p);
    canvas.drawLine(Offset(2, 2), Offset(2, 2 + l), p);
    // TR
    canvas.drawLine(Offset(size.width - 2, 2), Offset(size.width - 2 - l, 2), p);
    canvas.drawLine(Offset(size.width - 2, 2), Offset(size.width - 2, 2 + l), p);
    // BL
    canvas.drawLine(Offset(2, size.height - 2), Offset(2 + l, size.height - 2), p);
    canvas.drawLine(Offset(2, size.height - 2), Offset(2, size.height - 2 - l), p);
    // BR
    canvas.drawLine(Offset(size.width - 2, size.height - 2),
        Offset(size.width - 2 - l, size.height - 2), p);
    canvas.drawLine(Offset(size.width - 2, size.height - 2),
        Offset(size.width - 2, size.height - 2 - l), p);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter old) => false;
}
