import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:printing/printing.dart';

import '../services/omr_layout.dart';
import '../services/omr_result_pdf.dart';
import '../services/omr_scanner.dart';
import '../services/paper_key_store.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';

/// Scan photographed OMR sheets, mark them against a saved answer key and
/// print/share the result.
class OmrScannerScreen extends StatefulWidget {
  const OmrScannerScreen({super.key});

  @override
  State<OmrScannerScreen> createState() => _OmrScannerScreenState();
}

class _OmrScannerScreenState extends State<OmrScannerScreen> {
  final _picker = ImagePicker();
  final _countCtrl = TextEditingController();
  final _keyCtrl = TextEditingController();

  List<PaperKey> _keys = const [];
  String? _selectedKeyId;
  bool _manual = false;
  List<OmrGradeSheet> _sheets = const [];
  List<String> _errors = const [];
  bool _scanning = false;
  bool _printing = false;
  int _nextId = 1;

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  @override
  void dispose() {
    _countCtrl.dispose();
    _keyCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadKeys() async {
    final keys = await PaperKeyStore.list();
    if (!mounted) return;
    setState(() {
      _keys = keys;
      _selectedKeyId = keys.isEmpty ? null : keys.first.id;
      // Nothing to pick from: go straight to the manual key.
      if (keys.isEmpty) {
        _manual = true;
        _keyCtrl.text = 'ক'.padRight(15, ' ');
      }
    });
  }

  PaperKey? get _activeKey {
    if (_manual) {
      final n = int.tryParse(_countCtrl.text.trim()) ?? 0;
      if (n <= 0) return null;
      final key = parseKeyString(_keyCtrl.text, n);
      if (key == null) return null;
      return PaperKey(
        id: 'manual',
        title: 'Manual key',
        subject: '',
        dateIso: '',
        questionCount: n,
        setCode: -1,
        key: key,
      );
    }
    for (final k in _keys) {
      if (k.id == _selectedKeyId) return k;
    }
    return null;
  }

  String _keyProblem(PaperKey? k) {
    if (k != null) return '';
    if (!_manual) return 'Choose an answer key above.';
    final n = int.tryParse(_countCtrl.text.trim()) ?? 0;
    if (n <= 0) return 'Enter the number of MCQs.';
    return 'The key must be exactly $n letters (ক/খ/গ/ঘ or a/b/c/d or 1-4).';
  }

  Future<void> _scan({required bool fromCamera}) async {
    final key = _activeKey;
    if (key == null) {
      _snack(_keyProblem(key));
      return;
    }
    try {
      List<XFile> list;
      if (fromCamera) {
        final one = await _picker.pickImage(
            source: ImageSource.camera, maxWidth: 2600, imageQuality: 90);
        list = one == null ? <XFile>[] : [one];
      } else {
        list = await _picker.pickMultiImage(maxWidth: 2600, imageQuality: 90);
      }
      if (list.isEmpty) return;
      if (!mounted) return;
      setState(() {
        _scanning = true;
        _errors = const [];
      });
      final layout = OmrSheetLayout(key.questionCount);
      final newSheets = <OmrGradeSheet>[];
      final newErrors = <String>[];
      for (final file in list) {
        final bytes = await file.readAsBytes();
        final result = await OmrScanner.scan(bytes, layout);
        final name = file.name.isNotEmpty ? file.name : 'sheet';
        if (!result.ok) {
          newErrors.add('$name — ${result.error}');
          continue;
        }
        final roll = result.rollDigits.map((d) => d < 0 ? '?' : '$d').join();
        final reg = result.regDigits.map((d) => d < 0 ? '?' : '$d').join();
        final sheet = OmrGradeSheet(
          id: _nextId++,
          roll: roll,
          registration: reg,
          setCode: result.setCode,
          answers: result.answers,
          key: key.key,
        );
        sheet.grade();
        newSheets.add(sheet);
      }
      if (!mounted) return;
      setState(() {
        _scanning = false;
        _sheets = [..._sheets, ...newSheets];
        _errors = newErrors;
      });
      if (newSheets.isEmpty && newErrors.isEmpty) _snack('No sheets added.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _scanning = false);
      _snack('Scan failed: $e');
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _printResults() async {
    if (_sheets.isEmpty) return;
    final key = _activeKey;
    final title = key?.title ?? 'Question Paper';
    setState(() => _printing = true);
    try {
      final bytes = await OmrResultPdf.build(
        title: title,
        subject: key?.subject ?? '',
        sheets: _sheets,
      );
      await Printing.layoutPdf(onLayout: (format) async => bytes);
    } catch (_) {
      try {
        final bytes = await OmrResultPdf.build(
          title: title,
          subject: key?.subject ?? '',
          sheets: _sheets,
        );
        await Printing.sharePdf(bytes: bytes, filename: 'omr_result.pdf');
      } catch (e) {
        _snack('Could not print: $e');
      }
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  void _detailDialog(OmrGradeSheet s) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            'রোল ${s.roll} — ${s.score}/${s.total}  (ভুল ${s.wrongCount}, খালি ${s.blankCount})'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.6,
            ),
            itemCount: s.key.length,
            itemBuilder: (context, i) {
              final st = s.statusOf(i);
              final mine = i < s.answers.length && s.answers[i] >= 0
                  ? _letters[s.answers[i]]
                  : '—';
              final color = st == 0
                  ? const Color(0xFFEAF8F0)
                  : st == 1
                      ? const Color(0xFFFDF0F0)
                      : const Color(0xFFFFF8EC);
              final fg = st == 0
                  ? AppTheme.success
                  : st == 1
                      ? AppTheme.danger
                      : AppTheme.warning;
              return Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: fg.withOpacity(.35)),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${i + 1}.\n$mine',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: fg,
                    height: 1.15,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static const _letters = ['ক', 'খ', 'গ', 'ঘ'];

  @override
  Widget build(BuildContext context) {
    final key = _activeKey;
    final problem = _keyProblem(key);
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('OMR Scanner',
            style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        scrolledUnderElevation: 0.4,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _card('Answer Key', [
            if (_keys.isNotEmpty) ...[
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _manual ? null : _selectedKeyId,
                  isExpanded: true,
                  hint: const Text('Choose the paper…'),
                  dropdownColor: AppTheme.surface,
                  items: [
                    for (final k in _keys)
                      DropdownMenuItem(
                        value: k.id,
                        child: Text(
                          _keyLabel(k),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13.5),
                        ),
                      ),
                  ],
                  onChanged: _manual
                      ? null
                      : (v) => setState(() {
                            _selectedKeyId = v;
                            _manual = false;
                          }),
                ),
              ),
            ] else
              const Text(
                'No saved key yet — keys are stored automatically when you '
                'print a paper with MCQs. Or type the key below.',
                style: TextStyle(color: AppTheme.muted, fontSize: 12.5, height: 1.4),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _manual,
                  onChanged: (v) =>
                      setState(() => _manual = v ?? false),
                ),
                const Expanded(
                  child: Text('Manual key (type it yourself)',
                      style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
            if (_manual) ...[
              Row(
                children: [
                  SizedBox(
                    width: 92,
                    child: TextField(
                      controller: _countCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'MCQs',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _keyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Key — e.g. ক খ গ ঘ ক …',
                        hintText: 'ক খ গ ঘ ক খ …  (or a b c d, or 1 2 3 4)',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            if (key != null)
              Text(
                '✓ Ready — ${key.questionCount} questions'
                '${key.setCode >= 0 ? ', set ${_letters[key.setCode]}' : ''}',
                style: const TextStyle(
                    color: AppTheme.success,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700),
              )
            else
              Text(problem,
                  style: const TextStyle(
                      color: AppTheme.danger, fontSize: 12.5)),
          ]),
          const SizedBox(height: 12),
          _card('Scan Sheets', [
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Camera',
                    icon: Icons.photo_camera_rounded,
                    onPressed: _scanning ? null : () => _scan(fromCamera: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    label: 'Gallery',
                    icon: Icons.photo_library_rounded,
                    outlined: true,
                    onPressed:
                        _scanning ? null : () => _scan(fromCamera: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Photograph the full OMR sheet flat, in even light — all four '
              'corner squares must be visible. Several photos at once is fine.',
              style: TextStyle(color: AppTheme.muted, fontSize: 12, height: 1.4),
            ),
            if (_scanning) ...[
              const SizedBox(height: 10),
              const SizedBox(height: 4, child: LinearProgressIndicator()),
              const SizedBox(height: 4),
              const Text('Scanning…',
                  style: TextStyle(color: AppTheme.muted, fontSize: 12)),
            ],
            for (final e in _errors.take(4)) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF0F0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.danger.withOpacity(.3)),
                ),
                child: Text(e,
                    style: const TextStyle(
                        color: Color(0xFFA3282C), fontSize: 12, height: 1.35)),
              ),
            ],
            if (_errors.length > 4)
              Text('…and ${_errors.length - 4} more',
                  style: const TextStyle(color: AppTheme.muted, fontSize: 11.5)),
            const SizedBox(height: 12),
            if (_sheets.isEmpty)
              const Text(
                'Marked sheets will appear here.',
                style: TextStyle(color: AppTheme.muted, fontSize: 12.5),
              )
            else
              for (final s in _sheets)
                _sheetRow(s),
          ]),
          if (_sheets.isNotEmpty) ...[
            const SizedBox(height: 14),
            AppButton(
              label: _printing
                  ? 'Preparing…'
                  : 'Print / Share Results (${_sheets.length})',
              icon: Icons.print_rounded,
              onPressed: _printing ? null : _printResults,
            ),
          ],
        ],
      ),
    );
  }

  String _keyLabel(PaperKey k) {
    final date = k.dateIso.length >= 10 ? k.dateIso.substring(5, 10) : '';
    final t = k.title.length > 26 ? '${k.title.substring(0, 26)}…' : k.title;
    return '$t • ${k.questionCount} MCQ$'
        '${date.isEmpty ? '' : ' • $date'}';
  }

  Widget _card(String title, List<Widget> children) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      );

  Widget _sheetRow(OmrGradeSheet s) {
    final ratio = s.total == 0 ? 0 : s.score / s.total;
    final color = ratio >= .99 ? AppTheme.success
        : ratio >= .6 ? AppTheme.warning
        : AppTheme.danger;
    return GestureDetector(
      onTap: () => _detailDialog(s),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'রোল ${s.roll}'
                    '${s.registration.isNotEmpty ? '  •  ${s.registration}' : ''}'
                    '${s.setCode != null ? '  •  সেট ${_letters[s.setCode!].toLowerCase()}' : ''}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'সঠিক ${s.correctCount} • ভুল ${s.wrongCount} • খালি ${s.blankCount}',
                    style: const TextStyle(
                        color: AppTheme.muted, fontSize: 11.5),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${s.score}/${s.total}',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: color)),
            ),
          ],
        ),
      ),
    );
  }
}
