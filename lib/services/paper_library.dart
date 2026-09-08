import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// One question paper the tutor added to the app.
///
/// `kind` is either `'images'` (each page is a photo/scan, stored as
/// `{id}_p1.jpg`, `{id}_p2.jpg`, …) or `'pdf'` (a single `{id}.pdf`).
/// `thumb.jpg` is a small preview of page 1.
class PaperEntry {
  final String id;
  final String title;
  final String subject;
  final String year;
  final String kind;
  final int pages;
  final DateTime createdAt;

  const PaperEntry({
    required this.id,
    required this.title,
    required this.subject,
    required this.year,
    required this.kind,
    required this.pages,
    required this.createdAt,
  });

  String get kindLabel => kind == 'pdf' ? 'PDF' : 'ছবি';

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subject': subject,
        'year': year,
        'kind': kind,
        'pages': pages,
        'createdAt': createdAt.toIso8601String(),
      };

  static PaperEntry fromJson(Map<String, dynamic> m) => PaperEntry(
        id: m['id'] as String,
        title: m['title'] as String? ?? '',
        subject: m['subject'] as String? ?? '',
        year: m['year'] as String? ?? '',
        kind: m['kind'] as String? ?? 'images',
        pages: m['pages'] as int? ?? 1,
        createdAt:
            DateTime.tryParse(m['createdAt'] as String? ?? '') ??
                DateTime.now(),
      );
}

class PaperLibrary {
  PaperLibrary._();

  static const _indexName = 'index.json';

  static Future<Directory> root() async {
    final appDoc = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDoc.path}${Platform.pathSeparator}tutors_desk_papers');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  static Future<File> _indexFile() async =>
      File((await root()).path + '$_indexName');

  static Future<List<PaperEntry>> loadEntries() async {
    final f = await _indexFile();
    if (!f.existsSync()) return const [];
    try {
      final list = json.decode(f.readAsStringSync()) as List;
      final entries = list
          .map((e) => PaperEntry.fromJson((e as Map).cast<String, dynamic>()))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return entries;
    } catch (_) {
      return const [];
    }
  }

  static Future<void> _saveEntries(List<PaperEntry> entries) async {
    final f = await _indexFile();
    await f.writeAsString(json.encode([for (final e in entries) e.toJson()]));
  }

  static Future<File> _dirFor(String id) async {
    final dir =
        Directory((await root()).path + Platform.pathSeparator + id);
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// Adds a paper from photos (one photo per page, in order).
  static Future<PaperEntry> addFromImages({
    required String title,
    required String subject,
    required String year,
    required List<Uint8List> pages,
  }) async {
    if (pages.isEmpty) {
      throw Exception('কমপক্ষে এক পজের ছবি দাও।');
    }
    final id = 'p_${DateTime.now().millisecondsSinceEpoch}';
    final dir = await _dirFor(id);
    final norm = <Uint8List>[];
    for (final raw in pages) {
      norm.add(await _normalizeJpeg(raw));
    }
    for (var i = 0; i < norm.length; i++) {
      await File('${dir.path}${Platform.pathSeparator}p${i + 1}.jpg')
          .writeAsBytes(norm[i]);
    }
    // Thumbnail from the *normalized* first page so it matches what is
    // stored and printed.
    final thumb = await _thumbFrom(norm.first);
    await File('${dir.path}${Platform.pathSeparator}thumb.jpg')
        .writeAsBytes(thumb);

    final entry = PaperEntry(
      id: id,
      title: title,
      subject: subject,
      year: year,
      kind: 'images',
      pages: norm.length,
      createdAt: DateTime.now(),
    );
    final all = await loadEntries();
    await _saveEntries([entry, ...all]);
    return entry;
  }

  /// Adds a paper from a PDF file.
  static Future<PaperEntry> addFromPdf({
    required String title,
    required String subject,
    required String year,
    required Uint8List bytes,
    int pages = 0,
  }) async {
    if (bytes.isEmpty) throw Exception('PDF ফাইল খালি।');
    final id = 'p_${DateTime.now().millisecondsSinceEpoch}';
    final dir = await _dirFor(id);
    await File('${dir.path}${Platform.pathSeparator}doc.pdf')
        .writeAsBytes(bytes);
    // No raster thumbnail for PDFs — the list shows a document icon.

    final entry = PaperEntry(
      id: id,
      title: title,
      subject: subject,
      year: year,
      kind: 'pdf',
      pages: pages > 0 ? pages : 1,
      createdAt: DateTime.now(),
    );
    final all = await loadEntries();
    await _saveEntries([entry, ...all]);
    return entry;
  }

  static Future<void> deleteEntry(String id) async {
    final dir = Directory((await root()).path + Platform.pathSeparator + id);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    final all = (await loadEntries())..removeWhere((e) => e.id == id);
    await _saveEntries(all);
  }

  static Future<Uint8List?> pageBytes(String id, int page) async {
    final f = File(
        (await _dirFor(id)).path + Platform.pathSeparator + 'p${page}.jpg');
    if (!f.existsSync()) return null;
    return f.readAsBytes();
  }

  static Future<Uint8List?> pdfBytes(String id) async {
    final f =
        File((await _dirFor(id)).path + Platform.pathSeparator + 'doc.pdf');
    if (!f.existsSync()) return null;
    return f.readAsBytes();
  }

  static Future<Uint8List?> thumbBytes(String id) async {
    final f =
        File((await _dirFor(id)).path + Platform.pathSeparator + 'thumb.jpg');
    if (!f.existsSync()) return null;
    return f.readAsBytes();
  }

  /// Prints (or shares, when the system print service is unavailable) the
  /// paper. Image papers are assembled into an A4 PDF on the fly.
  static Future<void> printEntry(PaperEntry entry) async {
    if (entry.kind == 'pdf') {
      final bytes = await pdfBytes(entry.id);
      if (bytes == null) throw Exception('PDF পাওয়া যায়নি।');
      await _layoutOrShare(bytes, '${_safeName(entry.title)}.pdf');
      return;
    }
    final doc = pw.Document();
    for (var i = 1; i <= entry.pages; i++) {
      final bytes = await pageBytes(entry.id, i);
      if (bytes == null) continue;
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.Image(
            pw.MemoryImage(bytes),
            width: PdfPageFormat.a4.width,
            height: PdfPageFormat.a4.height,
            fit: pw.BoxFit.contain,
          ),
        ),
      );
    }
    final bytes = await doc.save();
    await _layoutOrShare(bytes, '${_safeName(entry.title)}.pdf');
  }

  /// Hands the paper to the system share sheet (PDF in both kinds).
  static Future<void> shareEntry(PaperEntry entry) async {
    if (entry.kind == 'pdf') {
      final bytes = await pdfBytes(entry.id);
      if (bytes == null) throw Exception('PDF পাওয়া যায়নি।');
      await Printing.sharePdf(
        bytes: bytes,
        filename: '${_safeName(entry.title)}.pdf',
      );
      return;
    }
    final doc = pw.Document();
    for (var i = 1; i <= entry.pages; i++) {
      final bytes = await pageBytes(entry.id, i);
      if (bytes == null) continue;
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.Image(
            pw.MemoryImage(bytes),
            width: PdfPageFormat.a4.width,
            height: PdfPageFormat.a4.height,
            fit: pw.BoxFit.contain,
          ),
        ),
      );
    }
    final bytes = await doc.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${_safeName(entry.title)}.pdf',
    );
  }

  static Future<void> _layoutOrShare(Uint8List bytes, String filename) async {
    try {
      await Printing.layoutPdf(onLayout: (format) async => bytes);
    } catch (_) {
      await Printing.sharePdf(bytes: bytes, filename: filename);
    }
  }

  static String _safeName(String title) {
    final clean =
        title.replaceAll(RegExp(r'[\\/:*?"<>|]'), ' ').trim();
    return clean.isEmpty ? 'paper' : clean;
  }

  // ═══════════ image normalisation ═══════════

  /// Decodes a picked photo, applies its EXIF orientation and re-encodes as
  /// a compact upright JPEG. Display, thumbnails and PDF assembly then all
  /// use the same correct-upright bytes.
  static Future<Uint8List> _normalizeJpeg(Uint8List raw) async {
    final image = img.decodeImage(raw);
    if (image == null) return raw; // not decodable — keep as-is, best effort
    var im = image;
    final orientation = exifOrientation(raw);
    if (orientation != null) {
      im = _applyOrientation(im, orientation);
    }
    // Cap long side at 2200 px — plenty for print, keeps storage small.
    const maxSide = 2200;
    final side = im.width > im.height ? im.width : im.height;
    if (side > maxSide) {
      final s = maxSide / side;
      im = img.copyResize(
          im,
          width: (im.width * s).round(),
          height: (im.height * s).round());
    }
    return img.encodeJpg(im, quality: 85);
  }

  static Future<Uint8List> _thumbFrom(Uint8List page) async {
    final image = img.decodeImage(page);
    if (image == null) return page;
    final s = 360.0 / (image.width > image.height ? image.width : image.height);
    final im = s < 1
        ? img.copyResize(image,
            width: (image.width * s).round(), height: (image.height * s).round())
        : image;
    return img.encodeJpg(im, quality: 78);
  }

  // ═══════════ EXIF orientation (JPEG only) ═══════════

  /// Returns the EXIF Orientation tag (1–8) of a JPEG, or null.
  ///
  /// Hand-rolled (≈40 lines) so the app never needs a native EXIF library:
  /// walk JPEG segments to APP1, verify the `Exif\0\0` payload, read the
  /// first IFD and return tag 0x0112.
  static int? exifOrientation(Uint8List j) {
    if (j.length < 4 || j[0] != 0xFF || j[1] != 0xD8) return null;
    int jpegU16(int o) => (j[o] << 8) | j[o + 1];
    var p = 2;
    while (p + 4 <= j.length) {
      if (j[p] != 0xFF) {
        p++;
        continue;
      }
      final marker = j[p + 1];
      if (marker == 0xDA) break; // start of scan — no EXIF before this
      if (marker >= 0xD0 && marker <= 0xD7) continue; // RST: no length
      final len = jpegU16(p + 2);
      if (marker == 0xE1) {
        final exif = p + 4; // APP1 payload start: "Exif\0\0" + TIFF header
        // TIFF header: byte order (II/MM), 0x002A, offset to first IFD.
        final tiffStart = exif + 6;
        if (tiffStart + 8 <= j.length &&
            j[exif] == 0x45 &&
            j[exif + 1] == 0x78 &&
            j[exif + 2] == 0x69 &&
            j[exif + 3] == 0x66 &&
            j[exif + 4] == 0x00 &&
            j[exif + 5] == 0x00 &&
            (j[tiffStart + 2] == 0x2A || j[tiffStart + 3] == 0x2A)) {
          final little = j[tiffStart] == 0x49; // 'I'
          int u16e(int o) =>
              little ? (j[o] | (j[o + 1] << 8)) : ((j[o] << 8) | j[o + 1]);
          int u32e(int o) => little
              ? (j[o] | (j[o + 1] << 8) | (j[o + 2] << 16) | (j[o + 3] << 24))
              : ((j[o] << 24) |
                  (j[o + 1] << 16) |
                  (j[o + 2] << 8) |
                  j[o + 3]);
          final ifdOff = u32e(tiffStart + 4);
          final ifd = tiffStart + ifdOff; // TIFF offsets are relative
          if (ifd + 2 <= j.length) {
            final n = u16e(ifd);
            for (var i = 0; i < n; i++) {
              final e = ifd + 2 + i * 12;
              if (e + 12 > j.length) break;
              if (u16e(e) == 0x0112) {
                return u16e(e + 8); // Orientation is SHORT — inline value
              }
            }
          }
        }
      }
      p += 2 + len;
    }
    return null;
  }

  static img.Image _applyOrientation(img.Image im, int o) {
    switch (o) {
      case 2:
        return img.flipHorizontal(im);
      case 3:
        return img.copyRotate(im, 180);
      case 4:
        return img.flipVertical(im);
      case 5:
        return img.flipHorizontal(img.copyRotate(im, 90));
      case 6:
        return img.copyRotate(im, 90);
      case 7:
        return img.flipHorizontal(img.copyRotate(im, 270));
      case 8:
        return img.copyRotate(im, 270);
      default:
        return im;
    }
  }
}
