import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Offset;

import 'package:camera/camera.dart';

/// Live-frame quality analysis for guided auto-capture.
///
/// Runs on a downscaled copy of the camera's Y (luma) plane, so each
/// frame costs a few milliseconds of Dart CPU. A frame is "ready" when the sheet
/// is visible (its outline is found), reasonably sharp, and large enough.
class OmFrameQuality {
  /// Laplacian variance of the downscaled luma (higher = sharper).
  final double sharpness;

  /// Fraction of the frame covered by the largest paper region (0..1).
  final double paperFrac;

  /// Number of corner marks found (0..4, estimated included).
  final int marks;

  /// The detected sheet outline — TL, TR, BR, BL in *native frame pixels* —
  /// or null when no plausible sheet region exists.
  final List<Offset>? quad;

  /// Native resolution of the analysed frame (for the overlay transform).
  final int frameW;
  final int frameH;

  OmFrameQuality({
    required this.sharpness,
    required this.paperFrac,
    required this.marks,
    this.quad,
    this.frameW = 0,
    this.frameH = 0,
  });

  bool get ready =>
      quad != null && paperFrac >= 0.25 && sharpness >= 40;

  /// Human-readable hint for the overlay (null when [ready]).
  String? get reason {
    if (quad == null) return 'Center the sheet inside the frame';
    if (paperFrac < 0.25) return 'Bring the sheet closer';
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
      return OmFrameQuality(sharpness: 0, paperFrac: 0, marks: 0);
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
    final dark = (otsuT * 0.55).round();
    final (sheetFrac, quad) = _sheetQuad(g, _outW, outH, fw, fh, otsuT);

    final found = <List<int>?>[
      for (var c = 0; c < 4; c++) _findMarkCenter(g, _outW, outH, c, dark),
    ];
    // Estimate a missing corner from the other three (parallelogram) —
    // the same trick the scanner uses, so the indicator reflects what
    // the scanner can actually register even with a neighbouring sheet.
    for (var c = 0; c < 4; c++) {
      if (found[c] != null) continue;
      if (found.where((f) => f != null).length < 3) break;
      final e = _parallelogram(c, found);
      if (e != null &&
          e[0] >= 0 &&
          e[0] < _outW &&
          e[1] >= 0 &&
          e[1] < outH) {
        found[c] = e;
      }
    }
    final marks = found.where((f) => f != null).length;
    return OmFrameQuality(
        sharpness: sharp,
        paperFrac: sheetFrac,
        marks: marks,
        quad: quad,
        frameW: fw,
        frameH: fh);
  }

  /// The four extreme corners (TL, TR, BR, BL) of the largest paper
  /// component — the live bounding box for the sheet outline.
  ///
  /// Returns (fraction of the frame it covers, corners in native frame
  /// pixels) and null corners when no plausible sheet region exists: the
  /// region must be large, sheet-shaped (not an L-shaped blob), and its
  /// four corners must be well spread out.
  static (double, List<Offset>?) _sheetQuad(
      Uint8List g, int w, int h, int nativeW, int nativeH, int otsuT) {
    final total = w * h;
    final label = Int32List(total); // 0 = not part of any paper component
    final sizes = <int>[0];
    final stack = <int>[];
    var nextId = 1;
    var bestSize = 0;
    var bestLabel = 0;
    for (var i = 0; i < total; i++) {
      if (label[i] != 0 || g[i] < otsuT) continue;
      final id = nextId++;
      sizes.add(0);
      stack.length = 0;
      stack.add(i);
      label[i] = id;
      var size = 0;
      while (stack.isNotEmpty) {
        final p = stack.removeLast();
        size++;
        final x = p % w;
        final y = p ~/ w;
        if (x > 0 && label[p - 1] == 0 && g[p - 1] >= otsuT) {
          label[p - 1] = id;
          stack.add(p - 1);
        }
        if (x < w - 1 && label[p + 1] == 0 && g[p + 1] >= otsuT) {
          label[p + 1] = id;
          stack.add(p + 1);
        }
        if (y > 0 && label[p - w] == 0 && g[p - w] >= otsuT) {
          label[p - w] = id;
          stack.add(p - w);
        }
        if (y < h - 1 && label[p + w] == 0 && g[p + w] >= otsuT) {
          label[p + w] = id;
          stack.add(p + w);
        }
      }
      sizes[id] = size;
      if (size > bestSize) {
        bestSize = size;
        bestLabel = id;
      }
    }
    final frac = bestSize / total.toDouble();
    if (bestSize < total * 0.12) return (frac, null);

    // Extreme points of the largest component = the sheet corners.
    var s0 = 1e18, s1 = 1e18, s2 = 1e18, s3 = 1e18;
    var x0 = 0.0, y0 = 0.0, x1 = 0.0, y1 = 0.0, x2 = 0.0, y2 = 0.0;
    var x3 = 0.0, y3 = 0.0;
    var minX = w, maxX = 0, minY = h, maxY = 0;
    for (var y = 0; y < h; y++) {
      final row = y * w;
      for (var x = 0; x < w; x++) {
        if (label[row + x] != bestLabel) continue;
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
        final a = (x + y).toDouble();
        if (a < s0) {
          s0 = a;
          x0 = x.toDouble();
          y0 = y.toDouble();
        }
        final b = (-x + y).toDouble();
        if (b < s1) {
          s1 = b;
          x1 = x.toDouble();
          y1 = y.toDouble();
        }
        final c = (-x - y).toDouble();
        if (c < s2) {
          s2 = c;
          x2 = x.toDouble();
          y2 = y.toDouble();
        }
        final d = (x - y).toDouble();
        if (d < s3) {
          s3 = d;
          x3 = x.toDouble();
          y3 = y.toDouble();
        }
      }
    }
    final pts = [
      Offset(x0, y0),
      Offset(x1, y1),
      Offset(x2, y2),
      Offset(x3, y3),
    ];
    // Shoelace area — a real sheet is convex-ish (>= 55% of its bbox).
    var area2 = 0.0;
    for (var i = 0; i < 4; i++) {
      final a = pts[i];
      final b = pts[(i + 1) % 4];
      area2 += a.dx * b.dy - b.dx * a.dy;
    }
    final quadArea = area2.abs() / 2;
    final bboxArea = (maxX - minX + 1) * (maxY - minY + 1);
    if (quadArea < bboxArea * 0.55) return (frac, null);
    final maxXs = math.max(math.max(x0, x1), math.max(x2, x3));
    final minXs = math.min(math.min(x0, x1), math.min(x2, x3));
    final maxYs = math.max(math.max(y0, y1), math.max(y2, y3));
    final minYs = math.min(math.min(y0, y1), math.min(y2, y3));
    final spread = math.min(maxXs - minXs, maxYs - minYs);
    if (spread < w * 0.4) return (frac, null);
    if (quadArea < total * 0.12) return (frac, null);

    final sx = nativeW / w.toDouble();
    final sy = nativeH / h.toDouble();
    return (frac, [
      for (final p in pts) Offset(p.dx * sx, p.dy * sy),
    ]);
  }

  static List<int>? _parallelogram(int missing, List<List<int>?> f) {
    final tl = f[0], tr = f[1], bl = f[2], br = f[3];
    List<int>? est;
    switch (missing) {
      case 0:
        if (tr != null && bl != null && br != null) {
          est = [tr[0] + bl[0] - br[0], tr[1] + bl[1] - br[1]];
        }
        break;
      case 1:
        if (tl != null && bl != null && br != null) {
          est = [tl[0] + br[0] - bl[0], tl[1] + br[1] - bl[1]];
        }
        break;
      case 2:
        if (tl != null && tr != null && br != null) {
          est = [tl[0] + br[0] - tr[0], tl[1] + br[1] - tr[1]];
        }
        break;
      default:
        if (tl != null && tr != null && bl != null) {
          est = [tr[0] + bl[0] - tl[0], tr[1] + bl[1] - tl[1]];
        }
    }
    return est;
  }

  /// Centre of the corner quadrant's compact dark blob — the corner
  /// registration square (same idea as the scanner's dark-mask detector,
  /// on the small preview); null when no blob passes the gates.
  static List<int>? _findMarkCenter(
      Uint8List g, int w, int h, int corner, int darkT) {
    const s = 0.45;
    final x0 = [0, (w * (1 - s)).round(), 0, (w * (1 - s)).round()][corner];
    final x1 = [(w * s).round(), w, (w * s).round(), w][corner];
    final y0 = [0, 0, (h * (1 - s)).round(), (h * (1 - s)).round()][corner];
    final y1 = [(h * s).round(), (h * s).round(), h, h][corner];
    final rw = x1 - x0;
    final rh = y1 - y0;
    if (rw < 4 || rh < 4) return null;

    final visited = Uint8List(rw * rh);
    // The mark is the one *compact* dark blob in its quadrant: both
    // dimensions >= 2 (a 1px-wide line/edge never qualifies), area within
    // a small share of the quadrant (desk/shadow regions are huge).
    var bestArea = 0;
    var bestCx = 0, bestCy = 0;
    for (var ly = 0; ly < rh; ly++) {
      for (var lx = 0; lx < rw; lx++) {
        final idx0 = ly * rw + lx;
        if (visited[idx0] == 1 || g[(y0 + ly) * w + (x0 + lx)] >= darkT) continue;
        // BFS.
        var top = 0;
        visited[idx0] = 1;
        final stackX = <int>[lx];
        final stackY = <int>[ly];
        var area = 0;
        var mnx = lx, mxx = lx, mny = ly, mxy = ly;
        var sumX = 0, sumY = 0;
        while (top < stackX.length) {
          final cx = stackX[top];
          final cy = stackY[top];
          top++;
          area++;
          sumX += cx;
          sumY += cy;
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
            bh < rh * 0.5 &&
            area > bestArea) {
          bestArea = area;
          bestCx = x0 + sumX ~/ area;
          bestCy = y0 + sumY ~/ area;
        }
      }
    }
    if (bestArea <= 0) return null;
    return [bestCx, bestCy];
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
