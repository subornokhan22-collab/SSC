import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel;
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:image_picker/image_picker.dart';

import '../services/omr/omr_geometry.dart';
import '../services/omr/omr_scanner.dart';
import '../services/omr/omr_store.dart';
import 'omr_analytics_screen.dart';
import 'omr_live_scan_screen.dart';
import '../services/paper_library.dart';
import '../services/paper_pdf.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/glass_card.dart';

/// OMR স্ক্যানার — ফটো থেকে ভরাট করা OMR শিট পড়ে, answer key-এর
/// সাথে মিলিয়ে মার্ক করে এবং ছাপার-যোগ্য স্কোর কার্ড দেয়।
class OMrScannerScreen extends StatefulWidget {
  /// Pre-loaded answer key (option index per question) — passed when the
  /// tutor scans a paper they just generated in the app.
  final List<int>? initialKey;

  /// Paper title used on the scorecard (and for the key draft).
  final String paperTitle;

  /// Subject name, pre-filled when the scanner is opened from a saved paper.
  final String initialSubject;

  const OMrScannerScreen({
    super.key,
    this.initialKey,
    this.paperTitle = '',
    this.initialSubject = '',
  });

  @override
  State<OMrScannerScreen> createState() => _OMrScannerScreenState();
}

class _OMrScannerScreenState extends State<OMrScannerScreen> {
  static const _letters = ['ক', 'খ', 'গ', 'ঘ'];

  Uint8List? _photoBytes;
  ui.Image? _photoImage;

  int _total = 30;
  late List<int> _key;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _subjectCtrl;

  bool _busy = false;
  OmScanResult? _result;
  OmGraded? _graded;
  Uint8List? _overlayJpg;
  int? _scanMs;

  List<OmScanRecord> _history = const [];

  // ── batch (whole-class) scan state ──
  bool _batchMode = false;
  List<OmScanRecord> _batch = [];
  String? _batchProgress;
  List<OmScanRecord>? _batchDone;

  @override
  void initState() {
    super.initState();
    final seed = widget.initialKey;
    if (seed != null && seed.isNotEmpty) {
      _total = seed.length;
      _key = List<int>.of(seed);
    } else {
      _key = List<int>.filled(30, -1);
    }
    _titleCtrl = TextEditingController(text: widget.paperTitle);
    _subjectCtrl = TextEditingController(text: widget.initialSubject);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final h = await OmrStore.loadHistory();
    if (mounted) setState(() => _history = h);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subjectCtrl.dispose();
    super.dispose();
  }

  // ── photo ─────────────────────────────────────────────────────────

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final xfile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 4096,
      );
      if (xfile == null) return;
      final bytes = await xfile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      setState(() {
        _photoBytes = bytes;
        _photoImage = frame.image;
        _result = null;
        _graded = null;
        _overlayJpg = null;
      });
    } catch (e) {
      _snack('Could not load the image: $e');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Primary capture path: Google's ML Kit document scanner — live corner
  /// tracking, auto-capture and a crop step, all inside Google's own
  /// scanner UI. It hands back an already-rectified page, so the OMR read
  /// only has to find the four corner marks on a straight sheet (or none
  /// at all — a markless page aligns on its own edges).
  ///
  /// The scanner UI and models live in an installable Google Play
  /// services "module", so the phone is asked about it before launch and
  /// every failure mode is explained instead of crashing the native side:
  ///   ready            → launch the scanner
  ///   downloadable     → offer the one-time download
  ///   no scanner API   → Play services update dialog
  ///
  /// filter mode (not full): full mode additionally downloads Google's
  /// stain/finger-cleaning ML models from Play services — an extra
  /// failure point for clean printed OMR sheets that never use it.
  Future<void> _openCamera() async {
    if (_key.any((k) => k < 0)) {
      _snack('Complete the answer key first — or tap "Use saved paper".');
      return;
    }
    final (status, statusError) = await _scannerModuleStatus();
    if (status == -2) {
      // The scanner client could not even be constructed on this phone.
      // Show the installed Play services version and the exact error so
      // the cause is visible, not guessed.
      final v = await _gmsVersion();
      final version = v > 0 ? ' (version ${_fmtGmsVersion(v)})' : '';
      await _googleScannerUnavailable(
          'The Google scanner could not be initialized on this phone'
          '$version.',
          detail: statusError ?? 'The scanner client failed to construct.');
      return;
    }
    if (status == 0) {
      // The scanner module is not on this phone yet — offer the
      // one-time download before launching.
      final download = await _offerScannerModuleDownload();
      if (download != true) return; // in-app camera chosen / cancelled
    }
    try {
      final scanner = DocumentScanner(
        options: DocumentScannerOptions(
          documentFormats: {DocumentFormat.jpeg},
          mode: ScannerMode.filter,
          pageLimit: 1,
          isGalleryImport: false,
        ),
      );
      try {
        final result = await scanner.scanDocument();
        final images = result.images;
        if (images == null || images.isEmpty) return; // cancelled
        // The page comes back straight and cropped to the sheet's
        // edges — the scan may anchor on the page boundary when the
        // sheet has no (or too few) printed corner marks.
        await _loadAndScan(images.first, rectified: true);
      } finally {
        await scanner.close();
      }
    } catch (e) {
      if (!mounted) return;
      final why = e.toString().replaceFirst('PlatformException(', '');
      await _googleScannerUnavailable(
          'It could not start on this phone. Updating Google Play '
          'services usually fixes this.',
          detail: why);
    }
  }

  /// Google scanner module status on this phone: 1 = ready, 0 =
  /// downloadable from Play services, -1 = unknown (query failed — try
  /// the launch anyway and let the real error surface), -2 = the scanner
  /// client could not be constructed. The second value carries the
  /// underlying error text when there is one.
  Future<(int, String?)> _scannerModuleStatus() async {
    try {
      final m = await _appChannel.invokeMethod<dynamic>('scannerModuleStatus');
      if (m is Map) {
        return ((m['status'] as int?) ?? -1, m['error'] as String?);
      }
      return (-1, null);
    } catch (_) {
      return (-1, null);
    }
  }

  /// Installed Play services version code (0 = none installed).
  Future<int> _gmsVersion() async {
    try {
      final v = await _appChannel.invokeMethod<int>('gmsVersion');
      return v ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Best-effort human form of a Play services version code
  /// (e.g. 233119325 → "23.31.19 (build 325)").
  static String _fmtGmsVersion(int v) {
    final s = v.toString();
    if (s.length == 9) {
      return '${s.substring(0, 2)}.${s.substring(2, 4)}.${s.substring(4, 6)}'
          ' (build ${s.substring(6)})';
    }
    if (s.length == 8) {
      return '${s.substring(0, 2)}.${s.substring(2, 4)}.${s.substring(4, 8)}';
    }
    return s;
  }

  /// Asks to download the scanner module from Play services; returns
  /// true only when the module is ready afterwards (downloaded, or
  /// already there). Anything else means "do not launch the scanner".
  Future<bool?> _offerScannerModuleDownload() async {
    if (!mounted) return null;
    final proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Download scanner module'),
        content: const Text(
            'The Google scanner keeps its scanning module inside Google '
            'Play services, and this phone does not have it yet. '
            'Downloading it is a one-time step of a few megabytes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Use in-app camera'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Download'),
          ),
        ],
      ),
    );
    if (proceed != true) return proceed;
    if (!mounted) return null;
    // Busy dialog for the download; PopScope keeps the back button from
    // dismissing it mid-download.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: const AlertDialog(
          title: Text('Downloading scanner…'),
          content: Row(children: [
            SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Expanded(
                child:
                    Text('This can take a moment on slow connections.')),
          ]),
        ),
      ),
    );
    bool ok;
    String? failedWhy;
    try {
      final r = await _appChannel.invokeMethod<int>('installScannerModule');
      ok = r == 0 || r == 1; // already installed, or downloaded
    } catch (e) {
      ok = false;
      failedWhy = e.toString().replaceFirst('PlatformException(', '');
    }
    if (mounted) Navigator.of(context).pop(); // busy dialog
    if (!ok) {
      await _googleScannerUnavailable(
          'The scanner module could not be downloaded from Play services.',
          detail: failedWhy);
      return null;
    }
    return true;
  }

  /// Shown when the Google scanner cannot start: offers the Play Store
  /// fix, or the in-app camera. The fallback only happens when the user
  /// actually chose it — after "Open Play Store" the phone must be fixed,
  /// and the next Camera tap gets to try the Google scanner for real.
  Future<void> _googleScannerUnavailable(String reason,
      {String? detail}) async {
    if (!mounted) return;
    final useInApp = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Google scanner unavailable'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(reason),
            if (detail != null) ...[
              const SizedBox(height: 10),
              Text('Error: $detail',
                  style: const TextStyle(
                      fontSize: 10.5, height: 1.35, color: AppTheme.muted)),
            ],
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await _appChannel.invokeMethod('openPlayServices');
              } catch (_) {}
              if (context.mounted) Navigator.of(context).pop(false);
            },
            child: const Text('Open Play Store'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Use in-app camera'),
          ),
        ],
      ),
    );
    if (useInApp == true) {
      await _openLiveScan();
    }
  }

  static const MethodChannel _appChannel =
      MethodChannel('com.tutorsdesk.app/storage');

  /// Guided live-camera capture: the in-app preview shows an A4 guide,
  /// sheet/marks/sharp indicators and auto-captures a steady frame.
  Future<void> _openLiveScan() async {
    if (_key.any((k) => k < 0)) {
      _snack('Complete the answer key first — or tap "Use saved paper".');
      return;
    }
    final result = await Navigator.of(context).push<String>(
        MaterialPageRoute(
            builder: (_) => const OmLiveScanScreen()));
    if (result == null) return;
    if (result == 'system') {
      _pickPhoto(ImageSource.camera);
      return;
    }
    await _loadAndScan(result);
  }

  Future<void> _loadAndScan(String path, {bool rectified = false}) async {
    try {
      final bytes = await File(path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      if (!mounted) return;
      setState(() {
        _photoBytes = bytes;
        _photoImage = frame.image;
        _result = null;
        _graded = null;
        _overlayJpg = null;
      });
      _scan(rectified: rectified);
    } catch (e) {
      _snack('Could not load the photo: $e');
    }
  }

  /// Writes the received page, the result overlay and the geometry the
  /// reader used to <external storage>/tutors_desk_debug/ — so a bad
  /// read can be analyzed against the exact pixels the app saw.
  Future<void> _saveDebugImages() async {
    final bytes = _photoBytes;
    if (bytes == null) return;
    try {
      final dir = await _appChannel.invokeMethod<String>('externalStorageDir');
      final out = Directory('$dir/tutors_desk_debug')..createSync(recursive: true);
      final ts = DateTime.now().toIso8601String().replaceAll(':', '-');
      File('${out.path}/page_$ts.jpg').writeAsBytesSync(bytes);
      final overlay = _overlayJpg;
      if (overlay != null) {
        File('${out.path}/overlay_$ts.jpg').writeAsBytesSync(overlay);
      }
      final res = _result;
      final meta = StringBuffer()
        ..writeln('saved: $ts')
        ..writeln('page bytes: ${bytes.length}');
      if (res != null) {
        meta
          ..writeln('work: ${res.workWidth}x${res.workHeight}')
          ..writeln('scale: ${res.scale.toStringAsFixed(4)}')
          ..writeln('homography: ${res.homography.map((v) => v.toStringAsFixed(5)).join(', ')}')
          ..writeln('photo corners (TL,TR,BL,BR):');
        for (final c in res.photoCorners) {
          meta.writeln(
              '  (${c.point.dx.toStringAsFixed(1)}, ${c.point.dy.toStringAsFixed(1)}) mark=${c.fromMark}');
        }
        meta
          ..writeln('answers: ${res.answers}')
          ..writeln('set code: ${res.setCode} subject: ${res.subjectCode}');
      }
      File('${out.path}/meta_$ts.txt').writeAsStringSync(meta.toString());
      _snack('Debug images saved to ${out.path} — send those files over.');
    } catch (e) {
      _snack('Could not save debug images: $e');
    }
  }

  // ── key editor ────────────────────────────────────────────────────

  void _setTotal(int total) {
    setState(() {
      final old = _key;
      _total = total;
      _key = List<int>.filled(total, -1);
      for (var i = 0; i < total && i < old.length; i++) {
        _key[i] = old[i];
      }
      _result = null;
      _graded = null;
    });
  }

  int get _keyDone => _key.where((k) => k >= 0).length;

  // ── scan ──────────────────────────────────────────────────────────

  Future<void> _scan({bool rectified = false}) async {
    final photo = _photoBytes;
    if (photo == null) {
      _snack('Take a clear photo of the OMR sheet first.');
      return;
    }
    if (_key.any((k) => k < 0)) {
      _snack('${_total - _keyDone} answer key question(s) still empty.');
      return;
    }
    setState(() {
      _busy = true;
      _result = null;
      _graded = null;
    });
    try {
      final sw = Stopwatch()..start();
      final res = await _runOmScan(photo, rectified: rectified);
      if (!res.ok) {
        _snack(res.error ?? 'Scan failed');
        setState(() => _busy = false);
        return;
      }
      final graded = OMrScanner.grade(res, _key);
      _scanMs = sw.elapsedMilliseconds;
      final overlay = await _buildOverlay(res, graded);
      final rec = _recordOf(res, graded);
      await OmrStore.addRecord(rec);
      if (_batchMode) _batch.add(rec);
      if (!mounted) return;
      setState(() {
        _result = res;
        _graded = graded;
        _overlayJpg = overlay;
        _busy = false;
      });
      _loadHistory();
    } on OmDecodeException catch (e) {
      _snack('Image could not be read: ${e.detail}');
      setState(() => _busy = false);
    } catch (e) {
      _snack('Scan error: $e');
      setState(() => _busy = false);
    }
  }

  /// Runs the scan in a background isolate, and — if that isolate cannot
  /// decode the image (a quirk of some Android builds; the UI isolate has
  /// already decoded these exact bytes for the preview, so it can) —
  /// retries the same scan on the UI isolate. A second or two of jank
  /// in exchange for a correct result.
  Future<OmScanResult> _runOmScan(Uint8List photo,
      {required bool rectified}) async {
    try {
      return await compute(
          omrScanIsolateEntry, OmScanRequest(photo, _total, rectified));
    } on OmDecodeException {
      return OMrScanner.scan(photo, total: _total, rectified: rectified);
    }
  }

  OmScanRecord _recordOf(OmScanResult res, OmGraded g) => OmScanRecord(
        id: 's_${DateTime.now().microsecondsSinceEpoch}',
        date: DateTime.now(),
        paperTitle: _titleCtrl.text.trim(),
        subjectName: _subjectCtrl.text.trim(),
        roll: res.roll,
        registration: res.registration,
        subjectCode: res.subjectCode,
        setCode: res.setCode >= 0 ? _letters[res.setCode] : '—',
        total: _total,
        score: g.score,
        correct: g.correct,
        wrong: g.wrong,
        blank: g.blank,
        ambiguous: g.ambiguous,
        answers: res.answers,
        key: _key,
        durationMs: _scanMs ?? 0,
      );

  /// Draws the verdict on top of the photo (green = correct, red = wrong,
  /// grey = blank, orange = double-marked; the correct bubble gets a ring).
  Future<Uint8List?> _buildOverlay(OmScanResult res, OmGraded g) async {
    final photo = _photoBytes;
    final img = _photoImage;
    if (photo == null || img == null) return null;
    try {
      const maxSide = 1500.0;
      final s = maxSide / math.max(img.width, img.height);
      final w = (img.width * s).round();
      final h = (img.height * s).round();
      final k = (w / res.workWidth.toDouble()); // work → display
      final geo = OMrGeometry(_total);

      final rec = ui.PictureRecorder();
      final canvas = Canvas(rec);
      canvas.drawImage(img, Offset.zero,
          Paint()..filterQuality = FilterQuality.medium);

      final ringPaint = ui.Paint()
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 3.0;

      // Registration corners.
      ringPaint.color = const Color(0xB33D5AFE);
      for (final c in res.photoCorners) {
        canvas.drawCircle(c.point * k, 9, ringPaint);
      }

      for (var i = 0; i < _total; i++) {
        final status = g.status[i];
        final a = i < res.answers.length ? res.answers[i] : -1;
        Color verdict;
        switch (status) {
          case 0:
            verdict = const Color(0xFF12A150);
          case 1:
            verdict = const Color(0xFFE5484D);
          case 3:
            verdict = const Color(0xFFE08700);
          default:
            verdict = const Color(0xFF8A93A6);
        }
        ringPaint.color = verdict;
        if (a >= 0) {
          final p = OMrScanner.applyHomography(
              res.homography, geo.questionBubble(i + 1, a));
          canvas.drawCircle(p * k, OMrGeometry.bubbleRadiusPx * k + 4, ringPaint);
        } else {
          // blank / unread: draw a dim line across the row
          final p0 = OMrScanner.applyHomography(
              res.homography, geo.questionBubble(i + 1, 0));
          final p3 = OMrScanner.applyHomography(
              res.homography, geo.questionBubble(i + 1, 3));
          final dim = ui.Paint()
            ..style = ui.PaintingStyle.stroke
            ..strokeWidth = 2.0
            ..color = verdict.withOpacity(.65);
          canvas.drawLine(p0 * k, p3 * k, dim);
        }
        // Ring the correct option for wrong answers.
        if (status == 1 || (status == 2 && g.key[i] >= 0)) {
          final pc = OMrScanner.applyHomography(
              res.homography, geo.questionBubble(i + 1, g.key[i]));
          canvas.drawCircle(pc * k, OMrGeometry.bubbleRadiusPx * k + 7,
              ui.Paint()
                ..style = ui.PaintingStyle.stroke
                ..strokeWidth = 2
                ..color = Color(0x9912A150));
        }
      }

      final picture = rec.endRecording();
      final out = await picture.toImage(w, h);
      final data = await out.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> _printScorecard() async {
    final res = _result;
    final g = _graded;
    if (res == null || g == null) return;
    try {
      await PaperPdf.printOmScorecard(
        title: _titleCtrl.text.trim().isEmpty ? 'OMR Test' : _titleCtrl.text.trim(),
        subject: _subjectCtrl.text.trim(),
        roll: res.roll,
        registration: res.registration,
        subjectCode: res.subjectCode,
        setCode: res.setCode >= 0 ? _letters[res.setCode] : '—',
        total: _total,
        score: g.score,
        correct: g.correct,
        wrong: g.wrong,
        blank: g.blank,
        ambiguous: g.ambiguous,
        answers: res.answers,
        key: _key,
      );
    } catch (e) {
      _snack('Print error: $e');
    }
  }

  Future<void> _saveKey() async {
    await OmrStore.saveKeyDraft(OmKeyDraft(
      paperTitle: _titleCtrl.text.trim(),
      total: _total,
      key: _key,
      savedAt: DateTime.now(),
    ));
    _snack('Answer key saved.');
  }

  void _scanNext() {
    setState(() {
      _photoBytes = null;
      _photoImage = null;
      _result = null;
      _graded = null;
      _overlayJpg = null;
    });
  }

  // ═══════════════════ UI ═══════════════════

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final graded = _graded;
    return Scaffold(
      appBar: AppBar(
        title: const Text('OMR Scanner'),
        actions: [
          IconButton(
            tooltip: 'Analytics & leaderboard',
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const OMrAnalyticsScreen())),
            icon: const Icon(Icons.bar_chart_rounded),
          ),
          IconButton(
            tooltip: 'Key draft restore',
            onPressed: _restoreKeyDraft,
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
          children: [
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('1. OMR sheet photo',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  const Text(
                      'Keep the whole sheet in frame with all four corner marks visible, in even light.',
                      style: TextStyle(
                          fontSize: 11.5, color: AppTheme.muted)),
                  const SizedBox(height: 10),
                  if (_photoBytes == null)
                    Row(children: [
                      Expanded(
                          child: AppButton(
                              label: 'Camera',
                              icon: Icons.view_in_ar_rounded,
                              onPressed: _busy ? null : _openCamera)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: AppButton(
                              label: 'Gallery',
                              icon: Icons.photo_library_rounded,
                              outlined: true,
                              onPressed: () => _pickPhoto(ImageSource.gallery))),
                    ])
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        _photoBytes!,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  if (_photoBytes != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => _scanNext(),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Change / remove photo'),
                    ),
                    TextButton.icon(
                      onPressed: _busy ? null : _saveDebugImages,
                      icon: const Icon(Icons.debug_mode_rounded, size: 16),
                      label: const Text('Save debug images'),
                    ),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _batchDialog,
                      icon: const Icon(Icons.groups_rounded, size: 18),
                      label: const Text('Batch scan (whole class)'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Expanded(
                        child: Text('2. Paper & answer key',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800))),
                    Text('$_keyDone/$_total filled',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _keyDone == _total
                                ? AppTheme.success
                                : AppTheme.warning)),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: TextField(
                            controller: _titleCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Paper title'))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: TextField(
                            controller: _subjectCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Subject (optional)'))),
                  ]),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _pickSavedPaper,
                      icon: const Icon(Icons.bookmarks_rounded, size: 18),
                      label: const Text('Use saved paper (key auto-loads)'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Text('মোট প্রশ্ন',
                        style:
                            TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 12),
                    IconButton(
                        onPressed: _total > 5
                            ? () => _setTotal(_total - 5)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline)),
                    SizedBox(
                        width: 44,
                        child: Center(
                            child: Text('$_total',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800)))),
                    IconButton(
                        onPressed: _total < 100
                            ? () => _setTotal(_total + 5)
                            : null,
                        icon: const Icon(Icons.add_circle_outline)),
                    const Spacer(),
                    TextButton(
                        onPressed: _key.any((k) => k >= 0) ? _clearKey : null,
                        child: const Text('Clear all')),
                  ]),
                  const SizedBox(height: 6),
                  _keyGrid(),
                ],
              ),
            ),
            if (_photoBytes != null) ...[
              const SizedBox(height: 12),
              AppButton(
                label: 'Scan & grade this sheet',
                icon: Icons.qr_code_scanner_rounded,
                onPressed: _busy ? null : _scan,
              ),
            ],
            if (_batchMode) ...[
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(14),
                highlighted: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.groups_rounded,
                          color: AppTheme.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Batch scan on — ${_batch.length} sheet(s) graded. Scan the next student, then finish.',
                          style: const TextStyle(
                              fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                          child: AppButton(
                              label: 'Cancel batch',
                              icon: Icons.close_rounded,
                              outlined: true,
                              onPressed: _cancelBatch)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: AppButton(
                              label: 'Finish batch',
                              icon: Icons.flag_rounded,
                              onPressed: _batch.isEmpty ? null : _finishBatch)),
                    ]),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            if (_busy)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(children: [
                  const CircularProgressIndicator(color: AppTheme.primary),
                  const SizedBox(width: 14),
                  Text(_batchProgress ?? 'শিট পড়া হচ্ছে...'),
                ]),
              ),
            if (result != null && graded != null) ...[
              GlassCard(
                padding: const EdgeInsets.all(16),
                highlighted: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${graded.score} / ${graded.total}   (${graded.percent.toStringAsFixed(1)}%)',
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary)),
                    if ((_scanMs ?? 0) > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text('Scanned in ${(_scanMs! / 1000).toStringAsFixed(1)}s',
                            style: const TextStyle(
                                fontSize: 11.5, color: AppTheme.muted)),
                      ),
                    if (graded.ambiguous > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Double-marked questions are invalid and count as wrong.',
                          style: TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.warning,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      _chip('সঠিক ${graded.correct}', AppTheme.success),
                      _chip('ভুল ${graded.wrong}', AppTheme.danger),
                      _chip('খালি ${graded.blank}', AppTheme.muted),
                      if (graded.ambiguous > 0)
                        _chip('দ্বি-দাগ ${graded.ambiguous}', AppTheme.warning),
                      _chip('রোল ${result.roll}', AppTheme.primaryDark),
                      _chip('বিষয় কোড ${result.subjectCode}', AppTheme.primaryDark),
                      _chip(
                          'সেট ${result.setCode >= 0 ? _letters[result.setCode] : '—'}',
                          AppTheme.primaryDark),
                    ]),
                    const SizedBox(height: 12),
                    if (result.registration.contains('?'))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Registration no. unclear: ${result.registration}',
                          style: const TextStyle(
                              fontSize: 11.5, color: AppTheme.warning),
                        ),
                      ),
                    if (_overlayJpg != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            Image.memory(_overlayJpg!, fit: BoxFit.fitWidth),
                      ),
                    const SizedBox(height: 12),
                    _verdictGrid(graded),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(
                          child: AppButton(
                              label: 'Print scorecard',
                              icon: Icons.print_rounded,
                              onPressed: _printScorecard)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: AppButton(
                              label: 'Save key',
                              icon: Icons.save_rounded,
                              outlined: true,
                              onPressed: _saveKey)),
                    ]),
                    const SizedBox(height: 10),
                    SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                            onPressed: _scanNext,
                            icon: const Icon(Icons.person_rounded, size: 18),
                            label: const Text(
                                "Scan next student's OMR sheet"))),
                  ],
                ),
              ),
            ],
            // ── batch results ──
            if (_batchDone != null && _batchDone!.isNotEmpty) ...[
              const SizedBox(height: 14),
              GlassCard(
                padding: const EdgeInsets.all(16),
                highlighted: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Expanded(
                          child: Text(
                        'Batch results',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900),
                      )),
                      TextButton(
                          onPressed: _closeBatchResults,
                          child: const Text('Close')),
                    ]),
                    const SizedBox(height: 8),
                    _batchSummary(),
                    const SizedBox(height: 10),
                    for (var i = 0; i < _batchDone!.length; i++)
                      _batchRow(i, _batchDone![i]),
                    const SizedBox(height: 8),
                    const Text(
                      'Every result is also saved in the scan history below.',
                      style: TextStyle(fontSize: 11, color: AppTheme.muted),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            // History
            if (_history.isNotEmpty) ...[
              Row(children: [
                const Text('স্ক্যান হিস্টরি',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                const Spacer(),
                TextButton(
                    onPressed: () async {
                      for (final r in _history) {
                        await OmrStore.deleteRecord(r.id);
                      }
                      _loadHistory();
                    },
                    child: const Text('Clear all')),
              ]),
              for (final r in _history)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: r.score * 100 ~/
                          math.max(1, r.total) >=
                          50
                          ? AppTheme.success
                          : AppTheme.warning,
                      child: Text('${r.score}/${r.total}',
                          style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(r.roll.isEmpty ? 'রোল —' : 'রোল ${r.roll}',
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700)),
                          Text(
                              '${r.paperTitle.isEmpty ? '—' : r.paperTitle} • সেট ${r.setCode} • ${_dateStr(r.date)}',
                              style: const TextStyle(
                                  fontSize: 10.5, color: AppTheme.muted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ])),
                    IconButton(
                        onPressed: () => _showRecord(r),
                        icon: const Icon(Icons.visibility_rounded,
                            size: 18, color: AppTheme.primary)),
                    IconButton(
                        onPressed: () async {
                          await OmrStore.deleteRecord(r.id);
                          _loadHistory();
                        },
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppTheme.danger)),
                  ]),
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _dateStr(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(.5)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      );

  // ── batch results helpers ──

  double _pct(OmScanRecord r) => r.score * 100.0 / math.max(1, r.total);

  Widget _batchSummary() {
    final items = _batchDone!;
    final n = items.length;
    final avg = items.fold<double>(0, (s, r) => s + _pct(r)) / n;
    var best = items.first;
    var low = items.first;
    for (final r in items) {
      if (_pct(r) > _pct(best)) best = r;
      if (_pct(r) < _pct(low)) low = r;
    }
    return Wrap(spacing: 8, runSpacing: 8, children: [
      _chip('Sheets $n', AppTheme.primaryDark),
      _chip('Avg ${avg.toStringAsFixed(1)}%', AppTheme.primary),
      _chip('Best ${best.score}/${best.total}', AppTheme.success),
      _chip('Lowest ${low.score}/${low.total}', AppTheme.warning),
    ]);
  }

  Widget _batchRow(int i, OmScanRecord r) {
    final pass = _pct(r) >= 50;
    return InkWell(
      onTap: () => _showRecord(r),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(children: [
          SizedBox(
              width: 20,
              child: Text('${i + 1}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.muted))),
          const SizedBox(width: 8),
          Expanded(
              child: Text(r.roll.isEmpty ? 'Roll —' : 'Roll ${r.roll}',
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Text('${r.correct}✓',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.success)),
          const SizedBox(width: 8),
          Text('${r.wrong}✗',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.danger)),
          const SizedBox(width: 8),
          Text('${r.blank}·',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.muted)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color:
                  (pass ? AppTheme.success : AppTheme.warning).withOpacity(.14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: pass ? AppTheme.success : AppTheme.warning),
            ),
            child: Text('${r.score}/${r.total}',
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w800)),
          ),
        ]),
      ),
    );
  }

  Widget _keyGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 58,
        crossAxisSpacing: 10,
        mainAxisSpacing: 6,
      ),
      itemCount: _total,
      itemBuilder: (context, i) {
        final chosen = _key[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: chosen >= 0 ? AppTheme.primary.withOpacity(.08) : AppTheme.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: chosen >= 0 ? AppTheme.primary.withOpacity(.5) : AppTheme.border),
          ),
          child: Row(children: [
            SizedBox(
                width: 26,
                child: Text('${i + 1}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.muted))),
            const SizedBox(width: 4),
            for (var o = 0; o < 4; o++)
              Expanded(
                  child: GestureDetector(
                      onTap: () => setState(() => _key[i] = o),
                      child: Center(
                          child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: chosen == o
                                      ? AppTheme.primary
                                      : Colors.white,
                                  border: Border.all(
                                      color: chosen == o
                                          ? AppTheme.primary
                                          : AppTheme.border)),
                              child: Center(
                                  child: Text(_letters[o],
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: chosen == o
                                              ? Colors.white
                                              : AppTheme.textDark))))))),
          ]),
        );
      },
    );
  }

  void _clearKey() {
    setState(() => _key = List<int>.filled(_total, -1));
  }

  // ── saved-paper link (no manual key entry) ──────────────────────

  /// Opens the list of papers saved from the in-app builder and loads the
  /// chosen one's title, subject, total and full answer key.
  Future<void> _pickSavedPaper() async {
    final papers = await PaperLibrary.loadSavedPapers();
    if (papers.isEmpty) {
      _snack('No saved papers yet. Generate a paper and tap "Save paper".');
      return;
    }
    if (!mounted) return;
    final p = await showDialog<SavedPaper>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Use a saved paper'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (final sp in papers)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(sp.title,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                        '${sp.subject} • ${sp.total} questions'
                        '${sp.setCode != '—' ? ' • set ${sp.setCode}' : ''}'),
                    onTap: () => Navigator.pop(c, sp),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
        ],
      ),
    );
    if (p == null) return;
    setState(() {
      _total = p.total;
      _key = List<int>.of(p.key);
      _titleCtrl.text = p.title;
      _subjectCtrl.text = p.subject;
      _result = null;
      _graded = null;
      _overlayJpg = null;
    });
    _snack('Answer key loaded — ${p.total} questions, ready to scan.');
  }

  // ── batch (whole-class) scan ────────────────────────────────────

  /// Entry point for batch scanning: pick the source for the whole class.
  Future<void> _batchDialog() async {
    if (_key.any((k) => k < 0)) {
      _snack('Complete the answer key first — or tap "Use saved paper".');
      return;
    }
    final mode = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Batch scan'),
        content: const Text(
            'Every sheet is graded with the current answer key and saved to the scan history.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton.icon(
            icon: const Icon(Icons.photo_library_rounded, size: 18),
            label: const Text('Gallery (pick many)'),
            onPressed: () => Navigator.pop(c, 'gallery'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.photo_camera_rounded, size: 18),
            label: const Text('Camera (one by one)'),
            onPressed: () => Navigator.pop(c, 'camera'),
          ),
        ],
      ),
    );
    if (mode == 'gallery') {
      await _runBatchGallery();
    } else if (mode == 'camera' && mounted) {
      setState(() {
        _batchMode = true;
        _batch = [];
        _batchDone = null;
      });
      _snack('Batch mode on — scan each student, then tap Finish batch.');
    }
  }

  /// Gallery batch: pick many photos at once, scan + grade each in order.
  Future<void> _runBatchGallery() async {
    final picked =
        await ImagePicker().pickMultiImage(imageQuality: 90, maxWidth: 4096);
    if (picked.isEmpty || !mounted) return;
    final items = <OmScanRecord>[];
    setState(() {
      _busy = true;
      _batchProgress = 'Scanning 0/${picked.length}…';
    });
    var idx = 0;
    for (final f in picked) {
      idx++;
      if (!mounted) return;
      setState(() => _batchProgress = 'Scanning $idx/${picked.length}…');
      try {
        final bytes = await f.readAsBytes();
        OmScanResult res;
        try {
          res = await compute(
              omrScanIsolateEntry, OmScanRequest(bytes, _total));
        } on OmDecodeException {
          // Background isolate can't decode it — retry on the UI isolate.
          res = await OMrScanner.scan(bytes, total: _total);
        }
        if (!res.ok) continue; // unreadable sheet — skip, keep going
        final g = OMrScanner.grade(res, _key);
        final rec = _recordOf(res, g);
        items.add(rec);
        await OmrStore.addRecord(rec);
      } catch (_) {
        // Skip this sheet and continue the batch.
      }
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _batchProgress = null;
      _batchDone = items;
      _batchMode = false;
    });
    _loadHistory();
    if (items.isEmpty) {
      _snack('No sheet could be read. Check the photos and try again.');
    }
  }

  void _finishBatch() {
    setState(() {
      _batchDone = _batch;
      _batchMode = false;
      _batch = [];
    });
  }

  void _cancelBatch() {
    setState(() {
      _batchMode = false;
      _batch = [];
    });
  }

  void _closeBatchResults() {
    setState(() => _batchDone = null);
  }

  Widget _verdictGrid(OmGraded g) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        const Text('প্রশ্নভিত্তিক ফল',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Wrap(spacing: 10, runSpacing: 6, children: [
          for (var i = 0; i < g.total; i++)
            Text(
              '${i + 1}._choiceLetter(i, g)}${_glyph(g.status[i])}',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: g.status[i] == 0
                      ? AppTheme.success
                      : (g.status[i] == 1
                          ? AppTheme.danger
                          : AppTheme.muted)),
            ),
        ]),
      ]),
    );
  }

  String _choiceLetter(int i, OmGraded g) =>
      i < g.answers.length && g.answers[i] >= 0
          ? _letters[g.answers[i]]
          : (i < g.answers.length && g.answers[i] == -2 ? '?' : '—');

  String _glyph(int status) =>
      status == 0 ? '✓' : (status == 1 ? '✗' : (status == 2 ? '·' : '?'));

  Future<void> _showRecord(OmScanRecord r) async {
    if (!mounted) return;
    showDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: Text('রোল ${r.roll.isEmpty ? '—' : r.roll} • ${r.score}/${r.total}'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Wrap(spacing: 10, runSpacing: 6, children: [
                    for (var i = 0; i < r.key.length; i++)
                      Text(
                        '${i + 1}.${i < r.answers.length && r.answers[i] >= 0 ? _letters[r.answers[i]] : '—'}',
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: i < r.answers.length &&
                                    r.answers[i] == r.key[i]
                                ? AppTheme.success
                                : AppTheme.danger),
                      ),
                  ]),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(c), child: const Text('Close')),
              ],
            ));
  }

  Future<void> _restoreKeyDraft() async {
    final draft = await OmrStore.loadKeyDraft();
    if (draft == null || draft.key.isEmpty) {
      _snack('No saved key found.');
      return;
    }
    setState(() {
      _total = draft.total;
      _key = List<int>.filled(draft.total, -1);
      for (var i = 0; i < draft.total && i < draft.key.length; i++) {
        _key[i] = draft.key[i];
      }
      if (draft.paperTitle.isNotEmpty) _titleCtrl.text = draft.paperTitle;
    });
    _snack('Saved key restored (${draft.total} questions).');
  }
}
