import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/subject_info.dart';
import '../services/paper_library.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'omr_scanner_screen.dart';

/// Question Papers — two lists:
///  • Saved: papers saved from the in-app builder (with their answer keys) —
///    these feed the OMR scanner directly.
///  • Added: the tutor's own past/model papers uploaded as photos or PDFs
///    (view, print, share).
class PapersLibraryScreen extends StatefulWidget {
  const PapersLibraryScreen({super.key});

  @override
  State<PapersLibraryScreen> createState() => _PapersLibraryScreenState();
}

class _PapersLibraryScreenState extends State<PapersLibraryScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabs;
  List<PaperEntry> _entries = const [];
  List<SavedPaper> _saved = const [];
  bool _loading = true;
  bool _busyAdd = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabs = TabController(length: 2, vsync: this);
    _reload();
    _maybeNudgeAutoSave();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabs.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Coming back from the one-time permission settings page?
    if (state == AppLifecycleState.resumed && _awaitingPermission) {
      _awaitingPermission = false;
      PaperBackup.permissionGranted().then((granted) {
        if (granted && mounted) {
          _snack('Done — an extra copy now also lives in '
              'Download/TutorsDesk and survives uninstalling the app.');
        }
      });
    }
  }

  Future<void> _reload() async {
    final all = await PaperLibrary.loadEntries();
    final saved = await PaperLibrary.loadSavedPapers();
    if (mounted) {
      setState(() {
        // The Added tab lists photo/PDF uploads only; saved papers live in
        // their own tab (with answer keys) and feed the OMR scanner.
        _entries = all.where((e) => e.kind != 'saved').toList();
        _saved = saved;
        _loading = false;
      });
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Auto-save (one-time nudge) ──────────────────────────────────
  // Android deletes the app's private folder on uninstall. With the one-time
  // "All files access" permission the library is kept automatically in the
  // shared Download folder and restored on the next start — nothing manual.

  bool _awaitingPermission = false;

  Future<void> _maybeNudgeAutoSave() async {
    try {
      if (await PaperBackup.permissionGranted()) return;
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('autosave_nudged') ?? false) return;
      await prefs.setBool('autosave_nudged', true);
      if (!mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Keep your papers safe?'),
          content: const Text(
            'When the app is uninstalled, Android deletes your saved papers. '
            'Allow the app to keep an automatic copy in the Download folder? '
            'One-time permission — nothing to do afterwards.',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Allow'),
            ),
          ],
        ),
      );
      if (ok == true) {
        _awaitingPermission = true;
        await PaperBackup.requestPermission();
      }
    } catch (_) {
      // Never let the nudge break the screen.
    }
  }

  // ── Saved tab ───────────────────────────────────────────────────

  /// Opens the OMR scanner with this paper's answer key pre-loaded — the
  /// teacher does not have to fill the key manually.
  Future<void> _scanWith(SavedPaper p) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OMrScannerScreen(
          initialKey: p.key,
          paperTitle: p.title,
          initialSubject: p.subject,
        ),
      ),
    );
  }

  Future<void> _showKey(SavedPaper p) async {
    const letters = ['ক', 'খ', 'গ', 'ঘ'];
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Answer key — ${p.title}',
            overflow: TextOverflow.ellipsis),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(spacing: 12, runSpacing: 6, children: [
                  for (var i = 0; i < p.key.length; i++)
                    Text('${i + 1}. ${letters[p.key[i] % 4]}',
                        style: const TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w700)),
                ]),
                if (p.questions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 16),
                  for (var i = 0;
                      i < p.questions.length && i < p.key.length;
                      i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text('${i + 1}. ${p.questions[i].text}',
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _deleteSaved(SavedPaper p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete this paper?'),
        content: Text('"${p.title}" and its answer key will be removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    await PaperLibrary.deleteEntry(p.id);
    _reload();
  }

  Widget _savedCard(SavedPaper p) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.primary.withOpacity(.35)),
          ),
          child: const Icon(Icons.key_rounded,
              color: AppTheme.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Wrap(spacing: 6, runSpacing: 4, children: [
            _pill(p.subject),
            _pill('${p.total} questions'),
            if (p.setCode.isNotEmpty && p.setCode != '—')
              _pill('Set ${p.setCode}'),
            if (p.subjectCode.isNotEmpty) _pill(p.subjectCode),
          ]),
          const SizedBox(height: 4),
          Text(_date(p.createdAt),
              style: const TextStyle(fontSize: 10.5, color: AppTheme.muted)),
        ])),
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _iconBtn(Icons.qr_code_scanner_rounded, 'Scan OMR',
                  () => _scanWith(p)),
              _iconBtn(Icons.key_rounded, 'View answers', () => _showKey(p)),
              _iconBtn(Icons.delete_outline_rounded, 'Delete',
                  () => _deleteSaved(p), color: AppTheme.danger),
            ]),
      ]),
    );
  }

  Widget _savedTab() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primary));
    }
    if (_saved.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.bookmarks_rounded,
                size: 54, color: AppTheme.primary),
            const SizedBox(height: 14),
            const Text('No saved papers yet',
                style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
              'Generate a paper (Chapter-wise / Full Model Test / Custom)\n'
              'and tap "Save paper" — its answer key is kept here so the\n'
              'OMR Scanner grades sheets without retyping the key.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 12.5, color: AppTheme.muted, height: 1.5),
            ),
          ]),
        ),
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
      itemCount: _saved.length,
      itemBuilder: (context, i) => _savedCard(_saved[i]),
    );
  }

  // ── Added tab (photos / PDFs — unchanged behaviour) ─────────────

  Future<void> _addDialog() async {
    final titleCtrl = TextEditingController();
    final otherSubjectCtrl = TextEditingController();
    String subject = allSubjects.first.bengaliName;
    final yearCtrl = TextEditingController(text: '2026');
    const other = 'অন্যান্য';
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setDialog) => AlertDialog(
          title: const Text('নতুন প্রশ্নপত্র যোগ করো'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'শিরোনাম (যেমন: মডেল পরীক্ষা ১ — গণিত)'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: subject,
                  decoration: const InputDecoration(labelText: 'বিষয়'),
                  items: [...allSubjects.map((s) => s.bengaliName), other]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setDialog(() => subject = v ?? subject),
                ),
                if (subject == other) ...[
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: otherSubjectCtrl,
                    decoration: const InputDecoration(labelText: 'বিষয়ের নাম'),
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: yearCtrl,
                  decoration: const InputDecoration(labelText: 'বছর'),
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
            FilledButton.icon(
              icon: const Icon(Icons.photo_camera_rounded, size: 18),
              label: const Text('From photos'),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(c);
                await _addFromPhotos(
                  title: titleCtrl.text.trim(),
                  subject: subject == other
                      ? (otherSubjectCtrl.text.trim().isEmpty
                          ? 'অন্যান্য'
                          : otherSubjectCtrl.text.trim())
                      : subject,
                  year: yearCtrl.text.trim(),
                );
              },
            ),
            FilledButton.icon(
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
              label: const Text('From PDF'),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(c);
                await _addFromPdf(
                  title: titleCtrl.text.trim(),
                  subject: subject == other
                      ? (otherSubjectCtrl.text.trim().isEmpty
                          ? 'অন্যান্য'
                          : otherSubjectCtrl.text.trim())
                      : subject,
                  year: yearCtrl.text.trim(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addFromPhotos({
    required String title,
    required String subject,
    required String year,
  }) async {
    try {
      setState(() => _busyAdd = true);
      final picked =
          await ImagePicker().pickMultiImage(imageQuality: 90, maxWidth: 4096);
      if (picked.isEmpty) return;
      final bytes = <Uint8List>[];
      for (final f in picked) {
        bytes.add(await f.readAsBytes());
      }
      await PaperLibrary.addFromImages(
          title: title, subject: subject, year: year, pages: bytes);
      _snack('${bytes.length}-page paper added.');
      _tabs.animateTo(1);
      await _reload();
    } catch (e) {
      _snack('Could not add: $e');
    } finally {
      if (mounted) setState(() => _busyAdd = false);
    }
  }

  Future<void> _addFromPdf({
    required String title,
    required String subject,
    required String year,
  }) async {
    try {
      setState(() => _busyAdd = true);
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null || result.files.isEmpty) return;
      final path = result.files.single.path;
      if (path == null) {
        _snack('PDF path not found.');
        return;
      }
      final bytes = await File(path).readAsBytes();
      await PaperLibrary.addFromPdf(
          title: title, subject: subject, year: year, bytes: bytes);
      _snack('PDF paper added.');
      _tabs.animateTo(1);
      await _reload();
    } catch (e) {
      _snack('Could not add: $e');
    } finally {
      if (mounted) setState(() => _busyAdd = false);
    }
  }

  Future<void> _view(PaperEntry e) async {
    if (e.kind == 'pdf') {
      final bytes = await PaperLibrary.pdfBytes(e.id);
      if (bytes == null) {
        _snack('PDF not found.');
        return;
      }
      if (!mounted) return;
      // printing 5.x-এর প্রিভিউ ডায়ালগই PDF ভিউয়ার হিসেবে কাজ করে —
      // zoom/pan করা যায়, সেখান থেকেই ছাপানোও যায়।
      await Printing.layoutPdf(onLayout: (format) async => bytes);
      return;
    }
    final thumbs = <Uint8List>[];
    for (var i = 1; i <= e.pages; i++) {
      final b = await PaperLibrary.pageBytes(e.id, i);
      if (b != null) thumbs.add(b);
    }
    if (thumbs.isEmpty) {
      _snack('Pages not found.');
      return;
    }
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => _PaperViewer(title: e.title, pages: thumbs)),
    );
  }

  Future<void> _print(PaperEntry e) async {
    try {
      await PaperLibrary.printEntry(e);
    } catch (err) {
      _snack('Could not print: $err');
    }
  }

  Future<void> _share(PaperEntry e) async {
    try {
      await PaperLibrary.shareEntry(e);
    } catch (err) {
      _snack('Could not share: $err');
    }
  }

  Future<void> _delete(PaperEntry e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('মুছে ফেলা হবে?'),
        content: Text('"${e.title}" will be permanently deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    await PaperLibrary.deleteEntry(e.id);
    _reload();
  }

  // ── UI ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Question Papers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busyAdd ? null : _addDialog,
        icon: const Icon(Icons.add_photo_alternate_rounded),
        label: const Text('Add'),
      ),
      body: SafeArea(
        child: Column(children: [
          TabBar(
            controller: _tabs,
            tabs: const [
              Tab(text: 'Saved'),
              Tab(text: 'Added'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _savedTab(),
                RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: _reload,
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primary))
                      : _entries.isEmpty
                          ? _empty()
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics()),
                              padding:
                                  const EdgeInsets.fromLTRB(16, 10, 16, 90),
                              itemCount: _entries.length,
                              itemBuilder: (context, i) => _card(_entries[i]),
                            ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.photo_library_rounded,
              size: 54, color: AppTheme.primary),
          const SizedBox(height: 14),
          const Text('এখনো কোনো প্রশ্নপত্র যোগ হয়নি',
              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text(
            'Add your own board/model papers as photos or PDF —\n'
            'view, print or share them inside the app.',
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 12.5, color: AppTheme.muted, height: 1.5),
          ),
        ]),
      ),
    );
  }

  Widget _card(PaperEntry e) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        SizedBox(
          width: 64,
          height: 82,
          child: _thumb(e),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(e.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Wrap(spacing: 6, runSpacing: 4, children: [
            _pill(e.subject),
            if (e.year.isNotEmpty) _pill(e.year),
            _pill('${e.kindLabel} • ${e.pages} পৃষ্ঠা'),
          ]),
          const SizedBox(height: 4),
          Text(_date(e.createdAt),
              style: const TextStyle(fontSize: 10.5, color: AppTheme.muted)),
        ])),
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _iconBtn(Icons.visibility_rounded, 'View', () => _view(e)),
              _iconBtn(Icons.print_rounded, 'Print', () => _print(e)),
              _iconBtn(Icons.share_rounded, 'Share', () => _share(e)),
              _iconBtn(Icons.delete_outline_rounded, 'Delete', () => _delete(e),
                  color: AppTheme.danger),
            ]),
      ]),
    );
  }

  Widget _thumb(PaperEntry e) {
    return FutureBuilder<Uint8List?>(
      future: PaperLibrary.thumbBytes(e.id),
      builder: (context, snap) {
        final bytes = snap.data;
        if (bytes != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(bytes, fit: BoxFit.cover),
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceAlt,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.border),
          ),
          child: const Icon(Icons.picture_as_pdf_rounded,
              color: AppTheme.primary, size: 26),
        );
      },
    );
  }

  Widget _pill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primary.withOpacity(.25)),
        ),
        child: Text(text,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryDark)),
      );

  Widget _iconBtn(IconData icon, String label, VoidCallback onTap,
          {Color? color}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Tooltip(
          message: label,
          child: IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(icon, size: 19, color: color ?? AppTheme.primary),
            onPressed: onTap,
          ),
        ),
      );

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

/// Full-screen page pager for photo papers.
class _PaperViewer extends StatefulWidget {
  final String title;
  final List<Uint8List> pages;
  const _PaperViewer({required this.title, required this.pages});

  @override
  State<_PaperViewer> createState() => _PaperViewerState();
}

class _PaperViewerState extends State<_PaperViewer> {
  final PageController _ctrl = PageController();
  int _page = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, overflow: TextOverflow.ellipsis),
        actions: [
          Text('${_page + 1}/${widget.pages.length}',
              style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
        ],
      ),
      body: PageView.builder(
        controller: _ctrl,
        itemCount: widget.pages.length,
        onPageChanged: (i) => setState(() => _page = i),
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.all(8),
          child: Image.memory(widget.pages[i], fit: BoxFit.contain),
        ),
      ),
    );
  }
}
