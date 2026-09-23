import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Offset;

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:tutors_desk/services/omr/omr_geometry.dart';
import 'package:tutors_desk/services/omr/omr_scanner.dart';

// ════════════════════════════════════════════════════════════════════
// Synthetic OMR pipeline test.
//
// A full OMR page is rasterised with [OMrGeometry] (corner marks, question
// bubbles, digit panels, set box), warped through a known homography into a
// fake photo, and OMrScanner.scan is expected to read back exactly what was
// filled in. This validates corner detection, homography solving,
// rotation disambiguation and bubble sampling together.
// ════════════════════════════════════════════════════════════════════

img.Image _canvas(int w, int h, int v) {
  final im = img.Image(width: w, height: h);
  final px = im.getBytes();
  final byte = v.toUnsigned(8);
  for (var i = 0; i < w * h; i++) {
    px[i * 4] = byte;
    px[i * 4 + 1] = byte;
    px[i * 4 + 2] = byte;
    px[i * 4 + 3] = 255;
  }
  return im;
}

void _fillRect(img.Image im, int x0, int y0, int ww, int hh, int gray) {
  final px = im.getBytes();
  for (var y = y0; y < y0 + hh; y++) {
    for (var x = x0; x < x0 + ww; x++) {
      if (x < 0 || y < 0 || x >= im.width || y >= im.height) continue;
      final i = (y * im.width + x) * 4;
      px[i] = gray;
      px[i + 1] = gray;
      px[i + 2] = gray;
    }
  }
}

void _fillDisk(img.Image im, int cx, int cy, double rad, int gray) {
  final px = im.getBytes();
  final ri = rad.ceil();
  for (var dy = -ri; dy <= ri; dy++) {
    for (var dx = -ri; dx <= ri; dx++) {
      if (dx * dx + dy * dy > rad * rad) continue;
      final x = cx + dx, y = cy + dy;
      if (x < 0 || y < 0 || x >= im.width || y >= im.height) continue;
      final i = (y * im.width + x) * 4;
      px[i] = gray;
      px[i + 1] = gray;
      px[i + 2] = gray;
    }
  }
}

void _ring(img.Image im, int cx, int cy, double rad, double stroke, int gray) {
  final px = im.getBytes();
  final outer = rad + stroke / 2;
  final ri = outer.ceil();
  for (var dy = -ri; dy <= ri; dy++) {
    for (var dx = -ri; dx <= ri; dx++) {
      final d = math.sqrt(dx * dx + dy * dy);
      if (d > outer || d < rad - stroke / 2) continue;
      final x = cx + dx, y = cy + dy;
      if (x < 0 || y < 0 || x >= im.width || y >= im.height) continue;
      final i = (y * im.width + x) * 4;
      px[i] = gray;
      px[i + 1] = gray;
      px[i + 2] = gray;
    }
  }
}

/// The printed option letter inside an empty bubble — a sparse dark cluster
/// (~10% ink in the sampling disc), exactly what the real sheet prints.
void _letterBlob(img.Image im, int cx, int cy, int gray) {
  final px = im.getBytes();
  for (var dy = -5; dy <= 5; dy++) {
    for (var dx = -3; dx <= 3; dx++) {
      if ((dx * 3 + dy * 5).abs() % 5 != 0) continue;
      final x = cx + dx, y = cy + dy;
      if (x < 0 || y < 0 || x >= im.width || y >= im.height) continue;
      final i = (y * im.width + x) * 4;
      px[i] = gray;
      px[i + 1] = gray;
      px[i + 2] = gray;
    }
  }
}

/// Rasterises one OMR page from [OMrGeometry].
///
/// [answers] is the option index per question (-1 = blank). Questions listed
/// in [doubles] are double-marked with the given option pair.
img.Image _buildOmPage({
  required int total,
  required List<int> answers,
  Map<int, List<int>> doubles = const {},
  String roll = '',
  String subject = '',
  int setOption = -1,
}) {
  final geo = OMrGeometry(total);
  final im = _canvas(OMrGeometry.pageW.round(), OMrGeometry.pageH.round(), 255);
  final r = OMrGeometry.bubbleRadiusPx;

  for (var i = 0; i < 4; i++) {
    final t = OMrGeometry.markTopLeft(i);
    _fillRect(im, t[0].round(), t[1].round(), OMrGeometry.markSize.round(),
        OMrGeometry.markSize.round(), 26);
  }

  for (var no = 1; no <= total; no++) {
    final filled = <int>{
      if (answers[no - 1] >= 0) answers[no - 1],
      ...?doubles[no - 1],
    };
    for (var o = 0; o < 4; o++) {
      final p = geo.questionBubble(no, o);
      final x = p.dx.round(), y = p.dy.round();
      _ring(im, x, y, r, 2, 90);
      if (filled.contains(o)) {
        _fillDisk(im, x, y, r * 0.82, 20);
      } else {
        _letterBlob(im, x, y, 60);
      }
    }
  }

  void digitPanel(int panel, int cols, String digits) {
    for (var c = 0; c < cols; c++) {
      for (var d = 0; d < 10; d++) {
        final p = geo.digitBubble(panel, c, d);
        final x = p.dx.round(), y = p.dy.round();
        _ring(im, x, y, r, 2, 90);
        if (c < digits.length && digits[c] == '$d') {
          _fillDisk(im, x, y, r * 0.82, 20);
        } else {
          _letterBlob(im, x, y, 60);
        }
      }
    }
  }

  digitPanel(0, 6, roll);
  digitPanel(1, 10, '');
  digitPanel(2, 3, subject);

  for (var o = 0; o < 4; o++) {
    final p = geo.setBubble(o);
    final x = p.dx.round(), y = p.dy.round();
    _ring(im, x, y, r, 2, 90);
    if (setOption == o) {
      _fillDisk(im, x, y, r * 0.82, 20);
    } else {
      _letterBlob(im, x, y, 60);
    }
  }
  return im;
}

/// Scatters the page pixels through homography [h] into a pw×ph photo.
img.Image _warp(img.Image page, List<double> h, int pw, int ph) {
  final out = _canvas(pw, ph, 255);
  final po = out.getBytes();
  final pp = page.getBytes();
  for (var y = 0; y < page.height; y++) {
    for (var x = 0; x < page.width; x++) {
      final w = h[6] * x + h[7] * y + 1;
      final px = ((h[0] * x + h[1] * y + h[2]) / w).round();
      final py = ((h[3] * x + h[4] * y + h[5]) / w).round();
      if (px < 0 || py < 0 || px >= pw || py >= ph) continue;
      final s = (y * page.width + x) * 4;
      final d = (py * pw + px) * 4;
      po[d] = pp[s];
      po[d + 1] = pp[s + 1];
      po[d + 2] = pp[s + 2];
      po[d + 3] = 255;
    }
  }
  return out;
}

List<Offset> _pageMarks() => [
      OMrGeometry.markCenter(0),
      OMrGeometry.markCenter(1),
      OMrGeometry.markCenter(2),
      OMrGeometry.markCenter(3),
    ];

void main() {
  const total = 30;
  final answers = List<int>.generate(total, (i) => i % 4);
  answers[4] = -1; // q5 blank
  answers[9] = -1; // q10 blank
  final doubles = {8: [0, 1]}; // q9 double-marked

  final expectedKey =
      List<int>.generate(total, (i) => (i == 4 || i == 9) ? 0 : i % 4);

  group('geometry', () {
    test('bubble layout stays sane for every sheet size', () {
      for (final t in [1, 5, 10, 25, 26, 30, 50, 75, 99, 100]) {
        final g = OMrGeometry(t);
        for (var no = 1; no <= t; no++) {
          for (var o = 0; o < 4; o++) {
            final p = g.questionBubble(no, o);
            expect(p.dx, greaterThan(OMrGeometry.margin - 1));
            expect(p.dx, lessThan(OMrGeometry.pageW - OMrGeometry.margin + 1));
            expect(p.dy, greaterThan(OMrGeometry.questionsTop));
            expect(p.dy, lessThan(g.questionsBottom));
          }
        }
        // Adjacent bubbles in a row must not overlap.
        final a = g.questionBubble(1, 0);
        final b = g.questionBubble(1, 1);
        expect((b.dx - a.dx).abs(),
            greaterThan(2 * OMrGeometry.bubbleRadiusPx));
        // Identity panels below the question grid.
        expect(g.identityTop, greaterThan(g.questionsBottom));
        expect(g.identityBottom, lessThan(OMrGeometry.pageH - OMrGeometry.margin));
        expect(g.setTop + OMrGeometry.setH,
            lessThan(OMrGeometry.pageH - OMrGeometry.margin));
      }
    });

    test('corner marks sit inside the page', () {
      for (var i = 0; i < 4; i++) {
        final t = OMrGeometry.markTopLeft(i);
        expect(t[0], greaterThanOrEqualTo(0));
        expect(t[1], greaterThanOrEqualTo(0));
        expect(t[0] + OMrGeometry.markSize, lessThanOrEqualTo(OMrGeometry.pageW));
        expect(t[1] + OMrGeometry.markSize, lessThanOrEqualTo(OMrGeometry.pageH));
      }
    });
  });

  group('homography', () {
    test('solves a known 4-point transform', () {
      final p = _pageMarks();
      // Simple: scale 0.5 + translate.
      final q = [
        for (final m in p) Offset(m.dx * 0.5 + 50, m.dy * 0.5 + 80),
      ];
      final h = OMrScanner.homographyFrom4(p, q);
      expect(h, isNotNull);
      for (var i = 0; i < 4; i++) {
        final m = OMrScanner.applyHomography(h!, p[i]);
        expect((m.dx - q[i].dx).abs(), lessThan(1e-6));
        expect((m.dy - q[i].dy).abs(), lessThan(1e-6));
      }
    });
  });

  group('scan (synthetic photo)', () {
    test('upright sheet with mild perspective', () async {
      final page = _buildOmPage(
          total: total,
          answers: answers,
          doubles: doubles,
          roll: '001234',
          subject: '109',
          setOption: 1);
      final h = OMrScanner.homographyFrom4(_pageMarks(), [
        const Offset(180, 260), // TL
        const Offset(1440, 200), // TR
        const Offset(220, 2010), // BL
        const Offset(1420, 1930), // BR
      ])!;
      final photo = _warp(page, h, 1600, 2200);
      final bytes = img.encodeJpg(photo, quality: 92);

      final res = await OMrScanner.scan(bytes, total: total);
      expect(res.ok, isTrue, reason: res.error);
      expect(res.answers, answers);
      expect(res.roll, '001234');
      expect(res.subjectCode, '109');
      expect(res.setCode, 1);

      final graded = OMrScanner.grade(res, expectedKey);
      expect(graded.correct, total - 3); // 2 blank + 1 double-marked
      expect(graded.blank, 2);
      expect(graded.ambiguous, 1);
      expect(graded.wrong, 1); // double-marked counts as wrong (invalid)
      expect(graded.score, total - 3);
    });

    test('sheet rotated 90° clockwise in a landscape photo', () async {
      final page = _buildOmPage(
          total: total,
          answers: answers,
          doubles: doubles,
          roll: '001234',
          subject: '109',
          setOption: 1);
      // Page TL → photo TR, TR → BR, BR → BL, BL → TL.
      final h = OMrScanner.homographyFrom4(_pageMarks(), [
        const Offset(1950, 200), // page TL → photo TR area
        const Offset(1990, 1400), // page TR → photo BR area
        const Offset(250, 1350), // page BL → photo BL area
        const Offset(200, 150), // page BR → photo TL area
      ])!;
      final photo = _warp(page, h, 2200, 1600);
      final bytes = img.encodeJpg(photo, quality: 92);

      final res = await OMrScanner.scan(bytes, total: total);
      expect(res.ok, isTrue, reason: res.error);
      expect(res.answers, answers);
      expect(res.roll, '001234');
      expect(res.setCode, 1);
    });

    test('sheet rotated 180° in a portrait photo', () async {
      final page = _buildOmPage(
          total: total,
          answers: answers,
          doubles: doubles,
          roll: '001234',
          subject: '109',
          setOption: 1);
      // Page TL → photo BR, TR → BL, BL → TR, BR → TL.
      final h = OMrScanner.homographyFrom4(_pageMarks(), [
        const Offset(1420, 1930), // page TL → photo BR
        const Offset(200, 1950), // page TR → photo BL
        const Offset(1440, 250), // page BL → photo TR
        const Offset(180, 260), // page BR → photo TL
      ])!;
      final photo = _warp(page, h, 1600, 2200);
      final bytes = img.encodeJpg(photo, quality: 92);

      final res = await OMrScanner.scan(bytes, total: total);
      expect(res.ok, isTrue, reason: res.error);
      expect(res.answers, answers);
      expect(res.roll, '001234');
      expect(res.subjectCode, '109');
      expect(res.setCode, 1);
    });
  });
}
