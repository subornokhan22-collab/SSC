import 'package:flutter/material.dart';
import '../data/extra_questions.dart';

/// কুইজ / ফলাফল স্ক্রিনে প্রশ্নের চিত্র/সারণি দেখায় (dp স্কেলে)
/// — প্রিন্ট PDF-এ PaperPdf.paintFig একই চিত্র আঁকে।
class QuestionFigureView extends StatelessWidget {
  final QuestionFigure figure;
  const QuestionFigureView({super.key, required this.figure});

  @override
  Widget build(BuildContext context) {
    final double h;
    final capExtra = figure.caption != null ? 22.0 : 0.0;
    switch (figure.kind) {
      case FigureKind.table:
        final rows =
            (figure.headers.isEmpty ? 0 : 1) + figure.rows.length;
        h = rows * 30.0 + capExtra + 16.0;
        break;
      case FigureKind.triangle:
        h = 196.0 + capExtra;
        break;
      case FigureKind.barChart:
        h = 214.0 + capExtra;
        break;
    }
    return Container(
      width: double.infinity,
      height: h,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: CustomPaint(painter: _FigurePainter(figure)),
    );
  }
}

class _FigurePainter extends CustomPainter {
  final QuestionFigure f;
  _FigurePainter(this.f);

  TextPainter _tp(String text, double size,
      {bool bold = false, TextAlign align = TextAlign.left}) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          color: Colors.black87,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    );
  }

  String _bn(int n) {
    const d = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return n
        .toString()
        .split('')
        .map((c) => (c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57)
            ? d[c.codeUnitAt(0) - 48]
            : c)
        .join();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    double bodyH = 0;
    const double topPad = 12;

    if (f.kind == FigureKind.table) {
      final headerRow = f.headers.isNotEmpty;
      final grid = <List<String>>[
        if (headerRow) f.headers,
        ...f.rows,
      ];
      if (grid.isEmpty) return;
      final nCol = grid.first.length;
      const cellH = 30.0;
      final colW = List<double>.filled(nCol, 0);
      for (int c = 0; c < nCol; c++) {
        for (int r = 0; r < grid.length; r++) {
          if (c >= grid[r].length) continue;
          final tp = _tp(grid[r][c], 13, bold: headerRow && r == 0)..layout();
          if (tp.width > colW[c]) colW[c] = tp.width;
        }
        colW[c] += 18;
      }
      var totalW = colW.fold<double>(0, (a, b) => a + b);
      final maxW = size.width * 0.92;
      if (totalW > maxW) {
        final s = maxW / totalW;
        for (int c = 0; c < nCol; c++) {
          colW[c] *= s;
        }
        totalW = maxW;
      }
      final startX = (size.width - totalW) / 2;
      bodyH = grid.length * cellH;
      canvas.drawRect(Rect.fromLTWH(startX, topPad, totalW, bodyH), line);
      double vx = startX;
      for (int c = 0; c < nCol - 1; c++) {
        vx += colW[c];
        canvas.drawLine(
            Offset(vx, topPad), Offset(vx, topPad + bodyH), line);
      }
      for (int r = 1; r < grid.length; r++) {
        final hy = topPad + r * cellH;
        canvas.drawLine(Offset(startX, hy), Offset(startX + totalW, hy), line);
      }
      for (int r = 0; r < grid.length; r++) {
        double cx = startX;
        for (int c = 0; c < nCol; c++) {
          if (c >= grid[r].length) break;
          final tp = _tp(grid[r][c], 13, bold: headerRow && r == 0)
            ..layout(maxWidth: colW[c] - 6);
          tp.paint(
            canvas,
            Offset(cx + (colW[c] - tp.width) / 2,
                topPad + r * cellH + (cellH - tp.height) / 2),
          );
          cx += colW[c];
        }
      }
    } else if (f.kind == FigureKind.triangle) {
      bodyH = 172;
      final cx = size.width / 2;
      var halfW = size.width * 0.30;
      if (halfW > 165) halfW = 165;
      if (halfW < 78) halfW = 78;
      final top = topPad + 18;
      final base = topPad + bodyH - 26;
      final a = Offset(cx, top);
      final b = Offset(cx - halfW, base);
      final c = Offset(cx + halfW, base);
      final tri = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;
      canvas.drawLine(a, b, tri);
      canvas.drawLine(b, c, tri);
      canvas.drawLine(c, a, tri);
      final v = f.headers;
      if (v.isNotEmpty && v[0].isNotEmpty) {
        final tp = _tp(v[0], 16, bold: true)..layout();
        tp.paint(canvas, Offset(a.dx - tp.width / 2, a.dy - tp.height - 2));
      }
      if (v.length > 1 && v[1].isNotEmpty) {
        final tp = _tp(v[1], 16, bold: true)..layout();
        tp.paint(canvas, Offset(b.dx - tp.width - 4, b.dy + 2));
      }
      if (v.length > 2 && v[2].isNotEmpty) {
        final tp = _tp(v[2], 16, bold: true)..layout();
        tp.paint(canvas, Offset(c.dx + 4, c.dy + 2));
      }
      final s = f.sides;
      if (s.isNotEmpty && s[0].isNotEmpty) {
        final tp = _tp(s[0], 13)..layout();
        final mx = (a.dx + b.dx) / 2;
        final my = (a.dy + b.dy) / 2;
        tp.paint(canvas, Offset(mx - tp.width - 6, my - tp.height / 2));
      }
      if (s.length > 1 && s[1].isNotEmpty) {
        final tp = _tp(s[1], 13)..layout();
        final mx = (b.dx + c.dx) / 2;
        final my = (b.dy + c.dy) / 2;
        tp.paint(canvas, Offset(mx - tp.width / 2, my + 3));
      }
      if (s.length > 2 && s[2].isNotEmpty) {
        final tp = _tp(s[2], 13)..layout();
        final mx = (c.dx + a.dx) / 2;
        final my = (c.dy + a.dy) / 2;
        tp.paint(canvas, Offset(mx + 6, my - tp.height / 2));
      }
      final an = f.angles;
      if (an.isNotEmpty && an[0].isNotEmpty) {
        final tp = _tp(an[0], 12)..layout();
        tp.paint(canvas, Offset(a.dx + 5, a.dy + 6));
      }
      if (an.length > 1 && an[1].isNotEmpty) {
        final tp = _tp(an[1], 12)..layout();
        tp.paint(canvas, Offset(b.dx + 8, b.dy - tp.height - 4));
      }
      if (an.length > 2 && an[2].isNotEmpty) {
        final tp = _tp(an[2], 12)..layout();
        tp.paint(canvas, Offset(c.dx - tp.width - 8, c.dy - tp.height - 4));
      }
      final ra = f.rightAngleAt;
      if (ra != null && ra.isNotEmpty) {
        const sz = 14.0;
        if (v.length > 1 && ra == v[1]) {
          canvas.drawLine(Offset(b.dx + sz, b.dy), Offset(b.dx + sz, b.dy - sz), tri);
          canvas.drawLine(Offset(b.dx + sz, b.dy - sz), Offset(b.dx, b.dy - sz), tri);
        } else if (v.length > 2 && ra == v[2]) {
          canvas.drawLine(Offset(c.dx - sz, c.dy), Offset(c.dx - sz, c.dy - sz), tri);
          canvas.drawLine(Offset(c.dx - sz, c.dy - sz), Offset(c.dx, c.dy - sz), tri);
        } else if (v.isNotEmpty && ra == v[0]) {
          canvas.drawLine(Offset(a.dx - sz, a.dy + sz), Offset(a.dx, a.dy + sz), tri);
          canvas.drawLine(Offset(a.dx, a.dy + sz), Offset(a.dx + sz, a.dy + sz), tri);
        }
      }
    } else if (f.kind == FigureKind.barChart) {
      bodyH = 190;
      var maxV = 0;
      for (final e in f.values) {
        if (e > maxV) maxV = e;
      }
      if (maxV <= 0 || f.values.isEmpty) return;
      final base = topPad + bodyH - 22;
      final top = topPad + 10;
      var chartW = size.width * 0.78;
      if (chartW > 420) chartW = 420;
      final startX = (size.width - chartW) / 2;
      canvas.drawLine(Offset(startX - 6, top - 4), Offset(startX - 6, base), line);
      canvas.drawLine(Offset(startX - 6, base), Offset(startX + chartW, base), line);
      final n = f.values.length;
      final slot = chartW / n;
      final barW = slot * 0.5;
      final fill = Paint()..color = const Color(0xFF3D6B99).withOpacity(0.75);
      for (int i = 0; i < n; i++) {
        final bh = (f.values[i] / maxV) * (base - top);
        final bx = startX + slot * i + (slot - barW) / 2;
        final rect = Rect.fromLTWH(bx, base - bh, barW, bh);
        canvas.drawRect(rect, fill);
        canvas.drawRect(rect, line);
        final vt = _tp(_bn(f.values[i]), 12, bold: true)..layout();
        vt.paint(canvas,
            Offset(bx + (barW - vt.width) / 2, base - bh - vt.height - 2));
        if (i < f.headers.length) {
          final lt = _tp(f.headers[i], 11)..layout(maxWidth: slot);
          lt.paint(canvas,
              Offset(startX + slot * i + (slot - lt.width) / 2, base + 3));
        }
      }
    }

    if (f.caption != null) {
      final tp = _tp(f.caption!, 12, align: TextAlign.center)
        ..layout(maxWidth: size.width);
      tp.paint(canvas,
          Offset((size.width - tp.width) / 2, topPad + bodyH + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _FigurePainter oldDelegate) =>
      oldDelegate.f != f;
}
