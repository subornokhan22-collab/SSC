import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/questions_data.dart';
import '../services/ai_question_generator.dart';
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

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (mounted) setState(() => _apiKey = p.getString('gemini_api_key'));
    });
  }

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

  static const _gold = Color(0xFFF7C948);

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
    if (h == 0) return '${_bn(m)} মিনিট';
    if (m == 0) return '${_bn(h)} ঘণ্টা';
    return '${_bn(h)} ঘণ্টা ${_bn(m)} মিনিট';
  }

  Future<void> _print() async {
    if (_subject == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('আগে বিষয় বাছাই করো')));
      return;
    }
    if (_mcqN == 0 && _saqN == 0 && _cqN == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('কমপক্ষে এক ধরনের প্রশ্ন রাখো')));
      return;
    }
    final pro = await PaperLicense.isPro();
    if (!pro) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pro প্রয়োজন'),
          content: const Text(
              'কাস্টম পেপার প্রিন্ট Pro সাবস্ক্রিপশনের সুবিধা — আগে Pro আনলক করো।'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('বাতিল')),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SubscriptionScreen()));
              },
              child: const Text('সাবস্ক্রিপশন'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final sid = _subject!.id;
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
                    'AI MCQ মেশা যায়নি — ব্যাংকের প্রশ্ন দিয়েই হচ্ছে। ($e)')));
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
                    'AI সৃজনশীল মেশা যায়নি — ব্যাংকের প্রশ্ন দিয়েই হচ্ছে। ($e)')));
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
      final saqs = saqPool.take(_saqN).toList();

      final wMin = cqs.length * 12 + saqs.length * 3;
      final mMin = mcqs.length;
      final isMath = sid == 'general_math' || sid == 'higher_math';

      await PaperPdf.printPaper(
        title: '${_subject!.name} (${_subject!.bengaliName})',
        modeLine: _chapters.isEmpty
            ? 'কাস্টম টেস্ট পেপার'
            : 'কাস্টম টেস্ট — ${_chapters.length <= 2 ? _chapters.join(", ") : "${_bn(_chapters.length)}টি অধ্যায়"}',
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
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('সমস্যা: $e')));
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
          label: const Text('🔑 Gemini API key বসাও (AI প্রশ্ন মেশাতে)'),
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
            title: const Text('🤖 AI প্রশ্ন ব্যাংকের সাথে মেশান',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
            subtitle: Text('নতুন AI প্রশ্ন + ব্যাংকের প্রশ্ন মিশে পেপার হবে',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ),
          if (_mixAi) ...[
            const Text('AI কত শতাংশ:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 25, label: Text('২৫%')),
                ButtonSegment(value: 50, label: Text('৫০%')),
                ButtonSegment(value: 75, label: Text('৭৫%')),
              ],
              selected: {_aiShare},
              onSelectionChanged: (s) => setState(() => _aiShare = s.first),
            ),
            const SizedBox(height: 6),
            Text(
              'AI মেশা থাকলে internet লাগবে ও প্রিন্টের আগে ২০–৪০ সেকেন্ড সময় লাগতে পারে। প্রিন্টের আগে প্রশ্নগুলো পড়ে নিন।',
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
              '১) ফোনের ব্রাউজারে যাও: aistudio.google.com\n'
              '২) Google একাউন্ট দিয়ে লগইন করো\n'
              '৩) "Get API key" → "Create API key" চাপো\n'
              '৪) ফ্রি key-টি কপি করে নিচে বসাও — একবারই লাগবে।',
              style: TextStyle(fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'AIza... দিয়ে শুরু হওয়া key এখানে বসাও',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('বাতিল'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('সংরক্ষণ'),
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
                ? 'Key মুছে ফেলা হয়েছে।'
                : '✅ Key সংরক্ষিত! AI প্রশ্ন মেশানো চালু হলো।')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapters = _availableChapters;
    final total = _cqN * 10 + _saqN * 2 + _mcqN;
    return Scaffold(
      appBar: AppBar(
        title: const Text('কাস্টমাইজড টেস্ট পেপার'),
        backgroundColor: const Color(0xFF17130A),
        foregroundColor: const Color(0xFFFFE08A),
      ),
      body: Container(
        color: const Color(0xFFF7F3EA),
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
                    decoration: const InputDecoration(labelText: 'বিষয়'),
                    items: allSubjects
                        .map((s) => DropdownMenuItem(
                            value: s, child: Text('${s.icon}  ${s.name}')))
                        .toList(),
                    onChanged: (s) => setState(() {
                      _subject = s;
                      _chapters.clear();
                    }),
                    hint: const Text('বিষয় বাছাই করো'),
                  ),
                  if (chapters.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('অধ্যায় (কিছু না বাছলে সব অধ্যায় থেকে আসবে)',
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
                ],
              ),
            ),
            const SizedBox(height: 14),
            _stepper('বহুনির্বাচনি (MCQ) সংখ্যা', _mcqN, (v) => setState(() => _mcqN = v)),
            const SizedBox(height: 10),
            _stepper('সংক্ষিপ্ত-উত্তর সংখ্যা', _saqN, (v) => setState(() => _saqN = v)),
            const SizedBox(height: 10),
            _stepper('সৃজনশীল (CQ) সংখ্যা', _cqN, (v) => setState(() => _cqN = v)),
            const SizedBox(height: 10),
            _aiMixCard(),
            const SizedBox(height: 14),
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
                      'পূর্ণমান: ${_bn(total)}  •  সময়: ${_timeLine(_cqN * 12 + _saqN * 3)} + ${_timeLine(_mcqN)} (MCQ)',
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
                label: Text(_busy ? 'পেপার বানানো হচ্ছে...' : 'পেপার বানাও ও প্রিন্ট'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'মান নিজে ঠিক করতে হবে না — সৃজনশীল ১০, সংক্ষিপ্ত ২, MCQ ১ ধরেই সময় ও পূর্ণমান অ্যাপই গুনে দেয়।',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
