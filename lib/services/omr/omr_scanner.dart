import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'omr_geometry.dart';

/// Argument bundle for running [OMrScanner.scan] via [compute] —
/// `compute` sends a single message across the isolate boundary.
class OmScanRequest {
  final Uint8List photoBytes;
  final int total;

  /// True when the image is a page a document scanner returned — already
  /// straight and cropped to the sheet's edges, so the read may fall back
  /// to the page boundary when the sheet carries no (or too few)
  /// registration marks.
  final bool rectified;

  const OmScanRequest(this.photoBytes, this.total, [this.rectified = false]);
}

/// Top-level entry point for [compute] (only top-level/static functions
/// may cross the isolate boundary). Running the whole scan off the UI
/// isolate keeps the interface responsive while a photo — or a gallery
/// batch — is being read.
Future<OmScanResult> omrScanIsolateEntry(OmScanRequest req) =>
    OMrScanner.scan(
        req.photoBytes, total: req.total, rectified: req.rectified);

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
    bool rectified = false,
  }) async {
    if (total < 1 || total > 100) {
      return OmScanResult.failed('Question count must be 1–100.');
    }
    final geo = OMrGeometry(total);

    // Decode with dart:ui (no third-party decoder needed).
    ui.Image decoded;
    try {
      final codec = await ui.instantiateImageCodec(photoBytes);
      decoded = (await codec.getNextFrame()).image;
    } catch (_) {
      return OmScanResult.failed(
          'Image could not be read. Use a normal photo (JPG).');
    }

    // Work on roughly the sheet's own resolution so one bubble stays a
    // sensible number of pixels (≈10–13 px). Downsample by hand — box
    // average straight to luma from the decoded image's own pixel data —
    // instead of drawing through a Canvas/PictureRecorder: Canvas.toImage
    // needs the engine's raster thread and throws the moment this
    // pipeline runs inside compute() (see omrScanIsolateEntry), which is
    // exactly where a scan this size belongs so the UI never freezes.
    const targetH = 2339;
    final srcW = decoded.width;
    final srcH = decoded.height;
    final srcBytes =
        (await decoded.toByteData(format: ui.ImageByteFormat.rawRgba))
            ?.buffer
            .asUint8List();
    if (srcBytes == null) {
      return OmScanResult.failed(
          'Image could not be processed. Try a different photo.');
    }
    final s = targetH / srcH;
    final w = (srcW * s).round();
    final h = targetH;
    if (w < 200) {
      return OmScanResult.failed('Photo is too small to scan.');
    }

    final pixels = Uint8List(w * h);
    for (var dy = 0; dy < h; dy++) {
      final sy0 = (dy * srcH / h).floor();
      final sy1 =
          math.max(sy0 + 1, ((dy + 1) * srcH / h).ceil()).clamp(0, srcH);
      final orow = dy * w;
      for (var dx = 0; dx < w; dx++) {
        final sx0 = (dx * srcW / w).floor();
        final sx1 =
            math.max(sx0 + 1, ((dx + 1) * srcW / w).ceil()).clamp(0, srcW);
        var sum = 0, n = 0;
        for (var sy = sy0; sy < sy1; sy++) {
          final srow = sy * srcW;
          for (var sx = sx0; sx < sx1; sx++) {
            final o = (srow + sx) * 4;
            // Luma (BT.601); the weighted sum is always within 0..65280,
            // so the >> 8 result is a valid 8-bit gray value.
            sum += (srcBytes[o] * 77 +
                    srcBytes[o + 1] * 150 +
                    srcBytes[o + 2] * 29) >>
                8;
            n++;
          }
        }
        pixels[orow + dx] = n == 0 ? 0 : (sum ~/ n);
      }
    }

    final double otsuT = _otsu(pixels);
    final ink = Uint8List(w * h);
    final paper = Uint8List(w * h);
    // A stricter mask for the corner-mark search: the printed corner
    // squares are the darkest things on the sheet, so thresholding at
    // well below Otsu keeps them isolated even when a shadow darkens
    // the paper around them (which would otherwise merge mark + shadow
    // band into one giant component in the Otsu mask).
    final darkT = otsuT * 0.55;
    final dark = Uint8List(w * h);
    for (var i = 0; i < w * h; i++) {
      ink[i] = pixels[i] < otsuT ? 1 : 0;
      paper[i] = 1 - ink[i];
      dark[i] = pixels[i] < darkT ? 1 : 0;
    }

    // ── 3. corner marks ────────────────────────────────────────────
    // Detect all four marks first so a missing corner can be *estimated*
    // from the other three (parallelogram rule) instead of hunting for
    // the brightest pixel in the corner band — with another sheet lying
    // next to or under the OMR sheet, that bright pixel often belongs to
    // the neighbour, which wrecks the homography fit.
    final marks = <DetectedCorner?>[
      for (var c = 0; c < 4; c++) _detectCornerMark(c, dark, w, h),
    ];
    final markCount = marks.where((m) => m != null).length;
    double cx = w / 2, cy = h / 2;
    if (markCount > 0) {
      var sx = 0.0, sy = 0.0;
      for (final m in marks) {
        sx += m!.point.dx;
        sy += m!.point.dy;
      }
      cx = sx / markCount;
      cy = sy / markCount;
    }
    final seed = ui.Offset(cx, cy);

    // The paper-fallback path can be needed for up to all four corners
    // plus once more for the outlier swap — every call used to redo the
    // same seeded flood-fill over the *entire* photo (≈4M pixels each).
    // Compute it once, lazily, and hand the same component to every call.
    Uint8List? sharedComp;
    var sharedCompReady = false;
    Uint8List? paperComp() {
      if (!sharedCompReady) {
        sharedComp =
            _paperComponent(paper, w, h, seed.dx.round(), seed.dy.round());
        sharedCompReady = true;
      }
      return sharedComp;
    }

    final corners = <DetectedCorner>[];
    for (var c = 0; c < 4; c++) {
      final mark = marks[c];
      if (mark != null) {
        corners.add(mark);
        continue;
      }
      if (markCount >= 3) {
        final est = _parallelogramCorner(c, marks, w, h);
        if (est != null) {
          // Estimated, not measured: keep it out of the mark-consistency
          // check and let the fit treat it as a soft (paper) anchor.
          corners.add(DetectedCorner(est, false));
          continue;
        }
      }
      final fallback = _paperCornerFallback(c, paper, w, h, paperComp());
      if (fallback == null) {
        return OmScanResult.failed(
            'Corner marks not found. Keep the whole OMR sheet in frame, in even light, and take the photo again.');
      }
      corners.add(fallback);
    }

    // If the four "marks" do not outline a consistent A4 sheet, one of
    // them is a false positive (tape, a dark stain, …) — swap it for the
    // paper-corner fallback so the homography stage can still anchor well.
    final outlier = _outlierMarkIndex(corners, w, h);
    if (outlier >= 0) {
      final fb = _paperCornerFallback(outlier, paper, w, h, paperComp());
      if (fb != null) corners[outlier] = fb;
    }

    // ── 4. homography (try all four sheet rotations) ───────────────
    final List<double>? solved =
        _bestRotationHomography(geo, corners, ink, pixels, w, h);
    List<double>? candidate =
        (solved != null && solved.every((v) => v.isFinite)) ? solved : null;
    // A page returned by the document scanner is already straight and
    // cropped to the sheet's edges, so its image corners are its page
    // corners — a second alignment that needs no registration marks at
    // all. A sheet without four printed corner marks can only be read
    // through this path.
    if (candidate == null && rectified) {
      candidate = _pageBoundsHomography(geo, ink, pixels, paper, w, h);
    }
    if (candidate == null) {
      return OmScanResult.failed(
          'Could not align the sheet (found $markCount of 4 corner marks). Keep it centered with a small margin, in even light, away from any other paper, and take the photo again.');
    }
    // Bound to a final: the read below captures [homography] in a
    // closure, and only a final local keeps its promoted (non-null) type
    // inside that closure.
    final homography = candidate;

    // Scale: page diagonal in the working image.
    final tl = applyHomography(homography, OMrGeometry.markCenter(0));
    final br = applyHomography(homography, OMrGeometry.markCenter(3));
    final scale = math.sqrt(
            (br.dx - tl.dx) * (br.dx - tl.dx) +
            (br.dy - tl.dy) * (br.dy - tl.dy)) /
        OMrGeometry.cornerDiagonal;
    if (!scale.isFinite || scale <= 0) {
      return OmScanResult.failed(
          'Could not align the sheet (no valid scale, $markCount of 4 corner marks). Keep it flat and still, and take the photo again.');
    }
    // A physical A4 sheet photographed for OMR sits well within this range;
    // anything else means the "alignment" is a distorted projective fit.
    if (scale < 0.3 || scale > 3.0) {
      return OmScanResult.failed(
          'Could not align the sheet (scale ${scale.toStringAsFixed(2)} — the whole sheet must fit in frame with a small margin).');
    }
    final bubbleR = OMrGeometry.bubbleRadiusPx * scale;
    if (bubbleR < 4) {
      return OmScanResult.failed(
          'The sheet is too small in the photo. Move closer and take the photo again.');
    }
    final rawR = bubbleR * 0.55;
    final sampleR = rawR < 3.5 ? 3.5 : (rawR > 22.0 ? 22.0 : rawR);

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

  /// Grades [result] against [key] (option index per question).
  ///
  /// Scoring rule (standard exam convention): a double-marked question is
  /// *invalid* — it is counted as wrong (no credit) and additionally kept
  /// in [OmGraded.ambiguous] so the UI, history and scorecard can flag it
  /// separately.
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
        wrong++;
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
        bestT = t.toDouble();
      }
    }
    return bestT;
  }

  /// Finds the filled corner square in quadrant [corner]
  /// (0 TL, 1 TR, 2 BL, 3 BR of the *photo*).
  ///
  /// Runs on the *dark* mask (luma < 0.55×Otsu): the printed corner squares
  /// are the darkest things on the sheet, so a shadow band, a dark desk
  /// strip or the grid ink around them is not even in the mask, and the
  /// mark stays an isolated solid blob no matter how the sheet is lit.
  ///
  /// A candidate must look like a *solid square*: high fill (a filled
  /// square inks ≥ ~0.85 of its box; a filled bubble is a circle at π/4
  /// ≈ 0.78, text glyphs far below) and a ~1:1 bounding box, a plausible
  /// mark size, and it must not be clipped by the search region (clipped
  /// blobs are regions — desk/shadow — not the mark).
  static DetectedCorner? _detectCornerMark(
      int corner, Uint8List dark, int w, int h) {
    // Wide enough for a sheet that lies sideways in the frame (a phone
    // photo with a 90° EXIF orientation puts the marks far from the photo
    // corners); the shape gate below keeps the intruding grid out.
    const s = 0.45;
    final x0 = [0, (w * (1 - s)).round(), 0, (w * (1 - s)).round()][corner];
    final x1 = [(w * s).round(), w, (w * s).round(), w][corner];
    final y0 = [0, 0, (h * (1 - s)).round(), (h * (1 - s)).round()][corner];
    final y1 = [(h * s).round(), (h * s).round(), h, h][corner];
    // No inset: a mark can sit right against the 0.45 quadrant boundary
    // (small sheet, off-centre) and must not be clipped away by the search
    // boundary; truly clipped desk/grid regions still touch it and are
    // rejected by the boundary check below.
    final insetX = 0;
    final insetY = 0;
    final rw = x1 - insetX - (x0 + insetX);
    final rh = y1 - insetY - (y0 + insetY);
    if (rw < 8 || rh < 8) return null;

    // Flood-fill connected components (4-connectivity) over the quadrant.
    final visited = Uint8List(rw * rh);
    var bestScore = 0.0;
    var bestCx = 0.0, bestCy = 0.0, bestDiag = 0.0;
    final stack = List<int>.filled(rw * rh, 0);
    final diag = math.sqrt(w * w + h * h);

    for (var ly = 0; ly < rh; ly++) {
      for (var lx = 0; lx < rw; lx++) {
        if (visited[ly * rw + lx] == 1) continue;
        final gx = x0 + insetX + lx;
        final gy = y0 + insetY + ly;
        if (dark[gy * w + gx] == 0) continue;
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
          if (dark[(y0 + insetY + ny) * w + (x0 + insetX + nx)] == 0) return;
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
        final ratio = bw < bh ? bw / bh : bh / bw;
        final blobD = math.sqrt(bw * bw + bh * bh);
        if (area < 40) continue; // too small to be a mark
        if (fill < 0.85) continue; // not solid (bubble circle ≈ 0.78, text ≪)
        if (ratio < 0.75 || ratio > 1.35) continue; // band/line, not square
        if (blobD < diag * 0.003 || blobD > diag * 0.08) continue;
        // Clipped by the search boundary → a region (desk/shadow/grid),
        // not the mark (the mark always sits well inside the sheet).
        if (minX == 0 || minY == 0 || maxX == rw - 1 || maxY == rh - 1) {
          continue;
        }
        final score = area * fill;
        if (score > bestScore) {
          bestScore = score;
          bestCx = x0 + insetX + (sumX / area);
          bestCy = y0 + insetY + (sumY / area);
          bestDiag = blobD;
        }
      }
    }
    if (bestScore <= 0) return null;
    return DetectedCorner(
      ui.Offset(bestCx, bestCy),
      true,
      blobDiag: bestDiag,
    );
  }

  /// Global sanity check over the four detected marks. The marks are equal
  /// solid squares on one sheet, so their sizes must agree and their
  /// centres must outline a plausible A4 quadrilateral. Returns the index
  /// (TL=0, TR=1, BL=2, BR=3) of the one "mark" to discard — the caller
  /// re-runs the paper-corner fallback for it — or -1 when the marks are
  /// consistent.
  static int _outlierMarkIndex(List<DetectedCorner> corners, int w, int h) {
    if (corners.where((c) => c.fromMark).length < 4) return -1;
    final q = [
      corners[0].point, // TL
      corners[1].point, // TR
      corners[3].point, // BR
      corners[2].point, // BL
    ];
    var bad = !_isConvexQuadrilateral(q);
    if (!bad) {
      double len(ui.Offset a, ui.Offset b) => math.sqrt(
          (b.dx - a.dx) * (b.dx - a.dx) + (b.dy - a.dy) * (b.dy - a.dy));
      final aW = (len(q[0], q[1]) + len(q[3], q[2])) / 2;
      final aH = (len(q[0], q[3]) + len(q[1], q[2])) / 2;
      final aspect = aW < aH ? aW / aH : aH / aW;
      // Quadrilateral area (shoelace).
      var area2 = 0.0;
      for (var i = 0; i < 4; i++) {
        final a = q[i], b = q[(i + 1) % 4];
        area2 += a.dx * b.dy - b.dx * a.dy;
      }
      if (aspect < 0.45 || aspect > 1.45 || area2.abs() / 2 < w * h * 0.08) {
        bad = true;
      }
    }
    if (!bad) return -1;
    final diags = [for (final c in corners) if (c.fromMark) c.blobDiag];
    final sorted = [...diags]..sort();
    final median = (sorted[1] + sorted[2]) / 2 < 1 ? 1.0 : (sorted[1] + sorted[2]) / 2;
    var worst = -1;
    var worstDev = -1.0;
    for (var i = 0; i < 4; i++) {
      if (!corners[i].fromMark) continue;
      final dev = (corners[i].blobDiag / median - 1).abs();
      if (dev > worstDev) {
        worstDev = dev;
        worst = i;
      }
    }
    if (worstDev < 0.35) return -1; // no clear outlier; keep everything
    return worst;
  }

  /// Fallback registration point: the extreme bright (paper) pixel in the
  /// corner's diagonal band — the page corner itself.
  ///
  /// A point that lands *on the frame border* is flagged [DetectedCorner.
  /// edgeSuspect]: it is usually the photo's own corner, captured because
  /// a bright desk/bedsheet merged with the sheet in the paper mask.
  /// Estimates a missing corner from the other three detected marks. The
  /// four physical marks form a rectangle, and under the mild perspective
  /// of a handheld photo the parallelogram rule (complete the opposite
  /// side's vector) is a close anchor — far closer than a bright pixel
  /// that may belong to a neighbouring sheet.
  static ui.Offset? _parallelogramCorner(
      int missing, List<DetectedCorner?> marks, int w, int h) {
    final tl = marks[0]?.point;
    final tr = marks[1]?.point;
    final bl = marks[2]?.point;
    final br = marks[3]?.point;
    ui.Offset? est;
    switch (missing) {
      case 0: // TL = TR + (BL − BR)
        if (tr != null && bl != null && br != null) {
          est = ui.Offset(tr.dx + bl.dx - br.dx, tr.dy + bl.dy - br.dy);
        }
        break;
      case 1: // TR = TL + (BR − BL)
        if (tl != null && bl != null && br != null) {
          est = ui.Offset(tl.dx + br.dx - bl.dx, tl.dy + br.dy - bl.dy);
        }
        break;
      case 2: // BL = TL + (BR − TR)
        if (tl != null && tr != null && br != null) {
          est = ui.Offset(tl.dx + br.dx - tr.dx, tl.dy + br.dy - tr.dy);
        }
        break;
      default: // BR = TR + (BL − TL)
        if (tl != null && tr != null && bl != null) {
          est = ui.Offset(tr.dx + bl.dx - tl.dx, tr.dy + bl.dy - tl.dy);
        }
    }
    if (est == null) return null;
    // A wild estimate means the marks are inconsistent (one is a false
    // positive) — refuse it and let the caller use the paper fallback.
    if (est.dx < -w * 0.05 || est.dx > w * 1.05 ||
        est.dy < -h * 0.05 || est.dy > h * 1.05) {
      return null;
    }
    return est;
  }

  /// The paper-mask connected component containing (sx, sy), or null when
  /// the seed isn't on paper.
  static Uint8List? _paperComponent(
      Uint8List paper, int w, int h, int sx, int sy) {
    if (sx < 0 || sy < 0 || sx >= w || sy >= h) return null;
    if (paper[sy * w + sx] == 0) return null;
    final comp = Uint8List(w * h);
    final stack = <int>[sy * w + sx];
    comp[sy * w + sx] = 1;
    var top = 0;
    while (top < stack.length) {
      final idx = stack[top++];
      final x = idx % w;
      final y = idx ~/ w;
      if (x > 0 && comp[idx - 1] == 0 && paper[idx - 1] == 1) {
        comp[idx - 1] = 1;
        stack.add(idx - 1);
      }
      if (x < w - 1 && comp[idx + 1] == 0 && paper[idx + 1] == 1) {
        comp[idx + 1] = 1;
        stack.add(idx + 1);
      }
      if (y > 0 && comp[idx - w] == 0 && paper[idx - w] == 1) {
        comp[idx - w] = 1;
        stack.add(idx - w);
      }
      if (y < h - 1 && comp[idx + w] == 0 && paper[idx + w] == 1) {
        comp[idx + w] = 1;
        stack.add(idx + w);
      }
    }
    return comp;
  }

  static DetectedCorner? _paperCornerFallback(
      int corner, Uint8List paper, int w, int h, Uint8List? comp) {
    final band = 0.45;
    // [comp] restricts the search to the paper region connected to the
    // scan's seed point (the sheet itself) — computed once by the caller
    // and shared across every corner + the outlier check, since it's a
    // full flood-fill over the whole photo. A neighbouring white sheet in
    // the corner band then can't win the "extreme bright pixel" search.
    // When the seed isn't on paper [comp] is null and the whole frame is
    // searched.
    var best = double.infinity;
    ui.Offset bestP = ui.Offset.zero;
    var found = false;
    final step = 2; // sampling stride — corners are large targets
    for (var y = 0; y < h; y += step) {
      final row = y * w;
      for (var x = 0; x < w; x += step) {
        if (paper[row + x] == 0) continue;
        if (comp != null && comp[row + x] == 0) continue;
        final inBand = switch (corner) {
          0 => x < w * band && y < h * band,
          1 => x > w * (1 - band) && y < h * band,
          2 => x < w * band && y > h * (1 - band),
          _ => x > w * (1 - band) && y > h * (1 - band),
        };
        if (!inBand) continue;
        final score = switch (corner) {
          0 => (x + y).toDouble(),
          1 => (y - x).toDouble(),
          2 => (x - y).toDouble(),
          _ => (-(x + y)).toDouble(),
        };
        if (score < best) {
          best = score;
          bestP = ui.Offset(x.toDouble(), y.toDouble());
          found = true;
        }
      }
    }
    if (!found) return null;
    final edgeSuspect =
        bestP.dx < 2 || bestP.dy < 2 || bestP.dx > w - 3 || bestP.dy > h - 3;
    return DetectedCorner(bestP, false, edgeSuspect: edgeSuspect);
  }

  /// Solves the page→photo homography.
  ///
  /// Each detected photo corner can anchor the sheet in two ways: its solid
  /// *mark* centre (page anchor = the mark centre on the page) or its
  /// extreme *paper* pixel (page anchor = the page corner itself). The
  /// page-side anchor must match what the photo point actually is, so every
  /// one of the 16 anchor combinations is tried — together with all four
  /// sheet rotations — and the mapping that looks most like a real
  /// photograph of an A4 sheet wins:
  ///
  ///  1. the four photo points form a convex quadrilateral,
  ///  2. the fit is nearly affine: the projected page centre must land near
  ///     the detected quadrilateral's diagonal crossing — a heavily
  ///     distorted projective fit (wrong pairing, or a photo-corner anchor)
  ///     fails this,
  ///  3. the sheet keeps its portrait A4 proportions,
  ///  4. the dense question grid sits at the *top* of the sheet (content
  ///     probe) and the bottom is not denser than the top,
  ///  5. mark anchors are preferred over paper anchors, and a photo-corner
  ///     ("edge suspect") anchor is heavily penalised.
  static List<double>? _bestRotationHomography(
      OMrGeometry geo, List<DetectedCorner> corners,
      [Uint8List? ink, Uint8List? luma, int w = 0, int h = 0]) {
    // Clockwise corner order: TL, TR, BR, BL.
    // `corners` is indexed TL(0), TR(1), BL(2), BR(3).
    final markAnchor = [
      OMrGeometry.markCenter(0),
      OMrGeometry.markCenter(1),
      OMrGeometry.markCenter(3),
      OMrGeometry.markCenter(2),
    ];
    final pageAnchor = [
      const ui.Offset(0, 0),
      ui.Offset(OMrGeometry.pageW, 0),
      ui.Offset(OMrGeometry.pageW, OMrGeometry.pageH),
      const ui.Offset(0, OMrGeometry.pageH),
    ];
    final hasMark = [
      corners[0].fromMark,
      corners[1].fromMark,
      corners[3].fromMark,
      corners[2].fromMark,
    ];
    final photoPoint = [
      corners[0].point,
      corners[1].point,
      corners[3].point,
      corners[2].point,
    ];
    final suspect = [
      corners[0].edgeSuspect,
      corners[1].edgeSuspect,
      corners[3].edgeSuspect,
      corners[2].edgeSuspect,
    ];

    List<double>? bestH;
    var bestErr = 1e18;

    for (var mask = 0; mask < 16; mask++) {
      final p = <ui.Offset>[];
      final q = <ui.Offset>[];
      var paperAnchors = 0;
      var suspects = 0;
      var valid = true;
      for (var k = 0; k < 4; k++) {
        final useMark = ((mask >> k) & 1) == 1;
        if (useMark && !hasMark[k]) {
          valid = false;
          break;
        }
        p.add(useMark ? markAnchor[k] : pageAnchor[k]);
        q.add(photoPoint[k]);
        if (!useMark) {
          paperAnchors++;
          if (suspect[k]) suspects++;
        }
      }
      if (!valid) continue;

      for (var rot = 0; rot < 4; rot++) {
        // Rotate only the photo side: page corner k is paired with photo
        // corner (k + rot) — a sheet turned rot × 90° in the frame.
        // (Shifting both sides would leave the correspondence — and the
        // homography — unchanged.)
        final qq = [for (var j = 0; j < 4; j++) q[(j + rot) % 4]];
        if (!_isConvexQuadrilateral(qq)) continue;
        final hHom = homographyFrom4(p, qq);
        if (hHom == null) continue;
        // Project the four page corners, measure width & height.
        final pts = [
          applyHomography(hHom, const ui.Offset(0, 0)),
          applyHomography(hHom, const ui.Offset(OMrGeometry.pageW, 0)),
          applyHomography(hHom, ui.Offset(OMrGeometry.pageW, OMrGeometry.pageH)),
          applyHomography(hHom, const ui.Offset(0, OMrGeometry.pageH)),
        ];
        // A nearly-collinear anchor set can produce a homography that maps
        // part of the page to infinity (or to absurdly far away); NaN
        // comparisons would silently pass every gate below, so reject such
        // fits here. A real sheet can never project beyond ~10 frames.
        final frameDiag = math.sqrt(w * w + h * h) * 10;
        if (pts.any((pt) =>
            !pt.dx.isFinite ||
            !pt.dy.isFinite ||
            pt.dx.abs() > frameDiag ||
            pt.dy.abs() > frameDiag)) {
          continue;
        }
        double len(ui.Offset a, ui.Offset b) => math.sqrt(
            (b.dx - a.dx) * (b.dx - a.dx) + (b.dy - a.dy) * (b.dy - a.dy));
        final width = (len(pts[0], pts[1]) + len(pts[3], pts[2])) / 2;
        final height = (len(pts[0], pts[3]) + len(pts[1], pts[2])) / 2;
        if (width < 200 || height < 200) continue;
        // Hard sanity gate: the projected sheet must keep A4 proportions,
        // even under strong perspective.
        final aspect = width < height ? width / height : height / width;
        if (aspect < 0.45) continue;
        var err = 0.0;

        // Affine-ness: the projected page centre should sit near the
        // detected quadrilateral's diagonal crossing.
        final pc = applyHomography(
            hHom, ui.Offset(OMrGeometry.pageW / 2, OMrGeometry.pageH / 2));
        final icx = (qq[0].dx + qq[2].dx) / 2, icy = (qq[0].dy + qq[2].dy) / 2;
        final jcX = (qq[1].dx + qq[3].dx) / 2, jcY = (qq[1].dy + qq[3].dy) / 2;
        final ic = ui.Offset((icx + jcX) / 2, (icy + jcY) / 2);
        final centerDev = len(pc, ic) / math.min(width, height);
        if (centerDev > 0.12) continue; // distorted fit — not a real sheet
        err += centerDev;

        // Orientation probe — shadow-invariant. The question grid (top of
        // the sheet) must be the more structured of the two probe regions:
        // a raw ink ratio saturates under a shadow (a shaded blank margin
        // reads "denser" than the bright grid), but the grid's luma
        // variance — bubble outlines, numbers, filled inks — stays far
        // above a blank or smoothly shaded area, so it survives shading.
        if (luma != null && ink != null && w > 0 && h > 0) {
          final gridH = geo.perColumn * OMrGeometry.rowH;
          final halfGrid = gridH * 0.5;
          final probeY = OMrGeometry.questionsTop +
              (halfGrid < 60 ? 60 : (halfGrid > 240 ? 240 : halfGrid));
          final top = applyHomography(
              hHom, ui.Offset(OMrGeometry.pageW / 2, probeY));
          final bottom =
              applyHomography(hHom, const ui.Offset(OMrGeometry.pageW / 2, 2189));
          final topVar = _diskVariance(luma, w, h, top.dx, top.dy, 24);
          final botVar = _diskVariance(luma, w, h, bottom.dx, bottom.dy, 24);
          if (topVar < 100) {
            // No grid structure at the top — the strip is desk, blank paper
            // or flat shadow, not the question grid. A 180°-flipped mapping
            // can be numerically tied with the correct one otherwise.
            err += 0.35;
          }
          if (botVar > topVar * 0.5) {
            // The page's bottom strip carries the signature space — it must
            // be far less structured than the grid strip. A shadowed blank
            // strip stays low-variance, so this stays shadow-invariant too.
            err += 0.6;
          }
          // Grid visibility: max over three grid columns — a single small
          // disk can miss the row lines, which wrongly penalises a correct
          // alignment (the grid has ink in every column).
          double topInk = 0;
          for (final qx in const [400.0, OMrGeometry.pageW / 2, 1254.0]) {
            final pp = applyHomography(hHom, ui.Offset(qx, probeY));
            final v = _inkRatio(ink, w, h, pp.dx, pp.dy, 24);
            if (v > topInk) topInk = v;
            if (topInk > 0.4) break; // clearly grid — no need to sample more
          }
          if (topInk < 0.15) {
            err += 0.15 - topInk; // grid not visible at the top
          }
        }

        // Prefer the unambiguous mark centres; distrust photo corners.
        err += paperAnchors * 0.05 + suspects * 0.3;

        if (err < bestErr) {
          bestErr = err;
          bestH = hHom;
        }
      }
    }
    return bestH;
  }

  /// Alignment for a page a document scanner returned: the image is
  /// already straight and cropped to the sheet's edges, so the image
  /// corners are the page corners — no registration marks required.
  ///
  ///  - the frame must keep A4 proportions (a 90°-turned page is
  ///    landscape and fails the gate; only upright vs. upside-down stays
  ///    ambiguous),
  ///  - when the paper mask shows the sheet ending before the frame edge
  ///    (a loose crop), the paper's own extreme corners anchor the sheet
  ///    instead of the frame's,
  ///  - the same orientation probe as [_bestRotationHomography] keeps
  ///    the side carrying the question grid at the top.
  static List<double>? _pageBoundsHomography(
      OMrGeometry geo,
      Uint8List? ink,
      Uint8List? luma,
      Uint8List paper,
      int w,
      int h) {
    final a4 = OMrGeometry.pageW / OMrGeometry.pageH;
    final actual = w / h;
    if (actual / a4 < 0.94 || actual / a4 > 1.06) return null;

    // Frame corners, clockwise: TL, TR, BR, BL.
    var photoPts = <ui.Offset>[
      const ui.Offset(0, 0),
      ui.Offset(w.toDouble(), 0),
      ui.Offset(w.toDouble(), h.toDouble()),
      ui.Offset(0, h.toDouble()),
    ];
    // Loose crop: the paper stops before the frame — anchor to the
    // paper's own extreme corners instead.
    final comp = _paperComponent(paper, w, h, (w / 2).round(), (h / 2).round());
    if (comp != null) {
      var count = 0;
      var s0 = 1e18, s1 = 1e18, s2 = 1e18, s3 = 1e18;
      var x0 = 0.0, y0 = 0.0, x1 = 0.0, y1 = 0.0;
      var x2 = 0.0, y2 = 0.0, x3 = 0.0, y3 = 0.0;
      for (var y = 0; y < h; y++) {
        final row = y * w;
        for (var x = 0; x < w; x++) {
          if (comp[row + x] == 0) continue;
          count++;
          final a = (x + y).toDouble();
          if (a < s0) {
            s0 = a;
            x0 = x.toDouble();
            y0 = y.toDouble();
          }
          final b = (y - x).toDouble();
          if (b < s1) {
            s1 = b;
            x1 = x.toDouble();
            y1 = y.toDouble();
          }
          final c = (-(x + y)).toDouble();
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
      if (count > w * h * 0.20 && count < w * h * 0.97) {
        photoPts = <ui.Offset>[
          ui.Offset(x0, y0),
          ui.Offset(x1, y1),
          ui.Offset(x2, y2),
          ui.Offset(x3, y3),
        ];
      }
    }

    final pagePts = <ui.Offset>[
      const ui.Offset(0, 0),
      ui.Offset(OMrGeometry.pageW, 0),
      ui.Offset(OMrGeometry.pageW, OMrGeometry.pageH),
      const ui.Offset(0, OMrGeometry.pageH),
    ];

    List<double>? best;
    var bestErr = 1e18;
    for (final rot in const [0, 2]) {
      final qq = [for (var j = 0; j < 4; j++) photoPts[(j + rot) % 4]];
      if (!_isConvexQuadrilateral(qq)) continue;
      final hHom = homographyFrom4(pagePts, qq);
      if (hHom == null) continue;
      var err = 0.0;
      if (luma != null && ink != null) {
        final gridH = geo.perColumn * OMrGeometry.rowH;
        final halfGrid = gridH * 0.5;
        final probeY = OMrGeometry.questionsTop +
            (halfGrid < 60 ? 60 : (halfGrid > 240 ? 240 : halfGrid));
        final top =
            applyHomography(hHom, ui.Offset(OMrGeometry.pageW / 2, probeY));
        final bottom =
            applyHomography(hHom, const ui.Offset(OMrGeometry.pageW / 2, 2189));
        final topVar = _diskVariance(luma, w, h, top.dx, top.dy, 24);
        final botVar = _diskVariance(luma, w, h, bottom.dx, bottom.dy, 24);
        if (topVar < 100) err += 0.35;
        if (botVar > topVar * 0.5) err += 0.6;
        double topInk = 0;
        for (final qx in const [400.0, OMrGeometry.pageW / 2, 1254.0]) {
          final pp = applyHomography(hHom, ui.Offset(qx, probeY));
          final v = _inkRatio(ink, w, h, pp.dx, pp.dy, 24);
          if (v > topInk) topInk = v;
          if (topInk > 0.4) break;
        }
        if (topInk < 0.15) err += 0.15 - topInk;
      }
      if (err < bestErr) {
        bestErr = err;
        best = hHom;
      }
    }
    return best;
  }

  /// True if [pts] (in order) form a simple convex quadrilateral.
  static bool _isConvexQuadrilateral(List<ui.Offset> pts) {
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
  static List<double>? homographyFrom4(List<ui.Offset> p, List<ui.Offset> q) {
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
        if (m[r][col].abs() > m[pivot][col].abs()) pivot = r;
      }
      if (m[pivot][col].abs() < 1e-12) return null;
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
    final solution = [for (var i = 0; i < n; i++) m[i][n] / m[i][i]];
    // Near-degenerate systems can survive the pivot check and still
    // produce Inf/NaN coefficients — never let those out.
    for (final v in solution) {
      if (!v.isFinite) return null;
    }
    return solution;
  }

  static ui.Offset applyHomography(List<double> h, ui.Offset p) {
    final w = h[6] * p.dx + h[7] * p.dy + 1;
    return ui.Offset(
      (h[0] * p.dx + h[1] * p.dy + h[2]) / w,
      (h[3] * p.dx + h[4] * p.dy + h[5]) / w,
    );
  }

  /// Fraction of dark pixels inside a disc (0 outside the frame).
  static double _inkRatio(
      Uint8List ink, int w, int h, double cx, double cy, double r) {
    // Check in the double domain: rounding a non-finite or huge value
    // throws. Nothing beyond the frame (by a wide margin) is meaningful.
    if (!cx.isFinite || !cy.isFinite) return 0;
    if (cx < -1e4 || cx > 1e4 || cy < -1e4 || cy > 1e4) return 0;
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

  /// Luma variance inside a disc — a shadow-invariant measure of local
  /// structure (a smooth darkening barely changes a region's variance).
  /// The question grid scores far higher than a blank margin or a
  /// smoothly shaded area.
  static double _diskVariance(
      Uint8List luma, int w, int h, double cx, double cy, double r) {
    if (!cx.isFinite || !cy.isFinite) return 0;
    if (cx < -1e4 || cx > 1e4 || cy < -1e4 || cy > 1e4) return 0;
    final cxI = cx.round(), cyI = cy.round();
    final ri = r.ceil();
    if (cxI - ri < 0 || cyI - ri < 0 || cxI + ri >= w || cyI + ri >= h) {
      return 0;
    }
    var sum = 0, sum2 = 0, tot = 0;
    final r2 = r * r;
    for (var dy = -ri; dy <= ri; dy++) {
      final row = (cyI + dy) * w;
      for (var dx = -ri; dx <= ri; dx++) {
        if (dx * dx + dy * dy > r2) continue;
        final v = luma[row + cxI + dx];
        sum += v;
        sum2 += v * v;
        tot++;
      }
    }
    if (tot == 0) return 0;
    final mean = sum / tot;
    final v = sum2 / tot - mean * mean;
    return v < 0 ? 0 : v;
  }
}
