import 'dart:typed_data';

import 'package:camera/camera.dart';

/// Live-frame quality analysis for guided auto-capture.
///
/// Runs on a downscaled copy of the camera's Y (luma) plane, so each frame
/// costs a few milliseconds of Dart CPU. A frame is "ready" when the sheet
/// is visible, reasonably sharp, and all four corner marks are found.
class OmFrameQuality {
  /// Laplacian variance of the downscaled luma (higher = sharper).
  final double sharpness;

  /// Fraction of the frame that is bright "paper" (0..1).
  final double paperFrac;

  /// Number of corner marks found (0..4).
  final int marks;

  const OmFrameQuality({
    required this.sharpness,
    required this.paperFrac,
    required this.marks,
  });

  bool get ready => paperFrac >= 0.30 && marks >= 4 && sharpness >= 40;

  /// Human-readable hint for the overlay (null when [ready]).
  String? get reason {
    if (paperFrac < 0.30) return 'Center the sheet inside the frame';
    if (marks < 4) return 'Keep all four corner squares visible';
    if (sharpness < 40) return 'Hold steady until it is sharp';
    return null;
  }
}

class OmQuality {
  OmQuality._();

  static const int _outW = 240; // downscale width — enough for marks + sharpness

  /// Analyzes one camera frame. Only YUV_420 (the format phones stream) is
  /// supported; anything else reports not-ready.
  static OmFrameQuality analyze(CameraImage frame) {
    if (frame.format.group != ImageFormatGroup.yuv420) {
      return const OmFrameQuality(sharpness: 0, paperFrac: 0, marks: 0);
    }
    final y = frame.planes.first;
    final fw = frame.width;
    final fh = frame.height;
    final pixStride = y.bytesPerPixel ?? 1;
    final rowStride = y.bytesPerRow > 0 ? y.bytesPerRow : pixStride * fw;

    final outH = (fh * _outW / fw).round();
    final g = Uint8List(_outW * outH);
    // Box downscale by nearest sampling (fast; smooth enough for the
    // Laplacian at this resolution).
    for (var oy = 0; oy < outH; oy++) {
      final sy = oy * fh ~/ outH;
      final srow = sy * rowStride;
      final orow = oy * _outW;
      for (var ox = 0; ox < _outW; ox++) {
        final sx = ox * fw ~/ _outW;
        g[orow + ox] = y.bytes[srow + sx * pixStride];
      }
    }

    final sharp = _laplacianVariance(g, _outW, outH);
    final otsuT = _otsu(g);
    var paper = 0;
    for (final v in g) {
      if (v >= otsuT) paper++;
    }
    final paperFrac = paper / g.length;
    final dark = (otsuT * 0.55).round();

    var marks = 0;
    for (var c = 0; c < 4; c++) {
      if (_hasMark(g, _outW, outH, c, dark)) marks++;
    }
    return OmFrameQuality(
        sharpness: sharp, paperFrac: paperFrac, marks: marks);
  }

  /// True when the corner quadrant holds one compact dark blob — the
  /// corner registration square (same idea as the scanner's dark-mask
  /// detector, on the small preview).
  static bool _hasMark(Uint8List g, int w, int h, int corner, int darkT) {
    const s = 0.45;
    final x0 = [0, (w * (1 - s)).round(), 0, (w * (1 - s)).round()][corner];
    final x1 = [(w * s).round(), w, (w * s).round(), w][corner];
    final y0 = [0, 0, (h * (1 - s)).round(), (h * (1 - s)).round()][corner];
    final y1 = [(h * s).round(), (h * s).round(), h, h][corner];
    final rw = x1 - x0;
    final rh = y1 - y0;
    if (rw < 4 || rh < 4) return false;

    final visited = Uint8List(rw * rh);
    // The mark is the one *compact* dark blob in its quadrant: both
    // dimensions >= 2 (a 1px-wide line/edge never qualifies), area within
    // a small share of the quadrant (desk/shadow regions are huge).
    var has = false;
    for (var ly = 0; ly < rh && !has; ly++) {
      for (var lx = 0; lx < rw && !has; lx++) {
        final idx0 = ly * rw + lx;
        if (visited[idx0] == 1 || g[(y0 + ly) * w + (x0 + lx)] >= darkT) continue;
        // BFS.
        var top = 0;
        visited[idx0] = 1;
        final stackX = <int>[lx];
        final stackY = <int>[ly];
        var area = 0;
        var mnx = lx, mxx = lx, mny = ly, mxy = ly;
        while (top < stackX.length) {
          final cx = stackX[top];
          final cy = stackY[top];
          top++;
          area++;
          if (cx < mnx) mnx = cx;
          if (cx > mxx) mxx = cx;
          if (cy < mny) mny = cy;
          if (cy > mxy) mxy = cy;
          for (final (nx, ny) in <(int, int)>[
            (cx + 1, cy),
            (cx - 1, cy),
            (cx, cy + 1),
            (cx, cy - 1),
          ]) {
            if (nx < 0 || ny < 0 || nx >= rw || ny >= rh) continue;
            final idx = ny * rw + nx;
            if (visited[idx] == 1) continue;
            if (g[(y0 + ny) * w + (x0 + nx)] >= darkT) continue;
            visited[idx] = 1;
            stackX.add(nx);
            stackY.add(ny);
          }
        }
        final bw = mxx - mnx + 1;
        final bh = mxy - mny + 1;
        final quad = rw * rh;
        if (area >= 5 &&
            bw >= 2 &&
            bh >= 2 &&
            area < quad * 0.10 &&
            bw < rw * 0.5 &&
            bh < rh * 0.5) {
          has = true;
        }
      }
    }
    return has;
  }

  /// Variance of the 3x3 Laplacian — a standard focus metric.
  static double _laplacianVariance(Uint8List g, int w, int h) {
    var sum = 0.0, sum2 = 0.0, n = 0.0;
    for (var y = 1; y < h - 1; y++) {
      final row = y * w;
      for (var x = 1; x < w - 1; x++) {
        final v = (g[row + x - 1] +
                g[row + x + 1] +
                g[row - w + x] +
                g[row + w + x] -
                4 * g[row + x])
            .toDouble();
        sum += v;
        sum2 += v * v;
        n++;
      }
    }
    if (n == 0) return 0;
    final mean = sum / n;
    final varr = sum2 / n - mean * mean;
    return varr < 0 ? 0 : varr;
  }

  static int _otsu(Uint8List px) {
    final hist = List<int>.filled(256, 0);
    for (final v in px) {
      hist[v]++;
    }
    final total = px.length;
    var sumAll = 0;
    for (var t = 0; t < 256; t++) {
      sumAll += t * hist[t];
    }
    var sumB = 0, wB = 0;
    var bestT = 127;
    var bestVar = -1.0;
    for (var t = 0; t < 256; t++) {
      wB += hist[t];
      if (wB == 0) continue;
      final wF = total - wB;
      if (wF == 0) break;
      sumB += t * hist[t];
      final mB = sumB / wB;
      final mF = (sumAll - sumB) / wF;
      final varr = wB * wF * (mB - mF) * (mB - mF);
      if (varr > bestVar) {
        bestVar = varr;
        bestT = t;
      }
    }
    return bestT;
  }
}
