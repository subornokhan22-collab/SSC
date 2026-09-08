import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:tutors_desk/services/omr_layout.dart';
import 'package:tutors_desk/services/omr_scanner.dart';

void main() {
  const k = OmrSheetLayout.k;
  const m = OmrSheetLayout.margin;

  group('OmrSheetLayout', () {
    test('marks sit at the fixed page corners', () {
      final l = OmrSheetLayout(10);
      const half = 5.0 * k; // 10pt square / 2
      expect(l.markCenters[0].x, closeTo(m + half, 1e-9));
      expect(l.markCenters[0].y, closeTo(m - (10 + 6) * k + half, 1e-9));
      expect(l.markCenters[1].x,
          closeTo(OmrSheetLayout.pageW - m - 10 * k + half, 1e-9));
      expect(l.markCenters[2].x, closeTo(m + half, 1e-9));
      expect(l.markCenters[2].y,
          closeTo(OmrSheetLayout.pageH - m + 6 * k + half, 1e-9));
      expect(l.markCenters[3].x,
          closeTo(OmrSheetLayout.pageW - m - 10 * k + half, 1e-9));
      expect(l.markCenters[3].y,
          closeTo(OmrSheetLayout.pageH - m + 6 * k + half, 1e-9));
    });

    test('question grid is deterministic and starts at the fixed top', () {
      final l = OmrSheetLayout(15);
      expect(l.questionColumns, 1);
      expect(l.perColumn, 15);
      expect(l.questionBubbles.length, 60);
      expect(l.questionsTop, m + 80 * k);

      // Same layout, independent instance → identical geometry.
      final l2 = OmrSheetLayout(15);
      for (var i = 0; i < l.questionBubbles.length; i++) {
        expect(l2.questionBubbles[i].x, l.questionBubbles[i].x);
        expect(l2.questionBubbles[i].y, l.questionBubbles[i].y);
      }

      // Title length must not matter: the grid top is a constant offset.
      final l3 = OmrSheetLayout(15);
      expect(l3.questionsTop, l.questionsTop);
    });

    test('40 questions split into two balanced columns', () {
      final l = OmrSheetLayout(40);
      expect(l.questionColumns, 2);
      expect(l.perColumn, 20);
      // Question 21 (index 20) starts column 2.
      final q21 = l.question(21).first;
      final q1 = l.question(1).first;
      expect(q21.x, greaterThan(q1.x));
      expect(q21.y, closeTo(q1.y, 0.0001));
    });

    test('identity and set-code panels are always present', () {
      final l = OmrSheetLayout(10);
      expect(l.rollBubbles.length, 60); // 6 columns × 10 digits
      expect(l.regBubbles.length, 100); // 10 columns × 10 digits
      expect(l.setBubbles.length, 4);
      // Identity panels begin below the question grid.
      expect(l.identityTop, greaterThan(l.questionsBottom));
      // Set-code bubbles are inside the 150pt-wide set box.
      for (final b in l.setBubbles) {
        expect(b.x >= m, isTrue);
        expect(b.x, lessThanOrEqualTo(m + 150 * k));
      }
    });

    test('100 questions still fit the page', () {
      final l = OmrSheetLayout(100);
      expect(l.questionColumns, 4);
      expect(l.perColumn, 25);
      final lastSetY = l.setBubbles.first.y;
      expect(lastSetY + 40 * k, lessThan(OmrSheetLayout.pageH));
    });
  });

  group('solveHomography', () {
    test('identity mapping stays identity', () {
      final pts = [
        const OmrPoint(10, 20),
        const OmrPoint(500, 20),
        const OmrPoint(10, 900),
        const OmrPoint(500, 900),
      ];
      final h = solveHomography(pts, pts);
      expect(h, isNotNull);
      final p = applyH(h!, 321.5, 777.25);
      expect(p.x, closeTo(321.5, 1e-6));
      expect(p.y, closeTo(777.25, 1e-6));
    });

    test('scale + translate is recovered exactly', () {
      final src = [
        const OmrPoint(0, 0),
        const OmrPoint(100, 0),
        const OmrPoint(0, 141),
        const OmrPoint(100, 141),
      ];
      final dst = src
          .map((p) => OmrPoint(p.x * 2.5 + 40, p.y * 2.5 - 10))
          .toList();
      final h = solveHomography(src, dst)!;
      for (final p in [
        const OmrPoint(0, 0),
        const OmrPoint(100, 141),
        const OmrPoint(55.5, 70.25),
      ]) {
        final r = applyH(h, p.x, p.y);
        expect(r.x, closeTo(p.x * 2.5 + 40, 1e-6));
        expect(r.y, closeTo(p.y * 2.5 - 10, 1e-6));
      }
    });
  });

  group('parseKeyString', () {
    test('accepts Bengali, Latin and digit keys', () {
      expect(parseKeyString('ক খ গ ঘ', 4), [0, 1, 2, 3]);
      expect(parseKeyString('a b c d', 4), [0, 1, 2, 3]);
      expect(parseKeyString('1234', 4), [0, 1, 2, 3]);
      expect(parseKeyString('কখগঘ', 4), [0, 1, 2, 3]);
    });
    test('rejects wrong length', () {
      expect(parseKeyString('ক খ', 4), isNull);
      expect(parseKeyString('', 4), isNull);
    });
  });

  group('OmrScanner end-to-end (synthetic photo)', () {
    /// Renders a fake sheet photo: white page, the four corner marks,
    /// empty rings + filled dark disks at the exact layout positions.
    Uint8List renderSheet({
      required OmrSheetLayout layout,
      required List<int> filled,
      List<int> roll = const [],
      double scale = 0.4,
    }) {
      final w = (OmrSheetLayout.pageW * scale).round();
      final h = (OmrSheetLayout.pageH * scale).round();
      final canvas = img.Image(width: w, height: h);
      img.fill(canvas, color: img.ColorInt8.rgb(250, 250, 250));
      final ring = img.ColorInt8.rgb(31, 95, 168); // accent blue, like the printer
      final ink = img.ColorInt8.rgb(20, 20, 20);

      void circle(OmrPoint c, double r, img.ColorInt8 color, {bool fill = false}) {
        for (var yy = (c.y - r).floor(); yy <= (c.y + r).ceil(); yy++) {
          for (var xx = (c.x - r).floor(); xx <= (c.x + r).ceil(); xx++) {
            if (xx < 0 || yy < 0 || xx >= w || yy >= h) continue;
            final dx = xx - c.x, dy = yy - c.y;
            if (fill) {
              if (dx * dx + dy * dy <= r * r) {
                canvas.setPixel(xx, yy, color);
              }
            } else if ((dx * dx + dy * dy - r * r).abs() <= r * 0.25 + 1) {
              canvas.setPixel(xx, yy, color);
            }
          }
        }
      }

      void mark(OmrPoint c) {
        final r = 5.0 * k * scale;
        for (var yy = (c.y - r).floor(); yy <= (c.y + r).ceil(); yy++) {
          for (var xx = (c.x - r).floor(); xx <= (c.x + r).ceil(); xx++) {
            if (xx >= 0 && yy >= 0 && xx < w && yy < h) {
              canvas.setPixel(xx, yy, ink);
            }
          }
        }
      }

      for (final mc in layout.markCenters) {
        mark(mc);
      }
      for (var q = 0; q < layout.totalQuestions; q++) {
        for (var o = 0; o < 4; o++) {
          final b = layout.questionBubbles[q * 4 + o];
          final c = OmrPoint(b.x * scale, b.y * scale);
          circle(c, b.r * scale, ring);
          if (filled.contains(q * 4 + o)) {
            circle(c, b.r * scale * 0.95, ink, fill: true);
          }
        }
      }
      // Roll digits: filled[bubbleIndex] where index = column*10 + digit.
      for (final i in roll) {
        final b = layout.rollBubbles[i];
        circle(OmrPoint(b.x * scale, b.y * scale),
            b.r * scale * 0.95, ink, fill: true);
      }
      return img.encodeJpg(canvas, quality: 92);
    }

    test('reads options, roll digits and rejects blanks', () async {
      final layout = OmrSheetLayout(20);
      // Fill: Q1→0(ক), Q2→1(খ), Q3→3(ঘ), Q4 left blank, rest random.
      final filled = <int>[0, 1 * 4 + 1, 2 * 4 + 3];
      for (var q = 4; q < 20; q++) {
        filled.add(q * 4 + (q % 4));
      }
      final photo = renderSheet(
          layout: layout, filled: filled, roll: [5, 1 * 10 + 2, 2 * 10 + 9]);

      final result = await OmrScanner.scan(photo, layout);
      expect(result.ok, isTrue, reason: result.error ?? '');
      expect(result.answers[0], 0);
      expect(result.answers[1], 1);
      expect(result.answers[2], 3);
      expect(result.answers[3], -1);
      for (var q = 4; q < 20; q++) {
        expect(result.answers[q], q % 4, reason: 'Q${q + 1}');
      }
      // Roll: 5, 2, 9, then three empty columns.
      expect(result.rollDigits, [5, 2, 9, -1, -1, -1]);
    });
  });
}
