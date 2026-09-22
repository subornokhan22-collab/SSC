import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart' as md;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/gemini_client.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/glass_card.dart';
import '../widgets/problem_dialog.dart';

/// MiMi — the in-app AI assistant.
///
/// Answers and solves questions in Bangladesh Education Board style using
/// the tutor's free Gemini API key (stored on the device). Accepts text
/// plus attachments: photos (with in-app crop), audio and PDFs — each with
/// a size limit so the model can actually work with them.
class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

// ── attachment limits (kept small so Gemini can read them reliably) ──
const int kPhotoMaxBytes = 15 * 1024 * 1024; // before crop/resize
const int kAudioMaxBytes = 5 * 1024 * 1024;
const int kPdfMaxBytes = 10 * 1024 * 1024;
const int kTextMaxChars = 4000;
const int kMaxAttachments = 3;

class _AttMeta {
  final String kind; // 'photo' | 'audio' | 'pdf'
  final String label;
  final String size;
  const _AttMeta(this.kind, this.label, this.size);
}

class _ChatMsg {
  final bool isUser;
  final String text;
  final List<_AttMeta> atts;
  const _ChatMsg({required this.isUser, required this.text, this.atts = const []});
}

class _Pending {
  final String kind;
  final String label;
  final String mime;
  final Uint8List bytes;
  const _Pending(this.kind, this.label, this.mime, this.bytes);
}

class _AiTutorScreenState extends State<AiTutorScreen>
    with SingleTickerProviderStateMixin {
  static const _keyPref = 'gemini_api_key';
  static const _chatPref = 'boktul_chat_v1';

  String? _key;
  bool _ready = false;
  final List<_ChatMsg> _msgs = [];
  final List<_Pending> _pending = [];
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();

  bool _busy = false;
  String? _streaming;
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
            vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
    _load();
  }

  @override
  void dispose() {
    _blink.dispose();
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_chatPref);
    if (raw != null) {
      try {
        final j = jsonDecode(raw);
        if (j is List) {
          for (final m in j) {
            if (m is Map) {
              _msgs.add(_ChatMsg(
                isUser: m['r'] == 1,
                text: (m['t'] ?? '').toString(),
                atts: [
                  for (final a in (m['a'] is List ? m['a'] : const []))
                    _AttMeta('photo', a.toString(), ''),
                ].where((a) => a.label.isNotEmpty).toList(),
              ));
            }
          }
        }
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _key = (p.getString(_keyPref) ?? '').trim().isEmpty
          ? null
          : (p.getString(_keyPref) ?? '').trim();
      _ready = true;
    });
  }

  Future<void> _problem(String title, String message, {String? detail}) =>
      showProblemDialog(context, title: title, message: message, detail: detail);

  // ── key ──────────────────────────────────────────────────────────

  /// Re-reads the key after the setup card saves it.
  Future<void> _reloadKey() async {
    final p = await SharedPreferences.getInstance();
    final k = (p.getString(_keyPref) ?? '').trim();
    if (!mounted) return;
    setState(() => _key = k.isEmpty ? null : k);
  }

  // ── attachments ──────────────────────────────────────────────────

  Future<void> _openAttachSheet() async {
    if (_pending.length >= kMaxAttachments) {
      await _problem('Attachment limit',
          'Up to $kMaxAttachments attachments per question (photo, audio or PDF).');
      return;
    }
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Attach to your question',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
          ),
          _attachOption(c, Icons.photo_library_rounded, 'Photo',
              'From gallery — with crop (max 15 MB)', 'photo', AppTheme.primary),
          _attachOption(c, Icons.photo_camera_rounded, 'Camera',
              'Take a photo of the question — with crop', 'camera', AppTheme.success),
          _attachOption(c, Icons.record_voice_over_rounded, 'Audio',
              'Voice note / mp3 / wav / ogg / flac (max 5 MB)', 'audio', AppTheme.secondary),
          _attachOption(c, Icons.picture_as_pdf_rounded, 'PDF',
              'A question paper or book page (max 10 MB)', 'pdf', AppTheme.accent),
          const SizedBox(height: 8),
        ]),
      ),
    );
    if (choice == 'photo') await _pickPhoto();
    if (choice == 'camera') await _pickPhoto(fromCamera: true);
    if (choice == 'audio') await _pickAudio();
    if (choice == 'pdf') await _pickPdf();
  }

  Widget _attachOption(BuildContext c, IconData icon, String title,
      String sub, String kind, Color color) {
    return InkWell(
      onTap: () => Navigator.pop(c, kind),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(.12),
              border: Border.all(color: color.withOpacity(.4)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(sub,
                  style: const TextStyle(fontSize: 11.5, color: AppTheme.muted)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
        ]),
      ),
    );
  }

  Future<void> _pickPhoto({bool fromCamera = false}) async {
    try {
      final xfile = await ImagePicker().pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 95,
        maxWidth: 4096,
      );
      if (xfile == null) return;
      final bytes = await xfile.readAsBytes();
      if (bytes.length > kPhotoMaxBytes) {
        await _problem('Photo too large',
            'This photo is ${_fmtBytes(bytes.length)}. The limit is 15 MB so MiMi can read it reliably.');
        return;
      }
      await _attachPhoto(bytes);
    } catch (e) {
      await _problem('Could not open the photo', '$e');
    }
  }

  /// Opens the native cropper. The photo is copied into the app's own
  /// temp folder first: the gallery usually returns a content:// URI,
  /// which the native cropper cannot open (that used to crash the app).
  Future<void> _attachPhoto(Uint8List bytes) async {
    File? tmp;
    try {
      final dir = await getTemporaryDirectory();
      tmp = File(
          '${dir.path}/mimi_photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tmp.writeAsBytes(bytes);
      final CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: tmp.path,
        maxWidth: 1600,
        maxHeight: 1600,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 88,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop the question',
            toolbarColor: AppTheme.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            aspectRatioPresets: const [CropAspectRatioPreset.square],
          ),
        ],
      );
      if (!mounted) return;
      final att = cropped != null
          ? await cropped.readAsBytes()
          : await _resizeJpeg(bytes, 1600, 82);
      setState(() => _pending
          .add(_Pending('photo', 'Photo', 'image/jpeg', att)));
    } finally {
      try {
        await tmp?.delete();
      } catch (_) {}
    }
  }

  Future<void> _pickAudio() async {
    try {
      final res = await FilePicker.platform.pickFiles(
          allowedExtensions: ['mp3', 'wav', 'ogg', 'flac', 'aiff', 'aif']);
      final f = res?.files.single;
      if (f == null || f.path == null) return;
      final bytes = await _readFile(f.path!);
      final ext = f.name.toLowerCase().split('.').last;
      const ok = {
        'wav': 'audio/wav',
        'mp3': 'audio/mpeg',
        'ogg': 'audio/ogg',
        'flac': 'audio/flac',
        'aiff': 'audio/aiff',
        'aif': 'audio/aiff',
      };
      final mime = ok[ext];
      if (mime == null) {
        await _problem('Audio format not supported',
            'Please use MP3, WAV, OGG or FLAC. Your file was .${ext.isEmpty ? 'unknown' : ext}.');
        return;
      }
      if (bytes.length > kAudioMaxBytes) {
        await _problem('Audio too long',
            'This audio is ${_fmtBytes(bytes.length)} — the limit is 5 MB (roughly one minute) so MiMi can listen and answer.');
        return;
      }
      setState(() => _pending
          .add(_Pending('audio', f.name, mime, bytes)));
    } catch (e) {
      await _problem('Could not open the audio file', '$e');
    }
  }

  Future<void> _pickPdf() async {
    try {
      final res =
          await FilePicker.platform.pickFiles(allowedExtensions: ['pdf']);
      final f = res?.files.single;
      if (f == null || f.path == null) return;
      final bytes = await _readFile(f.path!);
      if (bytes.length > kPdfMaxBytes) {
        await _problem('PDF too large',
            'This PDF is ${_fmtBytes(bytes.length)} — the limit is 10 MB. Export only the pages you need.');
        return;
      }
      setState(() => _pending
          .add(_Pending('pdf', f.name, 'application/pdf', bytes)));
    } catch (e) {
      await _problem('Could not open the PDF', '$e');
    }
  }

  Future<Uint8List> _readFile(String path) async {
    final f = File(path);
    if (await f.length() > 40 * 1024 * 1024) {
      throw Exception('file is larger than 40 MB');
    }
    return f.readAsBytesSync();
  }

  /// Scales a photo down to at most [maxSide] px and re-encodes as JPEG,
  /// keeping the payload small enough for the model. Pure Dart (the engine
  /// no longer JPEG-encodes raw images).
  Future<Uint8List> _resizeJpeg(Uint8List bytes, int maxSide, int quality) async {
    try {
      final source = img.decodeImage(bytes);
      if (source == null) return bytes;
      final longest = math.max(source.width, source.height);
      if (longest <= maxSide) return bytes;
      final out = img.copyResize(
        source,
        width: (source.width * maxSide / longest).round(),
        height: (source.height * maxSide / longest).round(),
        interpolation: img.Interpolation.cubic,
      );
      return Uint8List.fromList(img.encodeJpg(out, quality: quality));
    } catch (_) {
      return bytes;
    }
  }

  static String _fmtBytes(int n) {
    if (n < 1024 * 1024) return '${(n / 1024).round()} KB';
    return '${(n / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ── send ─────────────────────────────────────────────────────────

  Future<void> _send() async {
    if (_busy) return;
    final text = _ctrl.text.trim();
    if (text.length > kTextMaxChars) {
      await _problem('Message too long',
          'Your message is more than $kTextMaxChars characters — keep it under the limit.');
      return;
    }
    if (text.isEmpty && _pending.isEmpty) return;
    final key = _key;
    if (key == null) {
      await _problem('Set the Gemini key first',
          'MiMi needs a free Gemini API key to answer. Open the setup card below and paste your key — it takes a minute.',
          );
      return;
    }
    final atts = List<_Pending>.of(_pending);
    final attMeta = [
      for (final a in atts)
        _AttMeta(a.kind, a.label, _fmtBytes(a.bytes.length)),
    ];
    setState(() {
      _ctrl.clear();
      _pending.clear();
      _msgs.add(_ChatMsg(isUser: true, text: text, atts: attMeta));
      _busy = true;
      _streaming = '';
    });
    _scrollToEnd();

    // History: the last 8 turns, text-only (attachments live in the
    // current turn only — that is what the model should solve).
    final prev = _msgs.length > 1
        ? _msgs.sublist(0, _msgs.length - 1)
        : const <_ChatMsg>[];
    final history = [
      for (final m in prev.reversed.take(8))
        {
          'role': m.isUser ? 'user' : 'model',
          'text': m.text.isEmpty && m.atts.isNotEmpty
              ? '[attachment: ${m.atts.map((a) => a.kind).join(', ')}]'
              : m.text,
        },
    ].reversed.toList();

    // Paint the first frame so the loading state is visible before the
    // (slow) network work starts.
    await SchedulerBinding.instance.endOfFrame;
    try {
      final answer = await GeminiClient.chat(
        apiKey: key,
        systemPrompt: kMimiSystemPrompt,
        history: history,
        userText: text,
        attachments: [
          for (final a in atts) GeminiAttachment(a.mime, a.bytes),
        ],
        onChunk: (chunk) {
          if (!mounted) return;
          setState(() => _streaming = (_streaming ?? '') + chunk);
          _scrollToEnd();
        },
      );
      if (!mounted) return;
      setState(() {
        _msgs.add(_ChatMsg(isUser: false, text: answer));
        _busy = false;
        _streaming = null;
      });
      await _persist();
      _scrollToEnd();
    } on GeminiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _streaming = null;
      });
      await _problem('MiMi could not answer', e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _streaming = null;
      });
      await _problem('Something went wrong', '$e');
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    final start = _msgs.length > 40 ? _msgs.length - 40 : 0;
    final list = [
      for (final m in _msgs.sublist(start))
        {
          'r': m.isUser ? 1 : 0,
          't': m.text.length > 4000 ? m.text.substring(0, 4000) : m.text,
          'a': [for (final a in m.atts) '${a.kind} • ${a.label}${a.size.isEmpty ? '' : ' • ${a.size}'}'],
        },
    ];
    await p.setString(_chatPref, jsonEncode(list));
  }

  Future<void> _clearChat() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Clear the conversation?'),
        content: const Text('This removes the chat from this phone. Your key stays saved.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Keep')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Clear')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final p = await SharedPreferences.getInstance();
    await p.remove(_chatPref);
    setState(() => _msgs.clear());
  }

  // ── UI ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.brandGradient,
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text('MiMi',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
        ]),
        actions: [
          if (_msgs.isNotEmpty)
            IconButton(
              tooltip: 'Clear conversation',
              onPressed: _busy ? null : _clearChat,
              icon: const Icon(Icons.delete_sweep_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: !_ready
                ? const Center(child: BusyIndicator(message: 'Loading…'))
                : (_key == null
                    ? ListView(
                        padding: const EdgeInsets.all(18),
                        children: [
                          _SetupCard(onKeySaved: _reloadKey),
                        ],
                      )
                    : ListView(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                        children: [
                          if (_msgs.isEmpty) _emptyState(),
                          for (final m in _msgs) _bubble(m),
                          if (_busy && _streaming != null)
                            _streamingBubble(),
                          const SizedBox(height: 8),
                        ],
                      )),
          ),
          if (_pending.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                for (final a in _pending) _pendingChip(a),
              ]),
            ),
          _inputBar(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              'Photo ≤ 15 MB • Audio ≤ 5 MB • PDF ≤ 10 MB • up to 3 attachments per question',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: AppTheme.muted),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _emptyState() {
    const chips = [
      'Solve this MCQ and show the reason',
      'How do I write the স্রজন (creation) part of a CQ?',
      'Make 5 board-style questions on Motion',
      'দাও: সংক্ষিপ্ত প্রশ্নের নমুনা উত্তর (উপাদান-নির্ভর)',
    ];
    return Column(children: [
      const SizedBox(height: 26),
      const Center(
        child: Text(
          'Ask anything from the SSC syllabus —\nMCQ, creative question, short answer,\nmaths steps, or attach a photo of the question.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.5, height: 1.6, color: AppTheme.muted),
        ),
      ),
      const SizedBox(height: 18),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          for (final c in chips)
            PressableScale(
              onTap: () => setState(() => _ctrl.text = c),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(c,
                    style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark)),
              ),
            ),
        ],
      ),
    ]);
  }

  Widget _avatar() {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.brandGradient,
      ),
      child: const Icon(Icons.school_rounded, color: Colors.white, size: 19),
    );
  }

  Widget _attChip(_AttMeta a, {Color? iconColor}) {
    final icon = a.kind == 'photo'
        ? Icons.photo_library_rounded
        : (a.kind == 'audio' ? Icons.record_voice_over_rounded : Icons.picture_as_pdf_rounded);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: (iconColor ?? AppTheme.primary).withOpacity(.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (iconColor ?? AppTheme.primary).withOpacity(.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: iconColor ?? AppTheme.primary),
        const SizedBox(width: 6),
        Text(a.label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: iconColor ?? AppTheme.primary)),
        if (a.size.isNotEmpty) ...[
          const SizedBox(width: 5),
          Text(a.size,
              style: TextStyle(fontSize: 10, color: iconColor?.withOpacity(.8) ?? AppTheme.muted)),
        ],
      ]),
    );
  }

  Widget _bubble(_ChatMsg m) {
    final isU = m.isUser;
    return Padding(
      padding: EdgeInsets.only(bottom: 12, left: isU ? 52 : 0, right: isU ? 0 : 52),
      child: Row(
        mainAxisAlignment: isU ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isU) ...[
            _avatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isU ? AppTheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isU ? AppTheme.primaryDark : AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: isU ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  for (final a in m.atts)
                    _attChip(a, iconColor: isU ? Colors.white : AppTheme.primary),
                  if (m.text.isEmpty)
                    const SizedBox(height: 2)
                  else
                    isU
                        ? Text(
                            m.text,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13.5, height: 1.5),
                          )
                        : md.MarkdownBody(
                            data: m.text,
                            styleSheet: md.MarkdownStyleSheet(
                              p: TextStyle(
                                  fontSize: 13.5,
                                  height: 1.5,
                                  color: AppTheme.textDark),
                              strong: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textDark),
                              h1: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryDark),
                              h2: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryDark),
                              h3: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryDark),
                              code: TextStyle(
                                  fontSize: 12.5, color: AppTheme.primaryDark),
                            ),
                          ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _streamingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((_streaming ?? '').isEmpty)
                    Row(children: [
                      const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 10),
                      const Text('MiMi is solving…',
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.muted)),
                    ]),
                  if ((_streaming ?? '').isNotEmpty) ...[
                    md.MarkdownBody(
                      data: _streaming ?? '',
                      styleSheet: md.MarkdownStyleSheet(
                        p: TextStyle(
                            fontSize: 13.5,
                            height: 1.5,
                            color: AppTheme.textDark),
                        strong: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark),
                        h1: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryDark),
                        h2: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryDark),
                        h3: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryDark),
                        code: TextStyle(
                            fontSize: 12.5, color: AppTheme.primaryDark),
                      ),
                    ),
                    FadeTransition(
                      opacity: _blink,
                      child: const Text('▍',
                          style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w900)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pendingChip(_Pending a) {
    final icon = a.kind == 'photo'
        ? Icons.photo_library_rounded
        : (a.kind == 'audio' ? Icons.record_voice_over_rounded : Icons.picture_as_pdf_rounded);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: AppTheme.primary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            a.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryDark),
          ),
        ),
        const SizedBox(width: 4),
        Text(_fmtBytes(a.bytes.length),
            style: const TextStyle(fontSize: 10.5, color: AppTheme.muted)),
        const SizedBox(width: 4),
        InkWell(
          onTap: () => setState(() => _pending.remove(a)),
          child: const Icon(Icons.close_rounded,
              size: 14, color: AppTheme.danger),
        ),
      ]),
    );
  }

  Widget _inputBar() {
    final canSend =
        !_busy && (_ctrl.text.trim().isNotEmpty || _pending.isNotEmpty);
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 6),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(children: [
        IconButton(
          tooltip: 'Attach photo, audio or PDF',
          onPressed: _busy ? null : _openAttachSheet,
          icon: const Icon(Icons.attach_file_rounded,
              color: AppTheme.primary),
        ),
        Expanded(
          child: TextField(
            controller: _ctrl,
            minLines: 1,
            maxLines: 5,
            enabled: !_busy,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _send(),
            style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: 'Ask MiMi — type, or attach a photo / audio / PDF…',
              hintStyle:
                  const TextStyle(fontSize: 13, color: AppTheme.muted),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: canSend ? _send : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: canSend ? AppTheme.primary : AppTheme.border,
              boxShadow: canSend
                  ? [
                      BoxShadow(
                          color: AppTheme.primary.withOpacity(.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3))
                    ]
                  : null,
            ),
            child: const Icon(Icons.arrow_upward_rounded,
                color: Colors.white, size: 22),
          ),
        ),
      ]),
    );
  }
}

/// The one-time setup card shown until the tutor saves a Gemini key.
class _SetupCard extends StatelessWidget {
  final VoidCallback onKeySaved;

  _SetupCard({required this.onKeySaved});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      highlighted: true,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.brandGradient,
              ),
              child: const Icon(Icons.school_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Meet MiMi',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark)),
                SizedBox(height: 2),
                Text('Your AI assistant — answers in Education Board style',
                    style: TextStyle(fontSize: 12, color: AppTheme.muted)),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          const Text(
            'MiMi reads questions and attachments (photo, audio, PDF) and solves them the way the Education Board expects — MCQ reason, four-part creative question, short answers, maths steps.',
            style: TextStyle(fontSize: 12.8, height: 1.6, color: AppTheme.muted),
          ),
          const SizedBox(height: 14),
          const Text('One-time setup (2 minutes)',
              style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryDark)),
          const SizedBox(height: 8),
          const _Step(n: 1, text: 'Open aistudio.google.com in your phone browser (free Google account).'),
          const _Step(n: 2, text: 'Tap "Get API key" → "Create API key" and copy it.'),
          const _Step(n: 3, text: 'Paste the key below — it is stored on this phone only.'),
          const SizedBox(height: 10),
          _KeyField(onSaved: onKeySaved),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final int n;
  final String text;
  const _Step({required this.n, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.primary,
        ),
        child: Text('$n',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white)),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(text,
            style: const TextStyle(
                fontSize: 12.5, height: 1.45, color: AppTheme.textDark)),
      ),
    ]);
  }
}

class _KeyField extends StatefulWidget {
  final VoidCallback onSaved;

  const _KeyField({required this.onSaved});

  @override
  State<_KeyField> createState() => _KeyFieldState();
}

class _KeyFieldState extends State<_KeyField> {
  final _ctrl = TextEditingController();
  bool _busy = false;
  bool _show = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final k = _ctrl.text.trim();
    if (!RegExp(r'^(AIza|AQ)[A-Za-z0-9._\-]{16,}$').hasMatch(k)) {
      await showProblemDialog(
        context,
        title: 'That key does not look right',
        message:
            'A Gemini API key starts with "AIza" or "AQ" — usually about 39 characters.',
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('gemini_api_key', k);
      if (!mounted) return;
      widget.onSaved();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: TextField(
          controller: _ctrl,
          obscureText: !_show,
          decoration: InputDecoration(
            hintText: 'Paste the key (AIza… or AQ…)',
            prefixIcon: const Icon(Icons.vpn_key_rounded, size: 18),
            suffixIcon: IconButton(
              tooltip: _show ? 'Hide key' : 'Show key',
              onPressed: () => setState(() => _show = !_show),
              icon: Icon(_show
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded, size: 17),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      FilledButton(
        onPressed: _busy ? null : _save,
        child: _busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Save'),
      ),
    ]);
  }
}
