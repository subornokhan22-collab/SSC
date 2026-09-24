import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image/image.dart' as img;

import 'omr_geometry.dart';

/// Argument bundle for running [OMrScanner.scan] via [compute] —
/// `compute` sends a single message across the isolate boundary.
/// Decode failure raised from inside the scan isolate. Thrown (rather
/// than returned as a failure result) so the caller can retry the whole
/// scan on the UI isolate: on some Android builds a background isolate
/// cannot decode an image the UI isolate decodes without any trouble.
class OmDecodeException implements Exception {
  final String detail;
  const OmDecodeException(this.detail);
  @override
  String toString() => 'OmDecodeException: $detail';
}

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
  final List<int> correctedIndices;
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

  /// Alignment diagnostics captured at the moment of failure — the debug
  /// export writes them out so an unreadable photo can be analyzed against
  /// the exact corners and homography the app saw, without the phone.
  final Map<String, dynamic>? debug;

  /// Ink ratios the sampler actually saw at a *successful* read, one line
  /// per notable bubble — so an answer that came back blank can be judged
  /// against how much ink was really there (faint pen vs. wrong position).
  final List<String>? inkDiag;

  /// A front-on, auto-cropped JPEG of just the sheet (A4-proportioned,
  /// long side ≈1500 px). Present for uploaded photos after a successful
  /// alignment, so they get the same "cropped sheet" look the document
  /// scanner's camera crop produces. Null for scanner-rectified photos
  /// (already cropped) and failed reads.
  final Uint8List? rectifiedJpeg;

  OmScanResult._({
    this.correctedIndices=const [],
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
    this.debug,
    this.inkDiag,
    this.rectifiedJpeg,
  });

  factory OmScanResult.failed(String message,
      {Map<String, dynamic>? debug}) =>
      OmScanResult._(
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
        debug: debug,
      );

  /// Retains the measured ink/alignment data when a teacher overrides a read.
  OmScanResult corrected({List<int>? answers,String? roll,String? registration}) {
    final next=answers??this.answers;
    if(next.length!=total || next.any((a)=>a < -2 || a > 3))throw ArgumentError('Invalid answer correction');
    return OmScanResult._(total:total,answers:List.unmodifiable(next),inks:inks,
      correctedIndices:{...correctedIndices,for(var i=0;i<next.length;i++)if(next[i]!=this.answers[i])i}.toList(),
      roll:roll??this.roll,registration:registration??this.registration,subjectCode:subjectCode,setCode:setCode,
      photoCorners:photoCorners,homography:homography,scale:scale,workWidth:workWidth,workHeight:workHeight,
      error:error,debug:debug,inkDiag:inkDiag,rectifiedJpeg:rectifiedJpeg);
  }

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

  /// How much darker the best option must be than the row's runner-up
  /// before it counts as a real mark. Guards against a uniformly elevated
  /// baseline (the bubble's own printed ring, lighting, a slightly
  /// oversized sample circle) letting pure noise cross fillThreshold on a
  /// genuinely blank row — the whole row rises together, but a real pen
  /// mark still stands out from its siblings by far more than this.
  static const double minOptionMargin = 0.15;

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
    } catch (e) {
      // Let the caller decide: if we run in a background isolate it
      // retries on the UI isolate (which already decoded these exact
      // bytes for the preview), otherwise it reports this detail.
      throw OmDecodeException('$e');
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

    // A rectified page is the scanner's crop of the sheet. With the whole
    // sheet framed, that crop is (close to) the full A4 page; a flatter
    // ratio means the "Crop and rotate" rectangle covered only part of
    // the sheet. Such a page must be rejected BEFORE alignment: its
    // missing bottom edge would anchor to the crop border and the read
    // would "succeed" with every bubble sampling the wrong place.
    if (rectified) {
      final ar = w / h; // = source aspect ratio (h is fixed at 2339)
      if (ar < 0.60 || ar > 0.82) {
        return OmScanResult.failed(
            'The scanner crop only covers part of the sheet. In the '
            'scanner, open "Crop and rotate" and extend the crop until '
            'ALL FOUR corners of the sheet are inside it, then scan '
            'again.');
      }
    }

    // Box-average the photo straight to the working grid. Both luma AND
    // the colour channels are kept: the channels let the ink mask below
    // reject the sheet's maroon drop-out template by hue (see `dropout`).
    final pixels = Uint8List(w * h);
    final dropout = Uint8List(w * h);
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
        var sumR = 0, sumG = 0, sumB = 0;
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
            sumR += srcBytes[o];
            sumG += srcBytes[o + 1];
            sumB += srcBytes[o + 2];
            n++;
          }
        }
        final p = orow + dx;
        if (n == 0) {
          pixels[p] = 0;
          continue;
        }
        pixels[p] = sum ~/ n;
        // Drop-out signature of the printed template
        // (PaperPdf.omrTemplateInk, maroon 0xFFB03060): strongly
        // red-dominant — r far above g AND above b. No black/blue pen ink
        // carries it (pen ink is neutral or blue-dominant). A pixel is
        // *student ink* only when it is dark and not drop-out. Keep the
        // two in sync; tune against real photographed samples, since
        // lighting shifts channel readings.
        final ar = sumR ~/ n, ag = sumG ~/ n, ab = sumB ~/ n;
        dropout[p] = ar > ag + 25 && ar > ab + 10 ? 1 : 0;
      }
    }

    final double otsuT = _otsu(pixels);
    // `ink` = student ink only (drop-out template excluded) — what the
    // bubble / identity / set sampling sees.
    final ink = Uint8List(w * h);
    // `struct` = luma ink INCLUDING the template — what the alignment
    // content probes use. Orientation must be decided from the printed
    // grid structure, which a drop-out sheet shows even when completely
    // blank (a student-ink-only mask would see nothing to orient on).
    final struct = Uint8List(w * h);
    final paper = Uint8List(w * h);
    // A stricter mask for the corner-mark search: the printed corner
    // squares are the darkest things on the sheet, so thresholding at
    // well below Otsu keeps them isolated even when a shadow darkens
    // the paper around them (which would otherwise merge mark + shadow
    // band into one giant component in the Otsu mask).
    final darkT = otsuT * 0.55;
    // Fallback tiers for faint marks: on bright scanner pages the light
    // ink of the *printed* corner squares can sit below 0.55·Otsu and go
    // undetected (a pen-drawn mark stays dark and is found at tier 0 —
    // leaving 1 mark + 3 frame-edge anchors, a fit that bends to the
    // pen stroke). Each looser tier is searched only inside the tight
    // corner strip (see nearCorner), where title text, grid bubbles and
    // digit boxes never intrude.
    final darkT1 = otsuT * 0.80;
    final darkT2 = otsuT * 0.95;
    final dark = Uint8List(w * h);
    final dark1 = Uint8List(w * h);
    final dark2 = Uint8List(w * h);
    for (var i = 0; i < w * h; i++) {
      final darkPx = pixels[i] < otsuT;
      ink[i] = darkPx && dropout[i] == 0 ? 1 : 0;
      // Paper = "not student ink": on a drop-out sheet the maroon template
      // behaves as paper, so the paper component stays the whole sheet.
      paper[i] = ink[i] == 0 ? 1 : 0;
      // Corner-mark masks stay luma-based on purpose: a mark must be found
      // regardless of its ink colour (printed maroon OR pen-drawn black).
      dark[i] = pixels[i] < darkT ? 1 : 0;
      dark1[i] = pixels[i] < darkT1 ? 1 : 0;
      dark2[i] = pixels[i] < darkT2 ? 1 : 0;
    }

    // ── 3. corner marks ────────────────────────────────────────────
    // Detect all four marks first so a missing corner can be *estimated*
    // from the other three (parallelogram rule) instead of hunting for
    // the brightest pixel in the corner band — with another sheet lying
    // next to or under the OMR sheet, that bright pixel often belongs to
    // the neighbour, which wrecks the homography fit.
    final marks = <DetectedCorner?>[
      for (var c = 0; c < 4; c++)
        _detectCornerMark(c, dark, w, h) ??
            _detectCornerMark(c, dark1, w, h,
                nearCorner: true, minFill: 0.80) ??
            _detectCornerMark(c, dark2, w, h,
                nearCorner: true, minFill: 0.80),
    ];
    final markCount = marks.where((m) => m != null).length;
    // Alignment diagnostics carried by every failure that follows (see
    // OmScanResult.debug) — the debug export writes them to the meta file
    // so a "corner mismatch" can be verified against the real photo.
    final dbg = <String, dynamic>{'markCount': markCount};
    double cx = w / 2, cy = h / 2;
    if (markCount > 0) {
      var sx = 0.0, sy = 0.0;
      for (final m in marks) {
        // A scanner-cropped page can clip a corner mark, so with 1–3
        // detections some entries are null — seed from the ones found.
        if (m == null) continue;
        sx += m.point.dx;
        sy += m.point.dy;
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
        // The mark centroid can sit on a filled bubble (student ink) —
        // nudge the seed onto the nearest paper pixel so the sheet
        // component is found (a null component let the corner fallback
        // search the whole frame and capture the bright background).
        final sp = _paperSeed(paper, w, h, seed.dx.round(), seed.dy.round());
        sharedComp = sp == null
            ? null
            : _paperComponent(paper, w, h, sp.$1, sp.$2);
        sharedCompReady = true;
      }
      return sharedComp;
    }

    // A raw photo must contain the WHOLE sheet: if the paper connected to
    // the seed reaches the photo's border, part of the sheet (its edge, or
    // the corner marks on it) lies outside the frame. The corner anchors
    // would then be taken from the photo edge instead of the sheet edge,
    // the homography distorts, and the read "succeeds" with the bubbles
    // sampling the wrong places — garbage with a green light. Fail with a
    // clear instruction instead. (Scanner pages are excluded: their paper
    // is cropped to the frame by design.)
    //
    // Exception: when ALL FOUR corner marks were found, the fit is anchored
    // entirely to the marks and the frame edge is never consulted — a
    // sheet that legitimately fills the frame (a gallery import of the
    // sheet itself, a screenshot, a tight photo) scans fine.
    if (!rectified) {
      final comp = paperComp();
      if (comp != null) {
        final edges = <String>[];
        for (var x = 0; x < w; x += 2) {
          if (comp[x] == 1) edges.add('top');
          if (comp[(h - 1) * w + x] == 1) edges.add('bottom');
        }
        for (var y = 0; y < h; y += 2) {
          if (comp[y * w] == 1) edges.add('left');
          if (comp[y * w + w - 1] == 1) edges.add('right');
        }
        if (edges.isNotEmpty && markCount < 4) {
          final where = edges.toSet().join(' / ');
          return OmScanResult.failed(
              'The sheet is cut off at the $where of the photo. Step back '
              'until the whole sheet — including all four corners — is '
              'inside the frame, then take the photo again.',
              debug: dbg);
        }
      }
    }

    final corners = <DetectedCorner>[];
    for (var c = 0; c < 4; c++) {
      final mark = marks[c];
      if (mark != null) {
        corners.add(mark);
        continue;
      }
      // Prefer the paper's own visible edge for a missing corner: it
      // reflects this photo's actual perspective. The parallelogram
      // estimate below assumes the sheet projects as a true parallelogram,
      // which a handheld photo is only approximately — perspective
      // keystones it into an uneven quadrilateral, so the estimate can
      // land measurably off from the true corner and feed a bad point
      // into the homography (→ "no valid scale"). The estimate is the
      // last resort, for when the paper edge genuinely can't be found.
      final fallback = _paperCornerFallback(c, paper, w, h, paperComp());
      // A paper point on the frame border is a background hit (bright
      // desk/wall merged with the sheet in the paper mask), not the sheet
      // corner — the sheet's true corner is inside the frame, so the
      // parallelogram of the real marks is the better anchor. The edge
      // point is kept only as a last resort.
      if (fallback != null && !fallback.edgeSuspect) {
        corners.add(fallback);
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
      if (fallback != null) {
        corners.add(fallback);
        continue;
      }
      return OmScanResult.failed(
          'Corner marks not found. Keep the whole OMR sheet in frame, in '
          'even light, and take the photo again.',
          debug: dbg);
    }

    const _cornerNames = ['TL', 'TR', 'BL', 'BR'];
    dbg['corners'] = [
      for (var k = 0; k < 4; k++)
        '${_cornerNames[k]}: ${corners[k].point.dx.toStringAsFixed(1)},'
        '${corners[k].point.dy.toStringAsFixed(1)} '
        'mark=${corners[k].fromMark} '
        'edgeSuspect=${corners[k].edgeSuspect} '
        'blobDiag=${corners[k].blobDiag.toStringAsFixed(1)}',
    ];

    // If the four "marks" do not outline a consistent A4 sheet, one of
    // them is a false positive (tape, a dark stain, …) — swap it for the
    // paper-corner fallback so the homography stage can still anchor well.
    final outlier = _outlierMarkIndex(corners, w, h);
    if (outlier >= 0) {
      final fb = _paperCornerFallback(outlier, paper, w, h, paperComp());
      if (fb != null) {
        corners[outlier] = fb;
        dbg['outlierSwap'] = outlier;
      }
    }

    // ── 4. homography (try all four sheet rotations) ───────────────
    // Candidate anchor sets: the built set (marks + paper-edge
    // fallbacks) first; when a corner came from a paper-edge fallback,
    // also the parallelogram of the real marks — in dim or wrinkled
    // light the paper edge can sit far from the true corner while the
    // parallelogram of three good marks is usually within a few
    // pixels. The precision gate below (mark reprojection) decides.
    final cornerSets = <List<DetectedCorner>>[corners];
    if (markCount >= 3) {
      final alt = List<DetectedCorner>.from(corners);
      var altChanged = false;
      for (var c = 0; c < 4; c++) {
        if (alt[c].fromMark) continue;
        final est = _parallelogramCorner(c, marks, w, h);
        if (est != null) {
          alt[c] = DetectedCorner(est, false);
          altChanged = true;
        }
      }
      if (altChanged) {
        // An edge-suspect anchor is known-bad: the all-marks set wins.
        if (corners.any((k) => k.edgeSuspect)) {
          cornerSets.insert(0, alt);
        } else {
          cornerSets.add(alt);
        }
      }
    }

    List<double>? candidate;
    List<DetectedCorner>? winCorners;
    var failReason =
        'Could not align the sheet (found $markCount of 4 corner marks). Keep it centered with a small margin, in even light, away from any other paper, and take the photo again.';
    for (var si = 0; si < cornerSets.length; si++) {
      final cs = cornerSets[si];
      // `struct` (luma ink incl. the template) — the content probes inside
      // decide orientation from the printed grid, which a drop-out sheet
      // shows even when completely blank.
      final solved = _bestRotationHomography(geo, cs, struct, pixels, w, h);
      final rot = solved.$2;
      final solvedH = solved.$1;
      final cand =
          (solvedH != null && solvedH.every((v) => v.isFinite)) ? solvedH : null;
      dbg['set${si}_probe'] = solved.$3;
      if (cand == null) {
        dbg['set${si}'] = 'no surviving candidate';
        continue;
      }
      // The winning fit may have assumed a sheet turned rot × 90° in the
      // frame: page corner k is paired with the photo point the list
      // currently assigns to corner (k + rot). Re-assign the corner list
      // by that shift so the scale/reprojection gates below — and the
      // mark-consistency gate after the loop — check exactly the
      // correspondence the fit was built from (a rotated fit reprojected
      // against the un-rotated list shows the whole sheet diagonal).
      var csEff = cs;
      if (rot != 0) {
        // CW corner order: 0=TL, 1=TR, 2=BR, 3=BL. `cs` is indexed
        // TL=0, TR=1, BL=2, BR=3, so CW index j ↔ cs index [0,1,3,2][j].
        const cwToCs = [0, 1, 3, 2];
        const csToCw = [0, 1, 3, 2]; // the same map is its own inverse
        csEff = <DetectedCorner>[
          for (var i = 0; i < 4; i++)
            cs[cwToCs[(csToCw[i] + rot) % 4]],
        ];
        dbg['set${si}_rot'] = rot;
      }
      final tl0 = applyHomography(cand, const ui.Offset(0, 0));
      final br0 = applyHomography(
          cand, const ui.Offset(OMrGeometry.pageW, OMrGeometry.pageH));
      final pageDiag0 = math.sqrt(
          OMrGeometry.pageW * OMrGeometry.pageW +
              OMrGeometry.pageH * OMrGeometry.pageH);
      final sc = math.sqrt((br0.dx - tl0.dx) * (br0.dx - tl0.dx) +
              (br0.dy - tl0.dy) * (br0.dy - tl0.dy)) /
          pageDiag0;
      if (!sc.isFinite || sc <= 0) {
        failReason =
            'Could not align the sheet (no valid scale, $markCount of 4 corner marks). Keep it flat and still, and take the photo again.';
        continue;
      }
      if (sc < 0.3 || sc > 3.0) {
        failReason =
            'Could not align the sheet (scale ${sc.toStringAsFixed(2)} — the whole sheet must fit in frame with a small margin).';
        continue;
      }
      if (OMrGeometry.bubbleRadiusPx * sc < 4) {
        failReason =
            'The sheet is too small in the photo. Move closer and take the photo again.';
        continue;
      }
      // Precision gate: every detected mark must reproject onto its own
      // detected position. A set with one bad paper-edge anchor shifts
      // the whole grid by tens of pixels while passing every shape
      // check above.
      dbg['set${si}_scale'] = sc.toStringAsFixed(4);
      final setRes = <String>[];
      var precise = true;
      for (var k = 0; k < 4; k++) {
        if (!csEff[k].fromMark) continue;
        final e = applyHomography(cand, OMrGeometry.markCenter(k));
        final dxx = e.dx - csEff[k].point.dx;
        final dyy = e.dy - csEff[k].point.dy;
        final res = math.sqrt(dxx * dxx + dyy * dyy);
        final tol = math.max(csEff[k].blobDiag * 3, sc * 15);
        setRes.add(
            '${_cornerNames[k]} ${res.isFinite ? res.toStringAsFixed(1) : 'NON-FINITE'} (tol ${tol.toStringAsFixed(1)})');
        if (!res.isFinite || res > tol) {
          precise = false;
          failReason =
              'Could not align the sheet precisely (corner mismatch). Keep it flat, fill the frame with a small margin, and take the photo again.';
          break;
        }
      }
      dbg['set${si}_markResiduals'] = setRes.join(' | ');
      if (!precise) continue;
      candidate = cand;
      winCorners = csEff;
      break;
    }
    // A page returned by the document scanner is already straight and
    // cropped to the sheet's edges, so its image corners are its page
    // corners — a second alignment that needs no registration marks at
    // all. A sheet without four printed corner marks can only be read
    // through this path.
    if (candidate == null && rectified) {
      candidate =
          _marksSimilarityHomography(geo, marks, struct, pixels, w, h);
    }
    if (candidate == null && rectified) {
      candidate =
          _pageBoundsHomography(geo, struct, pixels, paper, w, h, marks);
    }
    if (candidate == null) {
      return OmScanResult.failed(failReason, debug: dbg);
    }
    // Bound to a final: the read below captures [homography] in a
    // closure, and only a final local keeps its promoted (non-null) type
    // inside that closure.
    final homography = candidate;
    dbg['homography'] =
        homography.map((v) => v.toStringAsFixed(5)).join(', ');

    // Scale: page diagonal in the working image. Deliberately the actual
    // page corners (0,0) -> (pageW, pageH), not the fiducial mark centers:
    // _bestRotationHomography proves the winning candidate projects the
    // page corners to finite, sanely-proportioned locations (its anchors
    // are sometimes page corners, sometimes mark centers — but the
    // validation always checks the page corners). The mark centers sit
    // inset from the page corners and were never part of that guarantee,
    // so measuring scale there can diverge for a homography that is
    // otherwise perfectly good — a validated-vs-evaluated mismatch, not a
    // bad photo.
    final tl = applyHomography(homography, const ui.Offset(0, 0));
    final br = applyHomography(
        homography, const ui.Offset(OMrGeometry.pageW, OMrGeometry.pageH));
    final pageDiagonal = math.sqrt(
        OMrGeometry.pageW * OMrGeometry.pageW +
            OMrGeometry.pageH * OMrGeometry.pageH);
    final scale = math.sqrt(
            (br.dx - tl.dx) * (br.dx - tl.dx) +
            (br.dy - tl.dy) * (br.dy - tl.dy)) /
        pageDiagonal;
    dbg['scale'] = scale.toStringAsFixed(4);
    if (!scale.isFinite || scale <= 0) {
      return OmScanResult.failed(
          'Could not align the sheet (no valid scale, $markCount of 4 corner marks). Keep it flat and still, and take the photo again.',
          debug: dbg);
    }
    // A physical A4 sheet photographed for OMR sits well within this range;
    // anything else means the "alignment" is a distorted projective fit.
    if (scale < 0.3 || scale > 3.0) {
      return OmScanResult.failed(
          'Could not align the sheet (scale ${scale.toStringAsFixed(2)} — the whole sheet must fit in frame with a small margin).',
          debug: dbg);
    }
    final bubbleR = OMrGeometry.bubbleRadiusPx * scale;
    if (bubbleR < 4) {
      return OmScanResult.failed(
          'The sheet is too small in the photo. Move closer and take the photo again.',
          debug: dbg);
    }

    // Diagnostics (debug export): the same reprojection the verification
    // below performs, recorded so a failure can be checked against the
    // photo without the device. Kept separate so the block that follows
    // stays exactly as specified.
    // The winning set (possibly rotation-reassigned) is the one the
    // homography was fitted through — check those points, not the
    // original list.
    final guardCorners = winCorners ?? corners;
    final dbgFinal = <String>[];
    for (var k = 0; k < 4; k++) {
      if (!guardCorners[k].fromMark) continue;
      final expect = applyHomography(homography, OMrGeometry.markCenter(k));
      final dx = expect.dx - guardCorners[k].point.dx;
      final dy = expect.dy - guardCorners[k].point.dy;
      final residual = math.sqrt(dx * dx + dy * dy);
      final tolerance = math.max(guardCorners[k].blobDiag * 3, scale * 15);
      dbgFinal.add(
          '${_cornerNames[k]} ${residual.isFinite ? residual.toStringAsFixed(1) : 'NON-FINITE'} (tol ${tolerance.toStringAsFixed(1)})');
    }
    dbg['finalMarkResiduals'] = dbgFinal.join(' | ');

    // Reprojection check: a precise fit must map each real mark's known
    // geometric position back to very close to where that mark was
    // actually found in the photo. The page-corner scale check above only
    // proves the fit is roughly the right size and shape overall — a
    // homography can pass that while still being subtly wrong in a way
    // that misaligns the bubble grid. This is the check that actually
    // guarantees the grid-sampling precision the rest of the pipeline
    // depends on, and a genuinely good fit satisfies it trivially.
    for (var k = 0; k < 4; k++) {
      if (!guardCorners[k].fromMark) continue;
      final expect = applyHomography(homography, OMrGeometry.markCenter(k));
      final dx = expect.dx - guardCorners[k].point.dx;
      final dy = expect.dy - guardCorners[k].point.dy;
      final residual = math.sqrt(dx * dx + dy * dy);
      final tolerance = math.max(guardCorners[k].blobDiag * 3, scale * 15);
      if (!residual.isFinite || residual > tolerance) {
        return OmScanResult.failed(
            'Could not align the sheet precisely (corner mismatch). Keep it flat, fill the frame with a small margin, and take the photo again.',
            debug: dbg);
      }
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
      final order = [0, 1, 2, 3]..sort((a, b) => row[b].compareTo(row[a]));
      final best = row[order[0]], second = row[order[1]];
      if (second >= fillThreshold) {
        // Both the top two are solidly dark — a real double-mark, not
        // noise (noise never pushes two options past fillThreshold at
        // once on a blank row).
        answers[no - 1] = -2;
      } else if (best >= fillThreshold && best - second >= minOptionMargin) {
        // Clearly darker than its own row's runner-up: a real mark.
        answers[no - 1] = order[0];
      } else {
        // Nothing solid, or the top option didn't separate enough from
        // the rest of its row to trust. A single weak mark is still
        // reported as blank but stays visible in the ink table.
        answers[no - 1] = -1;
      }
    }

    // ── 6. identity panels + set code ──────────────────────────────
    // Ink diagnostics for the debug export: per-bubble ink the sampler
    // actually saw, so a "blank" can be judged — faint pen (low ink) vs.
    // misalignment (a neighbouring bubble holds the ink).
    final diagLines = <String>[];
    for (var no = 1; no <= total; no++) {
      final parts = <String>[];
      for (var o = 0; o < 4; o++) {
        final v = inks[no - 1][o];
        if (v >= 0.08) parts.add('${'কখগঘ'[o]}=${v.toStringAsFixed(2)}');
      }
      if (parts.isNotEmpty) {
        diagLines.add('q$no [${answers[no - 1]}]: ${parts.join(' ')}');
      }
    }

    final digitDiag = <String>[];
    String readDigits(int panel, int cols) {
      final sb = StringBuffer();
      final colDiag = <String>[];
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
        colDiag.add(
            '${bestDigit < 0 ? '-' : bestDigit}@${best.toStringAsFixed(2)}/${second.toStringAsFixed(2)}');
        if (best >= fillThreshold && best > second + 0.12) {
          sb.write('$bestDigit');
        } else if (best >= weakThreshold) {
          sb.write('?');
        } else {
          sb.write('0'); // unfilled leading columns read as zero
        }
      }
      digitDiag.add('panel$panel: ${colDiag.join(' ')}');
      return sb.toString();
    }

    final roll = readDigits(0, 6);
    final registration = readDigits(1, 10);
    final subjectCode = readDigits(2, 3);

    var setCode = -1;
    final setDiag = <String>[];
    {
      var best = -1;
      var bestR = 0.0, secondR = 0.0;
      for (var o = 0; o < 4; o++) {
        final p = applyHomography(homography, geo.setBubble(o));
        final r = _inkRatio(ink, w, h, p.dx, p.dy, sampleR);
        setDiag.add('${'কখগঘ'[o]}=${r.toStringAsFixed(2)}');
        if (r > bestR) {
          secondR = bestR;
          bestR = r;
          best = o;
        } else if (r > secondR) {
          secondR = r;
        }
      }
      if (bestR >= fillThreshold && bestR - secondR >= minOptionMargin) {
        setCode = best;
      }
    }
    diagLines.add('set [$setCode]: ${setDiag.join(' ')}');
    diagLines.addAll(digitDiag);

    // Auto-crop: for uploaded (non-rectified) photos, warp the photo to a
    // front-on view of just the sheet so the result looks like the
    // scanner's camera crop. Runs in-isolate; a failed warp simply keeps
    // the original-photo overlay.
    final rectifiedCrop =
        !rectified ? rectifiedJpeg(srcBytes, srcW, srcH, w, h, homography) : null;

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
      inkDiag: diagLines,
      debug: dbg,
      rectifiedJpeg: rectifiedCrop,
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
    int corner,
    Uint8List dark,
    int w,
    int h, {
    bool nearCorner = false,
    double minFill = 0.85,
  }) {
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
        if (fill < minFill) continue; // not solid (bubble circle ≈ 0.78, text ≪)
        if (ratio < 0.75 || ratio > 1.35) continue; // band/line, not square
        if (blobD < diag * 0.003 || blobD > diag * 0.08) continue;
        // Clipped by the search boundary → a region (desk/shadow/grid),
        // not the mark (the mark always sits well inside the sheet).
        if (minX == 0 || minY == 0 || maxX == rw - 1 || maxY == rh - 1) {
          continue;
        }
        if (nearCorner) {
          // Faint-mark fallback only. The mark is printed a fixed inset
          // from the sheet's edges (≈30 px page-px), and on a scanner
          // page / a well-framed photo the sheet edges coincide with the
          // frame edges — so the mark must sit in the inner corner strip
          // of the frame. Everything else dark enough for a looser tier
          // (title text, numbers, bubbles, filled digit boxes) lies
          // further out and is excluded by this band.
          final portrait = h >= w;
          final bandEdge = (portrait ? h : w) * 0.05;
          final bandSide = (portrait ? w : h) * 0.18;
          final mx = x0 + insetX + sumX / area;
          final my = y0 + insetY + sumY / area;
          final bool inBand;
          if (portrait) {
            switch (corner) {
              case 0:
                inBand = mx < bandSide && my < bandEdge;
                break;
              case 1:
                inBand = mx > w - bandSide && my < bandEdge;
                break;
              case 2:
                inBand = mx < bandSide && my > h - bandEdge;
                break;
              default:
                inBand = mx > w - bandSide && my > h - bandEdge;
                break;
            }
          } else {
            switch (corner) {
              case 0:
                inBand = mx < bandEdge && my < bandSide;
                break;
              case 1:
                inBand = mx > w - bandEdge && my < bandSide;
                break;
              case 2:
                inBand = mx < bandEdge && my > h - bandSide;
                break;
              default:
                inBand = mx > w - bandEdge && my > h - bandSide;
                break;
            }
          }
          if (!inBand) continue;
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

  /// [seed] nudged onto the nearest paper pixel.
  ///
  /// The mark centroid (the default seed) can land on a filled bubble or a
  /// dark printed stroke — pixels that are ink, not paper — which would
  /// leave the paper component null and let the corner fallback search the
  /// whole frame (capturing the bright background at the photo corner).
  /// Search outward on expanding rings until a paper pixel is reached.
  static (int, int)? _paperSeed(
      Uint8List paper, int w, int h, int sx, int sy) {
    if (sx >= 0 && sy >= 0 && sx < w && sy < h && paper[sy * w + sx] == 1) {
      return (sx, sy);
    }
    if (sx < 0 || sy < 0 || sx >= w || sy >= h) return null;
    final maxR = (math.sqrt(w * w + h * h) * 0.15).round();
    for (var r = 2; r <= maxR; r += 4) {
      for (var a = 0; a < 360; a += 8) {
        final x = (sx + (r * math.cos(a * math.pi / 180)).round()).clamp(0, w - 1);
        final y = (sy + (r * math.sin(a * math.pi / 180)).round()).clamp(0, h - 1);
        if (paper[y * w + x] == 1) return (x, y);
      }
    }
    return null;
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
  /// The homography for the best (anchor mask, rotation) pair, plus the
  /// winning rotation: `rot` is the quarter-turn applied to the photo-side
  /// corner correspondence (0 = upright in frame, 1 = sheet turned 90°
  /// clockwise, …). The caller must re-assign its corner list by the same
  /// shift so every downstream gate checks the correspondence the fit
  /// actually used.
  /// Third field: a compact per-candidate score log (`m<mask> r<rot>
  /// err=…` for every candidate that passed the shape gates) — recorded on
  /// the result's debug map so a wrong-orientation read can be analyzed
  /// without the device.
  static (List<double>?, int, String) _bestRotationHomography(
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
    var bestRot = 0;
    final probeLog = <String>[];

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
        // Mark-reprojection gate: a mask that anchors a mark at the
        // page corner (or a wrong rotation) is a perfectly exact
        // projective fit through the detected points — yet it shifts
        // the whole bubble grid by the mark inset (~150 page px) and
        // can win the probe-score race below. Such a candidate must
        // never be allowed to compete: every detected mark must
        // reproject onto its own detected position. A mark-true fit has
        // ~0 residual here.
        var maxRes = 0.0;
        var markResFinite = true;
        for (var k = 0; k < 4; k++) {
          if (!hasMark[k]) continue;
          final mp = applyHomography(hHom, markAnchor[k]);
          // Against THIS candidate's photo point (qq, i.e. rotated by
          // [rot]) — a mark-true rotated fit sits ~0 px from it, while a
          // page-corner anchor or the wrong rotation is inset-shifted.
          // Comparing against the un-rotated photoPoint rejected every
          // rotated candidate (residual ≈ sheet corner distance) and made
          // rotated sheets unreadable.
          final dxx = mp.dx - qq[k].dx;
          final dyy = mp.dy - qq[k].dy;
          final res = math.sqrt(dxx * dxx + dyy * dyy);
          if (!res.isFinite) {
            // This transform's line at infinity passes through a detected
            // mark, so the grid's projection is undefined there. NaN would
            // slip past `res > maxRes` (and the `maxRes > 0` guard), so
            // reject such a candidate explicitly — it is unusable.
            markResFinite = false;
            break;
          }
          if (res > maxRes) maxRes = res;
        }
        if (!markResFinite) continue;
        if (maxRes > 0) {
          final scaleEst = len(pts[0], pts[2]) /
              math.sqrt(OMrGeometry.pageW * OMrGeometry.pageW +
                  OMrGeometry.pageH * OMrGeometry.pageH);
          if (maxRes > math.max(30.0, 0.012 * scaleEst * 2863)) continue;
        }
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

        probeLog.add('m$mask r$rot ${err.toStringAsFixed(2)}');
        if (err < bestErr) {
          bestErr = err;
          bestH = hHom;
          bestRot = rot;
        }
      }
    }
    return (bestH, bestRot, probeLog.join(' '));
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
  /// A rectified page is a straight, uniform-scale crop of the sheet, so
  /// two or more detected corner marks pin the alignment exactly through
  /// a similarity transform (rotation + uniform scale + translation).
  ///
  /// This is tried before _pageBoundsHomography, whose anchors are the
  /// Otsu paper component's extreme points. In a dim, low-contrast scan
  /// that mask bleeds into the surrounding background, so the "corners"
  /// can sit well outside the sheet's true corners — the page then
  /// stretches over an inflated rectangle and every sampled bubble
  /// lands a fraction of a bubble off its true circle. On an empty
  /// sheet that reads 1-2 false marks and garbles the metadata boxes;
  /// two real marks are far harder to fool than a luma threshold.
  static List<double>? _marksSimilarityHomography(
      OMrGeometry geo,
      List<DetectedCorner?> marks,
      Uint8List? ink,
      Uint8List? luma,
      int w,
      int h) {
    // Longest detected pair = most accurate anchor (diagonal > side).
    var bi = -1, bj = -1, bestDist = 0.0;
    for (var i = 0; i < 4; i++) {
      if (marks[i] == null) continue;
      for (var j = i + 1; j < 4; j++) {
        if (marks[j] == null) continue;
        final pi = OMrGeometry.markCenter(i);
        final pj = OMrGeometry.markCenter(j);
        final d = math.sqrt((pi.dx - pj.dx) * (pi.dx - pj.dx) +
            (pi.dy - pj.dy) * (pi.dy - pj.dy));
        if (d > bestDist) {
          bestDist = d;
          bi = i;
          bj = j;
        }
      }
    }
    if (bi < 0) return null;

    final pi = OMrGeometry.markCenter(bi);
    final pj = OMrGeometry.markCenter(bj);
    final qi = marks[bi]!.point;
    final qj = marks[bj]!.point;
    // Fit photo = s·R(θ)·page + t from the two correspondences.
    final ccx = pj.dx - pi.dx, ccy = pj.dy - pi.dy; // page vector
    final ddx = qj.dx - qi.dx, ddy = qj.dy - qi.dy; // photo vector
    final clen = math.sqrt(ccx * ccx + ccy * ccy);
    final dlen = math.sqrt(ddx * ddx + ddy * ddy);
    if (clen < 1e-6 || dlen < 1e-6) return null;
    final s = dlen / clen;
    final cosT = (ddx * ccx + ddy * ccy) / (dlen * clen);
    final sinT = (ccx * ddy - ccy * ddx) / (dlen * clen);
    final tx = qi.dx - s * (cosT * pi.dx - sinT * pi.dy);
    final ty = qi.dy - s * (sinT * pi.dx + cosT * pi.dy);
    final hom = <double>[
      s * cosT, -s * sinT, tx,
      s * sinT, s * cosT, ty,
      0, 0, 1,
    ];

    // Any other detected mark that is not on the fitted sheet is a
    // false positive (a dark stain near a corner): reject the fit.
    final tol = math.max(6.0, s * 10.0);
    for (var k = 0; k < 4; k++) {
      final mk = marks[k];
      if (mk == null || k == bi || k == bj) continue;
      final p = applyHomography(hom, OMrGeometry.markCenter(k));
      if (math.sqrt((p.dx - mk.point.dx) * (p.dx - mk.point.dx) +
              (p.dy - mk.point.dy) * (p.dy - mk.point.dy)) >
          tol) {
        return null;
      }
    }

    // The crop must show the sheet's top edge; the bottom edge may sit
    // below the frame (a crop that trims the sheet's bottom corners is
    // legal — the marks carry the alignment).
    final tL = applyHomography(hom, const ui.Offset(0, 0));
    final tR = applyHomography(hom, const ui.Offset(OMrGeometry.pageW, 0));
    final bL =
        applyHomography(hom, const ui.Offset(0, OMrGeometry.pageH));
    final bR =
        applyHomography(hom, const ui.Offset(OMrGeometry.pageW, OMrGeometry.pageH));
    for (final p in [tL, tR]) {
      if (p.dy < -0.20 * h || p.dy > 0.35 * h) return null;
      if (p.dx < -0.30 * w || p.dx > 1.30 * w) return null;
    }
    for (final p in [bL, bR]) {
      if (p.dy < 0.50 * h || p.dy > 1.45 * h) return null;
      if (p.dx < -0.30 * w || p.dx > 1.30 * w) return null;
    }

    // The fitted sheet must carry printed content near the top of the
    // question grid (header text / row numbers) — a dark stain pair that
    // happens to sit at the right distance does not.
    if (luma != null && ink != null) {
      final probeY = OMrGeometry.questionsTop + 120;
      var varT = 0.0, inkT = 0.0;
      for (final qx in const [400.0, OMrGeometry.pageW / 2, 1254.0]) {
        final pp = applyHomography(hom, ui.Offset(qx, probeY));
        if (luma != null) {
          final v = _diskVariance(luma, w, h, pp.dx, pp.dy, 24);
          if (v > varT) varT = v;
        }
        final v = _inkRatio(ink, w, h, pp.dx, pp.dy, 24);
        if (v > inkT) inkT = v;
      }
      if (varT < 60 && inkT < 0.10) return null;
    }
    return hom;
  }

  /// A detected mark must sit inside the candidate sheet rectangle:
  /// the marks are printed inset from the sheet corners, so a mark
  /// falling outside (by more than a few percent) means the rectangle
  /// latched onto the wrong edges.
  static bool _marksInsideRect(List<DetectedCorner?> marks, List<double> e) {
    for (final m in marks) {
      if (m == null) continue;
      final p = m.point;
      final wTol = (e[2] - e[0]) * 0.04;
      final hTol = (e[3] - e[1]) * 0.04;
      if (p.dx < e[0] - wTol || p.dx > e[2] + wTol ||
          p.dy < e[1] - hTol || p.dy > e[3] + hTol) {
        return false;
      }
    }
    return true;
  }

  /// Sheet edges in a rectified page, from luma-projection profiles.
  /// Returns [xLeft, yTop, xRight, yBottom] in photo coordinates, or
  /// null when the image does not contain a sheet-like rectangle.
  static List<double>? _sheetEdgesByProjection(Uint8List luma, int w, int h) {
    final col = _avgProfile(luma, w, h, true);
    final row = _avgProfile(luma, w, h, false);
    var colLo = 255.0, colHi = 0.0, rowLo = 255.0, rowHi = 0.0;
    for (var i = 0; i < w; i++) {
      if (col[i] < colLo) colLo = col[i];
      if (col[i] > colHi) colHi = col[i];
    }
    for (var i = 0; i < h; i++) {
      if (row[i] < rowLo) rowLo = row[i];
      if (row[i] > rowHi) rowHi = row[i];
    }
    final minStep = math.max(10.0, (colHi - colLo + rowHi - rowLo) * 0.08);
    // Small step window: the profile averages over the whole edge, so
    // it is clean even with a short window, and a short window keeps
    // the detected plateau narrow (see _strongestStep).
    var d = (math.min(w, h) * 0.005).round();
    if (d < 3) d = 3;
    if (d > 12) d = 12;

    // Each edge = strongest step in its outer band; "not found" means
    // the sheet touches that side of the frame (a tight crop, or the
    // crop cuts the sheet there) and the side snaps to the frame edge.
    // flags bit 1/2/4/8 = left/top/right/bottom edge detected.
    var flags = 0;
    final lDet = _strongestStep(col, w, d, minStep, 0.005, 0.40, true);
    final rDet = _strongestStep(col, w, d, minStep, 0.60, 0.995, false);
    final tDet = _strongestStep(row, h, d, minStep, 0.005, 0.40, true);
    final bDet = _strongestStep(row, h, d, minStep, 0.60, 0.995, false);
    final x0 = lDet ?? 0.0;
    if (lDet != null) flags |= 1;
    final y0 = tDet ?? 0.0;
    if (tDet != null) flags |= 2;
    final x1 = rDet ?? (w - 1.0);
    if (rDet != null) flags |= 4;
    final y1 = bDet ?? (h - 1.0);
    if (bDet != null) flags |= 8;

    final rw = x1 - x0, rh = y1 - y0;
    if (rw < w * 0.55 || rh < h * 0.55) return null;
    final ar = rw / rh;
    if (ar < 0.55 || ar > 0.95) return null;
    return [x0, y0, x1, y1, flags.toDouble()];
  }

  /// Strongest upward (or downward) step of a smoothed profile inside
  /// [lo, hi] (fractions of the length), or null when no step reaches
  /// [minStep].
  static double? _strongestStep(Float64List p, int n, int d, double minStep,
      double lo, double hi, bool wantUp) {
    var loI = (n * lo).round();
    var hiI = (n * hi).round();
    if (loI < d) loI = d;
    if (loI > n - d) loI = n - d;
    if (hiI < d) hiI = d;
    if (hiI > n - 1 - d) hiI = n - 1 - d;
    var best = 0.0, bx = -1;
    for (var i = loI; i <= hiI; i++) {
      final step = (p[i + d] - p[i - d]) * (wantUp ? 1.0 : -1.0);
      if (step > best) {
        best = step;
        bx = i;
      }
    }
    if (bx < 0 || best < minStep) return null;
    // The step forms a plateau ~2d wide around the true edge; the
    // argmax wanders inside it, so refine to the plateau midpoint.
    var pLo = bx, pHi = bx;
    while (pLo > loI) {
      final st = (p[pLo - 1 + d] - p[pLo - 1 - d]) * (wantUp ? 1.0 : -1.0);
      if (st >= best * 0.6) {
        pLo--;
      } else {
        break;
      }
    }
    while (pHi < hiI) {
      final st = (p[pHi + 1 + d] - p[pHi + 1 - d]) * (wantUp ? 1.0 : -1.0);
      if (st >= best * 0.6) {
        pHi++;
      } else {
        break;
      }
    }
    return (pLo + pHi) / 2;
  }

  /// Column- or row-average luma profile, 5-point box-smoothed.
  static Float64List _avgProfile(Uint8List luma, int w, int h, bool columns) {
    final n = columns ? w : h;
    final m = columns ? h : w;
    final p = Float64List(n);
    for (var i = 0; i < n; i++) {
      var sum = 0;
      if (columns) {
        for (var j = 0; j < m; j++) sum += luma[j * w + i];
      } else {
        final r = i * w;
        for (var j = 0; j < m; j++) sum += luma[r + j];
      }
      p[i] = sum / m;
    }
    final q = Float64List(n);
    for (var i = 0; i < n; i++) {
      var sm = 0.0, c = 0;
      for (var k = -2; k <= 2; k++) {
        final j = i + k;
        if (j >= 0 && j < n) {
          sm += p[j];
          c++;
        }
      }
      q[i] = sm / c;
    }
    return q;
  }

  /// Scale + page-zero origin along one axis, from a detected sheet
  /// edge at photo position [edgePhoto] (page position [edgePage]) and
  /// the best available corner mark on the opposite side of the sheet —
  /// the longest mark-to-edge lever arm wins. Returns [scale, origin]
  /// or null when no mark is available or every mark sits too close to
  /// this edge to measure a scale from.
  static List<double>? _edgeMarkAxis(
      List<DetectedCorner?> marks,
      List<int> ks,
      double edgePhoto,
      double edgePage,
      bool horizontal) {
    double? bestS;
    var bestO = 0.0;
    var bestLever = 0.0;
    for (final k in ks) {
      final mk = marks[k];
      if (mk == null) continue;
      final pc = OMrGeometry.markCenter(k);
      final mPhoto = horizontal ? mk.point.dx : mk.point.dy;
      final mPage = horizontal ? pc.dx : pc.dy;
      // Opposite-side marks give a 1500+ px lever arm; adjacent-side
      // marks (125/80 px) turn a few px of detection noise into a
      // multi-percent scale error — unusable.
      final lever = (edgePage - mPage).abs();
      if (lever < 1000) continue;
      final sC = (edgePhoto - mPhoto) / (edgePage - mPage);
      if (sC <= 0 || !sC.isFinite) continue;
      if (lever > bestLever) {
        bestLever = lever;
        bestS = sC;
        bestO = edgePhoto - sC * edgePage;
      }
    }
    return bestS == null ? null : <double>[bestS, bestO];
  }

  static List<double>? _pageBoundsHomography(
      OMrGeometry geo,
      Uint8List? ink,
      Uint8List? luma,
      Uint8List paper,
      int w,
      int h,
      List<DetectedCorner?> marks) {
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
    // Prefer the projection edges: the sheet's border is the strongest
    // AVERAGE contrast step across the whole edge, so it survives dim,
    // low-contrast scans in which the Otsu paper mask (below) bleeds
    // into the background and its extreme points sit well outside the
    // sheet's true corners — shifting every sampled bubble by a
    // fraction of a bubble.
    if (luma != null) {
      final e = _sheetEdgesByProjection(luma, w, h);
      if (e != null && _marksInsideRect(marks, e)) {
        final x0 = e[0], y0 = e[1], x1 = e[2], y1 = e[3];
        final flagsI = e[4].round();
        final leftDet = (flagsI & 1) != 0;
        final topDet = (flagsI & 2) != 0;
        final rightDet = (flagsI & 4) != 0;
        final botDet = (flagsI & 8) != 0;

        // Scale + origin per axis. A detected edge on one side plus a
        // detected mark on the opposite side measures the scale on a
        // long lever arm (~1500+ page px) that dim light cannot spoil;
        // two detected edges measure it on the full sheet side; an
        // undetected side is assumed to sit at the frame edge (the
        // scanner crop follows the sheet) — the mark cross-check below
        // rejects the assumption when it is wrong.
        double? sH;
        var x0c = x0;
        var sHExact = false;
        if (leftDet && rightDet) {
          sH = (x1 - x0) / OMrGeometry.pageW;
          sHExact = true;
        } else if (rightDet) {
          final r = _edgeMarkAxis(marks, const [0, 1], x1,
              OMrGeometry.pageW, true);
          if (r != null) {
            sH = r[0];
            x0c = r[1];
            sHExact = true;
          }
        }
        if (sH == null) {
          // Left edge only (or none): the frame's right side is the
          // assumed sheet edge.
          sH = (w - 1.0 - x0) / OMrGeometry.pageW;
        }
        double? sV;
        var y0c = y0;
        var sVExact = false;
        if (topDet && botDet) {
          sV = (y1 - y0) / OMrGeometry.pageH;
          sVExact = true;
        } else if (botDet) {
          final r = _edgeMarkAxis(marks, const [0, 2], y1,
              OMrGeometry.pageH, false);
          if (r != null) {
            sV = r[0];
            y0c = r[1];
            sVExact = true;
          }
        }
        // Combine: a rectified scan is uniform-scale, so one axis
        // carries the other. A crop that trims the sheet's bottom
        // shortens the visible height — a height ratio would understate
        // the scale, so the width carries the vertical axis whenever
        // the bottom is not detected. An exactly-measured ruler beats
        // a frame assumption; two exact rulers must agree.
        // sVExact/sHExact are set only where the corresponding value
        // is assigned, so the bangs below are safe.
        double? s;
        if (sVExact) {
          if (sHExact) {
            if ((sV! - sH!).abs() / ((sV! + sH!) / 2) > 0.08) {
              s = null; // inconsistent: a wrong edge — fall through
            } else {
              s = (sV! + sH!) / 2;
            }
          } else {
            s = sV;
          }
        } else {
          s = sH;
          y0c = y0; // vertical origin = detected top edge (or frame)
        }
        if (s == null || s <= 0 || !s.isFinite) {
          // fall through to the paper-mask path below
        } else {
          // With no marks at all there is no fiducial to bound a
          // horizontal frame assumption (an undetected vertical edge
          // means the origin is unknown by an unknowable amount):
          // the full sheet width must be detected, or refuse.
          final noMarks = marks.every((m) => m == null);
          if (!(noMarks && !sHExact)) {
            // With an exact scale and no detected left edge, a
            // left-side mark pins the horizontal origin exactly.
            if (!leftDet && (sVExact || sHExact)) {
            for (final k in const [0, 2]) {
              final mk = marks[k];
              if (mk == null) continue;
              final pc = OMrGeometry.markCenter(k);
              final cand = mk.point.dx - s * pc.dx;
              if (cand >= -0.05 * w &&
                  cand + OMrGeometry.pageW * s <= w * 1.05) {
                x0c = cand;
              }
              break;
            }
          }
          var ok = true;
          // Every detected mark must re-project onto its printed
          // position — this is what rejects a wrong frame assumption
          // and an edge that latched onto the wrong line.
          final markTol = math.max(18.0, s * 20.0);
          for (var k = 0; k < 4; k++) {
            final mk = marks[k];
            if (mk == null) continue;
            final pc = OMrGeometry.markCenter(k);
            final px = x0c + s * pc.dx;
            final py = y0c + s * pc.dy;
            if ((px - mk.point.dx).abs() > markTol ||
                (py - mk.point.dy).abs() > markTol) {
              ok = false;
              break;
            }
          }
          // Detected edges must agree with the fitted sheet boundary.
          if (ok) {
            final etolX = 0.02 * OMrGeometry.pageW * s;
            final etolY = 0.02 * OMrGeometry.pageH * s;
            if (leftDet && (x0c - x0).abs() > etolX) ok = false;
            if (rightDet &&
                (x0c + OMrGeometry.pageW * s - x1).abs() > etolX) {
              ok = false;
            }
            if (topDet && (y0c - y0).abs() > etolY) ok = false;
            if (botDet && (y0c + OMrGeometry.pageH * s - y1).abs() > etolY) {
              ok = false;
            }
          }
          // The fitted sheet must sit inside the photo.
          if (ok && (x0c < -0.05 * w || x0c > 0.15 * w ||
              y0c < -0.05 * h || y0c > 0.15 * h)) {
            ok = false;
          }
          // The fitted sheet must carry printed content at the top of
          // the question grid — a background "sheet" does not.
          if (ok && ink != null) {
            final probeY = OMrGeometry.questionsTop + 120;
            var varT = 0.0, inkT = 0.0;
            for (final qx in const [400.0, OMrGeometry.pageW / 2, 1254.0]) {
              final px = x0c + s * qx;
              final py = y0c + s * probeY;
              final v = _diskVariance(luma, w, h, px, py, 24);
              if (v > varT) varT = v;
              final u = _inkRatio(ink, w, h, px, py, 24);
              if (u > inkT) inkT = u;
            }
            if (varT < 60 && inkT < 0.10) ok = false;
          }
          if (ok) {
            // A rectified page is straight and axis-aligned: an
            // axis-aligned similarity homography (uniform scale s).
            return <double>[s, 0, x0c, 0, s, y0c, 0, 0, 1];
          }
            }
        }
      }
    }
    // Loose-crop fallback: the paper component's extreme corners.
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

  /// Warps the full-resolution photo through the page→work homography so
  /// the output is a front-on, auto-cropped view of just the sheet — the
  /// same look the document scanner's camera crop gives for taken photos.
  ///
  /// The output is A4-proportioned (pageW×pageH, long side [maxSide]) so
  /// the verdict overlay can place markers in plain page coordinates.
  /// Returns null on any failure — the caller keeps the original photo.
  static Uint8List? rectifiedJpeg(
    Uint8List src,
    int srcW,
    int srcH,
    int workW,
    int workH,
    List<double> h, {
    double maxSide = 1500,
  }) {
    try {
      final s = maxSide / OMrGeometry.pageH;
      final outW = (OMrGeometry.pageW * s).round();
      final outH = (OMrGeometry.pageH * s).round();
      final inv = 1 / s; // out px → page px
      final kx = srcW / workW.toDouble(); // work px → photo px
      final ky = srcH / workH.toDouble();
      final h0 = h[0], h1 = h[1], h2 = h[2];
      final h3 = h[3], h4 = h[4], h5 = h[5];
      final h6 = h[6], h7 = h[7];
      final buf = Uint8List(outW * outH * 4);
      final lastX = srcW - 1, lastY = srcH - 1;
      for (var oy = 0; oy < outH; oy++) {
        final py = (oy + .5) * inv;
        final a1 = h1 * py;
        final b1 = h4 * py;
        final c1 = h7 * py;
        final rowO = oy * outW * 4;
        for (var ox = 0; ox < outW; ox++) {
          final px = (ox + .5) * inv;
          final wH = h6 * px + c1 + 1;
          if (wH == 0) continue;
          var sx = (h0 * px + a1 + h2) / wH * kx;
          var sy = (h3 * px + b1 + h5) / wH * ky;
          if (sx < 0) {
            sx = 0;
          } else if (sx > lastX) {
            sx = lastX.toDouble();
          }
          if (sy < 0) {
            sy = 0;
          } else if (sy > lastY) {
            sy = lastY.toDouble();
          }
          final x0 = sx.floor(), y0 = sy.floor();
          final x1 = x0 >= lastX ? lastX : x0 + 1;
          final y1 = y0 >= lastY ? lastY : y0 + 1;
          final fx = sx - x0, fy = sy - y0;
          final i00 = (y0 * srcW + x0) * 4;
          final i10 = (y0 * srcW + x1) * 4;
          final i01 = (y1 * srcW + x0) * 4;
          final i11 = (y1 * srcW + x1) * 4;
          final o = rowO + ox * 4;
          final top0 = src[i00] * (1 - fx) + src[i10] * fx;
          final top1 = src[i00 + 1] * (1 - fx) + src[i10 + 1] * fx;
          final top2 = src[i00 + 2] * (1 - fx) + src[i10 + 2] * fx;
          final bot0 = src[i01] * (1 - fx) + src[i11] * fx;
          final bot1 = src[i01 + 1] * (1 - fx) + src[i11 + 1] * fx;
          final bot2 = src[i01 + 2] * (1 - fx) + src[i11 + 2] * fx;
          buf[o] = (top0 * (1 - fy) + bot0 * fy).round();
          buf[o + 1] = (top1 * (1 - fy) + bot1 * fy).round();
          buf[o + 2] = (top2 * (1 - fy) + bot2 * fy).round();
          buf[o + 3] = 255;
        }
      }
      // `buf` is a fresh standalone allocation, so its backing ByteBuffer
      // covers exactly the pixel data (offset 0, full length).
      final im = img.Image.fromBytes(
        width: outW,
        height: outH,
        bytes: buf.buffer,
        numChannels: 4,
        order: img.ChannelOrder.rgba,
      );
      return img.encodeJpg(im, quality: 85);
    } catch (_) {
      return null;
    }
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
