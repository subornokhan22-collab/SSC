import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ai/teacher_attachment.dart';

/// Session-only attachments: no upload on selection, no file persistence.
class TeacherAttachmentPanel extends StatefulWidget {
  final List<TeacherAttachment> files;
  final bool enabled;
  final ValueChanged<List<TeacherAttachment>> onChanged;
  final ValueChanged<bool> onPicking;
  const TeacherAttachmentPanel(
      {super.key,
      required this.files,
      required this.onChanged,
      required this.onPicking,
      this.enabled = true});
  @override
  State<TeacherAttachmentPanel> createState() => _TeacherAttachmentPanelState();
}

class _TeacherAttachmentPanelState extends State<TeacherAttachmentPanel> {
  bool picking = false;
  String? error;
  Future<void> pick(String source) async {
    if (picking || !widget.enabled) return;
    setState(() {
      picking = true;
      error = null;
    });
    widget.onPicking(true);
    try {
      late final TeacherAttachment attachment;
      if (source == 'pdf') {
        final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf'],
            withData: false,
            withReadStream: true);
        final file = result?.files.single;
        if (file == null) return;
        if (file.size > TeacherAttachment.maxBytes)
          throw const FormatException('Choose a PDF smaller than 3 MB.');
        final stream = file.readStream ??
            (file.path == null ? null : File(file.path!).openRead());
        if (stream == null)
          throw const FormatException(
              'Could not read this PDF. Save it locally and select it again.');
        final bytes = await readTeacherFile(stream, TeacherAttachment.maxBytes);
        attachment = TeacherAttachment(
            name: file.name, mimeType: 'application/pdf', bytes: bytes);
      } else {
        final file = await ImagePicker().pickImage(
            source:
                source == 'camera' ? ImageSource.camera : ImageSource.gallery,
            maxWidth: 1600,
            maxHeight: 1600,
            imageQuality: 85);
        if (file == null) return;
        final bytes = await readTeacherFile(
            file.openRead(), TeacherAttachment.maxOriginalImageBytes);
        attachment = await TeacherAttachment.photo(file.name, bytes);
      }
      if (!mounted || !widget.enabled) return;
      final files = [...widget.files, attachment];
      TeacherAttachment.validate(files);
      widget.onChanged(files);
    } on FormatException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted)
        setState(() => error =
            'Could not open the attachment. Check camera/file permissions or choose another file.');
    } finally {
      if (mounted) {
        setState(() => picking = false);
        widget.onPicking(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Reference photos / PDFs (optional)',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const Text(
            'Up to 3 files · 3 MB combined after photo resizing. Files are used only when you run a tool. Use clear, short PDFs without passwords.'),
        Wrap(spacing: 8, children: [
          for (final source in ['camera', 'gallery', 'pdf'])
            OutlinedButton.icon(
              onPressed: !widget.enabled ||
                      picking ||
                      widget.files.length >= TeacherAttachment.maxCount
                  ? null
                  : () => pick(source),
              icon: Icon(source == 'camera'
                  ? Icons.camera_alt_outlined
                  : source == 'pdf'
                      ? Icons.picture_as_pdf_outlined
                      : Icons.photo_library_outlined),
              label: Text(source == 'camera'
                  ? 'Camera'
                  : source == 'pdf'
                      ? 'PDF'
                      : 'Photos'),
            ),
        ]),
        if (picking) const LinearProgressIndicator(),
        if (error != null)
          Text(error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
        for (var i = 0; i < widget.files.length; i++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: widget.files[i].isPdf
                ? const Icon(Icons.picture_as_pdf_outlined)
                : Image.memory(widget.files[i].bytes,
                    width: 48, height: 48, fit: BoxFit.cover, cacheWidth: 160),
            title: Text(widget.files[i].name,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text(
                '${(widget.files[i].bytes.length / 1024).ceil()} KB · ${widget.files[i].isPdf ? 'PDF reference (no page preview)' : 'Tap to preview photo'}'),
            onTap: widget.files[i].isPdf
                ? null
                : () => showDialog<void>(
                    context: context,
                    builder: (c) => Dialog(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                              Flexible(
                                  child: InteractiveViewer(
                                      child:
                                          Image.memory(widget.files[i].bytes))),
                              TextButton(
                                  onPressed: () => Navigator.pop(c),
                                  child: const Text('Close preview')),
                            ]))),
            trailing: IconButton(
                tooltip: 'Remove attachment ${i + 1}',
                onPressed: !widget.enabled || picking
                    ? null
                    : () => widget.onChanged([...widget.files]..removeAt(i)),
                icon: const Icon(Icons.close)),
          ),
      ]);
}
