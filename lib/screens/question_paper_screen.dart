import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/questions_data.dart';
import '../services/ai_question_generator.dart';
import '../services/paper_license.dart';
import '../services/paper_pdf.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import 'subjects_screen.dart';

/// SSC-2027 অফিসিয়াল প্রশ্ন-কাঠামো (জাতীয় শিক্ষাক্রম ও পাঠ্যপুস্তক বোর্ড)
/// গণিত: সৃজনশীল ৮ (৫×১০) + সংক্ষিপ্ত-উত্তর ১৫ (১০×২) + MCQ ৩০ = ১০০
/// বিজ্ঞান/উচ্চতর গণিত (তত্ত্বীয় ৭৫): সৃজনশীল ৭ (৪×১০) + সংক্ষিপ্ত ৭ (৫×২) + MCQ ২৫
/// অন্যান্য: সৃজনশীল ৮ (৫×১০) + সংক্ষিপ্ত ১৫ (১০×২) + MCQ ৩০ = ১০০
class _PaperPattern {
  final int mcqCount;
  final int cqCount;
  final int saqCount;
  final int cqAnswerCount;
  final int saqAnswerCount;
  final bool mathDivisions;

  const _PaperPattern({
    required this.mcqCount,
    required this.cqCount,
    required this.saqCount,
    required this.cqAnswerCount,
    required this.saqAnswerCount,
    this.mathDivisions = false,
  });

  int get totalMarks => cqAnswerCount * 10 + saqAnswerCount * 2 + mcqCount;
}

class QuestionPaperScreen extends StatefulWidget {
  const QuestionPaperScreen({super.key});

  @override
  State<QuestionPaperScreen> createState() => _QuestionPaperScreenState();
}

class _QuestionPaperScreenState extends State<QuestionPaperScreen> {
  SubjectInfo? _subject;
  String _mode = 'chapter'; // 'chapter' | 'full'
  String? _chapter;

  bool _busy = false;
  bool _generated = false;
  bool _isPro = false;
  bool _showAnswerKey = false;
  String? _apiKey;
  String? _note;

  List<Question> _mcqs = [];
  List<CreativeQuestion> _cqs = [];
  List<Question> _saqs = []; // সংক্ষিপ্ত-উত্তর (SSC-2027 নতুন অংশ)

  static const _optionLetters = ['ক', 'খ', 'গ', 'ঘ'];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final pro = await PaperLicense.isPro();
    setState(() {
      _apiKey = prefs.getString('gemini_api_key');
      _isPro = pro;
    });
  }

  // ── লিখিত সংখ্যা বাংলায় ──────────────────────────────────────────
  String _bn(int n) {
    const d = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return n.toString().split('').map((c) {
      final code = c.codeUnitAt(0);
      return (code >= 48 && code <= 57) ? d[code - 48] : c;
    }).join();
  }

  // ── বিষয় অনুযায়ী SSC-2027 প্যাটার্ন ─────────────────────────────
  _PaperPattern _patternFor(String sid) {
    const science = {'physics', 'chemistry', 'higher_math', 'biology'};
    if (sid == 'general_math') {
      return const _PaperPattern(
        mcqCount: 30, cqCount: 8, saqCount: 15,
        cqAnswerCount: 5, saqAnswerCount: 10, mathDivisions: true,
      );
    }
    if (science.contains(sid)) {
      return const _PaperPattern(
        mcqCount: 25, cqCount: 7, saqCount: 7,
        cqAnswerCount: 4, saqAnswerCount: 5,
      );
    }
    return const _PaperPattern(
      mcqCount: 30, cqCount: 8, saqCount: 15,
      cqAnswerCount: 5, saqAnswerCount: 10,
    );
  }

  // ── সাধারণ গণিতের অধ্যায় → বিভাগ (বোর্ডের নির্দেশনা অনুযায়ী) ────
  static const _divChapters = {
    'বীজগণিত': {1, 2, 3, 4, 5, 11, 12, 13},
    'জ্যামিতি': {6, 7, 8, 14, 15},
    'ত্রিকোণমিতি ও পরিমিতি': {9, 10, 16},
    'পরিসংখ্যান': {17},
  };

  int? _chapterNumber(String chapter) {
    final m = RegExp(r'অধ্যায় ([০-৯]+)').firstMatch(chapter);
    if (m == null) return null;
    const bd = {
      '০': 0, '১': 1, '২': 2, '৩': 3, '৪': 4,
      '৫': 5, '৬': 6, '৭': 7, '৮': 8, '৯': 9,
    };
    int v = 0;
    for (final ch in m.group(1)!.split('')) {
      v = v * 10 + (bd[ch] ?? 0);
    }
    return v;
  }

  String? _divisionOf(String chapter) {
    final n = _chapterNumber(chapter);
    if (n == null) return null;
    for (final e in _divChapters.entries) {
      if (e.value.contains(n)) return e.key;
    }
    return null;
  }

  /// বিভাগভিত্তিক কোটা মেনে প্রশ্ন বাছাই (ঘাটতি হলে বাকি বিভাগ থেকে পূরণ)
  List<T> _pickByQuota<T>(
      List<T> pool, Map<String, int> quota, String Function(T) chapterOf) {
    final byDiv = <String, List<T>>{for (final d in quota.keys) d: []};
    final spare = <T>[];
    final shuffled = List<T>.from(pool)..shuffle();
    for (final q in shuffled) {
      final d = _divisionOf(chapterOf(q));
      if (d != null && byDiv.containsKey(d)) {
        byDiv[d]!.add(q);
      } else {
        spare.add(q);
      }
    }
    final out = <T>[];
    final overflow = <T>[];
    quota.forEach((d, need) {
      final list = byDiv[d]!;
      out.addAll(list.take(need));
      overflow.addAll(list.skip(need));
    });
    overflow.addAll(spare);
    overflow.shuffle();
    final total = quota.values.fold<int>(0, (a, b) => a + b);
    if (out.length < total) out.addAll(overflow.take(total - out.length));
    out.shuffle();
    return out;
  }

  // ── সংক্ষিপ্ত-উত্তরে রূপান্তরযোগ্য MCQ কিনা ───────────────────────
  // অপশন ছাড়া যে প্রশ্ন একা একা দাঁড়ায়, সেটিই ২ মার্কের সংক্ষিপ্ত প্রশ্ন হয়।
  static const _saqBad = [
    'কোনটি', 'কোনটির', 'কোন বাক্য', 'নিচের', 'নিচে', 'কোন সূত্র', 'কোন শ্রেণি',
    'কোন চতুর্ভুজ', 'কোন সেটটি', 'কোন জোড়া', 'কোন অনুক্রম', 'কোন ধারা',
    'কোন বিন্দুতে', 'কোন জোট', 'কোন ক্ষেত্রে', 'কোন প্রকার', 'কোন ধরনের',
    'কোন সংখ্যা', 'কোন অংশে', 'উল্লেখ করো', '—', 'কোন অবস্থান', 'কোন বিন্দু',
    'কোন ত্রিভুজ', 'কোন চতুর্ভুজের', 'কোন ভগ্নাংশ', 'কোন সমীকরণ',
  ];

  bool _saqOk(String text) => !_saqBad.any((b) => text.contains(b));

  List<String> get _chapters {
    if (_subject == null) return [];
    final set = <String>{
      ...allMCQs.where((q) => q.subjectId == _subject!.id).map((q) => q.chapter),
      ...allCQs.where((q) => q.subjectId == _subject!.id).map((q) => q.chapter),
    };
    return set.toList()..sort();
  }

  // ── পেপার তৈরি ────────────────────────────────────────────────────
  Future<void> _generate() async {
    if (_subject == null) return;
    if (_mode == 'chapter' && _chapter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('এই বিষয়ে অধ্যায় নেই — "ফুল মডেল টেস্ট পেপার" বাছাই করো')),
      );
      return;
    }

    setState(() {
      _busy = true;
      _generated = false;
      _note = null;
    });

    final sid = _subject!.id;
    final pat = _patternFor(sid);
    final isFull = _mode == 'full';
    final mcqNeed = isFull ? pat.mcqCount : 10;
    final cqNeed = isFull ? pat.cqCount : 2;
    final saqNeed = isFull ? pat.saqCount : 0;

    final bankMcqs = (_mode == 'chapter'
            ? allMCQs.where((q) => q.subjectId == sid && q.chapter == _chapter)
            : allMCQs.where((q) => q.subjectId == sid))
        .toList();
    final bankCqs = (_mode == 'chapter'
            ? allCQs.where((q) => q.subjectId == sid && q.chapter == _chapter)
            : allCQs.where((q) => q.subjectId == sid))
        .toList();

    List<Question> mcqs;
    List<CreativeQuestion> cqs;
    if (isFull && pat.mathDivisions) {
      // বোর্ডের বিভাগ-কোটা: বীজগণিত ১২, জ্যামিতি ১১, ত্রিকোণ+পরিমিতি ৪, পরিসংখ্যান ৩
      mcqs = _pickByQuota(bankMcqs, const {
        'বীজগণিত': 12,
        'জ্যামিতি': 11,
        'ত্রিকোণমিতি ও পরিমিতি': 4,
        'পরিসংখ্যান': 3,
      }, (q) => q.chapter);
      // সৃজনশীল: প্রতি বিভাগ থেকে ২টি করে মোট ৮টি
      cqs = _pickByQuota(bankCqs, const {
        'বীজগণিত': 2,
        'জ্যামিতি': 2,
        'ত্রিকোণমিতি ও পরিমিতি': 2,
        'পরিসংখ্যান': 2,
      }, (q) => q.chapter);
    } else {
      mcqs = List<Question>.from(bankMcqs)..shuffle();
      cqs = List<CreativeQuestion>.from(bankCqs)..shuffle();
    }

    // ভান্ডারে কম থাকলে AI দিয়ে পূরণ (Gemini key থাকলে)
    final hasKey = _apiKey != null && _apiKey!.isNotEmpty;
    if ((mcqs.length < mcqNeed || cqs.length < cqNeed) && hasKey) {
      final chapterLabel = _mode == 'chapter' ? (_chapter ?? 'সাধারণ') : 'সব অধ্যায়';
      try {
        if (mcqs.length < mcqNeed) {
          final gen = await AiQuestionGenerator.generateMcqs(
            apiKey: _apiKey!,
            subjectName: _subject!.name,
            chapter: chapterLabel,
            sourceText: '',
            count: mcqNeed - mcqs.length,
          );
          mcqs = [...mcqs, ...gen]..shuffle();
        }
      } catch (e) {
        _note = 'MCQ পূরণে সমস্যা: ${e.toString().replaceFirst('Exception: ', '')}';
      }
      try {
        if (cqs.length < cqNeed) {
          final gen = await AiQuestionGenerator.generateCqs(
            apiKey: _apiKey!,
            subjectName: _subject!.name,
            chapter: chapterLabel,
            sourceText: '',
            count: cqNeed - cqs.length,
          );
          cqs = [...cqs, ...gen]..shuffle();
        }
      } catch (e) {
        _note = 'CQ পূরণে সমস্যা: ${e.toString().replaceFirst('Exception: ', '')}';
      }
    }

    final pickedMcqs = mcqs.take(mcqNeed).toList();
    final pickedCqs = cqs.take(cqNeed).toList();

    // সংক্ষিপ্ত-উত্তর বাছাই (MCQ-র সঙ্গে ডুপ্লিকেট হবে না)
    List<Question> saqs = [];
    if (saqNeed > 0) {
      final used = pickedMcqs.map((q) => q.id).toSet();
      final pool = bankMcqs
          .where((q) => !used.contains(q.id) && _saqOk(q.questionText))
          .toList()
        ..shuffle();
      saqs = pool.take(saqNeed).toList();
    }

    if (!mounted) return;
    setState(() {
      _busy = false;
      _generated = true;
      _showAnswerKey = false;
      // Demo সীমা প্রয়োগ
      _mcqs = _isPro
          ? pickedMcqs
          : pickedMcqs.take(PaperLicense.demoMcqLimit).toList();
      _cqs = _isPro
          ? pickedCqs
          : pickedCqs.take(PaperLicense.demoCqLimit).toList();
      _saqs = _isPro ? saqs : saqs.take(5).toList();
      if (!hasKey && (mcqs.isEmpty && cqs.isEmpty)) {
        _note = 'এই বিষয়ে প্রশ্নভান্ডারে প্রশ্ন নেই। AI দিয়ে তৈরি করতে AI টিউটর পেজের 🔑 থেকে Gemini API Key সংরক্ষণ করো।';
      }
    });
  }

  // ── প্রো আনলক ডায়ালগ ─────────────────────────────────────────────
  Future<void> _showUnlockDialog() async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pro আনলক (টিউটর ভার্সন)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Demo তে থাকে সীমিত প্রশ্ন ও "DEMO" ওয়াটারমার্ক।\n'
              'Pro তে পূর্ণাঙ্গ পেপার, ওয়াটারমার্ক ছাড়া, প্রিন্ট সুবিধা।\n',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                hintText: 'অ্যাক্টিভেশন কোড (XXXX-XXXX)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('বাতিল')),
          FilledButton(
            onPressed: () async {
              final success = await PaperLicense.activate(controller.text);
              if (context.mounted) Navigator.pop(context, success);
            },
            child: const Text('আনলক'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      setState(() => _isPro = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Pro আনলক হয়েছে! নতুন করে পেপার তৈরি করো।')),
      );
    } else if (ok == false && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('কোডটি সঠিক নয়।')),
      );
    }
  }

  Future<void> _onPrintTap() async {
    if (!_isPro) {
      _showUnlockDialog();
      return;
    }
    if (!_generated) return;
    final isFull = _mode == 'full';
    final pat = _patternFor(_subject!.id);
    // স্কুল-বোর্ড স্টাইল: লিখিত পত্র ও বহুনির্বাচনি পত্রের আলাদা সময়/মান
    final int wMarks = _mode == 'chapter'
        ? _cqs.length * 10
        : pat.cqAnswerCount * 10 + pat.saqAnswerCount * 2;
    final int mMarks = _mode == 'chapter' ? _mcqs.length : pat.mcqCount;
    final String wTime = _mode == 'chapter'
        ? '৪০ মিনিট'
        : (pat.totalMarks == 75 ? '২ ঘণ্টা' : '২ ঘণ্টা ৩০ মিনিট');
    final String mTime = _mode == 'chapter'
        ? '২০ মিনিট'
        : (pat.totalMarks == 75 ? '২৫ মিনিট' : '৩০ মিনিট');
    try {
      await PaperPdf.printPaper(
        title: '${_subject!.name} (${_subject!.bengaliName})',
        modeLine: _mode == 'chapter' ? (_chapter ?? '') : 'ফুল মডেল টেস্ট পেপার',
        mcqs: _mcqs,
        cqs: _cqs,
        saqs: _saqs,
        time: _mode == 'chapter' ? '১ ঘণ্টা' : '৩ ঘণ্টা',
        marks: _mode == 'chapter' ? _bn(30) : _bn(pat.totalMarks),
        cqAnswerCount: _mode == 'chapter' ? _cqs.length : pat.cqAnswerCount,
        saqAnswerCount: pat.saqAnswerCount,
        cqNote: (isFull && pat.mathDivisions)
            ? '(ক, খ, গ ও ঘ — প্রত্যেক বিভাগ থেকে ন্যূনতম ১টি সহ যেকোনো ${_bn(pat.cqAnswerCount)}টি প্রশ্নের উত্তর দাও। প্রতিটি প্রশ্নের মান ১০)'
            : null,
        writtenTime: wTime,
        writtenMarks: _bn(wMarks),
        mcqTime: mTime,
        mcqMarks: _bn(mMarks),
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('প্রিন্ট চালু করা গেল না'),
          content: Text(
            'সমস্যা: $e\n\nassets/fonts/ ফোল্ডারে NotoSerifBengali-Regular.ttf, NotoSerifBengali-Bold.ttf ও HindSiliguri-Regular.ttf ফাইলগুলো আছে কিনা দেখো।',
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ঠিক আছে'),
            ),
          ],
        ),
      );
    }
  }

  // ── UI ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('প্রশ্নপত্র (প্রিন্ট-রেডি)'),
        actions: [
          TextButton.icon(
            onPressed: _showUnlockDialog,
            icon: Icon(_isPro ? Icons.verified : Icons.lock_outline,
                color: _isPro ? AppTheme.accent : Colors.white70, size: 18),
            label: Text(
              _isPro ? 'PRO' : 'DEMO',
              style: TextStyle(
                color: _isPro ? AppTheme.accent : Colors.white70,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _configCard(),
          const SizedBox(height: 14),
          if (_note != null) _noteCard(),
          if (_busy)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('পেপার তৈরি হচ্ছে...\nAI প্রশ্ন পূরণ হলে কিছু সময় লাগতে পারে',
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          else if (_generated)
            ..._paperPages()
          else
            _hintCard('বিষয় ও ধরন বেছে "প্রশ্নপত্র তৈরি করো" চাপো।'),
        ],
      ),
    );
  }

  String _patternInfoLine() {
    final p = _patternFor(_subject?.id ?? 'general_math');
    final line =
        'সৃজনশীল ${_bn(p.cqCount)}টি (${_bn(p.cqAnswerCount)}×১০ = ${_bn(p.cqAnswerCount * 10)})'
        ' + সংক্ষিপ্ত ${_bn(p.saqCount)}টি (${_bn(p.saqAnswerCount)}×২ = ${_bn(p.saqAnswerCount * 2)})'
        ' + MCQ ${_bn(p.mcqCount)}';
    final extra = p.totalMarks == 75 ? ' (তত্ত্বীয়; ব্যবহারিক ২৫ আলাদা)' : '';
    return '📄 SSC-2027 নতুন কাঠামো: $line • মোট ${_bn(p.totalMarks)}$extra • সময় ৩ ঘণ্টা';
  }

  Widget _configCard() {
    final chapters = _chapters;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<SubjectInfo>(
            value: _subject,
            decoration: const InputDecoration(labelText: 'বিষয়'),
            items: allSubjects
                .map((s) => DropdownMenuItem(value: s, child: Text('${s.icon}  ${s.name}')))
                .toList(),
            onChanged: (s) {
              final set = <String>{
                ...allMCQs.where((q) => q.subjectId == s!.id).map((q) => q.chapter),
                ...allCQs.where((q) => q.subjectId == s!.id).map((q) => q.chapter),
              }.toList()
                ..sort();
              setState(() {
                _subject = s;
                _chapter = set.isNotEmpty ? set.first : null;
                _generated = false;
              });
            },
            hint: const Text('বিষয় বাছাই করো'),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                  value: 'chapter',
                  label: Text('অধ্যায়ভিত্তিক পেপার'),
                  icon: Icon(Icons.bookmark_outline)),
              ButtonSegment(
                  value: 'full',
                  label: Text('ফুল মডেল টেস্ট পেপার'),
                  icon: Icon(Icons.description_rounded)),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() {
              _mode = s.first;
              _generated = false;
            }),
          ),
          if (_mode == 'chapter') ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _chapter,
              decoration: const InputDecoration(labelText: 'অধ্যায়'),
              items: chapters
                  .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (c) => setState(() {
                _chapter = c;
                _generated = false;
              }),
              hint: const Text('অধ্যায় বাছাই করো'),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            _mode == 'chapter'
                ? '📄 কাঠামো: MCQ ${_bn(10)} + সৃজনশীল ${_bn(2)}  •  পূর্ণমান ${_bn(30)}  •  সময় ১ ঘণ্টা'
                : _patternInfoLine(),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'প্রশ্নপত্র তৈরি করো',
            icon: Icons.auto_fix_high,
            onPressed: _busy ? null : _generate,
          ),
        ],
      ),
    );
  }

  Widget _noteCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.4)),
      ),
      child: Text(_note!, style: const TextStyle(fontSize: 12.5, height: 1.5)),
    );
  }

  Widget _hintCard(String text) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(Icons.library_books_outlined, size: 44, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(text, textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  // ── প্রিন্ট-স্টাইল পেপার (মানুষের তৈরির মতো দেখতে) ────────────────
  TextStyle get _serifTitle =>
      const TextStyle(fontFamily: 'serif', fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black, height: 1.5);
  TextStyle get _serifBody =>
      const TextStyle(fontFamily: 'serif', fontSize: 13.5, color: Colors.black87, height: 1.65);
  TextStyle get _serifSmall =>
      TextStyle(fontFamily: 'serif', fontSize: 12, color: Colors.grey.shade800, height: 1.5);

  List<Widget> _paperPages() {
    final isFull = _mode == 'full';
    final pat = _patternFor(_subject!.id);
    final time = _mode == 'chapter' ? '১ ঘণ্টা' : '৩ ঘণ্টা';
    final marks = _mode == 'chapter' ? _bn(30) : _bn(pat.totalMarks);
    final cqAnswerCount = _mode == 'chapter' ? _cqs.length : pat.cqAnswerCount;
    final cqNote = (isFull && pat.mathDivisions)
        ? '(ক, খ, গ ও ঘ — প্রত্যেক বিভাগ থেকে ন্যূনতম ১টি সহ যেকোনো ${_bn(pat.cqAnswerCount)}টি প্রশ্নের উত্তর দাও। প্রতিটি প্রশ্নের মান ১০)'
        : '(যেকোনো ${_bn(cqAnswerCount)}টি প্রশ্নের উত্তর দাও। প্রতিটি প্রশ্নের মান ১০)';

    String divLetter() {
      if (_saqs.isNotEmpty) return 'গ';
      if (_cqs.isNotEmpty) return 'খ';
      return 'ক';
    }

    return [
      Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4), // কাগজের মতো সরু কোণা
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.16), blurRadius: 18, offset: const Offset(0, 8))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── পেপার হেডার ──
                Center(
                  child: Column(
                    children: [
                      Text('মডেল টেস্ট পেপার — SSC 2027', style: _serifTitle),
                      const SizedBox(height: 2),
                      Text('(বাংলাদেশ শিক্ষাবোর্ড নতুন প্রশ্ন-কাঠামো অনুপ্রাণিত)', style: _serifSmall),
                      const SizedBox(height: 6),
                      Text(
                        'বিষয়: ${_subject!.name} (${_subject!.bengaliName})'
                        '${_mode == 'chapter' && _chapter != null ? '  •  $_chapter' : ''}',
                        style: _serifSmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _doubleDivider(),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('সময়: $time', style: _serifSmall),
                    Text('পূর্ণমান: $marks', style: _serifSmall),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'দ্রষ্টব্য: বিশেষভাবে উল্লেখ না থাকলে সব প্রশ্নের উত্তর দিতে হবে। উত্তরপত্রে প্রশ্নের ক্রমিক নম্বর স্পষ্টভাবে লিখতে হবে।',
                  style: _serifSmall.copyWith(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 10),
                _doubleDivider(),

                // ── বিভাগ-ক: সৃজনশীল ──
                if (_cqs.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Center(child: Text('বিভাগ — ক\nসৃজনশীল প্রশ্ন', textAlign: TextAlign.center, style: _serifTitle.copyWith(fontSize: 14.5))),
                  const SizedBox(height: 4),
                  Center(child: Text(cqNote, style: _serifSmall, textAlign: TextAlign.center)),
                  const SizedBox(height: 8),
                  ...List.generate(_cqs.length, (i) => _cqBlock(i + 1, _cqs[i])),
                ],

                // ── বিভাগ-খ: সংক্ষিপ্ত-উত্তর (SSC-2027 নতুন অংশ) ──
                if (_saqs.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _doubleDivider(),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      '${_cqs.isNotEmpty ? 'বিভাগ — খ' : 'বিভাগ — ক'}\nসংক্ষিপ্ত-উত্তর প্রশ্ন',
                      textAlign: TextAlign.center,
                      style: _serifTitle.copyWith(fontSize: 14.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      '(যেকোনো ${_bn(pat.saqAnswerCount)}টি প্রশ্নের উত্তর দাও। প্রতিটি প্রশ্নের মান ২)',
                      style: _serifSmall,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_saqs.length, (i) => _saqBlock(i + 1, _saqs[i])),
                ],

                // ── শেষ বিভাগ: বহুনির্বাচনি (MCQ) ──
                if (_mcqs.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _doubleDivider(),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'বিভাগ — ${divLetter()}\nবহুনির্বাচনি প্রশ্ন (MCQ)',
                      textAlign: TextAlign.center,
                      style: _serifTitle.copyWith(fontSize: 14.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text('(সবগুলো প্রশ্নের উত্তর দাও)', style: _serifSmall),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_mcqs.length, (i) => _mcqBlock(i + 1, _mcqs[i])),
                ],

                const SizedBox(height: 16),
                _doubleDivider(),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    _isPro ? '— শেষ —' : '— DEMO সংস্করণ (সীমিত প্রশ্ন) —',
                    style: _serifSmall.copyWith(
                      color: _isPro ? Colors.grey.shade800 : Colors.red.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // DEMO ওয়াটারমার্ক
          if (!_isPro)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Transform.rotate(
                    angle: -0.45,
                    child: Text(
                      'DEMO',
                      style: TextStyle(
                        fontSize: 90,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.withOpacity(0.10),
                        letterSpacing: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      _actionRow(),
      const SizedBox(height: 12),
      if (_showAnswerKey) _answerKeyCard(),
      const SizedBox(height: 30),
    ];
  }

  Widget _doubleDivider() {
    return Column(
      children: [
        Container(height: 1.4, color: Colors.black54),
        const SizedBox(height: 2.5),
        Container(height: 1.4, color: Colors.black54),
      ],
    );
  }

  Widget _mcqBlock(int no, Question q) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_bn(no)}। ${q.questionText}', style: _serifBody),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 22),
            child: Wrap(
              spacing: 18,
              runSpacing: 2,
              children: List.generate(
                q.options.length,
                (i) => Text('${_optionLetters[i]}) ${q.options[i]}',
                    style: _serifBody.copyWith(fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _saqBlock(int no, Question q) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text('${_bn(no)}। ${q.questionText}', style: _serifBody),
          ),
          Text('— ${_bn(2)}', style: _serifSmall),
        ],
      ),
    );
  }

  Widget _cqBlock(int no, CreativeQuestion cq) {
    Widget part(String letter, String text, int mark) {
      return Padding(
        padding: const EdgeInsets.only(left: 22, top: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text('$letter) $text', style: _serifBody)),
            Text('— ${_bn(mark)}', style: _serifSmall),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_bn(no)}। ${cq.stem}', style: _serifBody),
          part('ক', cq.questionK, cq.marks.isNotEmpty ? cq.marks[0] : 1),
          part('খ', cq.questionKh, cq.marks.length > 1 ? cq.marks[1] : 2),
          part('গ', cq.questionG, cq.marks.length > 2 ? cq.marks[2] : 3),
          part('ঘ', cq.questionGh, cq.marks.length > 3 ? cq.marks[3] : 4),
        ],
      ),
    );
  }

  Widget _actionRow() {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: 'উত্তরমালা',
            icon: Icons.key_rounded,
            outlined: true,
            onPressed: _isPro
                ? () => setState(() => _showAnswerKey = !_showAnswerKey)
                : _showUnlockDialog,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AppButton(
            label: 'PDF / প্রিন্ট',
            icon: Icons.print_rounded,
            onPressed: _onPrintTap,
          ),
        ),
      ],
    );
  }

  Widget _answerKeyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.secondary.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('উত্তরমালা (MCQ)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const Divider(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: List.generate(
              _mcqs.length,
              (i) => Text(
                '${_bn(i + 1)}. ${_optionLetters[_mcqs[i].correctIndex]}',
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (_saqs.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text('উত্তরমালা (সংক্ষিপ্ত-উত্তর)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const Divider(height: 16),
            ...List.generate(
              _saqs.length,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${_bn(i + 1)}। ${_saqs[i].options[_saqs[i].correctIndex]}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
