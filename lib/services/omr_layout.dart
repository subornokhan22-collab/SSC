/// Pure-Dart geometry of the app's printable OMR sheet.
///
/// This is the SINGLE SOURCE OF TRUTH for where every mark and bubble is
/// drawn on the OMR page: `paper_pdf.dart` uses these numbers to draw the
/// sheet, and `omr_scanner.dart` uses the very same numbers to know where to
/// sample ink in a photographed sheet. If the two ever drift apart, the
/// scanner silently misreads every bubble — keep them in lockstep.
///
/// Coordinates are in PaperPdf's raster page space: A4 at 200 dpi,
/// 1654 × 2339 px, where 1 pt = k px (k = 200/72).
///
/// The layout is fully deterministic for a given question count: the header
/// (title / instructions / rule) occupies fixed offsets so the question grid
/// does not move when the paper title changes length.
library;

import 'dart:math' as math;

/// A point in raster page space (px).
class OmrPoint {
  final double x;
  final double y;
  const OmrPoint(this.x, this.y);

  double distTo(OmrPoint o) {
    final dx = x - o.x, dy = y - o.y;
    return math.sqrt(dx * dx + dy * dy);
  }
}

/// One answerable bubble on the sheet.
///
/// For question bubbles [row] is the 1-based question number and [option]
/// is 0-3 (ক/খ/গ/ঘ). For the digit panels [row] is the digit column index
/// and [option] is the digit 0-9. For the set-code row [row] is 0 and
/// [option] is 0-3.
class OmrBubble {
  final int row;
  final int option;
  final double x;
  final double y;
  final double r;
  const OmrBubble({
    required this.row,
    required this.option,
    required this.x,
    required this.y,
    required this.r,
  });
}

class OmrSheetLayout {
  // ── Page constants (mirror PaperPdf) ─────────────────────────────
  static const double k = 200 / 72;
  static const double pageW = 1654;
  static const double pageH = 2339;
  static const double margin = 40 * k;
  static const double bubbleR = 4.8 * k;

  // Fixed header offsets (pt from the top margin) — the scanner relies on
  // these being independent of the printed title.
  static const double _questionsTopPt = 80;

  // ── Derived geometry (computed in _compute) ─────────────────────
  final int totalQuestions;
  final double contentW;
  int questionColumns = 0;
  int perColumn = 0;
  double questionWidth = 0;
  double questionsTop = 0;
  double questionsBottom = 0;
  double identityTop = 0;
  double identityBottom = 0;

  /// Corner alignment-mark centers, in the order TL, TR, BL, BR.
  final List<OmrPoint> markCenters;

  /// Question option bubbles: index (question-1) * 4 + option.
  List<OmrBubble> questionBubbles = const [];

  /// Roll-number digit bubbles: column * 10 + digit (6 columns).
  List<OmrBubble> rollBubbles = const [];

  /// Registration-number digit bubbles: column * 10 + digit (10 columns).
  List<OmrBubble> regBubbles = const [];

  /// Set-code bubbles (4).
  List<OmrBubble> setBubbles = const [];

  OmrSheetLayout(int mcqCount)
      : totalQuestions = mcqCount.clamp(0, 100),
        contentW = pageW - 2 * margin,
        markCenters = _marks() {
    _compute();
  }

  static List<OmrPoint> _marks() {
    const markSize = 10.0; // pt, same as paper_pdf.dart
    final half = markSize * k / 2;
    return [
      // TL, TR, BL, BR — top-left corners of the squares exactly as drawn:
      OmrPoint(margin + half, margin - (markSize + 6) * k + half),
      OmrPoint(pageW - margin - markSize * k + half, margin - (markSize + 6) * k + half),
      OmrPoint(margin + half, pageH - margin + 6 * k + half),
      OmrPoint(pageW - margin - markSize * k + half, pageH - margin + 6 * k + half),
    ];
  }

  void _compute() {
    const maxPerColumn = 25;
    final columns =
        ((totalQuestions + maxPerColumn - 1) ~/ maxPerColumn).clamp(1, 4);
    final perCol = ((totalQuestions + columns - 1) ~/ columns)
        .clamp(1, maxPerColumn)
        .toInt();
    questionColumns = columns;
    perColumn = perCol;

    questionsTop = margin + _questionsTopPt * k;

    final questionGap = 8 * k;
    final rawQuestionWidth =
        (contentW - (columns - 1) * questionGap) / columns;
    final numberW = 26 * k;
    const maxBubbleStep = 22.0;
    final naturalRowW = numberW +
        bubbleR +
        2 * k +
        6 * k +
        maxBubbleStep * 3 * k +
        (bubbleR + 6 * k);
    questionWidth = rawQuestionWidth > naturalRowW
        ? naturalRowW
        : rawQuestionWidth;
    final bubbleAreaX = numberW + bubbleR + 2 * k;
    final bubbleSpan = questionWidth - bubbleAreaX - (bubbleR + 4 * k);
    final bubbleStep = (bubbleSpan / 3) > maxBubbleStep * k
        ? maxBubbleStep * k
        : bubbleSpan / 3;
    final bubbleLeft = bubbleAreaX + 6 * k;
    final headerH = 13 * k;
    final rowH = 11.2 * k;

    final bubbles = <OmrBubble>[];
    for (var i = 0; i < totalQuestions; i++) {
      final column = i ~/ perCol;
      final row = i % perCol;
      final boxX = margin + column * (questionWidth + questionGap);
      final yy = questionsTop + headerH + row * rowH + rowH / 2;
      for (var option = 0; option < 4; option++) {
        bubbles.add(OmrBubble(
          row: i + 1,
          option: option,
          x: boxX + bubbleLeft + option * bubbleStep,
          y: yy,
          r: bubbleR,
        ));
      }
    }
    questionBubbles = bubbles;

    final tallest = totalQuestions < perCol ? totalQuestions : perCol;
    questionsBottom = questionsTop + headerH + tallest * rowH + 4 * k;

    // ── Identity digit panels (fixed caption height) ───────────────
    final identityGap = 8 * k;
    final rollW = (contentW - 2 * identityGap) * .30;
    final regW = (contentW - 2 * identityGap) * .46;
    identityTop = questionsBottom + 10 * k;
    final labelH = 12.5 * k; // fixed — see digitPanel in paper_pdf.dart
    final digitRowH = 10.8 * k;
    final panelH = labelH + 10 * digitRowH + 6 * k;

    List<OmrBubble> digits(double x, double width, int cols) {
      final out = <OmrBubble>[];
      final usable = width - 2 * (bubbleR + 4 * k);
      final step = cols > 1 ? usable / (cols - 1) : 0.0;
      final startX = cols > 1 ? x + (bubbleR + 4 * k) : x + width / 2;
      for (var column = 0; column < cols; column++) {
        final cx = startX + column * step;
        for (var digit = 0; digit < 10; digit++) {
          out.add(OmrBubble(
            row: column,
            option: digit,
            x: cx,
            y: identityTop + labelH + (digit + 0.5) * digitRowH,
            r: bubbleR,
          ));
        }
      }
      return out;
    }

    rollBubbles = digits(margin, rollW, 6);
    regBubbles = digits(margin + rollW + identityGap, regW, 10);
    identityBottom = identityTop + panelH;

    // ── Set code row ───────────────────────────────────────────────
    final setTop = identityBottom + 10 * k;
    final setW = 150 * k;
    final setH = 26 * k;
    const setTitleW = 36.0 * k; // fixed caption box — see paper_pdf.dart
    final bubbleD = bubbleR * 2;
    final setStart = margin + 8 * k + setTitleW + bubbleD;
    final setStep = (setW - (setStart - margin) - (bubbleR + 5 * k)) / 3;
    setBubbles = List.generate(4, (i) => OmrBubble(
          row: 0,
          option: i,
          x: setStart + i * setStep,
          y: setTop + setH / 2,
          r: bubbleR,
        ));
  }

  /// The four option bubbles of one question (1-based), or an empty list.
  List<OmrBubble> question(int number) {
    if (number < 1 || number > totalQuestions) return const [];
    final i = (number - 1) * 4;
    return questionBubbles.sublist(i, i + 4);
  }
}
