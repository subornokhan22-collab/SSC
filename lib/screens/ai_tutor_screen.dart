import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart' as md;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/gemini_client.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/image_crop_screen.dart';
import '../widgets/problem_dialog.dart';

// ── LaTeX → plain Unicode (the chat renderer cannot do math) ──────────

const Map<String, String> _latCmds = {
  'rightarrow': '→', 'to': '→', 'xrightarrow': '→',
  'leftarrow': '←', 'xleftarrow': '←', 'leftrightarrow': '↔',
  'uparrow': '↑', 'downarrow': '↓', 'approx': '≈', 'ne': '≠', 'neq': '≠',
  'pm': '±', 'times': '×', 'cdot': '·', 'div': '÷', 'le': '≤', 'leq': '≤',
  'ge': '≥', 'geq': '≥', 'infty': '∞', 'circ': '°', 'angle': '∠',
  'sqrt': '√', 'pi': 'π', 'alpha': 'α', 'beta': 'β', 'gamma': 'γ',
  'delta': 'δ', 'Delta': 'Δ', 'theta': 'θ', 'lambda': 'λ', 'mu': 'μ',
  'nu': 'ν', 'sigma': 'σ', 'phi': 'φ', 'rho': 'ρ', 'eta': 'η',
  'omega': 'ω', 'Omega': 'Ω',
};

const Map<String, String> _supMap = {
  '0': '⁰', '1': '¹', '2': '²', '3': '³', '4': '⁴', '5': '⁵', '6': '⁶',
  '7': '⁷', '8': '⁸', '9': '⁹', '+': '⁺', '-': '⁻',
  'a': 'ᵃ', 'b': 'ᵇ', 'c': 'ᶜ', 'd': 'ᵈ', 'e': 'ᵉ', 'f': 'ᶠ', 'g': 'ᵍ',
  'h': 'ʰ', 'i': 'ⁱ', 'k': 'ᵏ', 'l': 'ˡ', 'm': 'ᵐ', 'n': 'ⁿ', 'o': 'ᵒ',
  'p': 'ᵖ', 'r': 'ʳ', 't': 'ᵗ', 'u': 'ᵘ', 'v': 'ᵛ', 'w': 'ʷ', 'x': 'ˣ',
  'y': 'ʸ', 'A': 'ᴬ', 'B': 'ᴮ', 'D': 'ᴰ', 'E': 'ᴱ', 'F': 'ᶠ', 'G': 'ᴳ',
  'H': 'ᴴ', 'I': 'ᴵ', 'J': 'ᴶ', 'K': 'ᴷ', 'L': 'ᴸ', 'M': 'ᴹ', 'N': 'ᴺ',
  'O': 'ᴼ', 'P': 'ᴾ', 'T': 'ᵀ',
};

const Map<String, String> _subMap = {
  '0': '₀', '1': '₁', '2': '₂', '3': '₃', '4': '₄', '5': '₅', '6': '₆',
  '7': '₇', '8': '₈', '9': '₉', '+': '₊', '-': '₋',
  'a': 'ₐ', 'e': 'ₑ', 'h': 'ₕ', 'i': 'ᵢ', 'k': 'ₖ', 'l': 'ₗ', 'm': 'ₘ',
  'n': 'ₙ', 'o': 'ₒ', 'p': 'ₚ', 's': 'ₛ', 't': 'ₜ', 'x': 'ₓ',
};

String _mapScript(String group, Map<String, String> map) {
  final buf = StringBuffer();
  for (final rune in group.runes) {
    buf.write(map[String.fromCharCode(rune)] ?? String.fromCharCode(rune));
  }
  return buf.toString();
}

/// Turns the LaTeX the model sometimes emits (MgCl_2, Mg^{2+},
/// \rightarrow, \text{...}) into the plain Unicode text the chat
/// bubble can actually render: MgCl₂, Mg²⁺, →. No-op for normal text.
String plainifyMath(String text) {
  if (!text.contains(r'\') && !text.contains('\$')) return text;
  var s = text;

  // \begin{env} ... \end{env} -> drop the tags, keep the content.
  s = s.replaceAll(RegExp(r'\\(?:begin|end)\{[^{}]*\}'), '');
  s = s.replaceAll('&', ' ');

  // \text{...} / \mathrm{...} -> the inner text (repeat for nesting).
  for (var i = 0; i < 4; i++) {
    final t = s.replaceAll(RegExp(r'\\(?:text|textrm|mathrm|mathbf)\{([^{}]*)\}'), r'\1');
    if (t == s) break;
    s = t;
  }
  s = s.replaceAll(RegExp(r'\\(?:left|right)([|.(])?(?![a-zA-Z])'), r'\1');

  // \frac{a}{b} -> (a)/(b), one level of nested braces allowed
  for (var i = 0; i < 3; i++) {
    final t = s.replaceAll(
        RegExp(r'\\frac\{((?:[^{}]|\{[^{}]*\})*)\}\{((?:[^{}]|\{[^{}]*\})*)\}'),
        r'(\1)/(\2)');
    if (t == s) break;
    s = t;
  }

  // Named commands -> Unicode. Longest keys first so \ne wins over
  // \neq, \leftarrow over shorter prefixes, etc.
  final cmdEntries = _latCmds.entries.toList()
    ..sort((a, b) => b.key.length.compareTo(a.key.length));
  for (final e in cmdEntries) {
    s = s.replaceAll('\\${e.key}', e.value);
  }

  // Escapes & spacing.
  s = s.replaceAll(RegExp(r'\\[,;:!]'), ' ');
  s = s.replaceAll(r'\%', '%');
  s = s.replaceAll(r'\\', '\n'); // math line break
  s = s.replaceAll(r'\$', '');

  // Superscripts and subscripts.
  s = s.replaceAllMapped(RegExp(r'\^\{([^{}]*)\}'),
      (m) => _mapScript(m.group(1)!, _supMap));
  s = s.replaceAllMapped(RegExp(r'\^([0-9+\-])'),
      (m) => _supMap[m.group(1)!] ?? m.group(1)!);
  s = s.replaceAllMapped(RegExp(r'_\{([^{}]*)\}'),
      (m) => _mapScript(m.group(1)!, _subMap));
  s = s.replaceAllMapped(RegExp(r'_([0-9+\-])'),
      (m) => _subMap[m.group(1)!] ?? m.group(1)!);

  // Leftovers: $ delimiters, braces, unknown commands.
  s = s.replaceAll('\$', '');
  s = s.replaceAll('{', '').replaceAll('}', '');
  s = s.replaceAllMapped(RegExp(r'\\([a-zA-Z]+)'), (m) {
    final c = m.group(1)!;
    return (c == 'quad' || c == 'qquad') ? '  ' : '';
  });
  s = s.replaceAll(r'\', '');

  s = s.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return s;
}

/// MiMi — the in-app AI assistant.
///
/// Answers and solves questions in Bangladesh Education Board style using
/// the tutor's free Gemini API key (stored on the device). Accepts text
/// plus attachments: photos (with in-app crop), audio and PDFs — each with
/// a size limit so the model can actually work with them.
///
/// UI: a dark "mission control" look — full-width glass bubbles over a
/// slowly drifting neon backdrop, a glowing thinking orb while MiMi works,
/// and a rotating glow border while an answer streams in.
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

// ── the dark palette (every colour already exists elsewhere in the app) ─
const Color _mimiBg = Color(0xFF0B0E17); // same deep navy as the crop screen
const Color _mimiTeal = Color(0xFF7FE7DC); // bright teal from the crop screen
const Color _mimiAmber = Color(0xFFFFC93C); // amber from the crop corner ticks
const Color _mimiText = Color(0xFFE9EDF8);

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
    with TickerProviderStateMixin, WidgetsBindingObserver {
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

  /// Drives the thinking orb, the streaming glow border, the equalizer and
  /// the caret. Only runs while MiMi is working.
  late final AnimationController _fx;
  /// Drives the drifting aurora / star backdrop. Always running (while the
  /// app is in the foreground).
  late final AnimationController _bg;

  @override
  void initState() {
    super.initState();
    _fx = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));
    _bg = AnimationController(vsync: this, duration: const Duration(seconds: 26))
      ..repeat();
    _ctrl.addListener(() {
      if (mounted) setState(() {});
    });
    SystemChrome.setSystemUIOverlayStyle(
        AppTheme.overlayStyle.copyWith(statusBarIconBrightness: Brightness.light, statusBarColor: Colors.transparent, systemNavigationBarColor: _mimiBg, systemNavigationBarIconBrightness: Brightness.light));
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_bg.isAnimating) _bg.repeat();
      if (_busy && !_fx.isAnimating) _fx.repeat();
    } else {
      _bg.stop();
      _fx.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayStyle);
    _fx.dispose();
    _bg.dispose();
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

  // ── key ─────────────────────────────────────────────────────────

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

  /// Pure-Flutter cropper (no native code → no native crash possible).
  /// "Use as is" / back keeps the original, resized for the API.
  Future<void> _attachPhoto(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final cropped = await ImageCropScreen.open(context, frame.image, bytes);
      if (!mounted) return;
      final att = cropped ?? await _resizeJpeg(bytes, 1600, 82);
      setState(() => _pending
          .add(_Pending('photo', 'Photo', 'image/jpeg', att)));
    } catch (e) {
      await _problem('Could not open the photo', '$e');
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

  // ── send ────────────────────────────────────────────────────────

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
    if (!_fx.isAnimating) _fx.repeat();
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
      _fx.stop();
      await _persist();
      _scrollToEnd();
    } on GeminiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _streaming = null;
      });
      _fx.stop();
      await _problem('MiMi could not answer', e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _streaming = null;
      });
      _fx.stop();
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
      backgroundColor: _mimiBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleSpacing: 12,
        title: Row(children: [
          _orb(size: 32, active: false),
          const SizedBox(width: 11),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('MiMi',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: .6)),
            const SizedBox(height: 1),
            const Text('AI TUTOR • ONLINE',
                style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: _mimiTeal,
                    letterSpacing: 2.6)),
          ]),
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
      body: Stack(children: [
        // Drifting aurora + star field + fine grid behind everything.
        Positioned.fill(
            child: _MimiBackdrop(controller: _bg, visible: _ready)),
        SafeArea(
          child: Column(children: [
            // Neon hairline under the app bar.
            Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  Color(0x8C3D5AFE),
                  Color(0x667FE7DC),
                  Colors.transparent,
                ]),
              ),
            ),
            Expanded(
              child: !_ready
                  ? _bootState()
                  : (_key == null
                      ? ListView(
                          padding: const EdgeInsets.all(18),
                          children: [
                            _SetupCard(onKeySaved: _reloadKey),
                          ],
                        )
                      : ListView(
                          controller: _scroll,
                          padding: const EdgeInsets.fromLTRB(10, 12, 10, 16),
                          children: [
                            if (_msgs.isEmpty) _emptyState(),
                            for (var i = 0; i < _msgs.length; i++)
                              FadeSlideIn(
                                delay:
                                    Duration(milliseconds: (i * 45).clamp(0, 360)),
                                child: _bubble(_msgs[i]),
                              ),
                            if (_busy && _streaming != null)
                              _streamingBubble(),
                            const SizedBox(height: 8),
                          ],
                        )),
            ),
            if (_pending.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
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
                style: TextStyle(fontSize: 10, color: Colors.white54),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  /// First frame: the orb "booting up".
  Widget _bootState() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _orb(size: 64, active: false),
        const SizedBox(height: 18),
        const Text('CONNECTING TO MIMI',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white60,
                letterSpacing: 2.4)),
      ]),
    );
  }

  /// The glowing MiMi orb. [active] = spin the energy arcs (MiMi is
  /// working). Inactive orbs are fully static — zero tickers, so a chat
  /// full of avatars costs nothing.
  Widget _orb({required double size, required bool active}) {
    if (!active) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.brandGradient,
          boxShadow: [
            BoxShadow(
                color: AppTheme.primary.withOpacity(.4),
                blurRadius: size * .34,
                spreadRadius: size * .03),
          ],
        ),
        child: Icon(Icons.auto_awesome_rounded,
            color: Colors.white, size: size * .3),
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _fx,
        builder: (context, _) {
          return RepaintBoundary(
            child: Stack(alignment: Alignment.center, children: [
              CustomPaint(
                  size: Size.square(size), painter: _OrbArcsPainter(_fx.value)),
              Pulse(
                min: .92,
                max: 1.08,
                period: const Duration(milliseconds: 900),
                child: Container(
                  width: size * .58,
                  height: size * .58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.brandGradient,
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.primary.withOpacity(.75),
                          blurRadius: size * .38,
                          spreadRadius: size * .04),
                    ],
                  ),
                  child: Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: size * .3),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }

  /// The "MiMi is thinking" row: orb + shimmering label + bouncing dots.
  Widget _thinkingRow() {
    return AnimatedBuilder(
      animation: _fx,
      builder: (context, _) {
        final t = _fx.value;
        return Row(children: [
          Flexible(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'MiMi is thinking',
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .5,
                    color: _mimiText.withOpacity(.92)),
              ),
              const SizedBox(height: 7),
              Row(children: [
                for (var i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Transform.translate(
                      offset: Offset(
                          0, -3.2 * math.sin(2 * math.pi * (t * 1.7 + i * .27)).abs()),
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.brandGradient,
                          boxShadow: [
                            BoxShadow(
                                color: AppTheme.primary.withOpacity(.6),
                                blurRadius: 7),
                          ],
                        ),
                      ),
                    ),
                  ),
              ]),
            ]),
          ),
        ]);
      },
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
      const SizedBox(height: 30),
      _orb(size: 84, active: false),
      const SizedBox(height: 20),
      const Text('MIMI ASSISTANT',
          style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: _mimiTeal,
              letterSpacing: 3.4)),
      const SizedBox(height: 10),
      const Center(
        child: Text(
          'Ask anything from the SSC syllabus —\nMCQ, creative question, short answer,\nmaths steps, or attach a photo of the question.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 13.5, height: 1.65, color: Colors.white70),
        ),
      ),
      const SizedBox(height: 20),
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
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primary.withOpacity(.4)),
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.primary.withOpacity(.16),
                        blurRadius: 10,
                        offset: const Offset(0, 3)),
                  ],
                ),
                child: Text(c,
                    style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _mimiText)),
              ),
            ),
        ],
      ),
      const SizedBox(height: 24),
    ]);
  }

  Widget _attChip(_AttMeta a, {Color? iconColor}) {
    final icon = a.kind == 'photo'
        ? Icons.photo_library_rounded
        : (a.kind == 'audio' ? Icons.record_voice_over_rounded : Icons.picture_as_pdf_rounded);
    final c = iconColor ?? _mimiTeal;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: c.withOpacity(.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withOpacity(.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 6),
        Text(a.label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: c)),
        if (a.size.isNotEmpty) ...[
          const SizedBox(width: 5),
          Text(a.size,
              style: TextStyle(
                  fontSize: 10, color: Colors.white.withOpacity(.55))),
        ],
      ]),
    );
  }

  Widget _bubble(_ChatMsg m) {
    final isU = m.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isU ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isU) ...[
            _orb(size: 30, active: false),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: BoxDecoration(
                color: isU
                    ? null
                    : Colors.white.withOpacity(.045),
                gradient: isU ? AppTheme.brandGradient : null,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isU
                        ? Colors.transparent
                        : AppTheme.primary.withOpacity(.3)),
                boxShadow: [
                  BoxShadow(
                      color: isU
                          ? AppTheme.primary.withOpacity(.30)
                          : AppTheme.primary.withOpacity(.10),
                      blurRadius: isU ? 14 : 12,
                      offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: isU ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  for (final a in m.atts)
                    _attChip(a, iconColor: isU ? null : _mimiTeal),
                  if (m.text.isEmpty)
                    const SizedBox(height: 2)
                  else
                    isU
                        ? Text(
                            m.text,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13.8, height: 1.55),
                          )
                        : md.MarkdownBody(
                            data: plainifyMath(m.text),
                            styleSheet: _mdSheet(),
                          ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  md.MarkdownStyleSheet _mdSheet() {
    return md.MarkdownStyleSheet(
      p: TextStyle(
          fontSize: 13.8, height: 1.55, color: _mimiText.withOpacity(.94)),
      strong: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
      em: TextStyle(
          color: _mimiText.withOpacity(.85), fontStyle: FontStyle.italic),
      h1: TextStyle(
          fontSize: 15.5, fontWeight: FontWeight.w800, color: _mimiTeal),
      h2: TextStyle(
          fontSize: 14.8, fontWeight: FontWeight.w800, color: _mimiTeal),
      h3: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w800, color: _mimiTeal),
      code: TextStyle(
          fontSize: 12.5, color: _mimiAmber, backgroundColor: Colors.white.withOpacity(.08)),
      blockquote: TextStyle(
          color: _mimiText.withOpacity(.75), fontStyle: FontStyle.italic),
    );
  }

  Widget _streamingBubble() {
    final hasText = (_streaming ?? '').isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _orb(size: 30, active: true),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.045),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!hasText)
                      _thinkingRow()
                    else ...[
                      md.MarkdownBody(
                        data: plainifyMath(_streaming ?? ''),
                        styleSheet: _mdSheet(),
                      ),
                      const SizedBox(height: 6),
                      Row(children: [
                        _equalizer(),
                        const SizedBox(width: 8),
                        AnimatedBuilder(
                          animation: _fx,
                          builder: (context, _) {
                            final t = _fx.value;
                            // crisp on/off blink
                            final on = (t * 2.4) % 1.0 < 0.62;
                            return Opacity(
                              opacity: on ? 1 : .15,
                              child: const Text('▍',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: _mimiTeal,
                                      fontWeight: FontWeight.w900)),
                            );
                          },
                        ),
                      ]),
                    ],
                  ],
                ),
              ),
              // Rotating neon border — its own tiny per-frame layer so the
              // markdown text is never re-laid-out at 60fps.
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _fx,
                    builder: (_, __) =>
                        CustomPaint(painter: _GlowBorderPainter(_fx.value)),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  /// Four tiny neon bars dancing while tokens stream in.
  Widget _equalizer() {
    return AnimatedBuilder(
      animation: _fx,
      builder: (context, _) {
        final t = _fx.value;
        return SizedBox(
          height: 14,
          child: Row(children: [
            for (var i = 0; i < 4; i++)
              Padding(
                padding: const EdgeInsets.only(right: 2.5),
                child: Container(
                  width: 3,
                  height: 4 + 9 * math.sin(2 * math.pi * (t * 2.1 + i * .23)).abs(),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [AppTheme.primary, _mimiTeal]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ]),
        );
      },
    );
  }

  Widget _pendingChip(_Pending a) {
    final icon = a.kind == 'photo'
        ? Icons.photo_library_rounded
        : (a.kind == 'audio' ? Icons.record_voice_over_rounded : Icons.picture_as_pdf_rounded);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(.45)),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withOpacity(.2), blurRadius: 9),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: _mimiTeal),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            a.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: _mimiText),
          ),
        ),
        const SizedBox(width: 4),
        Text(_fmtBytes(a.bytes.length),
            style: const TextStyle(fontSize: 10.5, color: Colors.white54)),
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
    final armed = _ctrl.text.trim().isNotEmpty || _pending.isNotEmpty;
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: armed ? _mimiTeal.withOpacity(.65) : AppTheme.primary.withOpacity(.35)),
        boxShadow: [
          BoxShadow(
              color: armed
                  ? _mimiTeal.withOpacity(.22)
                  : AppTheme.primary.withOpacity(.14),
              blurRadius: armed ? 18 : 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(children: [
        IconButton(
          tooltip: 'Attach photo, audio or PDF',
          onPressed: _busy ? null : _openAttachSheet,
          icon: const Icon(Icons.attach_file_rounded, color: _mimiTeal),
        ),
        Expanded(
          child: TextField(
            controller: _ctrl,
            minLines: 1,
            maxLines: 5,
            enabled: !_busy,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _send(),
            style: const TextStyle(
                fontSize: 14, color: _mimiText, height: 1.4),
            decoration: InputDecoration(
              isCollapsed: false,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: 'Ask MiMi — type, or attach a photo / audio / PDF…',
              hintStyle: TextStyle(
                  fontSize: 13, color: Colors.white.withOpacity(.38)),
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
        const SizedBox(width: 2),
        GestureDetector(
          onTap: canSend ? _send : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: canSend ? AppTheme.brandGradient : null,
              color: canSend ? null : Colors.white.withOpacity(.08),
              border: Border.all(
                  color: canSend
                      ? Colors.transparent
                      : Colors.white.withOpacity(.14)),
              boxShadow: canSend
                  ? [
                      BoxShadow(
                          color: AppTheme.primary.withOpacity(.55),
                          blurRadius: 14,
                          offset: const Offset(0, 4))
                    ]
                  : null,
            ),
            child: Icon(Icons.arrow_upward_rounded,
                color: canSend ? Colors.white : Colors.white38, size: 22),
          ),
        ),
      ]),
    );
  }
}

// ── backdrop: aurora blobs, star field, fine grid, slow scan band ─────

class _MimiBackdrop extends StatelessWidget {
  final AnimationController controller;
  final bool visible;
  const _MimiBackdrop({required this.controller, required this.visible});

  static final List<Offset> _stars = [];

  @override
  Widget build(BuildContext context) {
    if (_stars.isEmpty) {
      final rnd = math.Random(7);
      for (var i = 0; i < 46; i++) {
        _stars.add(Offset(rnd.nextDouble(), rnd.nextDouble()));
      }
    }
    if (!visible) {
      return const DecoratedBox(
          decoration: BoxDecoration(color: _mimiBg));
    }
    return RepaintBoundary(
      child: ColoredBox(
        color: _mimiBg,
        child: AnimatedBuilder(
          animation: controller,
          builder: (_, __) => CustomPaint(
              painter: _MimiScenePainter(controller.value, _stars)),
        ),
      ),
    );
  }
}

class _MimiScenePainter extends CustomPainter {
  final double t;
  final List<Offset> stars;
  _MimiScenePainter(this.t, this.stars);

  void _blob(Canvas canvas, Offset c, double r, Color color) {
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
            c,
            r,
            [color, color.withOpacity(0)],
            const [0.0, 1.0],
            ui.TileMode.clamp),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final drift = t * 2 * math.pi;

    // Aurora blobs drifting slowly.
    _blob(canvas,
        Offset(w * (.18 + .06 * math.sin(drift)), h * (.16 + .05 * math.cos(drift))),
        w * .62, AppTheme.primary.withOpacity(.20));
    _blob(canvas,
        Offset(w * (.86 + .05 * math.cos(drift * 1.3)), h * (.58 + .07 * math.sin(drift * .8))),
        w * .55, _mimiTeal.withOpacity(.11));
    _blob(canvas,
        Offset(w * (.5 + .08 * math.sin(drift * .7)), h * 1.02),
        w * .7, AppTheme.primaryDark.withOpacity(.34));

    // Fine grid.
    final grid = Paint()
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(.028);
    const step = 46.0;
    for (double x = 0; x < w; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), grid);
    }
    for (double y = 0; y < h; y += step) {
      canvas.drawLine(Offset(0, y), Offset(w, y), grid);
    }

    // Twinkling stars.
    for (var i = 0; i < stars.length; i++) {
      final a = .12 + .22 * math.sin(drift * 2 + i * 1.7).abs();
      canvas.drawCircle(
        Offset(stars[i].dx * w, stars[i].dy * h),
        0.8 + (i % 3) * .45,
        Paint()..color = Colors.white.withOpacity(a),
      );
    }

    // A slow scan band sweeping down — mission-control feel.
    final bandY = ((t * 1.25) % 1.3) * h - h * .15;
    canvas.drawRect(
      Rect.fromLTWH(0, bandY, w, h * .16),
      Paint()
        ..shader = ui.Gradient.linear(
            Offset(0, bandY),
            Offset(0, bandY + h * .16),
            [Colors.white.withOpacity(0), Colors.white.withOpacity(.03), Colors.white.withOpacity(0)]),
    );
  }

  @override
  bool shouldRepaint(_MimiScenePainter old) => old.t != t;
}

// ── orb energy arcs ───────────────────────────────────────────────────

class _OrbArcsPainter extends CustomPainter {
  final double t;
  _OrbArcsPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 2.5;
    final rect = Rect.fromCircle(center: c, radius: r);

    canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withOpacity(.14));

    final a1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..color = AppTheme.primary;
    canvas.drawArc(rect, t * 2 * math.pi, 1.15, false, a1);

    final a2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = _mimiTeal;
    canvas.drawArc(rect, math.pi - t * 2 * math.pi * .83, .75, false, a2);

    // A tiny comet dot riding the primary arc.
    final ang = t * 2 * math.pi + 1.15;
    canvas.drawCircle(
      c + Offset(math.cos(ang), math.sin(ang)) * r,
      2.2,
      Paint()..color = _mimiTeal,
    );
  }

  @override
  bool shouldRepaint(_OrbArcsPainter old) => old.t != t;
}

// ── rotating neon border for the streaming bubble ─────────────────────

class _GlowBorderPainter extends CustomPainter {
  final double t;
  _GlowBorderPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    const r = 16.0;
    final rect = Rect.fromLTWH(1, 1, size.width - 2, size.height - 2);
    final border = RRect.fromRectAndRadius(rect, const Radius.circular(r));
    final c = Offset(rect.left + rect.width / 2, rect.top + rect.height / 2);
    final reach = (size.width + size.height) / 2;
    final ang = t * 2 * math.pi;
    final b = c + Offset(math.cos(ang), math.sin(ang)) * reach;
    final e = c - Offset(math.cos(ang), math.sin(ang)) * reach;

    // Soft outer glow.
    canvas.drawRRect(
      border,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = AppTheme.primary.withOpacity(.16),
    );

    // Rotating 4-stop neon gradient line.
    canvas.drawRRect(
      border,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..shader = ui.Gradient.linear(b, e, const [
          AppTheme.primary,
          _mimiTeal,
          _mimiAmber,
          AppTheme.primary,
        ]),
    );
  }

  @override
  bool shouldRepaint(_GlowBorderPainter old) => old.t != t;
}

/// The one-time setup card shown until the tutor saves a Gemini key
/// (dark glass version for the MiMi screen).
class _SetupCard extends StatelessWidget {
  final VoidCallback onKeySaved;

  const _SetupCard({required this.onKeySaved});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.045),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(.3)),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primary.withOpacity(.16),
              blurRadius: 24,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _orbWidget(),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Meet MiMi',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
                SizedBox(height: 2),
                Text('Your AI assistant — answers in Education Board style',
                    style: TextStyle(
                        fontSize: 12, color: Colors.white60)),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          const Text(
            'MiMi reads questions and attachments (photo, audio, PDF) and solves them the way the Education Board expects — MCQ reason, four-part creative question, short answers, maths steps.',
            style: TextStyle(
                fontSize: 12.8, height: 1.6, color: Colors.white70),
          ),
          const SizedBox(height: 14),
          const Text('ONE-TIME SETUP (2 MINUTES)',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: _mimiTeal,
                  letterSpacing: 1.6)),
          const SizedBox(height: 10),
          const _Step(n: 1, text: 'Open aistudio.google.com in your phone browser (free Google account).'),
          const _Step(n: 2, text: 'Tap "Get API key" → "Create API key" and copy it.'),
          const _Step(n: 3, text: 'Paste the key below — it is stored on this phone only.'),
          const SizedBox(height: 12),
          _KeyField(onSaved: onKeySaved),
        ],
      ),
    );
  }

  Widget _orbWidget() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.brandGradient,
        boxShadow: [
          BoxShadow(
              color: AppTheme.primary.withOpacity(.5),
              blurRadius: 18,
              spreadRadius: 1),
        ],
      ),
      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
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
          gradient: AppTheme.brandGradient,
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
                fontSize: 12.5, height: 1.5, color: Colors.white70)),
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
          style: const TextStyle(color: _mimiText, fontSize: 13.5),
          decoration: InputDecoration(
            hintText: 'Paste the key (AIza… or AQ…)',
            hintStyle: TextStyle(color: Colors.white.withOpacity(.35)),
            prefixIcon: const Icon(Icons.vpn_key_rounded, size: 18, color: _mimiTeal),
            suffixIcon: IconButton(
              tooltip: _show ? 'Hide key' : 'Show key',
              onPressed: () => setState(() => _show = !_show),
              icon: Icon(_show
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 17,
                  color: Colors.white60),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(.06),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppTheme.primary.withOpacity(.35)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppTheme.primary.withOpacity(.35)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _mimiTeal, width: 1.4),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: AppTheme.primary.withOpacity(.4),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: FilledButton(
          onPressed: _busy ? null : _save,
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save'),
        ),
      ),
    ]);
  }
}
