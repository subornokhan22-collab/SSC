import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/omr/omr_geometry.dart';
import '../services/omr/omr_scanner.dart';
import '../services/omr/omr_store.dart';
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

  const OMrScannerScreen({
    super.key,
    this.initialKey,
    this.paperTitle = '',
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

  List<OmScanRecord> _history = const [];

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
    _subjectCtrl = TextEditingController();
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
      _snack('ছবি লোড করা যায়নি: $e');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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

  Future<void> _scan() async {
    final photo = _photoBytes;
    if (photo == null) {
      _snack('আগে OMR শিটের একটা পরিষ্কার ফটো নাও।');
      return;
    }
    if (_key.any((k) => k < 0)) {
      _snack('Answer key-এর ${_total - _keyDone}টি প্রশ্ন এখনো বোঝা হয়নি।');
      return;
    }
    setState(() {
      _busy = true;
      _result = null;
      _graded = null;
    });
    try {
      final res = await OMrScanner.scan(photo, total: _total);
      if (!res.ok) {
        _snack(res.error ?? 'Scan failed');
        setState(() => _busy = false);
        return;
      }
      final graded = OMrScanner.grade(res, _key);
      final overlay = await _buildOverlay(res, graded);
      await OmrStore.addRecord(_recordOf(res, graded));
      if (!mounted) return;
      setState(() {
        _result = res;
        _graded = graded;
        _overlayJpg = overlay;
        _busy = false;
      });
      _loadHistory();
    } catch (e) {
      _snack('Scan error: $e');
      setState(() => _busy = false);
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
              const ui.Paint()
                ..style = ui.PaintingStyle.stroke
                ..strokeWidth = 2
                ..color = Color(0x9912A150));
        }
      }

      final picture = rec.endRecording();
      final out = await picture.toImage(w, h);
      final data =
          await out.toByteData(format: ui.ImageByteFormat.jpg, quality: 82);
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
    _snack('Answer key সংরক্ষিত হয়েছে।');
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
                  const Text('১। OMR শিটের ফটো',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(
                      'পুরো শিট ফ্রেমের ভেতরে, চার কোণের কালো চিহ্নসহ, সমান আলোয়।',
                      style: const TextStyle(
                          fontSize: 11.5, color: AppTheme.muted)),
                  const SizedBox(height: 10),
                  if (_photoBytes == null)
                    Row(children: [
                      Expanded(
                          child: AppButton(
                              label: '📷 Camera',
                              icon: Icons.photo_camera_rounded,
                              onPressed:
                                  () => _pickPhoto(ImageSource.camera))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: AppButton(
                              label: '🖼️ Gallery',
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
                      label: const Text('ছবি বদলাও / মুছুন'),
                    ),
                  ],
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
                        child: Text('২। Paper & Answer key',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800))),
                    Text('$_keyDone/$_total বোঝা হয়েছে',
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
                        child: const Text('সব মুছুন')),
                  ]),
                  const SizedBox(height: 6),
                  _keyGrid(),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Row(children: [
                  CircularProgressIndicator(color: AppTheme.primary),
                  SizedBox(width: 14),
                  Text('শিট পড়া হচ্ছে...'),
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
                          'রেজিস্ট্রেশন নং অস্পষ্ট: ${result.registration}',
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
                              label: 'স্কোর কার্ড ছাপাও',
                              icon: Icons.print_rounded,
                              onPressed: _printScorecard)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: AppButton(
                              label: 'Key সংরক্ষণ',
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
                            label:
                                const Text('পরবর্তী পরীক্ষার্থীর OMR স্ক্যান করো'))),
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
                    child: const Text('সব মুছুন')),
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
                    onPressed: () => Navigator.pop(c), child: const Text('বন্ধ করো')),
              ],
            ));
  }

  Future<void> _restoreKeyDraft() async {
    final draft = await OmrStore.loadKeyDraft();
    if (draft == null || draft.key.isEmpty) {
      _snack('কোনো সংরক্ষিত key পাওয়া যায়নি।');
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
    _snack('সংরক্ষিত key ফেরত আনা হয়েছে (${draft.total}টি প্রশ্ন)।');
  }
}
