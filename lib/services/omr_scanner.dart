/// OMR scanner for the sheets this app prints.
///
/// Pipeline (pure Dart, no native code):
///  1. Decode the photo, downscale for speed.
///  2. Find the four black corner alignment marks the printer draws
///     (services/omr_layout.dart knows where they are on the sheet).
///  3. Solve the homography sheet-space -> photo-space from those four
///     point pairs, so any camera angle / distance is corrected.
///  4. Sample the ink inside every bubble at its transformed position and
///     decide which option is filled, digit by digit, for the roll and
///     registration numbers.
///
/// Because the layout comes from the same [OmrSheetLayout] the printer uses,
/// the scanner only ever reads the app's own sheets — which is exactly what
/// makes it reliable.
library;

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'omr_layout.dart';

/// Tunable ink thresholds (fraction of the bubble area that is dark, 0..1).
/// A ball-point filled bubble reads ~0.6-0.9; an empty one ~0.05-0.25.
const double kFilledInk = 0.42;
const double kOptionContrast = 0.08;

/// Everything the scanner read off one photographed sheet.
class OmrScanResult {
  /// Selected option per question (0-3), -1 when nothing confidently filled.
  final List<int> answers;

  /// Ink of each option bubble: (question-1)*4 + option.
  final List<double> optionInk;

  /// Ink of the roll digits: column*10 + digit (6 columns).
  final List<double> rollInk;

  /// Ink of the registration digits: column*10 + digit (10 columns).
  final List<double> regInk;

  /// Ink of the four set-code bubbles.
  final List<double> setInk;

  /// Digits read per column; -1 when unreadable.
  final List<int> rollDigits;
  final List<int> regDigits;

  /// 0-3, or null when unreadable.
  final int? setCode;

  /// Photo-space centers of the detected corner marks (TL, TR, BL, BR).
  final List<OmrPoint> foundMarks;

  final bool ok;
  final String? error;

  const OmrScanResult({
    required this.answers,
    required this.optionInk,
    required this.rollInk,
    required this.regInk,
    required this.setInk,
    required this.rollDigits,
    required this.regDigits,
    required this.setCode,
    required this.foundMarks,
    required this.ok,
    this.error,
  });
}

/// A scanned sheet together with its grading against an answer key.
class OmrGradeSheet {
  final int id;
  final String roll;
  final String registration;
  final int? setCode;
  final List<int> answers;
  final List<int> key;

  OmrGradeSheet({
    required this.id,
    required this.roll,
    required this.registration,
    required this.setCode,
    required this.answers,
    required this.key,
  });

  int correctCount = -1;
  int wrongCount = 0;
  int blankCount = 0;

  void grade() {
    var c = 0, w = 0, b = 0;
    for (var i = 0; i < key.length; i++) {
      final a = i < answers.length ? answers[i] : -1;
      if (a < 0) {
        b++;
      } else if (a == key[i]) {
        c++;
      } else {
        w++;
      }
    }
    correctCount = c;
    wrongCount = w;
    blankCount = b;
  }

  int get score => correctCount < 0 ? 0 : correctCount;
  int get total => key.length;

  /// 0 correct, 1 wrong, 2 blank, -1 no key.
  int statusOf(int i) {
    if (i >= key.length) return -1;
    final a = i < answers.length ? answers[i] : -1;
    if (a < 0) return 2;
    return a == key[i] ? 0 : 1;
  }
}

class OmrScanner {
  OmrScanner._();

  /// Scans one photo. [photoBytes] is a JPEG/PNG as read from the camera or
  /// gallery; [layout] is the sheet's geometry (must match the printed paper).
  static Future<OmrScanResult> scan(
    Uint8List photoBytes,
    OmrSheetLayout layout,
  ) async {
    img.Image? photo;
    try {
      photo = img.decodeImage(photoBytes);
    } catch (_) {
      photo = null;
    }
    if (photo == null) {
      return _fail('Image could not be read. Try a different photo.');
    }
    final W = photo.width, H = photo.height;
    if (W < 400 || H < 400) {
      return _fail('Photo is too small — hold the phone a bit farther away.');
    }

    // ── 1) Corner mark detection on a small binarized copy ──────────
    const smallW = 1400;
    final small = W > smallW
        ? img.copyResize(photo, w: smallW)
        : photo;
    // Photo px per small-image px (1.0 when the photo was not resized).
    final scale = W / small.width;
    final sw = small.width, sh = small.height;

    // Threshold from the sheet's own whiteness (90th percentile), which is
    // far more predictable on a photographed sheet than global Otsu.
    final lumaHist = List<int>.filled(256, 0);
    final lumaSmall = Uint8List(sw * sh);
    for (var yy = 0; yy < sh; yy++) {
      for (var xx = 0; xx < sw; xx++) {
        final p = small.getPixel(xx, yy);
        final l = (p.r * 299 + p.g * 587 + p.b * 114) >> 10;
        lumaSmall[yy * sw + xx] = l;
        lumaHist[l]++;
      }
    }
    final p90 = _percentile(lumaHist, sw * sh, .90);
    final thr = math.max(60.0, math.min(150.0, p90 * 0.6));

    final bin = List<bool>.filled(sw * sh, false);
    for (var i = 0; i < sw * sh; i++) {
      bin[i] = lumaSmall[i] < thr;
    }

    final marks = await _findCornerMarks(bin, sw, sh);
    if (marks == null) {
      return _fail(
        'Sheet corner marks not found. Photograph the full sheet, flat and '
        'evenly lit, with all four black corner squares visible.',
      );
    }

    // ── 2) Homography: sheet space -> photo space ───────────────────
    final fullMarks = marks
        .map((m) => OmrPoint(m.x * scale, m.y * scale))
        .toList(growable: false);
    final h = solveHomography(layout.markCenters, fullMarks);
    if (h == null) {
      return _fail('Could not align the sheet. Retake the photo.');
    }
    // Sanity: the four detected points must resemble an A4 sheet.
    final wPx = fullMarks[0].distTo(fullMarks[1]);
    final hPx = fullMarks[0].distTo(fullMarks[2]);
    final wPt = layout.markCenters[0].distTo(layout.markCenters[1]);
    final hPt = layout.markCenters[0].distTo(layout.markCenters[2]);
    if (wPx < 1 || hPx < 1) return _fail('Sheet is too small in the photo.');
    final aspect = (wPx / hPx) / (wPt / hPt);
    if (aspect < 0.55 || aspect > 1.8) {
      return _fail(
          'The sheet looks skewed or cropped. Retake it straight on.');
    }
    // Uniform ink-radius scale: photo px per sheet px.
    final s1 = wPx / wPt, s2 = hPx / hPt;
    final scaleFactor = (s1 + s2) / 2;

    // ── 3) Sample ink at every bubble ───────────────────────────────
    // Sample on a <=1800px-wide copy: plenty of resolution, much faster.
    final sampleW = math.min(W, 1800);
    final sImg = sampleW < W ? img.copyResize(photo, w: sampleW) : photo;
    final f = sampleW / W;
    double lumaAt(double px, double py) {
      final x = px.round(), y = py.round();
      if (x < 0 || y < 0 || x >= sImg.width || y >= sImg.height) return 255;
      final p = sImg.getPixel(x, y);
      return (p.r * 299 + p.g * 587 + p.b * 114) >> 10;
    }

    double inkOf(OmrBubble bubble) {
      final pt = applyH(h, bubble.x, bubble.y);
      final cx = pt.$1 * f, cy = pt.$2 * f;
      final R = math.min(bubble.r * scaleFactor * f * 0.62, 30.0);
      if (R < 1.5) return 0.0;
      var sum = 0.0, n = 0;
      final x0 = (cx - R).floor(), x1 = (cx + R).ceil();
      final y0 = (cy - R).floor(), y1 = (cy + R).ceil();
      for (var yy = y0; yy <= y1; yy++) {
        for (var xx = x0; xx <= x1; xx++) {
          final dx = xx - cx, dy = yy - cy;
          if (dx * dx + dy * dy > R * R) continue;
          sum += lumaAt(xx, yy);
          n++;
        }
      }
      if (n == 0) return 0.0;
      return 1.0 - (sum / n) / 255.0;
    }

    final optionInk = <double>[];
    for (final b in layout.questionBubbles) {
      optionInk.add(inkOf(b));
    }
    final rollInk = <double>[];
    for (final b in layout.rollBubbles) {
      rollInk.add(inkOf(b));
    }
    final regInk = <double>[];
    for (final b in layout.regBubbles) {
      regInk.add(inkOf(b));
    }
    final setInk = <double>[];
    for (final b in layout.setBubbles) {
      setInk.add(inkOf(b));
    }

    // ── 4) Decide ───────────────────────────────────────────────────
    final answers = <int>[];
    for (var q = 0; q < layout.totalQuestions; q++) {
      final base = q * 4;
      var best = -1, bestV = -1.0, secondV = -1.0;
      for (var o = 0; o < 4; o++) {
        final v = optionInk[base + o];
        if (v > bestV) {
          secondV = bestV;
          bestV = v;
          best = o;
        } else if (v > secondV) {
          secondV = v;
        }
      }
      answers.add(
        best >= 0 && bestV > kFilledInk && (bestV - secondV) > kOptionContrast
            ? best
            : -1,
      );
    }

    List<int> digits(List<double> ink, int columns) {
      final out = <int>[];
      for (var c = 0; c < columns; c++) {
        var best = -1, bestV = -1.0;
        for (var d = 0; d < 10; d++) {
          final v = ink[c * 10 + d];
          if (v > bestV) {
            bestV = v;
            best = d;
          }
        }
        out.add(bestV > kFilledInk ? best : -1);
      }
      return out;
    }

    final rollDigits = digits(rollInk, 6);
    final regDigits = digits(regInk, 10);

    int? setCode;
    {
      var best = -1, bestV = -1.0;
      for (var i = 0; i < 4; i++) {
        if (setInk[i] > bestV) {
          bestV = setInk[i];
          best = i;
        }
      }
      setCode = bestV > 0.38 ? best : null;
    }

    return OmrScanResult(
      answers: answers,
      optionInk: optionInk,
      rollInk: rollInk,
      regInk: regInk,
      setInk: setInk,
      rollDigits: rollDigits,
      regDigits: regDigits,
      setCode: setCode,
      foundMarks: fullMarks,
      ok: true,
    );
  }

  static OmrScanResult _fail(String message) => OmrScanResult(
        answers: const [],
        optionInk: const [],
        rollInk: const [],
        regInk: const [],
        setInk: const [],
        rollDigits: const [],
        regDigits: const [],
        setCode: null,
        foundMarks: const [],
        ok: false,
        error: message,
      );

  // ── Corner marks ─────────────────────────────────────────────────

  /// Returns the detected mark centers (small-image px) in the order
  /// TL, TR, BL, BR, or null when any corner is missing.
  static Future<List<OmrPoint>?> _findCornerMarks(
    List<bool> bin,
    int w,
    int h,
  ) async {
    // Yield to the UI between corners so a big photo does not freeze it.
    await Future<void>.delayed(Duration.zero);
    final labels = Uint32List(w * h);
    final stack = <int>[];
    final areas = <int>[];
    final x1s = <int>[], y1s = <int>[], x2s = <int>[], y2s = <int>[];
    var next = 0;

    for (var yy = 0; yy < h; yy++) {
      for (var xx = 0; xx < w; xx++) {
        final start = yy * w + xx;
        if (!bin[start] || labels[start] != 0) continue;
        next++;
        labels[start] = next;
        var ax1 = xx, ay1 = yy, ax2 = xx, ay2 = yy, area = 0;
        stack.clear();
        stack.add(start);
        while (stack.isNotEmpty) {
          final i = stack.removeLast();
          final x = i % w, y = i ~/ w;
          area++;
          if (x < ax1) ax1 = x;
          if (x > ax2) ax2 = x;
          if (y < ay1) ay1 = y;
          if (y > ay2) ay2 = y;
          if (x > 0 && bin[i - 1] && labels[i - 1] == 0) {
            labels[i - 1] = next;
            stack.add(i - 1);
          }
          if (x < w - 1 && bin[i + 1] && labels[i + 1] == 0) {
            labels[i + 1] = next;
            stack.add(i + 1);
          }
          if (y > 0 && bin[i - w] && labels[i - w] == 0) {
            labels[i - w] = next;
            stack.add(i - w);
          }
          if (y < h - 1 && bin[i + w] && labels[i + w] == 0) {
            labels[i + w] = next;
            stack.add(i + w);
          }
        }
        areas.add(area);
        x1s.add(ax1);
        y1s.add(ay1);
        x2s.add(ax2);
        y2s.add(ay2);
      }
    }

    final found = <OmrPoint>[];
    // Corner zones: TL, TR, BL, BR.
    const zw = 0.45, zh = 0.45;
    final zones = [
      [0.0, zw, 0.0, zh],
      [1 - zw, 1.0, 0.0, zh],
      [0.0, zw, 1 - zh, 1.0],
      [1 - zw, 1.0, 1 - zh, 1.0],
    ];
    for (var z = 0; z < 4; z++) {
      var bestIdx = -1, bestScore = double.infinity;
      for (var i = 0; i < areas.length; i++) {
        final area = areas[i];
        if (area < 40 || area > 9000) continue;
        final bw = (x2s[i] - x1s[i] + 1).toDouble();
        final bh = (y2s[i] - y1s[i] + 1).toDouble();
        if (bw < 4 || bh < 4) continue;
        final aspect = bw / bh;
        if (aspect < 0.45 || aspect > 2.2) continue;
        final fill = area / (bw * bh);
        if (fill < 0.55) continue; // solid square, not a line or letter
        // Desk/background blobs touch the photo edge; sheet marks never do.
        if (x1s[i] < 3 || y1s[i] < 3 || x2s[i] > w - 4 || y2s[i] > h - 4) {
          continue;
        }
        final cx = (x1s[i] + x2s[i] + 1) / 2;
        final cy = (y1s[i] + y2s[i] + 1) / 2;
        final zx1 = zones[z][0] * w, zx2 = zones[z][1] * w;
        final zy1 = zones[z][2] * h, zy2 = zones[z][3] * h;
        if (cx < zx1 || cx > zx2 || cy < zy1 || cy > zy2) continue;
        // The alignment mark is the solid blob closest to the photo corner
        // of its zone (a filled answer bubble is also round and solid, but
        // always sits further from the corner than the mark).
        final cornerX = zones[z][0] < 0.5 ? 0.0 : w.toDouble();
        final cornerY = zones[z][2] < 0.5 ? 0.0 : h.toDouble();
        final score = (cx - cornerX) * (cx - cornerX) +
            (cy - cornerY) * (cy - cornerY);
        if (score < bestScore) {
          bestScore = score;
          bestIdx = i;
        }
      }
      if (bestIdx < 0) return null;
      found.add(OmrPoint(
        (x1s[bestIdx] + x2s[bestIdx] + 1) / 2,
        (y1s[bestIdx] + y2s[bestIdx] + 1) / 2,
      ));
    }
    return found;
  }

  static int _percentile(List<int> hist, int total, double q) {
    var target = (total * q).round();
    var acc = 0;
    for (var i = 0; i < 256; i++) {
      acc += hist[i];
      if (acc >= target) return i;
    }
    return 255;
  }
}

/// Solves the 8-dof homography mapping [src] -> [dst] (four point pairs).
///
/// Returns [h0..h7] with H = [[h0,h1,h2],[h3,h4,h5],[h6,h7,1]] and
/// (x',y') = H(x,y,1), or null when the points are degenerate.
List<double>? solveHomography(List<OmrPoint> src, List<OmrPoint> dst) {
  if (src.length != 4 || dst.length != 4) return null;
  final a = List.generate(8, (_) => List<double>.filled(9, 0.0));
  for (var i = 0; i < 4; i++) {
    final u = src[i].x, v = src[i].y, u2 = dst[i].x, v2 = dst[i].y;
    a[i][0] = u;
    a[i][1] = v;
    a[i][2] = 1;
    a[i][6] = -u2 * u;
    a[i][7] = -u2 * v;
    a[i][8] = u2;
    a[i + 4][3] = u;
    a[i + 4][4] = v;
    a[i + 4][5] = 1;
    a[i + 4][6] = -v2 * u;
    a[i + 4][7] = -v2 * v;
    a[i + 4][8] = v2;
  }
  // Gauss-Jordan with partial pivoting.
  for (var col = 0; col < 8; col++) {
    var piv = col;
    for (var r = col + 1; r < 8; r++) {
      if (a[r][col].abs() > a[piv][col].abs()) piv = r;
    }
    if (a[piv][col].abs() < 1e-12) return null;
    final tmp = a[col];
    a[col] = a[piv];
    a[piv] = tmp;
    for (var r = 0; r < 8; r++) {
      if (r == col) continue;
      final f = a[r][col] / a[col][col];
      if (f == 0) continue;
      for (var c = col; c < 9; c++) {
        a[r][c] -= f * a[col][c];
      }
    }
  }
  return List.generate(8, (r) => a[r][8] / a[r][r]);
}

/// Applies an [solveHomography] result to a point.
({double x, double y}) applyH(List<double> h, double x, double y) {
  final w = h[6] * x + h[7] * y + 1;
  if (w == 0) return (x: 0, y: 0);
  return (x: (h[0] * x + h[1] * y + h[2]) / w,
      y: (h[3] * x + h[4] * y + h[5]) / w);
}

/// Parses a manually typed answer key.
///
/// Accepts the Bangla letters ক খ গ ঘ, Latin a b c d, or the digits 1-4,
/// in any mix, separated by anything non-alphanumeric. Returns null when the
/// string is unparsable or its length differs from [expected].
List<int>? parseKeyString(String raw, int expected) {
  const map = {
    'ক': 0, 'a': 0, '1': 0,
    'খ': 1, 'b': 1, '2': 1,
    'গ': 2, 'c': 2, '3': 2,
    'ঘ': 3, 'd': 3, '4': 3,
  };
  final out = <int>[];
  for (final ch in raw.toLowerCase().split('')) {
    final v = map[ch];
    if (v != null) out.add(v);
  }
  if (out.length != expected) return null;
  return out;
}
