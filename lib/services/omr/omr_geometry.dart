import 'dart:math' as math;
import 'dart:ui' show Offset;

/// Deterministic geometry of the Tutor's Desk OMR sheet.
///
/// This is the single source of truth for *where every bubble and corner
/// mark sits on the A4 page*:
///
///  • `PaperPdf.renderOmrSheetPages` draws the sheet from these numbers, and
///  • `OMrScanner` samples a photographed sheet at these same numbers.
///
/// Nothing on the sheet is positioned by measured text flow — the header is
/// a fixed band and every bubble centre is a pure function of the question
/// count — so a printed sheet and its photo always line up, no matter what
/// title the tutor typed.
///
/// All coordinates are in *page pixels* of the 200 dpi A4 canvas used by the
/// rest of the print engine (1654 × 2339, margin 40 pt).
class OMrGeometry {
  OMrGeometry(this.total)
      : assert(total >= 1 && total <= 100, 'OMR supports 1–100 questions') {
    _columns = ((total + maxPerColumn - 1) ~/ maxPerColumn).clamp(1, 4).toInt();
    perColumn =
        ((total + _columns - 1) ~/ _columns).clamp(1, maxPerColumn).toInt();
    questionGap = 8.0 * k;
    final rawW = (contentW - (_columns - 1) * questionGap) / _columns;
    questionWidth = rawW > naturalRowW ? naturalRowW : rawW;
    bubbleSpan = questionWidth - bubbleAreaX - (bubbleR + 4) * k;
    bubbleStep = (bubbleSpan / 3) > maxBubbleStep * k
        ? maxBubbleStep * k
        : bubbleSpan / 3;
    identityTop = questionsBottom + 10 * k;
    setTop = identityBottom + 10 * k;
  }

  // ── Page constants (must match PaperPdf's raster canvas) ───────────
  static const double k = 200 / 72; // pt → px
  static const double pageW = 1654;
  static const double pageH = 2339;
  static const double margin = 40 * k;
  static final double contentW = pageW - 2 * margin;

  // ── Header band (fixed — title shrinks to fit, never wraps) ────────
  static const double titleTop = margin; // title text top
  static const double subtitleTop = margin + 19 * k;
  static const double ruleY = margin + 31 * k;
  static const double questionsTop = margin + 38 * k;

  // ── Corner alignment marks (filled squares, 13 pt) ─────────────────
  static const double markSize = 13 * k;
  static final double _markTLx = margin;

  /// Distance from the page edge to a corner mark's OUTER edge. All four
  /// marks sit this far in from the page border, so growing the mark
  /// (10 → 13 pt) enlarges the scanner's target without moving where the
  /// mark sits on the sheet's silhouette.
  static const double _markInset = 24 * k;

  /// Top-left corner of mark [i]: 0 = TL, 1 = TR, 2 = BL, 3 = BR.
  ///
  /// (case 3 used to be missing — BR fell through to the TL position, so
  /// the scanner looked for the bottom-right mark in the top-left corner
  /// and the print drew a second square at TL instead of one at BR.)
  static List<double> markTopLeft(int i) {
    switch (i) {
      case 1:
        return [pageW - margin - markSize, _markInset];
      case 2:
        return [margin, pageH - _markInset - markSize];
      case 3:
        return [pageW - margin - markSize, pageH - _markInset - markSize];
      default:
        return [_markTLx, _markInset];
    }
  }

  /// Centre of corner mark [i] (the scanner's registration points).
  static Offset markCenter(int i) {
    final t = markTopLeft(i);
    return Offset(t[0] + markSize / 2, t[1] + markSize / 2);
  }

  // ── Question grid ──────────────────────────────────────────────────
  final int total;
  late final int _columns;
  final int maxPerColumn = 25;
  late final int perColumn;
  late final double questionGap;
  late final double questionWidth;
  late final double bubbleSpan;
  late final double bubbleStep;

  // Bubbles are deliberately generous (6 pt radius, 17 pt rows): a sample
  // point a few pixels off still lands well inside the bubble instead of
  // grazing its rim, and the ~14 px gap between bubble edges keeps a
  // student's pen fill from bleeding into the row above/below.
  static const double bubbleR = 6.0; // bubble radius, pt
  static const double rowH = 17.0 * k;
  static const double numberW = 26 * k;
  static const double maxBubbleStep = 25.0;
  static final double naturalRowW = 26 * k +
      bubbleR * k +
      2 * k +
      6 * k +
      maxBubbleStep * 3 * k +
      (bubbleR + 6) * k;
  static final double bubbleAreaX = numberW + bubbleR * k + 2 * k;
  static final double bubbleLeft = bubbleAreaX + 6 * k;
  static final double boxHeaderH = 13 * k;

  int get questionColumns => _columns;

  /// X origin of question column [column] (0-based, left → right).
  double columnX(int column) => margin + column * (questionWidth + questionGap);

  /// Centre of the bubble for question number [no] (1-based) and option
  /// [option] (0 = ক, 1 = খ, 2 = গ, 3 = ঘ).
  Offset questionBubble(int no, int option) {
    final i = no - 1;
    final column = (i / perColumn).floor();
    final row = i % perColumn;
    return Offset(
      columnX(column) + bubbleLeft + option * bubbleStep,
      questionsTop + boxHeaderH + row * rowH + rowH / 2,
    );
  }

  /// Y coordinate of the bottom edge of the tallest question box.
  double get questionsBottom =>
      questionsTop + boxHeaderH + perColumn * rowH + 4 * k;

  // ── Identity panels (roll / registration / subject code) ───────────
  // Digit rows must out-grow the (now 6 pt) bubbles — at 10.8 pt rows the
  // 13.3 px bubble diameter exceeded the 10 pt pitch and the digit
  // circles in roll/registration/subject overlapped. 15 pt rows leave an
  // 8.3 px (≈1.1 mm) edge gap, matching the generous spacing of the grid.
  static const double digitRowH = 15.0 * k;
  static const double labelBand = 14 * k;
  static final double panelBottomPad = 6 * k;
  static final double panelH = labelBand + 10 * digitRowH + panelBottomPad;
  static final double identityGap = 8 * k;

  late final double identityTop;

  double get rollPanelW => (contentW - 2 * identityGap) * .30;
  double get registrationPanelW => (contentW - 2 * identityGap) * .46;
  double get subjectPanelW =>
      contentW - rollPanelW - registrationPanelW - 2 * identityGap;

  double get rollPanelX => margin;
  double get registrationPanelX => margin + rollPanelW + identityGap;
  double get subjectPanelX =>
      margin + rollPanelW + registrationPanelW + 2 * identityGap;

  /// Centre of digit [digit] (0–9) in panel [panel] (0 = roll, 1 =
  /// registration, 2 = subject), column [col] (0-based, left → right).
  Offset digitBubble(int panel, int col, int digit) {
    double x, w;
    int cols;
    switch (panel) {
      case 1:
        x = registrationPanelX;
        w = registrationPanelW;
        cols = 10;
        break;
      case 2:
        x = subjectPanelX;
        w = subjectPanelW;
        cols = 3;
        break;
      default:
        x = rollPanelX;
        w = rollPanelW;
        cols = 6;
    }
    final cx = _digitColumnCenter(x, w, col, cols);
    return Offset(cx, identityTop + labelBand + (digit + .5) * digitRowH);
  }

  static double _digitColumnCenter(double x, double w, int col, int cols) {
    if (cols <= 1) return x + w / 2;
    final usable = w - 2 * (bubbleR + 4) * k;
    final step = usable / (cols - 1);
    return x + (bubbleR + 4) * k + col * step;
  }

  double get identityBottom => identityTop + panelH;

  // ── Set code box ───────────────────────────────────────────────────
  static final double setW = 150 * k;
  static final double setH = 26 * k;
  late final double setTop;

  /// Centre of set-code bubble [option] (0 = ক … 3 = ঘ).
  Offset setBubble(int option) {
    return Offset(margin + 96 * k + option * 14.0 * k, setTop + setH / 2);
  }

  // ── Helpers ────────────────────────────────────────────────────────
  /// Page-space radius of one bubble, in page pixels.
  static double get bubbleRadiusPx => bubbleR * k;

  /// Diagonal between the two TL/BR corner-mark centres — used to
  /// normalise scale when a sheet is photographed.
}

/// A registration corner found in a photo, with flags describing how it
/// was found:
///  • [fromMark] — a solid corner *square* was detected (best accuracy);
///  • otherwise the extreme paper pixel (the sheet's own corner) was used.
///  • [edgeSuspect] — the paper point sits on the frame border, which
///    usually means the *photo* corner was captured (e.g. a bright desk
///    merged with the sheet in the paper mask), so the anchor is unreliable.
///  • [blobDiag] — bounding-box diagonal of the detected mark blob, used
///    to sanity-check the four marks against each other.
class DetectedCorner {
  final Offset point;
  final bool fromMark;
  final bool edgeSuspect;
  final double blobDiag;
  const DetectedCorner(
    this.point,
    this.fromMark, {
    this.edgeSuspect = false,
    this.blobDiag = 0.0,
  });
}
