import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../widgets/motion_policy.dart';
import 'package:printing/printing.dart';

import '../services/paper_library.dart';
import 'omr_scanner_screen.dart';

class SavedPaperScreen extends StatefulWidget {
  final PaperEntry entry;
  const SavedPaperScreen({super.key, required this.entry});
  @override
  State<SavedPaperScreen> createState() => _SavedPaperScreenState();
}

class _SavedPaperScreenState extends State<SavedPaperScreen> {
  List<Uint8List>? pages;
  String? error;
  int page = 0;
  bool busy = false;
  SavedPaper? saved;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      saved = await PaperLibrary.savedPaper(widget.entry.id);
      var images = <Uint8List>[];
      for (var i = 1;
          widget.entry.kind != 'pdf' && i <= widget.entry.pages;
          i++) {
        final bytes = await PaperLibrary.pageBytes(widget.entry.id, i);
        if (bytes == null)
          throw StateError(
            'A page is missing. Restore this paper from backup.',
          );
        images.add(bytes);
      }
      if (images.isEmpty) {
        final bytes = await PaperLibrary.pdfBytes(widget.entry.id);
        if (bytes != null) {
          images = [];
          await for (final page in Printing.raster(bytes, dpi: 120)) {
            images.add(await page.toPng());
          }
        }
      }
      if (images.isEmpty)
        throw StateError(
          'No printable pages are available. Restore this paper from backup or create it again.',
        );
      if (mounted) setState(() => pages = images);
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    }
  }

  Future<void> action(bool print) async {
    setState(() => busy = true);
    try {
      if (print)
        await PaperLibrary.printEntry(widget.entry);
      else
        await PaperLibrary.shareEntry(widget.entry);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not export: $e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.entry.title),
          actions: [
            IconButton(
              tooltip: 'Print',
              onPressed: busy || pages == null ? null : () => action(true),
              icon: const Icon(Icons.print_outlined),
            ),
            IconButton(
              tooltip: 'Share PDF',
              onPressed: busy || pages == null ? null : () => action(false),
              icon: const Icon(Icons.share_outlined),
            ),
          ],
        ),
        body: error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(error!),
                ),
              )
            : pages == null
                ? const Center(child: ActivityIndicator())
                : Column(
                    children: [
                      if (busy) const ActivityBar(),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Page ${page + 1} of ${pages!.length} · Pinch to zoom',
                        ),
                      ),
                      Expanded(
                        child: PageView.builder(
                          itemCount: pages!.length,
                          onPageChanged: (v) => setState(() => page = v),
                          itemBuilder: (_, i) => Padding(
                            padding: const EdgeInsets.all(16),
                            child: InteractiveViewer(
                              maxScale: 4,
                              child:
                                  Image.memory(pages![i], fit: BoxFit.contain),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
        bottomNavigationBar: saved?.key.isNotEmpty == true
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OMrScannerScreen(
                          initialKey: saved!.key,
                          paperTitle: widget.entry.title,
                          initialSubject: widget.entry.subject,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.document_scanner_outlined),
                    label: const Text('Scan answers for this paper'),
                  ),
                ),
              )
            : null,
      );
}
