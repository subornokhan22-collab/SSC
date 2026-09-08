import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Offset;

import 'package:image/image.dart' as img;

import 'omr_geometry.dart';

/// Result of reading one photographed OMR sheet.
class OmScanResult {
  final int total;
  final List<int> answers; // per question: 0–3 option, -1 blank, -2 double-marked
  final List<List<double>> inks; // per question: 4 ink ratios
  final String roll;
  final String registration;
  final String subjectCode;
  final int setCode; // 0–3, -1 if not readable

  /// Registration corners in *photo* order: TL, TR, BL, BR of the frame.
  final List<DetectedCorner> photoCorners;
  /// Homography that maps page pixels → working-image pixels.
  final List<double> homography;
  /// Page-px → working-px scale (≈ photoDiagonal / pageDiagonal).
  final double scale;
  final int workWidth;
  final int workHeight;
  final String? error;

  OmScanResult._({
    required this.total,
    required this.answers,
    required this.inks,
    required this.roll,
    required this.registration,
    required this.subjectCode,
    required this.setCode,
    required this.photoCorners,
    required this.homography,
    required this.scale,
    required this.workWidth,
    required this.workHeight,
    this.error,
  });

  factory OmScanResult.failed(String message) => OmScanResult._(
        total: 0,
        answers: const [],
        inks: const [],
        roll: '',
        registration: '',
        subjectCode: '',
        setCode: -1,
        photoCorners: const [],
        homography: const [1, 0, 0, 0, 1, 0, 0, 0, 1],
        scale: 0,
        workWidth: 0,
        workHeight: 0,
        error: message,
      );

  bool get ok => error == null;
  int get blankCount => answers.where((a) => a == -1).length;
  int get ambiguousCount => answers.where((a) => a == -2).length;
}

/// Graded outcome of a scan against an answer key.
class OmGraded {
  final List<int> answers;
  final List<int> key;
  /// Per question: 0 correct, 1 wrong, 2 blank, 3 double-marked.
  final List<int> status;
  final int correct;
  final int wrong;
  final int blank;
  final int ambiguous;

  OmGraded({
    required this.answers,
    required this.key,
    required this.status,
    required this.correct,
    required this.wrong,
    required this.blank,
    required this.ambiguous,
  });

  int get total => key.length;
  int get score => correct;
  double get percent => total == 0 ? 0 : correct * 100.0 / total;
}

/// Photographed OMR sheet → answers.
///
/// The pipeline:
///  1. decode + resize the photo to the sheet's native pixel grid,
///  2. Otsu-threshold to an ink mask,
///  3. find the four filled corner squares (registration marks),
///  4. solve the 4-point homography page → photo (trying all four sheet
///     rotations, keeping the one that looks like a portrait A4 sheet),
///  5. sample the ink ratio in every expected bubble from [OMrGeometry],
///  6. turn bubble states into answers, roll/registration/subject codes and
///     the set code.
class OMrScanner {
  OMrScanner._();

  /// Ink-ratio at or above which a bubble counts as filled.
  static const double fillThreshold = 0.45;
  static const double weakThreshold = 0.22;

  static Future<OmScanResult> scan(
    Uint8List photoBytes, {
    required int total,
  }) async {
    if (total < 1 || total > 100) {
      return OmScanResult.failed('Question count must be 1–100.');
    }
    final geo = OMrGeometry(total);

    img.Image decoded;
    try {
      final d = img.decodeImage(photoBytes);
      if (d == null) {
        return OmScanResult.failed(
            'Image could not be read. Use a normal photo (JPG).');
      }
      decoded = d;
    } catch (_) {
      return OmScanResult.failed(
          'Image could not be read. Use a normal photo (JPG).');
    }

    // Work on roughly the sheet's own resolution so one bubble stays a
    // sensible number of pixels (≈10–13 px).
    const targetH = 2339;
    img.Image work;
    if (decoded.height >= targetH * 0.9) {
      final scaleH = targetH / decoded.height;
      work = scaleH < 1
          ? img.copyResize(decoded,
              width: (decoded.width * scaleH).round(), height: targetH)
          : decoded;
    } else {
      final scaleH = targetH / decoded.height;
      work = img.copyResize(decoded,
          width: (decoded.width * scaleH).round(),
          height: (decoded.height * scaleH).round());
    }

    final gray = img.copyToFormat(work, format: img.FORMAT_L8);
    final w = work.width, h = work.height;
    final pixels = gray.getBytes(order: ByteOrder.native);

    final double otsuT = _otsu(pixels);
    final ink = Uint8List(w * h);
    final paper = Uint8List(w * h);
    for (var i = 0; i < w * h; i++) {
      ink[i] = pixels[i] < otsuT ? 1 : 0;
      paper[i] = 1 - ink[i];
    }

    // ── 3. corner marks ────────────────────────────────────────────
    final corners = <DetectedCorner>[];
    for (var c = 0; c < 4; c++) {
      final mark = _detectCornerMark(c, ink, w, h);
      if (mark != null) {
        corners.add(mark);
        continue;
      }
      final fallback = _paperCornerFallback(c, paper, w, h);
      if (fallback == null) {
        return OmScanResult.failed(
            'Corner marks not found. Keep the whole OMR sheet in frame, in even light, and take the photo again.');
      }
      corners.add(fallback);
    }

    // ── 4. homography (try all four sheet rotations) ───────────────
    final List<double>? solved =
        _bestRotationHomography(geo, corners, ink, w, h);
    if (solved == null) {
      return OmScanResult.failed(
          'Could not align the sheet. Keep the sheet centered with a small margin around it, and take the photo again.');
    }
    final homography = solved;

    // Scale: page diagonal in the working image.
    final tl = applyHomography(homography, OMrGeometry.markCenter(0));
    final br = applyHomography(homography, OMrGeometry.markCenter(3));
    final scale =
        math.sqrt(math.pow(br.dx - tl.dx, 2) + math.pow(br.dy - tl.dy, 2)) /
            OMrGeometry.cornerDiagonal;
    final bubbleR = OMrGeometry.bubbleRadiusPx * scale;
    if (bubbleR < 4) {
      return OmScanResult.failed(
          'The sheet is too small in the photo. Move closer and take the photo again.');
    }
    final sampleR = (bubbleR * 0.55).clamp(3.5, 22.0);

    // ── 5. sample every bubble ─────────────────────────────────────
    final answers = List<int>.filled(total, -1);
    final inks = <List<double>>[];
    for (var no = 1; no <= total; no++) {
      final row = <double>[];
      for (var o = 0; o < 4; o++) {
        final p = applyHomography(homography, geo.questionBubble(no, o));
        row.add(_inkRatio(ink, w, h, p.dx, p.dy, sampleR));
      }
      inks.add(row);
      final filled = [0, 1, 2, 3].where((o) => row[o] >= fillThreshold).toList();
      if (filled.length == 1) {
        answers[no - 1] = filled.first;
      } else if (filled.isEmpty) {
        // Nothing solid. A single weak mark is still reported as blank but
        // stays visible in the ink table for the tutor.
        answers[no - 1] = -1;
      } else {
        answers[no - 1] = -2;
      }
    }

    // ── 6. identity panels + set code ──────────────────────────────
    String readDigits(int panel, int cols) {
      final sb = StringBuffer();
      for (var c = 0; c < cols; c++) {
        var bestDigit = -1;
        var best = 0.0;
        var second = 0.0;
        for (var d = 0; d < 10; d++) {
          final p =
              applyHomography(homography, geo.digitBubble(panel, c, d));
          final r = _inkRatio(ink, w, h, p.dx, p.dy, sampleR * 0.9);
          if (r > best) {
            second = best;
            best = r;
            bestDigit = d;
          } else if (r > second) {
            second = r;
          }
        }
        if (best >= fillThreshold && best > second + 0.12) {
          sb.write('$bestDigit');
        } else if (best >= weakThreshold) {
          sb.write('?');
        } else {
          sb.write('0'); // unfilled leading columns read as zero
        }
      }
      return sb.toString();
    }

    final roll = readDigits(0, 6);
    final registration = readDigits(1, 10);
    final subjectCode = readDigits(2, 3);

    var setCode = -1;
    {
      var best = -1, second = -1;
      var bestR = 0.0;
      for (var o = 0; o < 4; o++) {
        final p = applyHomography(homography, geo.setBubble(o));
        final r = _inkRatio(ink, w, h, p.dx, p.dy, sampleR);
        if (r > bestR) {
          second = best;
          bestR = r;
          best = o;
        } else if (r > second) {
          second = o;
        }
      }
      if (bestR >= fillThreshold) setCode = best;
    }

    return OmScanResult._(
      total: total,
      answers: answers,
      inks: inks,
      roll: roll,
      registration: registration,
      subjectCode: subjectCode,
      setCode: setCode,
      photoCorners: corners,
      homography: homography,
      scale: scale,
      workWidth: w,
      workHeight: h,
    );
  }

  /// Compare [result] with [key] (option index per question).
  static OmGraded grade(OmScanResult result, List<int> key) {
    final status = List<int>.filled(key.length, 0);
    var correct = 0, wrong = 0, blank = 0, ambiguous = 0;
    for (var i = 0; i < key.length; i++) {
      final a = i < result.answers.length ? result.answers[i] : -1;
      if (a == -1) {
        status[i] = 2;
        blank++;
      } else if (a == -2) {
        status[i] = 3;
        ambiguous++;
      } else if (a == key[i]) {
        status[i] = 0;
        correct++;
      } else {
        status[i] = 1;
        wrong++;
      }
    }
    return OmGraded(
      answers: result.answers,
      key: key,
      status: status,
      correct: correct,
      wrong: wrong,
      blank: blank,
      ambiguous: ambiguous,
    );
  }

  // ═══════════════════ internals ═══════════════════

  static double _otsu(Uint8List px) {
    final hist = List<int>.filled(256, 0);
    for (final v in px) {
      hist[v]++;
    }
    final n = px.length;
    var sum = 0.0;
    for (var i = 0; i < 256; i++) {
      sum += i * hist[i];
    }
    var sumB = 0.0, wB = 0.0;
    var bestT = 127.0, bestVar = -1.0;
    for (var t = 0; t < 256; t++) {
      wB += hist[t];
      if (wB == 0) continue;
      final wF = n - wB;
      if (wF == 0) break;
      sumB += t * hist[t];
      final mB = sumB / wB, mF = (sum - sumB) / wF;
      final v = wB * wF * (mB - mF) * (mB - mF);
      if (v > bestVar) {
        bestVar = v;
        bestT = t;
      }
    }
    return bestT;
  }

  /// Finds the filled corner square in quadrant [corner]
  /// (0 TL, 1 TR, 2 BL, 3 BR of the *photo*).
  ///
  /// The mark is picked by connected-component compactness: it is the only
  /// *solid* blob in its corner (a filled square), while printed grid ink,
  /// shadows or fingers form thin or scattered components. This keeps the
  /// centre on the mark even when the page nearly fills the frame and the
  /// question grid intrudes into the quadrant.
  static DetectedCorner? _detectCornerMark(
      int corner, Uint8List ink, int w, int h) {
    const s = 0.22;
    final x0 = [0, (w * (1 - s)).round(), 0, (w * (1 - s)).round()][corner];
    final x1 = [(w * s).round(), w, (w * s).round(), w][corner];
    final y0 = [0, 0, (h * (1 - s)).round(), (h * (1 - s)).round()][corner];
    final y1 = [(h * s).round(), (h * s).round(), h, h][corner];
    final insetX = ((x1 - x0) * 0.01).round();
    final insetY = ((y1 - y0) * 0.01).round();
    final rw = x1 - insetX - (x0 + insetX);
    final rh = y1 - insetY - (y0 + insetY);
    if (rw < 8 || rh < 8) return null;

    // Flood-fill connected components (4-connectivity) over the quadrant.
    final visited = Uint8List(rw * rh);
    var bestScore = 0.0;
    var bestCx = 0.0, bestCy = 0.0;
    final stack = List<int>.filled(rw * rh, 0);

    for (var ly = 0; ly < rh; ly++) {
      for (var lx = 0; lx < rw; lx++) {
        if (visited[ly * rw + lx] == 1) continue;
        final gx = x0 + insetX + lx;
        final gy = y0 + insetY + ly;
        if (ink[gy * w + gx] == 0) continue;
        // BFS one component.
        var top = 0;
        stack[top++] = ly * rw + lx;
        visited[ly * rw + lx] = 1;
        var area = 0, minX = lx, maxX = lx, minY = ly, maxY = ly;
        var sumX = 0, sumY = 0;
        void visit(int nx, int ny) {
          if (nx < 0 || ny < 0 || nx >= rw || ny >= rh) return;
          final idx = ny * rw + nx;
          if (visited[idx] == 1) return;
          if (ink[(y0 + insetY + ny) * w + (x0 + insetX + nx)] == 0) return;
          visited[idx] = 1;
          stack[top++] = idx;
        }
        while (top > 0) {
          final cell = stack[--top];
          final cy = cell ~/ rw, cx = cell % rw;
          area++;
          sumX += cx;
          sumY += cy;
          if (cx < minX) minX = cx;
          if (cx > maxX) maxX = cx;
          if (cy < minY) minY = cy;
          if (cy > maxY) maxY = cy;
          visit(cx + 1, cy);
          visit(cx - 1, cy);
          visit(cx, cy + 1);
          visit(cx, cy - 1);
        }
        final bw = maxX - minX + 1;
        final bh = maxY - minY + 1;
        final fill = area / (bw * bh);
        final blobD = math.hypot(bw.toDouble(), bh.toDouble());
        final diag = math.hypot(w.toDouble(), h.toDouble());
        if (area < 40 || fill < 0.35) continue; // too small / not a solid square
        if (blobD < diag * 0.006 || blobD > diag * 0.14) continue;
        final score = area * fill;
        if (score > bestScore) {
          bestScore = score;
          bestCx = x0 + insetX + (sumX / area);
          bestCy = y0 + insetY + (sumY / area);
        }
      }
    }
    if (bestScore <= 0) return null;

    // The mark sits near the outer corner of its quadrant.
    final qcx = (x0 + x1) / 2, qcy = (y0 + y1) / 2;
    switch (corner) {
      case 0:
        if (bestCx > qcx || bestCy > qcy) return null;
      case 1:
        if (bestCx < qcx || bestCy > qcy) return null;
      case 2:
        if (bestCx > qcx || bestCy < qcy) return null;
      default:
        if (bestCx < qcx || bestCy < qcy) return null;
    }
    return DetectedCorner(Offset(bestCx, bestCy), true);
  }

  /// Fallback registration point: the extreme bright (paper) pixel in the
  /// corner's diagonal band — the page corner itself.
  static Offset? _paperCornerFallback(
      int corner, Uint8List paper, int w, int h) {
    final band = 0.45;
    var best = 1e18;
    Offset bestP = Offset.zero;
    var found = false;
    final step = 2; // sampling stride — corners are large targets
    for (var y = 0; y < h; y += step) {
      final row = y * w;
      for (var x = 0; x < w; x += step) {
        if (paper[row + x] == 0) continue;
        final inBand = switch (corner) {
          0 => x < w * band && y < h * band,
          1 => x > w * (1 - band) && y < h * band,
          2 => x < w * band && y > h * (1 - band),
          _ => x > w * (1 - band) && y > h * (1 - band),
        };
        if (!inBand) continue;
        final score = switch (corner) {
          0 => x + y,
          1 => -x + y,
          2 => x - y,
          _ => -(x + y).toDouble(),
        };
        if (score < best) {
          best = score;
          bestP = Offset(x.toDouble(), y.toDouble());
          found = true;
        }
      }
    }
    return found ? bestP : null;
  }

  /// Solves page→photo homographies for all four possible sheet rotations
  /// and returns the best one. A candidate must (a) map the four registration
  /// corners to a convex quadrilateral (rejects crossed "butterfly" matches),
  /// (b) look like a portrait A4 sheet, and (c) put the dense question grid
  /// at the *top* of the sheet — the sheet's bottom is mostly blank, which
  /// kills the 180° and 90°/270° ambiguities the aspect ratio alone cannot.
  static List<double>? _bestRotationHomography(
      OMrGeometry geo, List<DetectedCorner> corners,
      [Uint8List? ink, int w = 0, int h = 0]) {
    // Cyclic clockwise orders.
    final pageCw = [
      OMrGeometry.markCenter(0), // TL
      OMrGeometry.markCenter(1), // TR
      OMrGeometry.markCenter(3), // BR
      OMrGeometry.markCenter(2), // BL
    ];
    final photoCw = [
      corners[0], // TL
      corners[1], // TR
      corners[3], // BR
      corners[2], // BL
    ];
    const targetAspect = OMrGeometry.pageW / OMrGeometry.pageH; // 0.707
    List<double>? bestH;
    var bestErr = 1e18;
    for (var rot = 0; rot < 4; rot++) {
      final q = <Offset>[];
      for (var j = 0; j < 4; j++) {
        q.add(photoCw[(j + rot) % 4].point);
      }
      if (!_isConvexQuadrilateral(q)) continue;
      final hHom = homographyFrom4(pageCw, q);
      if (hHom == null) continue;
      // Project the four page corners, measure width & height.
      final pts = [
        applyHomography(hHom, const Offset(0, 0)),
        applyHomography(hHom, const Offset(OMrGeometry.pageW, 0)),
        applyHomography(hHom, Offset(OMrGeometry.pageW, OMrGeometry.pageH)),
        applyHomography(hHom, const Offset(0, OMrGeometry.pageH)),
      ];
      double len(Offset a, Offset b) =>
          math.sqrt(math.pow(b.dx - a.dx, 2) + math.pow(b.dy - a.dy, 2));
      final width = (len(pts[0], pts[1]) + len(pts[3], pts[2])) / 2;
      final height = (len(pts[0], pts[3]) + len(pts[1], pts[2])) / 2;
      if (width < 200 || height < 200) continue;
      final aspect = width / height;
      var err = (aspect - targetAspect).abs() +
          (width > height ? 0.5 : 0.0); // mild penalty for landscape

      // Content probe: the question grid (top of the sheet) must be
      // denser in ink than the signature strip (bottom of the sheet).
      if (ink != null && w > 0 && h > 0) {
        final gridH = geo.perColumn * OMrGeometry.rowH;
        final top = applyHomography(
            hHom, Offset(OMrGeometry.pageW / 2,
                OMrGeometry.questionsTop + (gridH * 0.5).clamp(60, 240)));
        final bottom =
            applyHomography(hHom, const Offset(OMrGeometry.pageW / 2, 2189));
        final topInk = _inkRatio(ink, w, h, top.dx, top.dy, 24);
        final botInk = _inkRatio(ink, w, h, bottom.dx, bottom.dy, 24);
        if (botInk > topInk) {
          // Denser at the bottom: this rotation is wrong.
          err += 10 + (botInk - topInk) * 20;
        }
      }
      if (err < bestErr) {
        bestErr = err;
        bestH = hHom;
      }
    }
    return bestH;
  }

  /// True if [pts] (in order) form a simple convex quadrilateral.
  static bool _isConvexQuadrilateral(List<Offset> pts) {
    if (pts.length != 4) return false;
    var sign = 0;
    for (var i = 0; i < 4; i++) {
      final a = pts[i];
      final b = pts[(i + 1) % 4];
      final c = pts[(i + 2) % 4];
      final cross = (b.dx - a.dx) * (c.dy - b.dy) - (b.dy - a.dy) * (c.dx - b.dx);
      if (cross.abs() < 1) return false;
      final s = cross > 0 ? 1 : -1;
      if (sign == 0) {
        sign = s;
      } else if (s != sign) {
        return false;
      }
    }
    return true;
  }

  /// Solves the 4-point homography (page points [p] → photo points [q]).
  /// Returns the 9 coefficients [h11 h12 h13 h21 h22 h23 h31 h32 1].
  static List<double>? homographyFrom4(List<Offset> p, List<Offset> q) {
    final a = List.generate(8, (_) => List<double>.filled(8, 0.0));
    final b = List<double>.filled(8, 0.0);
    for (var i = 0; i < 4; i++) {
      final px = p[i].dx, py = p[i].dy, qx = q[i].dx, qy = q[i].dy;
      a[2 * i] = [px, py, 1, 0, 0, 0, -qx * px, -qx * py];
      b[2 * i] = qx;
      a[2 * i + 1] = [0, 0, 0, px, py, 1, -qy * px, -qy * py];
      b[2 * i + 1] = qy;
    }
    return solveLinear(a, b);
  }

  /// Gaussian elimination with partial pivoting.
  static List<double>? solveLinear(List<List<double>> a, List<double> b) {
    final n = b.length;
    final m = [for (var i = 0; i < n; i++) [...a[i], b[i]]];
    for (var col = 0; col < n; col++) {
      var pivot = col;
      for (var r = col + 1; r < n; r++) {
        if (math.abs(m[r][col]) > math.abs(m[pivot][col])) pivot = r;
      }
      if (math.abs(m[pivot][col]) < 1e-12) return null;
      if (pivot != col) {
        final t = m[col];
        m[col] = m[pivot];
        m[pivot] = t;
      }
      final pv = m[col][col];
      for (var r = 0; r < n; r++) {
        if (r == col) continue;
        final f = m[r][col] / pv;
        if (f == 0) continue;
        for (var c = col; c <= n; c++) {
          m[r][c] -= f * m[col][c];
        }
      }
    }
    return [for (var i = 0; i < n; i++) m[i][n] / m[i][i]];
  }

  static Offset applyHomography(List<double> h, Offset p) {
    final w = h[6] * p.dx + h[7] * p.dy + 1;
    return Offset(
      (h[0] * p.dx + h[1] * p.dy + h[2]) / w,
      (h[3] * p.dx + h[4] * p.dy + h[5]) / w,
    );
  }

  /// Fraction of dark pixels inside a disc (0 outside the frame).
  static double _inkRatio(
      Uint8List ink, int w, int h, double cx, double cy, double r) {
    final cxI = cx.round(), cyI = cy.round();
    final ri = r.ceil();
    if (cxI - ri < 0 || cyI - ri < 0 || cxI + ri >= w || cyI + ri >= h) {
      return 0;
    }
    var dark = 0, tot = 0;
    final r2 = r * r;
    for (var dy = -ri; dy <= ri; dy++) {
      final row = (cyI + dy) * w;
      for (var dx = -ri; dx <= ri; dx++) {
        if (dx * dx + dy * dy > r2) continue;
        tot++;
        if (ink[row + cxI + dx] == 1) dark++;
      }
    }
    return tot == 0 ? 0 : dark / tot;
  }
}
