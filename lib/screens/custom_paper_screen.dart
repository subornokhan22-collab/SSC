import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/english_board_data.dart';
import '../data/english_first_data.dart';
import '../data/questions_data.dart';
import '../services/ai_question_generator.dart';
import '../services/app_style.dart';
import '../services/english_paper_adapter.dart';
import '../services/paper_license.dart';
import '../services/paper_pdf.dart';
import 'subscription_screen.dart';
import 'subjects_screen.dart';

/// কাস্টমাইজড টেস্ট পেপার — বিষয়, অধ্যায় (একাধিক), আর MCQ/সংক্ষিপ্ত/CQ-এর
/// ***সংখ্যা*** টিউটর নিজে ঠিক করে (মান হিসেব অ্যাপই করে)।
/// মান: সৃজনশীল ১০, সংক্ষিপ্ত ২, MCQ ১ — প্রচলিত নিয়মেই।
class CustomPaperScreen extends StatefulWidget {
  const CustomPaperScreen({super.key});

  @override
  State<CustomPaperScreen> createState() => _CustomPaperScreenState();
}

class _CustomPaperScreenState extends State<CustomPaperScreen> {
  SubjectInfo? _subject;
  final Set<String> _chapters = {}; // খালি থাকলে সব অধ্যায়
  int _mcqN = 15;
  int _saqN = 5;
  int _cqN = 3;
  bool _busy = false;
  String? _apiKey;
  bool _mixAi = false; // 🤖 AI প্রশ্ন ব্যাংকের সাথে মেশাবে কি না
  int _aiShare = 50;   // পেপারে AI প্রশ্নের শতাংশ (25/50/75)
  final TextEditingController _titleCtrl =
      TextEditingController(text: 'মডেল পরীক্ষা — ২০২৭');
  String _setLetter = 'ক';
  static const _setLetters = ['ক', 'খ', 'গ', 'ঘ'];
  static const _subjectCodes = {
    'general_math': '১০৯',
    'physics': '১৩৬',
    'chemistry': '১৩৭',
    'biology': '১৩৮',
    'higher_math': '১২৬',
    'ict': '১৫৪',
  };

  static const _gold = Color(0xFFF7C948);

  // ── English বিষয় শনাক্তকরণ (id-সহনশীল) ────────────────────────
  static bool _isEnglish2nd(String? id) {
    if (id == null) return false;
    final s = id.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
    return s.contains('english') && (s.contains('2') || s.contains('second'));
  }

  static bool _isEnglish1st(String? id) {
    if (id == null) return false;
    final s = id.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
    return s.contains('english') && (s.contains('1') || s.contains('first'));
  }

  bool get _isEnglish =>
      _isEnglish1st(_subject?.id) || _isEnglish2nd(_subject?.id);

  @override
  void initState() {
    super.initState();
    AppStyle.load();
    SharedPreferences.getInstance().then((p) {
      if (!mounted) return;
      setState(() {
        _apiKey = p.getString('gemini_api_key');
        final idx = p.getInt('paper_set_idx') ?? 0;
        _setLetter = _setLetters[idx % _setLetters.length];
      });
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  /// প্রতিবার পেপার তৈরিতে সেট কোড পরেরটায় সরে যায় (ক→খ→গ→ঘ→ক...)
  Future<void> _advanceSetCode() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = _setLetters.indexOf(_setLetter);
    final next = ((idx < 0 ? 0 : idx) + 1) % _setLetters.length;
    await prefs.setInt('paper_set_idx', next);
  }

  String get _titleText => _titleCtrl.text.trim().isEmpty
      ? 'মডেল পরীক্ষা — ২০২৭'
      : _titleCtrl.text.trim();

  // প্রিন্ট-অযোগ্য MCQ বাদ দেওয়ার ছাঁক (question_paper_screen-এর মতোই)
  static const _saqBad = [
    'কোনটি', 'কোনটির', 'কোন বাক্য', 'নিচের', 'নিচে', 'কোন সূত্র', 'কোন শ্রেণি',
    'কোন চতুর্ভুজ', 'কোন সেটটি', 'কোন জোড়া', 'কোন অনুক্রম', 'কোন ধারা',
    'কোন বিন্দুতে', 'কোন জোট', 'কোন ক্ষেত্রে', 'কোন প্রকার', 'কোন ধরনের',
    'কোন সংখ্যা', 'কোন অংশে', 'উল্লেখ করো', '—', 'কোন অবস্থান', 'কোন বিন্দু',
    'কোন ত্রিভুজ', 'কোন চতুর্ভুজের', 'কোন ভগ্নাংশ', 'কোন সমীকরণ',
  ];

  static String _bn(int n) {
    const d = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return n.toString().split('').map((c) {
      final code = c.codeUnitAt(0);
      return (code >= 48 && code <= 57) ? d[code - 48] : c;
    }).join();
  }

  List<String> get _availableChapters {
    if (_subject == null) return [];
    final set = <String>{
      ...allMCQs.where((q) => q.subjectId == _subject!.id).map((q) => q.chapter),
      ...allCQs.where((q) => q.subjectId == _subject!.id).map((q) => q.chapter),
    };
    return set.toList()..sort();
  }

  Widget _stepper(String label, int value, void Function(int) onChanged,
      {int max = 30}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _gold.withOpacity(0.0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
          ),
          IconButton(
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
            visualDensity: VisualDensity.compact,
          ),
          SizedBox(
            width: 34,
            child: Center(
              child: Text(_bn(value),
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w800)),
            ),
          ),
          IconButton(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_circle_outline),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  String _timeLine(int minutes) {
    if (minutes <= 0) return '—';
    final h = minutes ~/ 60, m = minutes % 60;
    if (h == 0) return '$m min';
    if (m == 0) return '$h hr';
    return '$h hr $m min';
  }

  Future<void> _print() async {
    if (_subject == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Choose a subject first')));
      return;
    }
    if (_mcqN == 0 && _saqN == 0 && _cqN == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keep at least one question type')));
      return;
    }
    final pro = await PaperLicense.isPro();
    if (!pro) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pro Required'),
          content: const Text(
              'Custom paper printing is a Pro feature — unlock Pro first.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SubscriptionScreen()));
              },
              child: const Text('Subscription'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final sid = _subject!.id;

      // ── English 1st/2nd: mixed board paper (প্রতিটি প্রশ্ন আলাদা বোর্ডের)
      // + ঐচ্ছিক AI অতিরিক্ত — সংখ্যা-সিলেক্টরের দরকার নেই ──
      if (_isEnglish) {
        List<Question> aiMcqs = const [];
        final hasKey = _apiKey != null && _apiKey!.isNotEmpty;
        if (_mixAi && hasKey) {
          try {
            final n = _aiShare == 25 ? 3 : (_aiShare == 75 ? 8 : 5);
            aiMcqs = await AiQuestionGenerator.generateMcqs(
              apiKey: _apiKey!,
              subjectName: _isEnglish2nd(sid)
                  ? 'English Second Paper (Board-2024 style)'
                  : 'English First Paper (Board-2024 style)',
              chapter: 'Board-style mixed paper 2024',
              sourceText: '',
              count: n,
            );
          } catch (_) {/* ব্যাংক-প্রশ্নেই থাকুক */}
        } else if (_mixAi && !hasKey) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(
                    'AI mixing needs a saved 🔑 Gemini API key — printing board questions only.')));
          }
        }
        final ttl = _titleCtrl.text.trim().isEmpty
            ? 'Model Test'
            : _titleCtrl.text.trim();
        if (_isEnglish2nd(sid)) {
          final m = EnglishBoardMixer.mix();
          await PaperPdf.printEnglishPaper(
            paperTitle: ttl,
            subTitle: 'English (Compulsory)–Second Paper   [Subject Code: 108]',
            sections: [
              ...EnglishPaperAdapter.second(m.set),
              if (aiMcqs.isNotEmpty) EnglishPaperAdapter.aiSection(aiMcqs),
            ],
          );
        } else {
          final m = EnglishFirstMixer.mix();
          await PaperPdf.printEnglishPaper(
            paperTitle: ttl,
            subTitle: 'English (Compulsory)–First Paper   [Subject Code: 107]',
            sections: [
              ...EnglishPaperAdapter.first(m.set),
              if (aiMcqs.isNotEmpty) EnglishPaperAdapter.aiSection(aiMcqs),
            ],
          );
        }
        return;
      }

      bool ok(String ch) => _chapters.isEmpty || _chapters.contains(ch);
      final mcqPool = allMCQs
          .where((q) => q.subjectId == sid && ok(q.chapter))
          .toList()
        ..shuffle();
      final cqPool = allCQs
          .where((q) => q.subjectId == sid && ok(q.chapter))
          .toList()
        ..shuffle();

      // 🤖 AI মিক্স: চাওয়া সংখ্যার নির্দিষ্ট শতাংশ AI-এর নতুন প্রশ্ন
      List<Question> aiMcqs = const [];
      List<CreativeQuestion> aiCqs = const [];
      final hasKey = _apiKey != null && _apiKey!.isNotEmpty;
      if (_mixAi && hasKey) {
        final chapLabel =
            _chapters.isEmpty ? 'সব অধ্যায় মিলিয়ে' : _chapters.join(', ');
        try {
          final aiMcqNeed = (_mcqN * _aiShare / 100).round();
          if (aiMcqNeed > 0) {
            aiMcqs = await AiQuestionGenerator.generateMcqs(
              apiKey: _apiKey!,
              subjectName: _subject!.name,
              chapter: chapLabel,
              sourceText: '',
              count: aiMcqNeed,
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'AI MCQs could not be mixed — using bank questions. ($e)')));
          }
        }
        try {
          final aiCqNeed = (_cqN * _aiShare / 100).round();
          if (aiCqNeed > 0) {
            aiCqs = await AiQuestionGenerator.generateCqs(
              apiKey: _apiKey!,
              subjectName: _subject!.name,
              chapter: chapLabel,
              sourceText: '',
              count: aiCqNeed,
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'AI creative questions could not be mixed — using bank questions. ($e)')));
          }
        }
      }

      final mcqBankN = _mcqN - aiMcqs.length;
      final cqBankN = _cqN - aiCqs.length;
      final mcqs = [
        ...mcqPool.take(mcqBankN < 0 ? 0 : mcqBankN),
        ...aiMcqs,
      ]..shuffle();
      final cqs = [
        ...cqPool.take(cqBankN < 0 ? 0 : cqBankN),
        ...aiCqs,
      ];
      final usedIds = mcqs.map((q) => q.id).toSet();
      final saqPool = mcqPool
          .where((q) =>
              !usedIds.contains(q.id) &&
              !_saqBad.any((b) => q.questionText.contains(b)))
          .toList();
      // জটিল SQ আগে: কঠিন নতুন সেট (_x) + গাণিতিক টোকেন + দীর্ঘ প্রশ্ন
      int saqScore(Question q) {
        var s = 0;
        if (q.id.contains('_x')) s += 2;
        if (RegExp(r'[০-৯0-9√°²=^x]').hasMatch(q.questionText)) s += 1;
        if (q.questionText.length > 42) s += 1;
        return s;
      }

      final hardSaq = saqPool.where((q) => saqScore(q) >= 3).toList()..shuffle();
      final easySaq = saqPool.where((q) => saqScore(q) < 3).toList()..shuffle();
      final saqs = [...hardSaq, ...easySaq].take(_saqN).toList();

      // সেট কোড পরের পেপারের জন্য এক ঘর সরে যাবে
      _advanceSetCode();

      final wMin = cqs.length * 12 + saqs.length * 3;
      final mMin = mcqs.length;
      final isMath = sid == 'general_math' || sid == 'higher_math';

      await PaperPdf.printPaper(
        title: '${_subject!.name} (${_subject!.bengaliName})',
        modeLine: _chapters.isEmpty
            ? 'ফুল সিলেবাস'
            : (_chapters.length <= 2
                ? _chapters.join(', ')
                : '${_bn(_chapters.length)}টি অধ্যায় মিলিয়ে'),
        mcqs: mcqs,
        cqs: cqs,
        saqs: saqs,
        cqAnswerCount: cqs.length,
        saqAnswerCount: saqs.length,
        cqNote: cqs.isEmpty
            ? null
            : '(সবগুলো সৃজনশীল প্রশ্নের উত্তর দাও। প্রতিটি প্রশ্নের মান ১০)',
        writtenTime: _timeLine(wMin),
        writtenMarks: _bn(cqs.length * 10 + saqs.length * 2),
        mcqTime: _timeLine(mMin),
        mcqMarks: _bn(mcqs.length),
        time: _timeLine(wMin + mMin),
        marks: _bn(cqs.length * 10 + saqs.length * 2 + mcqs.length),
        mathCqThreePart: isMath,
        headerLine1: _titleText,
        subjectCode: _subjectCodes[sid],
        setCode: _setLetter,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ── 🤖 AI মিক্স কার্ড (কালো-সোনালি থিম) ─────────────────────────
  Widget _aiMixCard() {
    final hasKey = _apiKey != null && _apiKey!.isNotEmpty;
    if (!hasKey) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF17130A),
            side: const BorderSide(color: Color(0xFF17130A)),
          ),
          onPressed: _showApiKeyDialog,
          icon: const Icon(Icons.vpn_key_outlined, size: 18),
          label: const Text('🔑 Set a Gemini API key (to mix AI questions)'),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _gold.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: _mixAi,
            onChanged: (v) => setState(() => _mixAi = v),
            title: const Text('🤖 Mix AI questions with the bank',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
            subtitle: Text('Fresh AI questions blended with the bank',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ),
          if (_mixAi) ...[
            const Text('How much AI content:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 25, label: Text('25%')),
                ButtonSegment(value: 50, label: Text('50%')),
                ButtonSegment(value: 75, label: Text('75%')),
              ],
              selected: {_aiShare},
              onSelectionChanged: (s) => setState(() => _aiShare = s.first),
            ),
            const SizedBox(height: 6),
            Text(
              'With AI mixing, internet is required — generation may take 20–40 seconds. Review the questions before printing.',
              style: TextStyle(
                  fontSize: 10.5, color: Colors.grey.shade600, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showApiKeyDialog() async {
    final controller = TextEditingController(text: _apiKey ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔑 Gemini API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1) Open your phone browser: aistudio.google.com\n'
              '2) Sign in with your Google account\n'
              '3) Tap \"Get API key\" → \"Create API key\"\n'
              '4) Copy the free key and paste it below — needed only once.',
              style: TextStyle(fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Paste the key that starts with AIza...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      final prefs = await SharedPreferences.getInstance();
      final key = controller.text.trim();
      await prefs.setString('gemini_api_key', key);
      if (!mounted) return;
      setState(() {
        _apiKey = key.isEmpty ? null : key;
        _mixAi = key.isNotEmpty;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(key.isEmpty
                ? 'Key removed.'
                : '✅ Key saved! AI question mixing is on.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapters = _availableChapters;
    final total = _cqN * 10 + _saqN * 2 + _mcqN;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customised Test Paper'),
        backgroundColor: const Color(0xFF17130A),
        foregroundColor: const Color(0xFFFFE08A),
      ),
      body: AnimatedBuilder(
        animation: AppStyle.bgIndex,
        builder: (context, _) => Container(
          color: AppStyle.bg,
          child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<SubjectInfo>(
                    value: _subject,
                    decoration: const InputDecoration(labelText: 'Subject'),
                    items: allSubjects
                        .map((s) => DropdownMenuItem(
                            value: s, child: Text('${s.icon}  ${s.name}')))
                        .toList(),
                    onChanged: (s) => setState(() {
                      _subject = s;
                      _chapters.clear();
                    }),
                    hint: const Text('Choose a subject'),
                  ),
                  if (chapters.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('Chapters (leave empty to use all)',
                        style: TextStyle(
                            fontSize: 12.5, color: Colors.grey.shade700)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final c in chapters)
                          FilterChip(
                            label: Text(c, style: const TextStyle(fontSize: 12)),
                            selected: _chapters.contains(c),
                            onSelected: (v) => setState(() {
                              v ? _chapters.add(c) : _chapters.remove(c);
                            }),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Paper Title',
                      hintText: 'মডেল পরীক্ষা — ২০২৭',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Subject Code: ${_subjectCodes[_subject?.id] ?? '—'}   •   Set Code: $_setLetter (changes each time)',
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (!_isEnglish) ...[
              _stepper('Number of MCQs', _mcqN, (v) => setState(() => _mcqN = v)),
              const SizedBox(height: 10),
              _stepper('Number of short-answer questions', _saqN, (v) => setState(() => _saqN = v)),
              const SizedBox(height: 10),
              _stepper('Number of creative questions (CQ)', _cqN, (v) => setState(() => _cqN = v)),
              const SizedBox(height: 10),
            ],
            if (_isEnglish)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade100),
                ),
                child: Text(
                  _isEnglish2nd(_subject?.id)
                      ? '📋 English 2nd Paper builds a MIXED board paper (Grammar Q1–9 + Composition Q10–12, Marks 100) — every question from a DIFFERENT board, shuffled each time. AI mixing (optional) adds fresh MCQs at the end.'
                      : '📋 English 1st Paper builds a MIXED board paper (Reading Q1–9 + Writing Q10–11, Marks 100) — every question from a DIFFERENT board, shuffled each time. AI mixing (optional) adds fresh MCQs at the end.',
                  style: TextStyle(
                      fontSize: 12, height: 1.55, color: Colors.teal.shade900),
                ),
              ),
            _aiMixCard(),
            const SizedBox(height: 14),
            if (!_isEnglish)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF17130A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _gold.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calculate_outlined, color: _gold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Marks: $total  •  Time: ${_timeLine(_cqN * 12 + _saqN * 3)} + ${_timeLine(_mcqN)} (MCQ)',
                        style: const TextStyle(
                            color: Color(0xFFFFE08A), fontSize: 13, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF17130A),
                  foregroundColor: const Color(0xFFFFE08A),
                ),
                onPressed: _busy ? null : _print,
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.print_rounded),
                label: Text(_busy ? 'Building paper...' : 'Build & Print Paper'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No need to set marks — Creative = 10, Short-answer = 2, MCQ = 1; time and marks are calculated automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, height: 1.5),
            ),
          ],
        ),
      ),
        ),
    );
  }
}
