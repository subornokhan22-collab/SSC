import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/questions_data.dart';
import '../services/app_settings.dart';
import '../services/app_style.dart';
import '../services/paper_license.dart';
import '../services/paper_library.dart';
import '../services/paper_pdf.dart';
import '../services/chapter_catalog.dart';
import 'subscription_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/glass_card.dart';
import '../widgets/app_button.dart';
import '../widgets/problem_dialog.dart';
import '../data/english_board_data.dart';
import '../data/english_first_data.dart';
import '../data/english_answers_data.dart';
import '../services/english_paper_adapter.dart';
import '../models/subject_info.dart';

/// SSC-2027 অফিসিয়াল প্রশ্ন-কাঠামো — PDF যাচাইকৃত (Lalmonirhat Govt Girls, ব্যবসায় বিভাগ) + NCTB Sep-2025 সংশোধনী
/// Reference PDF pages: 101 বাংলা ১ম 70(50+20)+30, 102 বাংলা ২য় 70(10+10+10+10+10+20 নতুন সংবাদ প্রতিবেদন)+30,
/// 107 English 1st Reading 70+Writing30=100, 108 English 2nd Grammar60+Writing40=100,
/// 109 গণিত 70(50+20)+30 – বিভাগ-কোটা: বীজগণিত 2, জ্যামিতি 2, ত্রিকোণ/পরিমিতি 2, পরিসংখ্যান 2,
/// 127 বিজ্ঞান 70+30=100, 143 ব্যবসায় উদ্যোগ 70+30, 152 ফিন্যান্স 70+30 (ফিন্যান্স 5/ব্যাংকিং 3 কোটা, সংক্ষিপ্ত 8+7 কোটা),
/// 146 হিসাববিজ্ঞান 70(7 CQ উত্তর 4×10=40 + বাধ্যতামূলক আর্থিক বিবরণী 20 + 7 SAQ উত্তর 5×2=10)+30=100,
/// 134 কৃষি 50(7 CQ উত্তর4=40+7 SAQ উত্তর5=10)+25 MCQ+25 ব্যবহারিক=100,
/// 154 ICT নতুন সার্কুলার (Sep 2025): তত্ত্বীয় 25 MCQ only + ব্যবহারিক 25 =50,
/// 147 শারীরিক ও 156 ক্যারিয়ার: ধারাবাহিক মূল্যায়ন 50 (তাত্ত্বিক/ব্যবহারিক অভিক্ষা),
/// বিজ্ঞান বিভাগ (Physics/Chem/Bio/Higher Math): তত্ত্বীয় 75 (CQ 4×10=40 + SAQ 5×2=10 + MCQ 25) + ব্যবহারিক 25 =100
class _PaperPattern {
  final int mcqCount;
  final int cqCount;
  final int saqCount;
  final int cqAnswerCount;
  final int saqAnswerCount;
  final int compulsoryCount; // e.g., accounting compulsory financial statement
  final int compulsoryMarks; // 20 for accounting
  final bool mathDivisions;
  final bool financeDivisions;
  final int practicalMarks;
  final String note; // UI explanation

  const _PaperPattern({
    required this.mcqCount,
    required this.cqCount,
    required this.saqCount,
    required this.cqAnswerCount,
    required this.saqAnswerCount,
    this.compulsoryCount = 0,
    this.compulsoryMarks = 0,
    this.mathDivisions = false,
    this.financeDivisions = false,
    this.practicalMarks = 0,
    this.note = '',
  });

  int get theoryMarks => cqAnswerCount * 10 + compulsoryMarks + saqAnswerCount * 2 + mcqCount;
  int get totalMarks => theoryMarks + practicalMarks;
}

class QuestionPaperScreen extends StatefulWidget {
  const QuestionPaperScreen({super.key, this.initialSubjectId, this.initialMode});

  /// টিউটর-হোম থেকে সরাসরি মোড বেছে দেওয়া যায় ('chapter' | 'full')
  final String? initialSubjectId;
  final String? initialMode;

  @override
  State<QuestionPaperScreen> createState() => _QuestionPaperScreenState();
}

class _QuestionPaperScreenState extends State<QuestionPaperScreen> {
  SubjectInfo? _subject;
  String _mode = 'chapter'; // 'chapter' | 'full'
  String? _chapter;

  bool _busy = false;
  // True while the (now multi-step) save/print actions run, so the
  // buttons can show a loading spinner instead of looking dead.
  bool _busySave = false;
  bool _busyPrint = false;
  bool _generated = false;
  EnglishBoardSet? _englishSet;

  /// English 2nd Paper board sets live in a dedicated bank (word boxes and
  /// column tables) — matched tolerantly to ids like 'english_2' / 'english-2nd'.
  static bool _isEnglish2nd(String? id) {
    if (id == null) return false;
    final s = id.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
    return s.contains('english') && (s.contains('2') || s.contains('second'));
  }

  /// Chapter-dropdown label for one board set.
  static String _ebLabel(EnglishBoardSet s) => '${s.serial} • ${s.board}';

  /// English 1st Paper board sets live in their own bank (poem/story
  /// questions, info tables) — matched tolerantly to ids like 'english_1'.
  static bool _isEnglish1st(String? id) {
    if (id == null) return false;
    final s = id.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
    return s.contains('english') && (s.contains('1') || s.contains('first'));
  }

  /// Any English board-paper subject (1st or 2nd paper).
  bool get _isEnglish =>
      _isEnglish1st(_subject?.id) || _isEnglish2nd(_subject?.id);

  EnglishFirstSet? _firstSet;

  /// Chapter-dropdown label for a 1st-paper set.
  static String _ef1Label(EnglishFirstSet s) => '${s.serial} • ${s.board}';

  /// English বিষয়ে প্রতিবার নতুন মিক্স — Chapter ড্রপডাউনে একটাই আইটেম।
  static const _mixedLabel = '🔀 Mixed Board Papers–2024 (shuffle)';

  /// Mixed English পেপারে প্রতিটি প্রশ্ন-গ্রুপের উৎস-সিরিয়াল।
  List<int> _e2Src = []; // 2nd paper: 12 গ্রুপ (Q1..Q12)
  List<int> _e1Src = []; // 1st paper: 9 গ্রুপ
  /// 👁️ প্রিভিউ পেজগুলো — printed PDF-এর হুবহু রূপ।
  List<Uint8List>? _pagePngs;
  bool _isPro = false;
  bool _showAnswerKey = false;
  String? _note;
  // Settings → Default paper name overrides the built-in default.
  final TextEditingController _titleCtrl = TextEditingController(
      text: AppSettings.defaultName.isNotEmpty
          ? AppSettings.defaultName
          : 'মডেল পরীক্ষা — ২০২৭');
  String _setLetter = 'ক';
  static const _setLetters = ['ক', 'খ', 'গ', 'ঘ'];
  // PDF যাচাইকৃত বিষয় কোড – Page-1 সূচিপত্র
  static const _subjectCodes = {
    'bangla_1st': '১০১',
    'bangla_2nd': '১০২',
    'english_1st': '১০৭',
    'english_2nd': '১০৮',
    'general_math': '১০৯', // গণিত 109
    'religion': '১১১', // ইসলাম 111 (হিন্দু 112)
    'general_science': '১২৭', // বিজ্ঞান 127
    'agriculture': '১৩৪', // কৃষিশিক্ষা 134
    'higher_math': '১২৬',
    'physics': '১৩৬',
    'chemistry': '১৩৭',
    'biology': '১৩৮',
    'business_ent': '১৪৩', // ব্যবসায় উদ্যোগ 143
    'accounting': '১৪৬', // হিসাববিজ্ঞান 146
    'physical_edu': '১৪৭', // শারীরিক শিক্ষা 147
    'finance': '১৫২', // ফিন্যান্স ও ব্যাংকিং 152
    'ict': '১৫৪', // ICT 154
    'career': '১৫৬', // ক্যারিয়ার 156
    'bgs': '১৫০',
    'history': '১১০',
    'civics': '১৪০',
  };

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
    await AppStyle.load();
    final prefs = await SharedPreferences.getInstance();
    final pro = await PaperLicense.isPro();
    final subj = subjectById(widget.initialSubjectId) ?? _subject;
    if (!mounted) return;
    setState(() {
      _isPro = pro;
      if (subj != null) _subject = subj;
      if (widget.initialMode != null) _mode = widget.initialMode!;
      final idx = prefs.getInt('paper_set_idx') ?? 0;
      _setLetter = _setLetters[idx % _setLetters.length];
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

  // ── লিখিত সংখ্যা বাংলায় ──────────────────────────────────────────
  String _bn(int n) {
    const d = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return n.toString().split('').map((c) {
      final code = c.codeUnitAt(0);
      return (code >= 48 && code <= 57) ? d[code - 48] : c;
    }).join();
  }

  // ── বিষয় অনুযায়ী SSC-2027 প্যাটার্ন — PDF + Sep-2025 Circular যাচাইকৃত ──
  _PaperPattern _patternFor(String sid) {
    // Science with practical 25
    const sciencePractical = {'physics', 'chemistry', 'higher_math', 'biology', 'agriculture'};
    // 100 marks without practical: 70 written (50 CQ +20 SAQ) +30 MCQ
    const general100 = {'general_math', 'bgs', 'religion', 'history', 'civics', 'business_ent', 'general_science', 'finance'};

    switch (sid) {
      // ——— গণিত 109: PDF Page-14 — 8 CQ (2 per division) answer 5 + 15 SAQ answer10 +30 MCQ =100
      case 'general_math':
        return const _PaperPattern(
          mcqCount: 30, cqCount: 8, saqCount: 15,
          cqAnswerCount: 5, saqAnswerCount: 10,
          mathDivisions: true,
          note: 'বিভাগ-কোটা: বীজ 12, জ্যামিতি 11, ত্রিকোণ+পরিমিতি 4, পরিসংখ্যান 3 (MCQ); CQ প্রতি বিভাগে 2টি করে',
        );

      // ——— বিজ্ঞান বিভাগ তত্ত্বীয় 75 + ব্যবহারিক 25 — Page 20, RisingBD source
      case 'physics':
      case 'chemistry':
      case 'biology':
      case 'higher_math':
        return const _PaperPattern(
          mcqCount: 25, cqCount: 7, saqCount: 7,
          cqAnswerCount: 4, saqAnswerCount: 5,
          practicalMarks: 25,
          note: 'তত্ত্বীয় 75 (CQ 40 + SAQ 10 + MCQ 25) + ব্যবহারিক 25 =100',
        );

      // ——— কৃষিশিক্ষা 134: PDF Page-21/22 — তত্ত্বীয় 50 (CQ 40+SAQ10) + MCQ 25 + ব্যবহারিক 25 =100
      case 'agriculture':
        return const _PaperPattern(
          mcqCount: 25, cqCount: 7, saqCount: 7,
          cqAnswerCount: 4, saqAnswerCount: 5,
          practicalMarks: 25,
          note: 'তত্ত্বীয় 50 (CQ 4×10=40 + SAQ 5×2=10) + MCQ 25 =75 + ব্যবহারিক 25 =100 (PDF Page-21)',
        );

      // ——— হিসাববিজ্ঞান 146: PDF Page-24 — 7 CQ answer4 (40) + বাধ্যতামূলক আর্থিক বিবরণী 20 + SAQ 10 =70 + MCQ30=100
      case 'accounting':
        return const _PaperPattern(
          mcqCount: 30, cqCount: 7, saqCount: 7,
          cqAnswerCount: 4, saqAnswerCount: 5,
          compulsoryCount: 1, compulsoryMarks: 20,
          note: '7 CQ → উত্তর 4টি (40) + 1টি বাধ্যতামূলক আর্থিক বিবরণী (20, বিকল্প নেই) + SAQ 5×2=10 =70 + MCQ30=100',
        );

      // ——— ফিন্যান্স ও ব্যাংকিং 152: PDF Page-26 + Sep-2025 circular — CQ 8 (ফিন্যান্স 5+ব্যাংকিং3, উত্তর 5, প্রতি অংশে কমপক্ষে 2) + SAQ 15 (8+7, উত্তর10, কমপক্ষে 4 যেকোনো অংশে) + MCQ30
      case 'finance':
        return const _PaperPattern(
          mcqCount: 30, cqCount: 8, saqCount: 15,
          cqAnswerCount: 5, saqAnswerCount: 10,
          financeDivisions: true,
          note: 'ফিন্যান্স 5+ব্যাংকিং 3 (CQ), উত্তর 5 (প্রতি অংশে ≥2); SAQ 8+7, উত্তর 10 (≥4 যেকোনো অংশে) – Sep-2025 সংশোধনী',
        );

      // ——— ICT 154: PDF Page-27/28 + Sep-2025 circular — নতুন: MCQ 25 only + ব্যবহারিক 25 =50 (SAQ বাতিল)
      case 'ict':
        return const _PaperPattern(
          mcqCount: 25, cqCount: 0, saqCount: 0,
          cqAnswerCount: 0, saqAnswerCount: 0,
          practicalMarks: 25,
          note: 'Sep-2025 সংশোধনী: সংক্ষিপ্ত বাতিল, MCQ 25 + ব্যবহারিক 25 =50 (আগে 15 MCQ+10 SAQ=25 তত্ত্বীয়)',
        );

      // ——— ব্যবসায় উদ্যোগ 143, বিজ্ঞান 127, BGS, Religion ইত্যাদি — 70+30=100
      case 'business_ent':
      case 'general_science':
      case 'bgs':
      case 'religion':
      case 'history':
      case 'civics':
        return const _PaperPattern(
          mcqCount: 30, cqCount: 8, saqCount: 15,
          cqAnswerCount: 5, saqAnswerCount: 10,
          note: 'লিখিত 70 (CQ 50 + SAQ 20) + MCQ 30 =100 (PDF Page-23 বিজ্ঞান/উদ্যোগ)',
        );

      // ——— বাংলা ১ম 101: Page-3 — গদ্য 4+পদ্য 4=8 CQ উত্তর5=50 + উপন্যাস 2+নাটক2=4 বর্ণনামূলক উত্তর2=20 (Ka3 Kha7) + MCQ30=100
      case 'bangla_1st':
        return const _PaperPattern(
          mcqCount: 30, cqCount: 8, saqCount: 4,
          cqAnswerCount: 5, saqAnswerCount: 2,
          note: 'গদ্য 4+পদ্য 4=8 CQ (উত্তর5, প্রতি অংশে ≥2) =50 + সহপাঠ 4 (উপন্যাস2+নাটক2) উত্তর2=20 (Ka3 Kha7) + MCQ30=100',
        );

      // ——— বাংলা ২য় 102: Page-5 + Sep-2025 — রচনামূলক 70 (অনুচ্ছেদ10+চিঠি/প্রতিবেদন10+সারাংশ10+ভাব10+সংবাদ প্রতিবেদন10 (অনুবাদ বাতিল Sep-2025)+প্রবন্ধ20) + MCQ30=100
      case 'bangla_2nd':
        return const _PaperPattern(
          mcqCount: 30, cqCount: 6, saqCount: 0,
          cqAnswerCount: 6, saqAnswerCount: 0,
          note: 'রচনামূলক 70: অনুচ্ছেদ10+পত্র/প্রতিবেদন10+সারাংশ10+ভাব10+সংবাদ প্রতিবেদন10 (অনুবাদ বাতিল Sep-2025)+প্রবন্ধ20 + MCQ30=100',
        );

      // ——— শারীরিক শিক্ষা 147 ও ক্যারিয়ার 156 — ধারাবাহিক মূল্যায়ন 50
      case 'physical_edu':
      case 'career':
        return const _PaperPattern(
          mcqCount: 0, cqCount: 0, saqCount: 0,
          cqAnswerCount: 0, saqAnswerCount: 0,
          practicalMarks: 0,
          note: 'ধারাবাহিক মূল্যায়ন 50 – শ্রেণি অভীক্ষা + অ্যাসাইনমেন্ট/খেলাধুলা (PDF Page-25/29)',
        );

      default:
        // fallback general 70+30
        return const _PaperPattern(
          mcqCount: 30, cqCount: 8, saqCount: 15,
          cqAnswerCount: 5, saqAnswerCount: 10,
          note: 'সাধারণ: লিখিত 70 (CQ 50 + SAQ 20) + MCQ 30 =100',
        );
    }
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
    if (_isEnglish2nd(_subject!.id) || _isEnglish1st(_subject!.id)) {
      return const [_mixedLabel];
    }
    final set = <String>{
      ...allMCQs.where((q) => q.subjectId == _subject!.id).map((q) => q.chapter),
      ...allCQs.where((q) => q.subjectId == _subject!.id).map((q) => q.chapter),
    };
    return ChapterCatalog.ordered(set, subjectId: _subject!.id);
  }

  // ── পেপার তৈরি ────────────────────────────────────────────────────
  /// The standard red, animated problem dialog — every error the user must
  /// act on uses this (never a plain snackbar).
  Future<void> _problem(String title, String message, {String? detail}) =>
      showProblemDialog(context, title: title, message: message, detail: detail);

  Future<void> _generate() async {

    if (_subject == null) return;
    if (_mode == 'chapter' && _chapter == null) {
      await _problem('No chapters available',
          'No chapters found for this subject — choose "Full Model Test".');
      return;
    }

    setState(() {
      _busy = true;
      _generated = false;
      _note = null;
    });
    // Paint the spinner frame before the heavy (now yielding) generation
    // work starts, so the loading icon is visible the whole time.
    await SchedulerBinding.instance.endOfFrame;

    final sid = _subject!.id;
    // ── English 2nd Paper: fixed board set from the bank — no AI mix,
    // no random pick; the paper prints same-to-same as the board paper ──
    if (_isEnglish2nd(sid)) {
      // 🔀 প্রতিটি প্রশ্ন আলাদা বোর্ড থেকে — প্রতিবার নতুন পেপার
      final m = EnglishBoardMixer.mix();
      final pages = await PaperPdf.renderEnglishPages(
        paperTitle: _titleText,
        subTitle: 'English (Compulsory)–Second Paper   [Subject Code: 108]',
        sections: [...EnglishPaperAdapter.second(m.set)],
        setCode: _setLetter,
      );
      if (!mounted) return;
      setState(() {
        _busy = false;
        _generated = true;
        _showAnswerKey = false;
        _mcqs = [];
        _cqs = [];
        _saqs = [];
        _englishSet = m.set;
        _firstSet = null;
        _e2Src = m.sources;
        _e1Src = [];
        _pagePngs = pages;
      });
      return;
    }
    // ── English 1st Paper: fixed board set from the bank — no AI mix,
    // no random pick; the paper prints same-to-same as the board paper ──
    if (_isEnglish1st(sid)) {
      final m = EnglishFirstMixer.mix();
      final pages = await PaperPdf.renderEnglishPages(
        paperTitle: _titleText,
        subTitle: 'English (Compulsory)–First Paper   [Subject Code: 107]',
        sections: [...EnglishPaperAdapter.first(m.set)],
        setCode: _setLetter,
      );
      if (!mounted) return;
      setState(() {
        _busy = false;
        _generated = true;
        _showAnswerKey = false;
        _mcqs = [];
        _cqs = [];
        _saqs = [];
        _englishSet = null;
        _e2Src = [];
        _e1Src = m.sources;
        _firstSet = m.set;
        _pagePngs = pages;
      });
      return;
    }
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

    final pickedMcqs = mcqs.take(mcqNeed).toList();
    final pickedCqs = cqs.take(cqNeed).toList();

    // সংক্ষিপ্ত-উত্তর বাছাই (MCQ-র সঙ্গে ডুপ্লিকেট হবে না)
    // জটিল SQ আগে: কঠিন নতুন সেট (_x) + গাণিতিক টোকেন + দীর্ঘ প্রশ্ন অগ্রাধিকার পায়
    List<Question> saqs = [];
    if (saqNeed > 0) {
      final used = pickedMcqs.map((q) => q.id).toSet();
      final pool = bankMcqs
          .where((q) => !used.contains(q.id) && _saqOk(q.questionText))
          .toList();
      int saqScore(Question q) {
        var s = 0;
        if (q.id.contains('_x')) s += 2;
        if (RegExp(r'[০-৯0-9√°²=^x]').hasMatch(q.questionText)) s += 1;
        if (q.questionText.length > 42) s += 1;
        return s;
      }

      final hard = pool.where((q) => saqScore(q) >= 3).toList()..shuffle();
      final easy = pool.where((q) => saqScore(q) < 3).toList()..shuffle();
      saqs = [...hard, ...easy].take(saqNeed).toList();
    }

    // সেট কোড পরের পেপারের জন্য এক ঘর সরে যাবে
    _advanceSetCode();

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
      if (mcqs.isEmpty && cqs.isEmpty) {
        _note = 'No banked questions found for this subject — choose another subject or chapter.';
      }
    });
    await _buildPreviewPages();
  }

  /// 👁️ প্রিভিউ: প্রিন্ট-পাইপলাইনের ***ঠিক একই*** পেজ স্ক্রিনে (সব বিষয়ে)।
  Future<void> _buildPreviewPages() async {
    if (_subject == null) return;
    try {
      final isFull = _mode == 'full';
      final pat = _patternFor(_subject!.id);
      // PDF যাচাই + compulsory (Accounting 20) অন্তর্ভুক্ত
      final int wMarks = _mode == 'chapter'
          ? _cqs.length * 10
          : pat.cqAnswerCount * 10 + pat.compulsoryMarks + pat.saqAnswerCount * 2;
      final int mMarks = _mode == 'chapter' ? _mcqs.length : pat.mcqCount;
      String wTime;
      String mTime;
      if (_subject!.id == 'ict') {
        wTime = _mode == 'chapter' ? '৪০ মিনিট' : '১ ঘণ্টা'; // PDF Page-27: তত্ত্বীয় 1 ঘণ্টা পূর্ণমান 25
        mTime = _mode == 'chapter' ? '২০ মিনিট' : '১ ঘণ্টা';
      } else if (pat.practicalMarks == 25 && pat.mcqCount == 25) {
        wTime = _mode == 'chapter' ? '৪০ মিনিট' : '২ ঘণ্টা'; // science 75 theory = 2h? Actually PDF says বিজ্ঞান 2h30 but theory 75
        mTime = _mode == 'chapter' ? '২০ মিনিট' : '২৫ মিনিট';
      } else {
        wTime = _mode == 'chapter' ? '৪০ মিনিট' : '২ ঘণ্টা ৩০ মিনিট';
        mTime = _mode == 'chapter' ? '২০ মিনিট' : '৩০ মিনিট';
      }
      if (pat.totalMarks == 50 || pat.totalMarks == 25) {
        wTime = '১ ঘণ্টা';
        mTime = '১ ঘণ্টা';
      }
      String? cqNote;
      if (isFull) {
        if (pat.mathDivisions) {
          cqNote = '(ক, খ, গ ও ঘ — প্রত্যেক বিভাগ থেকে ন্যূনতম ১টি সহ যেকোনো ${_bn(pat.cqAnswerCount)}টি প্রশ্নের উত্তর দাও। প্রতিটি প্রশ্নের মান ১০) – PDF Page-14';
        } else if (pat.financeDivisions) {
          cqNote = '(ফিন্যান্স অংশ থেকে 5টি ও ব্যাংকিং অংশ থেকে 3টি নিয়ে মোট 8টি CQ থাকবে। প্রতিটি অংশ থেকে কমপক্ষে 2টি করে নিয়ে মোট ${_bn(pat.cqAnswerCount)}টি প্রশ্নের উত্তর দাও) – PDF Page-26 + Sep-2025 সংশোধনী, SAQ 8+7 থেকে উত্তর 10 (≥4 যেকোনো অংশে)';
        } else if (_subject!.id == 'accounting') {
          cqNote = '(৭টি সৃজনশীল প্রশ্ন থেকে যেকোনো ৪টির উত্তর দাও (40) + ৮নং প্রশ্নে 1টি বাধ্যতামূলক আর্থিক বিবরণী প্রস্তুতকরণ (20, বিকল্প নেই) =70) – PDF Page-24';
        } else if (_subject!.id == 'bangla_1st') {
          cqNote = '(গদ্য অংশ থেকে 4টি ও কবিতা অংশ থেকে 4টি নিয়ে মোট 8টি সৃজনশীল প্রশ্ন থাকবে। গদ্য থেকে কমপক্ষে 2টি ও কবিতা থেকে কমপক্ষে 2টি নিয়ে মোট 5টি প্রশ্নের উত্তর দাও। সহপাঠ থেকে 4টি বর্ণনামূলক (উপন্যাস2+নাটক2) থেকে উত্তর 2টি (প্রতি প্রশ্নে ক=3+খ=7)) – PDF Page-3';
        } else {
          cqNote = null;
        }
      }
      final pages = await PaperPdf.renderPages(
        title: '${_subject!.name} (${_subject!.bengaliName})',
        modeLine: _mode == 'chapter' ? (_chapter ?? '') : 'ফুল মডেল টেস্ট পেপার',
        mcqs: _mcqs,
        cqs: _cqs,
        saqs: _saqs,
        time: _mode == 'chapter' ? '১ ঘণ্টা' : '৩ ঘণ্টা',
        marks: _mode == 'chapter' ? _bn(30) : _bn(pat.totalMarks),
        cqAnswerCount: _mode == 'chapter' ? _cqs.length : pat.cqAnswerCount,
        saqAnswerCount: pat.saqAnswerCount,
        cqNote: cqNote,
        writtenTime: wTime,
        writtenMarks: _bn(wMarks),
        mcqTime: mTime,
        mcqMarks: _bn(mMarks),
        mathCqThreePart:
            _subject!.id == 'general_math' || _subject!.id == 'higher_math',
        headerLine1: _titleText,
        subjectCode: _subjectCodes[_subject!.id],
        setCode: _setLetter,
      );
      if (mounted) setState(() => _pagePngs = pages);
    } catch (_) {}
  }

  // ── প্রো আনলক ─────────────────────────────────────────────
  /// Pro is bought in-app via bKash — straight to the subscription screen.
  void _showUnlockDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
    );
  }

  Future<void> _onPrintTap() async {
    if (!_isPro) {
      _showUnlockDialog();
      return;
    }
    if (!_generated) return;
    // PDF/layout is slow on phone — show the loading icon while it runs.
    setState(() => _busyPrint = true);
    // Wait one painted frame so the spinner is visible BEFORE the slow
    // synchronous layout/raster work starts (it blocks the UI thread).
    await SchedulerBinding.instance.endOfFrame;
    try {
      await _runPrint();
    } finally {
      if (mounted) setState(() => _busyPrint = false);
    }
  }

  Future<void> _runPrint() async {
    // English 2nd Paper: exact board-paper layout (boxes, columns, rows)
    if (_isEnglish2nd(_subject!.id) && _englishSet != null) {
      await PaperPdf.printEnglishPaper(
        paperTitle: _titleText,
        subTitle: 'English (Compulsory)–Second Paper   [Subject Code: 108]',
        sections: [
          ...EnglishPaperAdapter.second(_englishSet!),
        ],
        setCode: _setLetter,
      );
      return;
    }
    if (_isEnglish1st(_subject!.id) && _firstSet != null) {
      await PaperPdf.printEnglishPaper(
        paperTitle: _titleText,
        subTitle: 'English (Compulsory)–First Paper   [Subject Code: 107]',
        sections: [
          ...EnglishPaperAdapter.first(_firstSet!),
        ],
        setCode: _setLetter,
      );
      return;
    }
    final isFull = _mode == 'full';
    final pat = _patternFor(_subject!.id);
    // স্কুল-বোর্ড স্টাইল: লিখিত পত্র ও বহুনির্বাচনি পত্রের আলাদা সময়/মান – PDF + Sep-2025 যাচাই
    final int wMarks = _mode == 'chapter'
        ? _cqs.length * 10
        : pat.cqAnswerCount * 10 + pat.compulsoryMarks + pat.saqAnswerCount * 2;
    final int mMarks = _mode == 'chapter' ? _mcqs.length : pat.mcqCount;
    String wTime;
    String mTime;
    if (_subject!.id == 'ict') {
      wTime = _mode == 'chapter' ? '৪০ মিনিট' : '১ ঘণ্টা'; // PDF Page-27 theory 1h, practical 2h
      mTime = _mode == 'chapter' ? '২০ মিনিট' : '১ ঘণ্টা';
    } else if (pat.practicalMarks == 25 && pat.mcqCount == 25) {
      wTime = _mode == 'chapter' ? '৪০ মিনিট' : '২ ঘণ্টা ৩০ মিনিট'; // Page-20/21: লিখিত 2h30
      mTime = _mode == 'chapter' ? '২০ মিনিট' : '২৫ মিনিট';
    } else {
      wTime = _mode == 'chapter' ? '৪০ মিনিট' : '২ ঘণ্টা ৩০ মিনিট';
      mTime = _mode == 'chapter' ? '২০ মিনিট' : '৩০ মিনিট';
    }
    if (pat.totalMarks == 50) {
      wTime = '১ ঘণ্টা'; // ICT theory 1h
      mTime = '১ ঘণ্টা';
    }
    String? printCqNote;
    if (isFull) {
      if (pat.mathDivisions) {
        printCqNote = '(ক, খ, গ ও ঘ — প্রত্যেক বিভাগ থেকে ন্যূনতম ১টি সহ যেকোনো ${_bn(pat.cqAnswerCount)}টি প্রশ্নের উত্তর দাও। প্রতিটি প্রশ্নের মান ১০) – PDF Page-14';
      } else if (pat.financeDivisions) {
        printCqNote = '(ফিন্যান্স 5+ব্যাংকিং 3=8 CQ, উত্তর 5 (প্রতি অংশে ≥2); SAQ 8+7=15, উত্তর 10 (≥4 যেকোনো অংশে)) – Sep-2025 সংশোধনী';
      } else if (_subject!.id == 'accounting') {
        printCqNote = '(7 CQ থেকে 4টি (40) + বাধ্যতামূলক আর্থিক বিবরণী 20 =60, SAQ 5×2=10 => লিখিত 70) – PDF Page-24';
      } else if (_subject!.id == 'bangla_1st') {
        printCqNote = '(গদ্য 4+পদ্য 4=8 CQ, উত্তর 5 (প্রতি অংশে ≥2)=50 + সহপাঠ 4 থেকে উত্তর2=20 (Ka3 Kha7))';
      }
    }
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
        cqNote: printCqNote,
        writtenTime: wTime,
        writtenMarks: _bn(wMarks),
        mcqTime: mTime,
        mcqMarks: _bn(mMarks),
        // গণিত/উচ্চতর গণিত (SSC-2027 নতুন নিয়ম): সৃজনশীল ৩ ভাগ — ক(২) খ(৪) গ(৪)
        mathCqThreePart:
            _subject!.id == 'general_math' || _subject!.id == 'higher_math',
        headerLine1: _titleText,
        subjectCode: _subjectCodes[_subject!.id],
        setCode: _setLetter,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busyPrint = false);
      await showProblemDialog(
        context,
        title: 'Could not start printing',
        message: 'Error: $e',
        detail:
            'Tip: on many phones this happens when the system print service is off. Try again — if it keeps happening, restart your phone.',
      );
    }
  }

  // ── UI ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Paper'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: PressableScale(
                onTap: _showUnlockDialog,
                child: StatusPill(
                  label: _isPro ? 'PRO' : 'DEMO',
                  color: _isPro ? AppTheme.accent : AppTheme.muted,
                  icon: _isPro
                      ? Icons.verified_rounded
                      : Icons.lock_outline_rounded,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
          children: [
            FadeSlideIn(child: _configCard()),
            const SizedBox(height: 14),
            if (_note != null) _noteCard(),
            SoftSwitcher(
              child: _busy
                  ? const BusyIndicator(
                      key: ValueKey('busy'),
                      message:
                          'Generating your paper...\nFilling in AI questions can take a moment.',
                    )
                  : Column(
                      key: ValueKey(_generated),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _generated
                          ? _paperPages()
                          : [
                              const EmptyState(
                                icon: Icons.library_books_outlined,
                                title: 'Ready when you are',
                                message:
                                    'Pick a subject and mode above, then tap Generate Paper.',
                              ),
                            ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String get _titleText => _titleCtrl.text.trim().isNotEmpty
      ? _titleCtrl.text.trim()
      : (_isEnglish ? 'Model Test' : 'মডেল পরীক্ষা — ২০২৭');

  String _patternInfoLine() {
    final p = _patternFor(_subject?.id ?? 'general_math');
    String line;
    if (_subject?.id == 'ict') {
      line = 'MCQ ${p.mcqCount} (তত্ত্বীয় 25) + ব্যবহারিক ${p.practicalMarks} =50 (Sep-2025: SAQ বাতিল)';
    } else if (_subject?.id == 'accounting') {
      line = 'Creative ${p.cqCount} (উত্তর ${p.cqAnswerCount}=40) + বাধ্যতামূলক ${p.compulsoryCount}×${p.compulsoryMarks}=20 + SAQ ${p.saqCount} (উত্তর ${p.saqAnswerCount}×2=10) + MCQ ${p.mcqCount}=30 => 100';
    } else if (p.financeDivisions) {
      line = 'Creative ${p.cqCount} (Fin5+Bank3, উত্তর5≥2) =50 + SAQ ${p.saqCount} (8+7, উত্তর10≥4)=20 + MCQ ${p.mcqCount}=30 =>100';
    } else if (p.practicalMarks == 25 && p.mcqCount == 25) {
      line = 'Creative ${p.cqCount} (উত্তর${p.cqAnswerCount}=${p.cqAnswerCount*10}) + SAQ ${p.saqCount} (উত্তর${p.saqAnswerCount}=${p.saqAnswerCount*2}) + MCQ ${p.mcqCount}=25 => তত্ত্বীয় ${p.theoryMarks} + ব্যবহারিক ${p.practicalMarks}=${p.totalMarks}';
    } else {
      line = 'Creative ×${p.cqCount} (${p.cqAnswerCount}×10=${p.cqAnswerCount*10}) + SAQ ×${p.saqCount} (${p.saqAnswerCount}×2=${p.saqAnswerCount*2}) + MCQ ${p.mcqCount}=${p.mcqCount} => ${p.theoryMarks}';
    }
    final extra = p.practicalMarks > 0 ? ' + ব্যবহারিক ${p.practicalMarks}' : '';
    final note = p.note.isNotEmpty ? '\n📝 ${p.note}' : '';
    return '📄 SSC-2027 (PDF Page-14/24/26 যাচাই): $line • Total ${p.totalMarks}$extra • ${p.totalMarks==50?"1h+2h practical":"3h"}$note';
  }

  Widget _configCard() {
    final chapters = _chapters;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Paper setup',
            subtitle: 'Choose the subject, format and title for this paper.',
            icon: Icons.tune_rounded,
          ),
          DropdownButtonFormField<SubjectInfo>(
            // DropdownButtonFormField draws its own text; it does not read
            // dropdownMenuTheme, so the colour must be set here or items fall
            // back to a near-white default on the light menu.
            style: const TextStyle(color: AppTheme.textDark, fontSize: 15),
            value: _subject,
            decoration: const InputDecoration(labelText: 'Subject'),
            items: allSubjects
                .map((s) => DropdownMenuItem(value: s, child: Text('${s.icon}  ${s.name}')))
                .toList(),
            onChanged: (s) {
              final List<String> set;
              if (_isEnglish2nd(s!.id) || _isEnglish1st(s.id)) {
                set = const [_mixedLabel];
              } else {
                set = <String>{
                  ...allMCQs.where((q) => q.subjectId == s!.id).map((q) => q.chapter),
                  ...allCQs.where((q) => q.subjectId == s!.id).map((q) => q.chapter),
                }.toList()
                  ..sort();
              }
              setState(() {
                _subject = s;
                _chapter = set.isNotEmpty ? set.first : null;
                _generated = false;
              });
            },
            hint: const Text('Choose a subject'),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                  value: 'chapter',
                  label: Text('Chapter-wise Paper'),
                  icon: Icon(Icons.bookmark_outline)),
              ButtonSegment(
                  value: 'full',
                  label: Text('Full Model Test Paper'),
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
              // DropdownButtonFormField draws its own text; it does not read
              // dropdownMenuTheme, so the colour must be set here or items fall
              // back to a near-white default on the light menu.
              style: const TextStyle(color: AppTheme.textDark, fontSize: 15),
              value: _chapter,
              decoration: const InputDecoration(labelText: 'Chapter'),
              items: chapters
                  .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (c) => setState(() {
                _chapter = c;
                _generated = false;
              }),
              hint: const Text('Choose a chapter'),
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
            style: const TextStyle(fontSize: 11.5, color: AppTheme.muted),
          ),
          const SizedBox(height: 10),
          Text(
            _isEnglish2nd(_subject?.id)
                ? '📋 Mixed Board Papers 2024 — Part–A: Grammar (Q1–9, 60) + Part–B: Composition (Q10–12, 40)  •  প্রতিটি প্রশ্ন আলাদা বোর্ড থেকে'
                : _isEnglish1st(_subject?.id)
                    ? '📋 Mixed Board Papers 2024 — Part–A: Reading (Q1–9, 70) + Part–B: Writing (Q10–11, 30)  •  প্রতিটি প্রশ্ন আলাদা বোর্ড থেকে'
                    : (_mode == 'chapter'
                        ? '📋 Structure: MCQ 10 + Creative 2  •  Marks 30  •  1 hour'
                        : _patternInfoLine()),
            style: const TextStyle(fontSize: 12, color: AppTheme.muted),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: _busy ? 'Generating…' : 'Generate Paper',
            icon: Icons.auto_fix_high,
            loading: _busy,
            onPressed: _busy ? null : _generate,
          ),
        ],
      ),
    );
  }

  Widget _noteCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InfoBanner(
        text: _note!,
        color: const Color(0xFFFFB347),
        icon: Icons.lightbulb_outline_rounded,
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
    // ── 👁️ EXACT preview: প্রিন্ট-পাইপলাইনের হুবহু পেজ-ছবি (সব বিষয়) ──
    final pages = _pagePngs;
    if (pages != null && pages.isNotEmpty) {
      return [
        for (var i = 0; i < pages.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black26),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.20),
                    blurRadius: 16,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Image.memory(pages[i], fit: BoxFit.fitWidth),
          ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'প্রিভিউ = প্রিন্ট হওয়া PDF-এর হুবহু রূপ (সব বিষয়ের ক্ষেত্রে)',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.muted),
            ),
          ),
        ),
        _actionRow(),
        if (_showAnswerKey) ...[
          if (_isEnglish) _englishAnswerCard() else _answerKeyCard(),
        ],
        const SizedBox(height: 30),
      ];
    }
    // ── English (প্রিভিউ ব্যর্থ হলে): ছোট নোট + বাটন ──
    if (_isEnglish) {
      return [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black12),
          ),
          child: Text(
            'প্রিভিউ বানাতে সমস্যা হয়েছে — PDF / Print চাপলেই পুরো পেপার দেখা যাবে (বোর্ড-লেআউট একই থাকবে)।',
            style: _serifSmall,
          ),
        ),
        _actionRow(),
        if (_showAnswerKey) _englishAnswerCard(),
        const SizedBox(height: 30),
      ];
    }
    final isFull = _mode == 'full';
    final pat = _patternFor(_subject!.id);
    final time = _mode == 'chapter' ? '১ ঘণ্টা' : '৩ ঘণ্টা';
    final marks = _mode == 'chapter' ? _bn(30) : _bn(pat.totalMarks);
    final cqAnswerCount = _mode == 'chapter' ? _cqs.length : pat.cqAnswerCount;
    String cqNote;
    if (isFull && pat.mathDivisions) {
      cqNote = '(ক, খ, গ ও ঘ — প্রত্যেক বিভাগ থেকে ন্যূনতম ১টি সহ যেকোনো ${_bn(pat.cqAnswerCount)}টি প্রশ্নের উত্তর দাও। প্রতিটি প্রশ্নের মান ১০) – PDF Page-14';
    } else if (isFull && pat.financeDivisions) {
      cqNote = '(ফিন্যান্স 5+ব্যাংকিং 3=8 CQ, উত্তর 5 (≥2 প্রতি অংশে); SAQ 8+7=15, উত্তর10 (≥4 যেকোনো অংশে)) – PDF Page-26';
    } else if (isFull && _subject!.id == 'accounting') {
      cqNote = '(7 CQ থেকে 4টি=40 + বাধ্যতামূলক আর্থিক বিবরণী 20 =60, SAQ 5×2=10) – PDF Page-24';
    } else if (isFull && _subject!.id == 'bangla_1st') {
      cqNote = '(গদ্য 4+পদ্য 4=8 CQ উত্তর5=50 + সহপাঠ 4 থেকে উত্তর2=20) – PDF Page-3';
    } else {
      cqNote = '(যেকোনো ${_bn(cqAnswerCount)}টি প্রশ্নের উত্তর দাও। প্রতিটি প্রশ্নের মান ১০)';
    }

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
                      Text(_titleText, style: _serifTitle),
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

  /// English 2nd Paper — board set structure card (exact paper prints in PDF).
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
    // গণিত/উচ্চতর গণিত (SSC-2027 নতুন নিয়ম): ক(২) খ(৪) গ(৪) — ৩ ভাগ
    final bool math3 =
        _subject?.id == 'general_math' || _subject?.id == 'higher_math';
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
          part('ক', cq.questionK, math3 ? 2 : (cq.marks.isNotEmpty ? cq.marks[0] : 1)),
          part('খ', cq.questionKh, math3 ? 4 : (cq.marks.length > 1 ? cq.marks[1] : 2)),
          part('গ', cq.questionG, math3 ? 4 : (cq.marks.length > 2 ? cq.marks[2] : 3)),
          if (!math3) part('ঘ', cq.questionGh, cq.marks.length > 3 ? cq.marks[3] : 4),
        ],
      ),
    );
  }

  Widget _actionRow() {
    if (_isEnglish) {
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
              label: 'PDF / Print',
              icon: Icons.print_rounded,
              onPressed: _onPrintTap,
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        Row(
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
                label: _busyPrint ? 'Creating PDF…' : 'PDF / Print',
                icon: Icons.print_rounded,
                loading: _busyPrint,
                onPressed: _busyPrint ? null : _onPrintTap,
              ),
            ),
          ],
        ),
        // Save keeps the paper + its answer key so the OMR scanner can
        // grade sheets against it without retyping the key.
        if (_generated && _mcqs.isNotEmpty) ...[
          const SizedBox(height: 10),
          AppButton(
            label: _busySave
                ? 'Saving paper + pages…'
                : 'Save paper (with answer key)',
            icon: Icons.save_rounded,
            loading: _busySave,
            outlined: true,
            onPressed: _busySave ? null : _savePaper,
          ),
        ],
      ],
    );
  }

  /// Saves the generated paper (title, subject, set + every MCQ with its
  /// correct option) to the Question Papers library → Saved tab.
  Future<void> _savePaper() async {
    if (_mcqs.isEmpty || _subject == null) return;
    setState(() => _busySave = true);
    // Paint the spinner frame before the (synchronous) page encoding starts.
    await SchedulerBinding.instance.endOfFrame;
    try {
      final sp = SavedPaper(
        id: 'sp_${DateTime.now().microsecondsSinceEpoch}',
        title: _titleText,
        subject: _subject!.bengaliName,
        subjectId: _subject!.id,
        subjectCode: _subjectCodes[_subject!.id] ?? '',
        setCode: _setLetter,
        total: _mcqs.length,
        key: _mcqs.map((q) => q.correctIndex).toList(),
        questions: [
          for (final q in _mcqs)
            SavedQuestion(
              text: q.questionText,
              options: q.options,
              answer: q.correctIndex,
            ),
        ],
        createdAt: DateTime.now(),
        pages: _pagePngs?.length ?? 0,
      );
      // Also save the rendered pages so the paper itself (not just the
      // key) is stored locally and can be viewed/printed from Saved.
      await PaperLibrary.addSavedPaper(sp, pageImages: _pagePngs);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Paper saved. Open Question Papers → Saved, or pick it in the OMR Scanner.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        await _problem('Save failed', '$e');
      }
    } finally {
      if (mounted) setState(() => _busySave = false);
    }
  }

  /// Answer keys keep the printed-sheet look (white paper, dark ink) so they
  /// match the paper preview above them.
  Widget _paperSheet({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.secondary.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.24),
              blurRadius: 18,
              offset: const Offset(0, 8)),
        ],
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.black87),
        child: child,
      ),
    );
  }

  Widget _answerKeyCard() {
    return _paperSheet(
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

  // ── English board-set উত্তরমালা কার্ড (Pro) ─────────────────────────
  Widget _englishAnswerCard() {
    final children = <Widget>[];

    String letters(List<String> ws, [String ls = 'abcdefghij']) {
      final b = StringBuffer();
      for (var i = 0; i < ws.length && i < ls.length; i++) {
        b.write('(${ls[i]}) ${ws[i]}${i + 1 < ws.length ? '    ' : ''}');
      }
      return b.toString();
    }

    void sec(String title, String body, [String? from]) {
      children.add(Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13.5)),
            if (from != null)
              Text('from: $from',
                  style: TextStyle(
                      fontSize: 10.5, color: Colors.teal.shade700)),
            const SizedBox(height: 3),
            Text(body,
                style: _serifBody.copyWith(fontSize: 12.5, height: 1.6)),
          ],
        ),
      ));
    }

    void secList(String title, List<String> lines, [String? from]) =>
        sec(title, lines.join('\n'), from);

    String boardOf(int serial, List<EnglishBoardSet> sets) {
      for (final st in sets) {
        if (st.serial == serial) return st.board;
      }
      return 'Set $serial';
    }

    String boardOf1(int serial) {
      for (final st in englishFirstSets2024) {
        if (st.serial == serial) return st.board;
      }
      return 'Set $serial';
    }

    if (_isEnglish2nd(_subject?.id) && _e2Src.isNotEmpty) {
      final src = _e2Src;
      for (var i = 0; i < src.length && i < 12; i++) {
        final an = english2Answers2024[src[i]];
        if (an == null) continue;
        final from = '${src[i]} • ${boardOf(src[i], englishBoardSets2024)}';
        switch (i) {
          case 0:
            sec('1. Fill in the gaps (word box)', letters(an.q1), from);
            break;
          case 1:
            secList('2. Making sentences', an.q2, from);
            break;
          case 2:
            sec('3. Right form of verbs', letters(an.q3), from);
            break;
          case 3:
            secList('4. Changing sentences', an.q4, from);
            break;
          case 4:
            secList('5. Tag questions', an.q5, from);
            break;
          case 5:
            sec('6. Suffix & prefix', letters(an.q6, 'abcde'), from);
            break;
          case 6:
            sec('7. Prepositions', letters(an.q7, 'abcde'), from);
            break;
          case 7:
            sec('8. Connectors', letters(an.q8, 'abcde'), from);
            break;
          case 8:
            sec('9. Capitalization & punctuation', an.q9, from);
            break;
          case 9:
            sec('10. Paragraph', an.q10, from);
            break;
          case 10:
            sec('11. Application / Email / Letter', an.q11, from);
            break;
          case 11:
            sec('12. Composition', an.q12, from);
            break;
        }
      }
    } else if (_isEnglish1st(_subject?.id) && _e1Src.isNotEmpty) {
      final src = _e1Src;
      for (var i = 0; i < src.length && i < 9; i++) {
        final an = english1Answers2024[src[i]];
        if (an == null) continue;
        final from = '${src[i]} • ${boardOf1(src[i])}';
        switch (i) {
          case 0:
            secList('1. Multiple choice (correct options)', an.q1, from);
            secList('2. Answering questions', an.q2, from);
            break;
          case 1:
            sec('3. Cloze test without clues', letters(an.q3, 'abcde'), from);
            break;
          case 2:
            secList('4. Information transfer', an.q4, from);
            sec('5. Summary', an.q5, from);
            break;
          case 3:
            secList('6. Matching parts of sentences', an.q6, from);
            break;
          case 4:
            sec('7. Arrangement of sentences', an.q7, from);
            break;
          case 5:
            secList('8. Poem-based questions', an.q8, from);
            break;
          case 6:
            secList('9. Story-based questions', an.q9, from);
            break;
          case 7:
            sec('10. Completing story — ${an.q10Title}', an.q10, from);
            break;
          case 8:
            sec('11. Dialogue', an.q11, from);
            break;
        }
      }
    }

    if (children.isEmpty) {
      children.add(Text('এই সেটের উত্তরমালা তৈরি হচ্ছে…', style: _serifSmall));
    }
    return _paperSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('উত্তরমালা',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const Divider(height: 16, color: Colors.black26),
          ...children,
        ],
      ),
    );
  }
}

