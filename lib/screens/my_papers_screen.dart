import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../services/app_style.dart';
import '../services/my_paper_store.dart';
import '../theme/app_theme.dart';

/// Saved question papers ("My Papers") — print or share them again later.
class MyPapersScreen extends StatefulWidget {
  const MyPapersScreen({super.key});

  @override
  State<MyPapersScreen> createState() => _MyPapersScreenState();
}

class _MyPapersScreenState extends State<MyPapersScreen> {
  List<MyPaper> _papers = const [];
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final papers = await MyPaperStore.list();
    if (!mounted) return;
    setState(() {
      _papers = papers;
      _loading = false;
    });
  }

  Future<void> _print(MyPaper paper) async {
    final bytes = await MyPaperStore.bytesOf(paper.id);
    if (bytes == null) {
      _snack('Paper file missing — it may have been cleared.');
      return;
    }
    try {
      await Printing.layoutPdf(onLayout: (format) async => bytes);
    } catch (_) {
      try {
        await Printing.sharePdf(
            bytes: bytes, filename: '${_safe(paper.title)}.pdf');
      } catch (e) {
        _snack('Could not print: $e');
      }
    }
  }

  Future<void> _share(MyPaper paper) async {
    final bytes = await MyPaperStore.bytesOf(paper.id);
    if (bytes == null) {
      _snack('Paper file missing — it may have been cleared.');
      return;
    }
    try {
      await Printing.sharePdf(
          bytes: bytes, filename: '${_safe(paper.title)}.pdf');
    } catch (e) {
      _snack('Could not share: $e');
    }
  }

  Future<void> _delete(MyPaper paper) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete paper?'),
        content: Text('"${paper.title}" will be removed from My Papers.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await MyPaperStore.delete(paper.id);
    await _load();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  static String _safe(String s) =>
      s.replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_').substring(0, s.length < 30 ? s.length : 30);

  String _date(String iso) {
    if (iso.length < 10) return '';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso.substring(0, 10);
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${d.day}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    AppStyle.load();
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('My Papers',
            style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        scrolledUnderElevation: 0.4,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _papers.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.folder_open_rounded,
                            size: 54, color: AppTheme.border),
                        const SizedBox(height: 14),
                        const Text('No papers saved yet',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        const Text(
                          'Make any paper and press the Save button next to\nPDF / Print — it will appear here.',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: AppTheme.muted, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppTheme.primary,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _papers.length,
                    itemBuilder: (context, i) => _row(_papers[i]),
                  ),
                ),
    );
  }

  Widget _row(MyPaper paper) {
    final counts = <String>[
      if (paper.mcqs > 0) '${paper.mcqs} MCQ',
      if (paper.saqs > 0) '${paper.saqs} SAQ',
      if (paper.cqs > 0) '${paper.cqs} CQ',
    ].join(' • ');
    final sizeKb = paper.sizeBytes ~/ 1024;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.description_rounded,
                    size: 18, color: AppTheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(paper.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (paper.subject.isNotEmpty) paper.subject,
                        if (counts.isNotEmpty) counts,
                        _date(paper.dateIso),
                        '${sizeKb} KB',
                      ].join('  •  '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppTheme.muted, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _miniButton('Print', Icons.print_rounded,
                    () => _busy ? null : () async {
                  setState(() => _busy = true);
                  await _print(paper);
                  if (mounted) setState(() => _busy = false);
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _miniButton('Share', Icons.ios_share_rounded,
                    () => _busy ? null : () async {
                  setState(() => _busy = true);
                  await _share(paper);
                  if (mounted) setState(() => _busy = false);
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _miniButton(
                    'Delete',
                    Icons.delete_outline_rounded,
                    () => _busy ? null : () async {
                  setState(() => _busy = true);
                  await _delete(paper);
                  if (mounted) setState(() => _busy = false);
                },
                    danger: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniButton(
      String label, IconData icon, VoidCallback? Function() onPressed,
      {bool danger = false}) {
    final color = danger ? AppTheme.danger : AppTheme.primary;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onPressed(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: color.withOpacity(danger ? .06 : .08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: color)),
          ],
        ),
      ),
    );
  }
}
