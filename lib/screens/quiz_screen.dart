import 'dart:async';
import 'package:flutter/material.dart';
import '../data/questions_data.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/app_button.dart';

class QuizScreen extends StatefulWidget {
  final String? subjectId;
  final String? chapter;

  /// Used by Model Test & AI Generate screens: a ready-made question list.
  final List<Question>? customQuestions;

  /// Optional app-bar title when [customQuestions] is supplied.
  final String? customTitle;

  const QuizScreen({
    super.key,
    this.subjectId,
    this.chapter,
    this.customQuestions,
    this.customTitle,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Question> _questions;
  late List<int?> _answers;
  int _current = 0;
  int _direction = 1; // slide direction for question transitions
  Timer? _timer;
  int _secondsLeft = 0;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _questions = _buildQuestionSet();
    _answers = List<int?>.filled(_questions.length, null);

    // Custom (model test / AI generated): 1 minute per question (30 Q = 30 min).
    // Mixed full quiz (no subject): 15 minutes as before.
    if (widget.customQuestions != null) {
      _secondsLeft = _questions.length * 60;
    } else if (widget.subjectId == null) {
      _secondsLeft = 15 * 60;
    } else {
      _secondsLeft = _questions.length * 60;
    }

    if (_questions.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        if (_secondsLeft <= 0) {
          _submit();
        } else {
          setState(() => _secondsLeft--);
        }
      });
    }
  }

  List<Question> _buildQuestionSet() {
    // 1) Custom questions passed in (Model Test / AI Generate)
    if (widget.customQuestions != null) {
      return List.of(widget.customQuestions!);
    }
    // 2) Built-in bank
    List<Question> pool;
    if (widget.subjectId == null) {
      pool = List.of(allMCQs)..shuffle();
      return pool.take(20).toList();
    } else if (widget.chapter != null) {
      pool = allMCQs
          .where(
              (q) => q.subjectId == widget.subjectId && q.chapter == widget.chapter)
          .toList();
    } else {
      pool = allMCQs.where((q) => q.subjectId == widget.subjectId).toList();
    }
    pool.shuffle();
    return pool;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _submit() {
    if (_submitted) return;
    _timer?.cancel();
    setState(() => _submitted = true);
  }

  void _next() {
    if (_current < _questions.length - 1) {
      setState(() {
        _direction = 1;
        _current++;
      });
    } else {
      _submit();
    }
  }

  void _prev() {
    if (_current > 0) {
      setState(() {
        _direction = -1;
        _current--;
      });
    }
  }

  int get _score => List.generate(
        _questions.length,
        (i) => _answers[i] == _questions[i].correctIndex ? 1 : 0,
      ).fold(0, (a, b) => a + b);

  String get _timeLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _timerPill() {
    final low = _secondsLeft <= 60;
    final pill = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: low
            ? Colors.red.shade600
            : Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_rounded, size: 16, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            _timeLabel,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
    return Pulse(enabled: low, child: pill);
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.customTitle ?? 'Quiz')),
        body: const Center(child: Text('কোনো প্রশ্ন পাওয়া যায়নি।')),
      );
    }
    if (_submitted) return _buildResult();

    final q = _questions[_current];
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.customTitle ?? 'প্রশ্ন ${_current + 1}/${_questions.length}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: _timerPill()),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Animated progress bar ────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                            begin: 0,
                            end: (_current + 1) / _questions.length),
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, _) => LinearProgressIndicator(
                          value: v,
                          minHeight: 7,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${_current + 1}/${_questions.length}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Question area with slide transition ──────────────
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final slide = Tween<Offset>(
                      begin: Offset(0.10 * _direction, 0),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: slide, child: child),
                    );
                  },
                  child: SingleChildScrollView(
                    key: ValueKey(_current),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.chapter,
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          q.questionText,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 20),
                        ...List.generate(q.options.length, (i) {
                          final selected = _answers[_current] == i;
                          return FadeSlideIn(
                            delay: Duration(milliseconds: 55 * i),
                            duration: const Duration(milliseconds: 320),
                            offset: const Offset(0, 14),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () =>
                                    setState(() => _answers[_current] = i),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: selected
                                          ? AppTheme.primary
                                          : Colors.grey.shade300,
                                      width: selected ? 1.6 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    color: selected
                                        ? AppTheme.primary.withOpacity(0.08)
                                        : Colors.white,
                                    boxShadow: selected
                                        ? [
                                            BoxShadow(
                                              color: AppTheme.primary
                                                  .withOpacity(0.15),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: selected
                                              ? AppTheme.primary
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: selected
                                                ? AppTheme.primary
                                                : Colors.grey.shade400,
                                            width: 1.6,
                                          ),
                                        ),
                                        child: selected
                                            ? const Icon(Icons.check,
                                                size: 15,
                                                color: Colors.white)
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(child: Text(q.options[i])),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Navigation buttons ───────────────────────────────
              Row(
                children: [
                  if (_current > 0)
                    Expanded(
                      child: AppButton(
                        label: 'আগের প্রশ্ন',
                        outlined: true,
                        onPressed: _prev,
                      ),
                    ),
                  if (_current > 0) const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      label: _current < _questions.length - 1
                          ? 'পরের প্রশ্ন'
                          : 'জমা দিন',
                      icon: _current < _questions.length - 1
                          ? Icons.arrow_forward
                          : Icons.check_circle,
                      onPressed: _next,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    return Scaffold(
      appBar: AppBar(title: const Text('ফলাফল')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FadeSlideIn(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Pulse(
                    min: 0.95,
                    max: 1.08,
                    period: Duration(milliseconds: 1500),
                    child: Icon(Icons.emoji_events_rounded,
                        color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        'স্কোর: ',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70),
                      ),
                      CountUp(
                        value: _score,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        ' / ${_questions.length}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(_questions.length, (i) {
            final q = _questions[i];
            final userAns = _answers[i];
            final correct = userAns == q.correctIndex;
            return FadeSlideIn(
              delay: Duration(milliseconds: 35 * (i > 10 ? 10 : i)),
              duration: const Duration(milliseconds: 350),
              offset: const Offset(0, 14),
              child: Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            correct ? Icons.check_circle : Icons.cancel,
                            size: 18,
                            color: correct ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${i + 1}. ${q.questionText}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'সঠিক উত্তর: ${q.options[q.correctIndex]}',
                        style: const TextStyle(color: Colors.green),
                      ),
                      if (userAns != null && !correct)
                        Text(
                          'আপনার উত্তর: ${q.options[userAns]}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      if (userAns == null)
                        const Text(
                          'উত্তর দেওয়া হয়নি',
                          style: TextStyle(color: Colors.orange),
                        ),
                      if (q.explanation.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          q.explanation,
                          style: TextStyle(
                              color: Colors.grey[700], fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
