import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/bangla_1st/bangla_1st_literature_questions.dart';
import '../data/english_board_data.dart';
import '../data/english_first_data.dart';
import '../data/questions_data.dart';
import '../services/ai_question_generator.dart';
import '../services/bangla_first_board_pattern.dart';
import '../services/app_style.dart';
import '../services/english_paper_adapter.dart';
import '../services/general_math_board_pattern.dart';
import '../services/ict_board_pattern.dart';
import '../services/paper_license.dart';
import '../services/paper_pdf.dart';
import '../services/chapter_catalog.dart';
import '../services/chapter_source_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import 'subscription_screen.dart';
import 'subjects_screen.dart';

/// কাস্টমাইজড টেস্ট পেপার — UPGRADED v2
/// - Preview added (was missing before)
/// - Full subject codes (PDF verified: 101-156)
/// - Pattern notes for Accounting/Finance/ICT
/// - Same rendering engine as Question Paper Screen (100% match print vs preview)
class CustomPaperScreen extends StatefulWidget {
  /// Opens directly from the Teacher dashboard for a chapter-quantity MCQ PDF + OMR.
  final bool mcqOnly;
  const CustomPaperScreen({super.key, this.mcqOnly = false});

  @override
  State<CustomPaperScreen> createState() => _CustomPaperScreenState();
}

class _CustomPaperScreenState extends State<CustomPaperScreen> {
  SubjectInfo? _subject;
  final Set<String> _chapters = {};
  // Custom MCQ test: one independent quantity for every selected chapter.
  final Map<String, int> _chapterMcqCounts = {};
  int _mcqN = 15;
  int _saqN = 5;
  int _cqN = 3;
  bool _busy = false;
  bool _generated = false;
  bool _isPro = false;
  bool _showAnswerKey = false;
  String? _apiKey;
  bool _mixAi = false;
  bool _mathBoardPattern = false;
  bool _ictBoardPattern = false;
  bool _banglaFirstBoardPattern = false;
  int _aiShare = 50;
  final TextEditingController _titleCtrl =
      TextEditingController(text: 'মডেল পরীক্ষা — ২০২৭');
  String _setLetter = 'ক';
  static const _setLetters = ['ক', 'খ', 'গ', 'ঘ'];

  // PDF verified subject codes – same as question_paper_screen
  static const _subjectCodes = {
    'bangla_1st': '১০১',
    'bangla_2nd': '১০২',
    'english_1st': '১০৭',
    'english_2nd': '১০৮',
    'general_math': '১০৯',
    'religion': '১১১',
    'general_science': '১২৭',
    'agriculture': '১৩৪',
    'higher_math': '১২৬',
    'physics': '১৩৬',
    'chemistry': '১৩৭',
    'biology': '১৩৮',
    'business_ent': '১৪৩',
    'accounting': '১৪৬',
    'physical_edu': '১৪৭',
    'finance': '১৫২',
    'ict': '১৫৪',
    'career': '১৫৬',
    'bgs': '১৫০',
    'history': '১১০',
    'civics': '১৪০',
  };

  static const _gold = Color(0xFFF7C948);

  // English detection
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

  bool get _isGeneralMath => _subject?.id == 'general_math';
  bool get _isMathBoardMode => _isGeneralMath && _mathBoardPattern;
  bool get _isIct => _subject?.id == 'ict';
  bool get _isIctBoardMode => _isIct && _ictBoardPattern;
  bool get _isBanglaFirst => _subject?.id == 'bangla_1st';
  bool get _isBanglaFirstBoardMode =>
      _isBanglaFirst && _banglaFirstBoardPattern;
  bool get _usesAutomaticBoardPattern =>
      _isMathBoardMode || _isIctBoardMode || _isBanglaFirstBoardMode;

  // Preview state (NEW)
  List<Uint8List>? _pagePngs;
  List<Question> _mcqs = [];
  List<CreativeQuestion> _cqs = [];
  List<Question> _saqs = [];
  List<LiteratureQuestion> _literatureQuestions = [];
  EnglishBoardSet? _englishSet;
  EnglishFirstSet? _firstSet;
  List<Question> _eAiMcqs = const [];
  List<int> _e2Src = [];
  List<int> _e1Src = [];

  @override
  void initState() {
    super.initState();
    AppStyle.load();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    final pro = await PaperLicense.isPro();
    if (!mounted) return;
    setState(() {
      _apiKey = p.getString('gemini_api_key');
      _isPro = pro;
      final idx = p.getInt('paper_set_idx') ?? 0;
      _setLetter = _setLetters[idx % _setLetters.length];
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _advanceSetCode() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = _setLetters.indexOf(_setLetter);
    final next = ((idx < 0 ? 0 : idx) + 1) % _setLetters.length;
    await prefs.setInt('paper_set_idx', next);
  }

  String get _titleText => _titleCtrl.text.trim().isEmpty
      ? 'মডেল পরীক্ষা — ২০২৭'
      : _titleCtrl.text.trim();

  /// Renders a curated [ShortQuestion] through the existing [Question]-based
  /// paper pipeline. Only `questionText` is read when printing SAQs, so the
  /// option fields are inert placeholders.
  static Question _saqAsQuestion(ShortQuestion q) => Question(
        id: q.id,
        subjectId: q.subjectId,
        chapter: q.chapter,
        questionText: q.questionText,
        options: const ['', '', '', ''],
        correctIndex: 0,
        explanation: q.explanation.isNotEmpty ? q.explanation : q.answer,
        source: q.source,
        sourceLabel: q.sourceLabel,
        figure: q.figure,
      );

  /// Gemini's parser intentionally returns generic identities. Reattach the
  /// exact selected subject/chapter before adding generated shortage items to
  /// a custom test so downstream filtering and provenance remain correct.
  static Question _generatedForChapter(
          Question q, String subjectId, String chapter) =>
      Question(
        id: q.id,
        subjectId: subjectId,
        chapter: chapter,
        questionText: q.questionText,
        options: List<String>.unmodifiable(q.options),
        correctIndex: q.correctIndex,
        explanation: q.explanation,
        source: QuestionSource.ai,
        sourceLabel: 'Gemini • chapter-source grounded',
        figure: q.figure,
      );

  static const _saqBad = [
    'কোনটি',
    'কোনটির',
    'কোন বাক্য',
    'নিচের',
    'নিচে',
    'কোন সূত্র',
    'কোন শ্রেণি',
    'কোন চতুর্ভুজ',
    'কোন সেটটি',
    'কোন জোড়া',
    'কোন অনুক্রম',
    'কোন ধারা',
    'কোন বিন্দুতে',
    'কোন জোট',
    'কোন ক্ষেত্রে',
    'কোন প্রকার',
    'কোন ধরনের',
    'কোন সংখ্যা',
    'কোন অংশে',
    'উল্লেখ করো',
    '—',
    'কোন অবস্থান',
    'কোন বিন্দু',
    'কোন ত্রিভুজ',
    'কোন চতুর্ভুজের',
    'কোন ভগ্নাংশ',
    'কোন সমীকরণ',
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
      ...allMCQs
          .where((q) => q.subjectId == _subject!.id)
          .map((q) => q.chapter),
      ...allCQs.where((q) => q.subjectId == _subject!.id).map((q) => q.chapter),
    };
    return ChapterCatalog.ordered(set, subjectId: _subject!.id);
  }

  Widget _stepper(String label, int value, void Function(int) onChanged,
      {int max = 30}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14.5, fontWeight: FontWeight.w600))),
          IconButton(
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
              visualDensity: VisualDensity.compact),
          SizedBox(
              width: 34,
              child: Center(
                  child: Text(_bn(value),
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800)))),
          IconButton(
              onPressed: value < max ? () => onChanged(value + 1) : null,
              icon: const Icon(Icons.add_circle_outline),
              visualDensity: VisualDensity.compact),
        ],
      ),
    );
  }

  int get _requestedMcqTotal =>
      _chapterMcqCounts.values.fold(0, (sum, n) => sum + n);

  void _toggleChapter(String chapter, bool selected) {
    setState(() {
      if (selected) {
        _chapters.add(chapter);
        // Start at 10, but never claim more stored questions than we have.
        final available = allMCQs
            .where((q) => q.subjectId == _subject!.id && q.chapter == chapter)
            .length;
        _chapterMcqCounts[chapter] =
            available == 0 ? 1 : (available < 10 ? available : 10);
      } else {
        _chapters.remove(chapter);
        _chapterMcqCounts.remove(chapter);
      }
      _generated = false;
      _pagePngs = null;
    });
  }

  void _setChapterMcqCount(String chapter, int next) {
    final current = _chapterMcqCounts[chapter] ?? 0;
    final proposedTotal = _requestedMcqTotal - current + next;
    if (next < 1 || proposedTotal > 100) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text('একটি কাস্টম MCQ টেস্টে সর্বোচ্চ ১০০টি প্রশ্ন রাখা যাবে।'),
      ));
      return;
    }
    setState(() {
      _chapterMcqCounts[chapter] = next;
      _generated = false;
      _pagePngs = null;
    });
  }

  Widget _chapterMcqRow(String chapter) {
    final selected = _chapterMcqCounts.containsKey(chapter);
    final count = _chapterMcqCounts[chapter] ?? 0;
    final available = allMCQs
        .where((q) => q.subjectId == _subject!.id && q.chapter == chapter)
        .length;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFFF8E5) : Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: selected ? _gold : Colors.black12),
      ),
      child: Row(children: [
        Checkbox(
            value: selected,
            activeColor: _gold,
            onChanged: (v) => _toggleChapter(chapter, v ?? false)),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(chapter,
              style:
                  const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          Text('ব্যাংকে $available টি MCQ',
              style: TextStyle(fontSize: 10.5, color: Colors.grey.shade700)),
        ])),
        if (selected) ...[
          IconButton(
              onPressed: count > 1
                  ? () => _setChapterMcqCount(chapter, count - 1)
                  : null,
              icon: const Icon(Icons.remove_circle_outline)),
          SizedBox(
              width: 30,
              child: Text('$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800))),
          IconButton(
              onPressed: count < 100
                  ? () => _setChapterMcqCount(chapter, count + 1)
                  : null,
              icon: const Icon(Icons.add_circle_outline)),
        ],
      ]),
    );
  }

  String _timeLine(int minutes) {
    if (minutes <= 0) return '—';
    final h = minutes ~/ 60, m = minutes % 60;
    if (h == 0) return '$m min';
    if (m == 0) return '$h hr';
    return '$h hr $m min';
  }

  // ── NEW: Build preview pages (same pipeline as print) ──
  Future<void> _buildPreviewPages() async {
    if (_subject == null) return;
    try {
      // English handled separately – its preview built in _generate
      if (_isEnglish) return;
      final boardMath = _isMathBoardMode;
      final boardIct = _isIctBoardMode;
      final boardBangla = _isBanglaFirstBoardMode;
      final wMin =
          boardMath || boardBangla ? 150 : _cqs.length * 12 + _saqs.length * 3;
      final mMin = boardMath || boardBangla ? 30 : _mcqs.length;
      final isMath =
          _subject!.id == 'general_math' || _subject!.id == 'higher_math';
      String? cqNote;
      if (boardBangla) {
        cqNote =
            '(গদ্য ও কবিতা অংশ থেকে মোট ৫টি সৃজনশীল প্রশ্নের উত্তর দাও। গদ্য থেকে ন্যূনতম ২টি এবং কবিতা থেকে ন্যূনতম ২টি প্রশ্নের উত্তর দিতে হবে।)';
      } else if (boardMath) {
        cqNote =
            '(৮টি থেকে ৫টি উত্তর দাও; ক, খ, গ ও ঘ—প্রত্যেক বিভাগ থেকে অন্তত ১টি এবং অবশিষ্ট ১টি যেকোনো বিভাগ থেকে। প্রতিটি প্রশ্নের মান ১০)';
      } else if (_subject!.id == 'accounting') {
        cqNote =
            '(৭টি থেকে ৪টি=40 + বাধ্যতামূলক আর্থিক বিবরণী 20=60, SAQ 5×2=10) – PDF Page-24';
      } else if (_subject!.id == 'finance') {
        cqNote =
            '(Fin 5+Bank 3=8 CQ, উত্তর 5≥2 প্রতি অংশে; SAQ 8+7=15 উত্তর10≥4) – Page-26';
      } else if (isMath) {
        cqNote =
            '(ক, খ, গ, ঘ – প্রত্যেক বিভাগ থেকে ≥1 সহ ${_bn(_cqN)}টি উত্তর) – PDF Page-14';
      }
      final pages = await PaperPdf.renderPages(
        title: _titleText,
        subjectName: _subject!.bengaliName,
        modeLine: boardBangla
            ? 'বাংলা প্রথম পত্র বোর্ড প্যাটার্ন'
            : boardMath
                ? 'গণিত বোর্ড প্যাটার্ন'
                : boardIct
                    ? 'ICT বোর্ড প্যাটার্ন'
                    : (_chapters.isEmpty
                        ? 'ফুল সিলেবাস'
                        : (_chapters.length <= 2
                            ? _chapters.join(', ')
                            : '${_bn(_chapters.length)}টি অধ্যায় মিলিয়ে')),
        mcqs: _mcqs,
        cqs: _cqs,
        literatureQuestions: _literatureQuestions,
        literatureNote: boardBangla
            ? '(উপন্যাস থেকে ১টি এবং নাটক থেকে ১টি প্রশ্নের উত্তর দাও। প্রতিটি প্রশ্নে ক ও খ দুটি উপ-প্রশ্ন; ক-এর মান ৩ এবং খ-এর মান ৭।)'
            : null,
        saqs: _saqs,
        cqAnswerCount: boardBangla
            ? BanglaFirstBoardPatternGenerator.cqAnswerCount
            : boardMath
                ? GeneralMathBoardPatternGenerator.cqAnswerCount
                : _cqs.length,
        saqAnswerCount: boardMath
            ? GeneralMathBoardPatternGenerator.saqAnswerCount
            : _saqs.length,
        cqNote: _cqs.isEmpty
            ? null
            : cqNote ??
                '(সবগুলো সৃজনশীল প্রশ্নের উত্তর দাও। প্রতিটি প্রশ্নের মান ১০)',
        writtenTime:
            boardMath || boardBangla ? '২ ঘণ্টা ৩০ মিনিট' : _timeLine(wMin),
        writtenMarks: boardMath || boardBangla
            ? '৭০'
            : _bn(_cqs.length * 10 + _saqs.length * 2),
        mcqTime: boardIct
            ? '১ ঘণ্টা'
            : (boardMath || boardBangla ? '৩০ মিনিট' : _timeLine(mMin)),
        mcqMarks: boardIct
            ? '২৫'
            : (boardMath || boardBangla ? '৩০' : _bn(_mcqs.length)),
        time: boardIct
            ? '১ ঘণ্টা'
            : (boardMath || boardBangla ? '৩ ঘণ্টা' : _timeLine(wMin + mMin)),
        marks: boardIct
            ? '২৫'
            : (boardMath || boardBangla
                ? '১০০'
                : _bn(_cqs.length * 10 + _saqs.length * 2 + _mcqs.length)),
        mathCqThreePart: isMath,
        headerLine1: _titleText,
        subjectCode: _subjectCodes[_subject!.id],
        setCode: _setLetter,
      );
      if (mounted) setState(() => _pagePngs = pages);
    } catch (e) {
      debugPrint('Preview failed: $e');
    }
  }

  // ── Main generate (now with preview) ──
  Future<void> _generate() async {
    if (_subject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Choose a subject first')));
      return;
    }
    if (!_isEnglish &&
        !_usesAutomaticBoardPattern &&
        _chapterMcqCounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('অন্তত একটি অধ্যায় বেছে নিয়ে MCQ সংখ্যা নির্ধারণ করো।')));
      return;
    }
    if (!_usesAutomaticBoardPattern && _requestedMcqTotal > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('মোট MCQ ১০০-এর বেশি হতে পারবে না।')));
      return;
    }
    setState(() {
      _busy = true;
      _generated = false;
      _pagePngs = null;
      _showAnswerKey = false;
      _literatureQuestions = const <LiteratureQuestion>[];
    });
    try {
      final sid = _subject!.id;

      // English: mixed board + preview
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
          } catch (_) {}
        }
        final ttl = _titleText.isEmpty ? 'Model Test' : _titleText;
        if (_isEnglish2nd(sid)) {
          final m = EnglishBoardMixer.mix();
          final pages = await PaperPdf.renderEnglishPages(
            paperTitle: ttl,
            subTitle: 'English (Compulsory)–Second Paper   [Subject Code: 108]',
            sections: [
              ...EnglishPaperAdapter.second(m.set),
              if (aiMcqs.isNotEmpty) EnglishPaperAdapter.aiSection(aiMcqs)
            ],
            setCode: _setLetter,
          );
          if (!mounted) return;
          setState(() {
            _englishSet = m.set;
            _firstSet = null;
            _e2Src = m.sources;
            _e1Src = [];
            _eAiMcqs = aiMcqs;
            _pagePngs = pages;
            _mcqs = [];
            _cqs = [];
            _saqs = [];
            _busy = false;
            _generated = true;
          });
        } else {
          final m = EnglishFirstMixer.mix();
          final pages = await PaperPdf.renderEnglishPages(
            paperTitle: ttl,
            subTitle: 'English (Compulsory)–First Paper   [Subject Code: 107]',
            sections: [
              ...EnglishPaperAdapter.first(m.set),
              if (aiMcqs.isNotEmpty) EnglishPaperAdapter.aiSection(aiMcqs)
            ],
            setCode: _setLetter,
          );
          if (!mounted) return;
          setState(() {
            _firstSet = m.set;
            _englishSet = null;
            _e1Src = m.sources;
            _e2Src = [];
            _eAiMcqs = aiMcqs;
            _pagePngs = pages;
            _mcqs = [];
            _cqs = [];
            _saqs = [];
            _busy = false;
            _generated = true;
          });
        }
        return;
      }

      if (_isMathBoardMode) {
        final paper = GeneralMathBoardPatternGenerator.generate(
          mcqBank: allMCQs,
          saqBank: allSAQs,
          cqBank: allCQs,
        );
        _advanceSetCode();
        if (!mounted) return;
        setState(() {
          _mcqs = paper.mcqs;
          _saqs = paper.saqs.map(_saqAsQuestion).toList(growable: false);
          _cqs = paper.cqs;
          _busy = false;
          _generated = true;
        });
        await _buildPreviewPages();
        return;
      }

      if (_isIctBoardMode) {
        final mcqs = IctBoardPatternGenerator.generate(allMCQs);
        _advanceSetCode();
        if (!mounted) return;
        setState(() {
          _mcqs = mcqs;
          _cqs = const <CreativeQuestion>[];
          _saqs = const <Question>[];
          _busy = false;
          _generated = true;
        });
        await _buildPreviewPages();
        return;
      }

      if (_isBanglaFirstBoardMode) {
        final paper = BanglaFirstBoardPatternGenerator.generate(
          mcqBank: allMCQs,
          cqBank: allCQs,
          literatureBank: banglaFirstLiteratureQuestions,
        );
        _advanceSetCode();
        if (!mounted) return;
        setState(() {
          _mcqs = paper.mcqs;
          _cqs = paper.cqs;
          _saqs = const <Question>[];
          _literatureQuestions = paper.literatureQuestions;
          _busy = false;
          _generated = true;
        });
        await _buildPreviewPages();
        return;
      }

      // Custom MCQ PDF + OMR: keep each chapter quantity exactly as the user requested.
      if (_chapterMcqCounts.isNotEmpty) {
        final customMcqs = <Question>[];
        final hasKey = _apiKey != null && _apiKey!.isNotEmpty;
        for (final entry in _chapterMcqCounts.entries) {
          final pool = allMCQs
              .where((q) => q.subjectId == sid && q.chapter == entry.key)
              .toList()
            ..shuffle();
          customMcqs.addAll(pool.take(entry.value));
          final shortage = entry.value - pool.length;
          if (shortage > 0) {
            if (!hasKey) {
              throw Exception(
                  '${entry.key}-এ ${shortage}টি সংরক্ষিত প্রশ্ন কম আছে। Gemini API key যোগ করো অথবা সংখ্যাটি কমাও।');
            }
            final source = await ChapterSourceService.getSource(sid, entry.key);
            if (source.trim().isEmpty) {
              throw Exception(
                  '${entry.key}-এর নির্ভরযোগ্য অধ্যায়-উৎস পাঠ পাওয়া যায়নি। উৎস পাঠ যোগ করো অথবা MCQ সংখ্যা ${pool.length}-এর মধ্যে রাখো।');
            }
            final ai = await AiQuestionGenerator.generateMcqs(
              apiKey: _apiKey!,
              subjectName: _subject!.bengaliName,
              chapter: entry.key,
              sourceText: source,
              count: shortage,
            );
            if (ai.length != shortage) {
              throw Exception(
                  '${entry.key}-এর জন্য Gemini ${shortage}টির বদলে ${ai.length}টি বৈধ MCQ দিয়েছে। আবার চেষ্টা করো অথবা সংখ্যা কমাও।');
            }
            customMcqs.addAll(
              ai.map((q) => _generatedForChapter(q, sid, entry.key)),
            );
          }
        }
        customMcqs.shuffle();
        if (customMcqs.length != _requestedMcqTotal) {
          throw Exception(
              'চাওয়া MCQ সংখ্যা ঠিকভাবে তৈরি হয়নি। আবার চেষ্টা করো।');
        }
        _advanceSetCode();
        if (!mounted) return;
        setState(() {
          // Custom chapter quantities are an explicit contract. Do not trim
          // this list after generation; the existing print license gate still
          // controls PDF/printing without corrupting requested quantities.
          _mcqs = customMcqs;
          _cqs = [];
          _saqs = [];
          _busy = false;
          _generated = true;
        });
        await _buildPreviewPages();
        return;
      }

      // General subjects
      bool ok(String ch) => _chapters.isEmpty || _chapters.contains(ch);
      final mcqPool = allMCQs
          .where((q) => q.subjectId == sid && ok(q.chapter))
          .toList()
        ..shuffle();
      final cqPool = allCQs
          .where((q) => q.subjectId == sid && ok(q.chapter))
          .toList()
        ..shuffle();

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
                count: aiMcqNeed);
          }
        } catch (_) {}
        try {
          final aiCqNeed = (_cqN * _aiShare / 100).round();
          if (aiCqNeed > 0) {
            aiCqs = await AiQuestionGenerator.generateCqs(
                apiKey: _apiKey!,
                subjectName: _subject!.name,
                chapter: chapLabel,
                sourceText: '',
                count: aiCqNeed);
          }
        } catch (_) {}
      }

      final mcqBankN = _mcqN - aiMcqs.length;
      final cqBankN = _cqN - aiCqs.length;
      final mcqs = [...mcqPool.take(mcqBankN < 0 ? 0 : mcqBankN), ...aiMcqs]
        ..shuffle();
      final cqs = [...cqPool.take(cqBankN < 0 ? 0 : cqBankN), ...aiCqs];

      final usedIds = mcqs.map((q) => q.id).toSet();
      final saqPool = mcqPool
          .where((q) =>
              !usedIds.contains(q.id) &&
              !_saqBad.any((b) => q.questionText.contains(b)))
          .toList();
      int saqScore(Question q) {
        var s = 0;
        if (q.id.contains('_x')) s += 2;
        if (RegExp(r'[০-৯0-9√°²=^x]').hasMatch(q.questionText)) s += 1;
        if (q.questionText.length > 42) s += 1;
        return s;
      }

      final hardSaq = saqPool.where((q) => saqScore(q) >= 3).toList()
        ..shuffle();
      final easySaq = saqPool.where((q) => saqScore(q) < 3).toList()..shuffle();
      final derivedSaqs = [...hardSaq, ...easySaq].take(_saqN).toList();

      // Prefer the curated short-answer bank when this subject/chapter set has
      // one; otherwise keep the original leftover-MCQ derivation untouched.
      final curatedSaqs = allSAQs
          .where((q) => q.subjectId == sid && ok(q.chapter))
          .toList()
        ..shuffle();
      final saqs = curatedSaqs.isNotEmpty
          ? curatedSaqs.take(_saqN).map(_saqAsQuestion).toList()
          : derivedSaqs;

      _advanceSetCode();

      if (!mounted) return;
      setState(() {
        _mcqs = _isPro ? mcqs : mcqs.take(PaperLicense.demoMcqLimit).toList();
        _cqs = _isPro ? cqs : cqs.take(PaperLicense.demoCqLimit).toList();
        _saqs = _isPro ? saqs : saqs.take(5).toList();
        _busy = false;
        _generated = true;
      });
      await _buildPreviewPages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _print() async {
    if (!_generated) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Generate preview first!')));
      return;
    }
    final pro = await PaperLicense.isPro();
    if (!pro) {
      if (!mounted) return;
      showDialog(
          context: context,
          builder: (c) => AlertDialog(
                  title: const Text('Pro Required'),
                  content: const Text(
                      'Custom paper printing is Pro – unlock first.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(c),
                        child: const Text('OK'))
                  ]));
      return;
    }
    if (_subject == null) return;
    final sid = _subject!.id;
    try {
      if (_isEnglish2nd(sid) && _englishSet != null) {
        await PaperPdf.printEnglishPaper(
          paperTitle: _titleText,
          subTitle: 'English (Compulsory)–Second Paper   [Subject Code: 108]',
          sections: [
            ...EnglishPaperAdapter.second(_englishSet!),
            if (_eAiMcqs.isNotEmpty) EnglishPaperAdapter.aiSection(_eAiMcqs)
          ],
          setCode: _setLetter,
        );
        return;
      }
      if (_isEnglish1st(sid) && _firstSet != null) {
        await PaperPdf.printEnglishPaper(
          paperTitle: _titleText,
          subTitle: 'English (Compulsory)–First Paper   [Subject Code: 107]',
          sections: [
            ...EnglishPaperAdapter.first(_firstSet!),
            if (_eAiMcqs.isNotEmpty) EnglishPaperAdapter.aiSection(_eAiMcqs)
          ],
          setCode: _setLetter,
        );
        return;
      }
      final boardMath = _isMathBoardMode;
      final boardIct = _isIctBoardMode;
      final boardBangla = _isBanglaFirstBoardMode;
      final wMin =
          boardMath || boardBangla ? 150 : _cqs.length * 12 + _saqs.length * 3;
      final mMin = boardMath || boardBangla ? 30 : _mcqs.length;
      final isMath = sid == 'general_math' || sid == 'higher_math';
      await PaperPdf.printPaper(
        title: _titleText,
        subjectName: _subject!.bengaliName,
        modeLine: boardBangla
            ? 'বাংলা প্রথম পত্র বোর্ড প্যাটার্ন'
            : boardMath
                ? 'গণিত বোর্ড প্যাটার্ন'
                : boardIct
                    ? 'ICT বোর্ড প্যাটার্ন'
                    : (_chapters.isEmpty
                        ? 'ফুল সিলেবাস'
                        : (_chapters.length <= 2
                            ? _chapters.join(', ')
                            : '${_bn(_chapters.length)}টি অধ্যায় মিলিয়ে')),
        mcqs: _mcqs,
        cqs: _cqs,
        literatureQuestions: _literatureQuestions,
        literatureNote: boardBangla
            ? '(উপন্যাস থেকে ১টি এবং নাটক থেকে ১টি প্রশ্নের উত্তর দাও। প্রতিটি প্রশ্নে ক ও খ দুটি উপ-প্রশ্ন; ক-এর মান ৩ এবং খ-এর মান ৭।)'
            : null,
        saqs: _saqs,
        cqAnswerCount: boardBangla
            ? BanglaFirstBoardPatternGenerator.cqAnswerCount
            : boardMath
                ? GeneralMathBoardPatternGenerator.cqAnswerCount
                : _cqs.length,
        saqAnswerCount: boardMath
            ? GeneralMathBoardPatternGenerator.saqAnswerCount
            : _saqs.length,
        cqNote: _cqs.isEmpty
            ? null
            : (boardBangla
                ? '(গদ্য ও কবিতা অংশ থেকে মোট ৫টি সৃজনশীল প্রশ্নের উত্তর দাও। গদ্য থেকে ন্যূনতম ২টি এবং কবিতা থেকে ন্যূনতম ২টি প্রশ্নের উত্তর দিতে হবে।)'
                : boardMath
                    ? '(৮টি থেকে ৫টি উত্তর দাও; ক, খ, গ ও ঘ—প্রত্যেক বিভাগ থেকে অন্তত ১টি এবং অবশিষ্ট ১টি যেকোনো বিভাগ থেকে। প্রতিটি প্রশ্নের মান ১০)'
                    : _subject!.id == 'accounting'
                        ? '(৭টি থেকে ৪টি=40 + বাধ্যতামূলক 20=60, SAQ 10) – PDF Page-24'
                        : _subject!.id == 'finance'
                            ? '(Fin5+Bank3 উত্তর5≥2, SAQ 8+7 উত্তর10≥4) – Page-26'
                            : '(সবগুলো সৃজনশীল প্রশ্নের উত্তর দাও। প্রতিটি প্রশ্নের মান ১০)'),
        writtenTime:
            boardMath || boardBangla ? '২ ঘণ্টা ৩০ মিনিট' : _timeLine(wMin),
        writtenMarks: boardMath || boardBangla
            ? '৭০'
            : _bn(_cqs.length * 10 + _saqs.length * 2),
        mcqTime: boardIct
            ? '১ ঘণ্টা'
            : (boardMath || boardBangla ? '৩০ মিনিট' : _timeLine(mMin)),
        mcqMarks: boardIct
            ? '২৫'
            : (boardMath || boardBangla ? '৩০' : _bn(_mcqs.length)),
        time: boardIct
            ? '১ ঘণ্টা'
            : (boardMath || boardBangla ? '৩ ঘণ্টা' : _timeLine(wMin + mMin)),
        marks: boardIct
            ? '২৫'
            : (boardMath || boardBangla
                ? '১০০'
                : _bn(_cqs.length * 10 + _saqs.length * 2 + _mcqs.length)),
        mathCqThreePart: isMath,
        headerLine1: _titleText,
        subjectCode: _subjectCodes[sid],
        setCode: _setLetter,
      );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Print error: $e')));
    }
  }

  // AI mix card
  Widget _aiMixCard() {
    final hasKey = _apiKey != null && _apiKey!.isNotEmpty;
    if (!hasKey) {
      return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF17130A),
                  side: const BorderSide(color: Color(0xFF17130A))),
              onPressed: _showApiKeyDialog,
              icon: const Icon(Icons.vpn_key_outlined, size: 18),
              label:
                  const Text('🔑 Set Gemini API key (to mix AI questions)')));
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
                offset: const Offset(0, 3))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: _mixAi,
            onChanged: (v) => setState(() => _mixAi = v),
            title: const Text('🤖 Mix AI questions',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
            subtitle: Text('Fresh AI + bank',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600))),
        if (_mixAi) ...[
          const Text('AI %:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          SegmentedButton<int>(segments: const [
            ButtonSegment(value: 25, label: Text('25%')),
            ButtonSegment(value: 50, label: Text('50%')),
            ButtonSegment(value: 75, label: Text('75%'))
          ], selected: {
            _aiShare
          }, onSelectionChanged: (s) => setState(() => _aiShare = s.first)),
        ],
      ]),
    );
  }

  Future<void> _showApiKeyDialog() async {
    final controller = TextEditingController(text: _apiKey ?? '');
    final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: const Text('🔑 Gemini API Key'),
                content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'AIza...')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Save'))
                ]));
    if (ok == true && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gemini_api_key', controller.text.trim());
      setState(() {
        _apiKey = controller.text.trim();
        _mixAi = _apiKey!.isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapters = _availableChapters;
    final total = _isMathBoardMode || _isBanglaFirstBoardMode
        ? 100
        : (_isIctBoardMode
            ? 25
            : (_isEnglish
                ? (_cqN * 10 + _saqN * 2 + _mcqN)
                : _requestedMcqTotal));
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.mcqOnly
              ? 'Custom MCQ Test + OMR'
              : 'Custom Paper + Preview'),
          backgroundColor: const Color(0xFF17130A),
          foregroundColor: const Color(0xFFFFE08A)),
      // This screen intentionally uses light paper-style cards. Force a local
      // light text/input theme so the global dark+gold app theme cannot fade text on white cards.
      body: Theme(
        data: ThemeData.light(useMaterial3: true).copyWith(
          colorScheme: ColorScheme.fromSeed(
              seedColor: _gold, brightness: Brightness.light),
          textTheme: ThemeData.light().textTheme.apply(
              bodyColor: const Color(0xFF17130A),
              displayColor: const Color(0xFF17130A)),
          inputDecorationTheme: const InputDecorationTheme(
            labelStyle: TextStyle(color: Color(0xFF5E574B)),
            hintStyle: TextStyle(color: Color(0xFF756E63)),
          ),
        ),
        child: AnimatedBuilder(
          animation: AppStyle.bgIndex,
          builder: (context, _) => Container(
            color: AppStyle.bg,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Config card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ]),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<SubjectInfo>(
                            value: _subject,
                            decoration:
                                const InputDecoration(labelText: 'Subject'),
                            items: allSubjects
                                .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(
                                        '${s.icon} ${s.id == 'chemistry' || s.id == 'biology' || s.id == 'general_math' || s.id == 'ict' || s.id == 'bangla_1st' ? s.bengaliName : s.name}')))
                                .toList(),
                            onChanged: (s) => setState(() {
                                  _subject = s;
                                  _chapters.clear();
                                  _chapterMcqCounts.clear();
                                  _mathBoardPattern = false;
                                  _ictBoardPattern = false;
                                  _banglaFirstBoardPattern = false;
                                  _generated = false;
                                  _pagePngs = null;
                                }),
                            hint: const Text('Choose subject')),
                        const SizedBox(height: 12),
                        TextField(
                            controller: _titleCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Paper Title'),
                            onChanged: (_) => setState(() {})),
                        const SizedBox(height: 6),
                        Text(
                            'Code: ${_subjectCodes[_subject?.id] ?? '—'} • Set: $_setLetter',
                            style: TextStyle(
                                fontSize: 11.5, color: Colors.grey.shade700)),
                      ]),
                ),
                const SizedBox(height: 14),
                if (_isBanglaFirst) ...[
                  const Text('বাংলা প্রথম পত্র মোড',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  SegmentedButton<bool>(
                    segments: const <ButtonSegment<bool>>[
                      ButtonSegment<bool>(
                        value: false,
                        icon: Icon(Icons.tune_rounded),
                        label: Text('কাস্টম MCQ মোড'),
                      ),
                      ButtonSegment<bool>(
                        value: true,
                        icon: Icon(Icons.article_outlined),
                        label: Text('বাংলা প্রথম পত্র বোর্ড প্যাটার্ন'),
                      ),
                    ],
                    selected: <bool>{_banglaFirstBoardPattern},
                    onSelectionChanged: (selection) => setState(() {
                      _banglaFirstBoardPattern = selection.first;
                      _chapters.clear();
                      _chapterMcqCounts.clear();
                      _generated = false;
                      _pagePngs = null;
                    }),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_isBanglaFirstBoardMode) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _gold),
                    ),
                    child: const Text(
                      'পূর্ণমান ১০০ • সময় ৩ ঘণ্টা\n'
                      'গদ্য CQ ৪টি + কবিতা CQ ৪টি; উত্তর মোট ৫টি — ৫০\n'
                      'উপন্যাস ২টি + নাটক ২টি; উত্তর ১+১টি — ২০\n'
                      'গদ্য MCQ ১৫টি + কবিতা MCQ ১৫টি; সব উত্তর — ৩০',
                      style: TextStyle(fontSize: 12.5, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: const Color(0xFF17130A),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(children: [
                      Icon(Icons.fact_check_outlined, color: _gold),
                      SizedBox(width: 9),
                      Text('মোট MCQ: 30 / 100',
                          style: TextStyle(
                              color: Color(0xFFFFE08A),
                              fontWeight: FontWeight.w800)),
                    ]),
                  ),
                  const SizedBox(height: 10),
                ],
                if (_isGeneralMath) ...[
                  const Text('গণিত প্রশ্নপত্র মোড',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  SegmentedButton<bool>(
                    segments: const <ButtonSegment<bool>>[
                      ButtonSegment<bool>(
                        value: false,
                        icon: Icon(Icons.tune_rounded),
                        label: Text('কাস্টম MCQ মোড'),
                      ),
                      ButtonSegment<bool>(
                        value: true,
                        icon: Icon(Icons.article_outlined),
                        label: Text('গণিত বোর্ড প্যাটার্ন'),
                      ),
                    ],
                    selected: <bool>{_mathBoardPattern},
                    onSelectionChanged: (selection) => setState(() {
                      _mathBoardPattern = selection.first;
                      _chapters.clear();
                      _chapterMcqCounts.clear();
                      _generated = false;
                      _pagePngs = null;
                    }),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_isIct) ...[
                  const Text('ICT প্রশ্নপত্র মোড',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  SegmentedButton<bool>(
                    segments: const <ButtonSegment<bool>>[
                      ButtonSegment<bool>(
                        value: false,
                        icon: Icon(Icons.tune_rounded),
                        label: Text('কাস্টম ICT MCQ টেস্ট'),
                      ),
                      ButtonSegment<bool>(
                        value: true,
                        icon: Icon(Icons.article_outlined),
                        label: Text('ICT বোর্ড প্যাটার্ন'),
                      ),
                    ],
                    selected: <bool>{_ictBoardPattern},
                    onSelectionChanged: (selection) => setState(() {
                      _ictBoardPattern = selection.first;
                      _chapters.clear();
                      _chapterMcqCounts.clear();
                      _generated = false;
                      _pagePngs = null;
                    }),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_isIctBoardMode) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _gold),
                    ),
                    child: const Text(
                      'পূর্ণমান ২৫ • সময় ১ ঘণ্টা\n'
                      'মোট ২৫টি MCQ; সবগুলোর উত্তর দিতে হবে।\n'
                      'প্রশ্নপত্রের সঙ্গে OMR স্বয়ংক্রিয়ভাবে তৈরি হবে।',
                      style: TextStyle(fontSize: 12.5, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: const Color(0xFF17130A),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(children: [
                      Icon(Icons.fact_check_outlined, color: _gold),
                      SizedBox(width: 9),
                      Text('মোট MCQ: 25 / 100',
                          style: TextStyle(
                              color: Color(0xFFFFE08A),
                              fontWeight: FontWeight.w800)),
                    ]),
                  ),
                  const SizedBox(height: 10),
                ],
                if (_isMathBoardMode) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _gold),
                    ),
                    child: const Text(
                      'পূর্ণমান ১০০ • সময় ৩ ঘণ্টা\n'
                      'CQ: ৮টি থাকবে, ৫টি উত্তর (প্রতি বিভাগে ২টি) — ৫০\n'
                      'SAQ: ১৫টি থাকবে, ১০টি উত্তর — ২০\n'
                      'MCQ: ৩০টি, সবগুলোর উত্তর — ৩০\n'
                      'MCQ বণ্টন: বীজগণিত ১৩, জ্যামিতি ১২, ত্রিকোণমিতি-পরিমিতি ৪, পরিসংখ্যান ১',
                      style: TextStyle(fontSize: 12.5, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: const Color(0xFF17130A),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(children: [
                      Icon(Icons.fact_check_outlined, color: _gold),
                      SizedBox(width: 9),
                      Text('মোট MCQ: 30 / 100',
                          style: TextStyle(
                              color: Color(0xFFFFE08A),
                              fontWeight: FontWeight.w800)),
                    ]),
                  ),
                  const SizedBox(height: 10),
                ],
                if (!_isEnglish && !_usesAutomaticBoardPattern) ...[
                  const Text('Custom MCQ test',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                      'অধ্যায় নির্বাচন করো, তারপর প্রতিটি অধ্যায়ের পাশে MCQ সংখ্যা নির্ধারণ করো।',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  const SizedBox(height: 10),
                  for (final chapter in chapters) _chapterMcqRow(chapter),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                        color: const Color(0xFF17130A),
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      const Icon(Icons.fact_check_outlined, color: _gold),
                      const SizedBox(width: 9),
                      Expanded(
                          child: Text('মোট MCQ: $_requestedMcqTotal / 100',
                              style: const TextStyle(
                                  color: Color(0xFFFFE08A),
                                  fontWeight: FontWeight.w800))),
                    ]),
                  ),
                  const SizedBox(height: 10),
                ],
                if (_isEnglish)
                  Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.teal.shade100)),
                      child: Text(
                          _isEnglish2nd(_subject?.id)
                              ? 'English 2nd: Grammar 60 + Composition 40 (mixed boards)'
                              : 'English 1st: Reading 70 + Writing 30 (mixed boards)',
                          style: TextStyle(
                              fontSize: 12, color: Colors.teal.shade900))),
                if (!_usesAutomaticBoardPattern) _aiMixCard(),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: const Color(0xFF17130A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _gold.withOpacity(0.5))),
                  child: Row(children: [
                    const Icon(Icons.calculate_outlined, color: _gold),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(
                            _isBanglaFirstBoardMode
                                ? 'বাংলা প্রথম পত্র বোর্ড প্যাটার্ন: ১০০ নম্বর • ৩ ঘণ্টা'
                                : _isMathBoardMode
                                    ? 'গণিত বোর্ড প্যাটার্ন: ১০০ নম্বর • ৩ ঘণ্টা'
                                    : _isIctBoardMode
                                        ? 'ICT বোর্ড প্যাটার্ন: ২৫ নম্বর • ১ ঘণ্টা'
                                        : (_isEnglish
                                            ? 'Marks: $total • Time: ${_timeLine(_cqN * 12 + _saqN * 3)} + ${_timeLine(_mcqN)} MCQ'
                                            : 'Custom MCQ: $total marks • Time: ${_timeLine(total)}'),
                            style: const TextStyle(
                                color: Color(0xFFFFE08A), fontSize: 13)))
                  ]),
                ),
                const SizedBox(height: 16),
                // Generate button (now shows preview too)
                SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF17130A),
                            foregroundColor: const Color(0xFFFFE08A)),
                        onPressed: _busy ? null : _generate,
                        icon: _busy
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Color(0xFFFFE08A)))
                            : const Icon(Icons.visibility_rounded),
                        label: Text(
                            _busy ? 'Building...' : 'Generate & Preview'))),
                const SizedBox(height: 12),
                // Preview (NEW)
                if (_busy)
                  const Center(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator())),
                if (_generated && _pagePngs != null) ...[
                  for (var i = 0; i < _pagePngs!.length; i++)
                    Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black26),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: Offset(0, 6))
                            ]),
                        child:
                            Image.memory(_pagePngs![i], fit: BoxFit.fitWidth)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                        child: AppButton(
                            label: _showAnswerKey ? 'Hide Answers' : 'Answers',
                            icon: Icons.key_rounded,
                            outlined: true,
                            onPressed: () => setState(
                                () => _showAnswerKey = !_showAnswerKey))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: AppButton(
                            label: 'PDF / Print',
                            icon: Icons.print_rounded,
                            onPressed: _print)),
                  ]),
                  if (_showAnswerKey) ...[
                    const SizedBox(height: 12),
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.secondary.withOpacity(0.3))),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('MCQ Answers',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Wrap(spacing: 12, children: [
                                for (var j = 0; j < _mcqs.length; j++)
                                  Text(
                                      '${_bn(j + 1)}. ${[
                                        'ক',
                                        'খ',
                                        'গ',
                                        'ঘ'
                                      ][_mcqs[j].correctIndex]}',
                                      style: const TextStyle(fontSize: 13))
                              ]),
                            ])),
                  ],
                ],
                const SizedBox(height: 8),
                Text(
                    'Creative=10, SAQ=2, MCQ=1 – auto calculated. Preview = exact print.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
