import 'dart:async';
import 'package:flutter/material.dart';
import '../data/questions_data.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';

class QuizScreen extends StatefulWidget {
  final String? subjectId;
  final String? chapter;
  const QuizScreen({super.key, this.subjectId, this.chapter});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Question> _questions;
  late List<int?> _answers;
  int _current = 0;
  Timer? _timer;
  int _secondsLeft = 0;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _questions = _buildQuestionSet();
    _answers = List<int?>.filled(_questions.length, null);
    _secondsLeft = widget.subjectId == null ? 15 * 60 : _questions.length * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        _submit();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  List<Question> _buildQuestionSet() {
    List<Question> pool;
    if (widget.subjectId == null) {
      pool = List.of(allMCQs)..shuffle();
      return pool.take(20).toList();
    } else if (widget.chapter != null) {
      pool = allMCQs.where((q) => q.subjectId == widget.subjectId && q.chapter == widget.chapter).toList();
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

  int get _score => List.generate(_questions.length, (i) => _answers[i] == _questions[i].correctIndex ? 1 : 0).fold(0, (a, b) => a + b);

  String get _timeLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(appBar: AppBar(title: const Text('Quiz')), body: const Center(child: Text('কোনো প্রশ্ন পাওয়া যায়নি।')));
    }
    if (_submitted) return _buildResult();

    final q = _questions[_current];
    return Scaffold(
      appBar: AppBar(
        title: Text('প্রশ্ন ${_current + 1}/${_questions.length}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_timeLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.chapter, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 8),
            Text(q.questionText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            ...List.generate(q.options.length, (i) {
              final selected = _answers[_current] == i;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => setState(() => _answers[_current] = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: selected ? AppTheme.primary : Colors.grey.shade300, width: selected ? 1.6 : 1),
                      borderRadius: BorderRadius.circular(14),
                      color: selected ? AppTheme.primary.withOpacity(0.08) : Colors.white,
                      boxShadow: selected
                          ? [BoxShadow(color: AppTheme.primary.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected ? AppTheme.primary : Colors.transparent,
                            border: Border.all(color: selected ? AppTheme.primary : Colors.grey.shade400, width: 1.6),
                          ),
                          child: selected ? const Icon(Icons.check, size: 15, color: Colors.white) : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(q.options[i])),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            Row(
              children: [
                if (_current > 0)
                  Expanded(
                    child: AppButton(
                      label: 'আগের প্রশ্ন',
                      outlined: true,
                      onPressed: () => setState(() => _current--),
                    ),
                  ),
                if (_current > 0) const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    label: _current < _questions.length - 1 ? 'পরের প্রশ্ন' : 'জমা দিন',
                    icon: _current < _questions.length - 1 ? Icons.arrow_forward : Icons.check_circle,
                    onPressed: () {
                      if (_current < _questions.length - 1) {
                        setState(() => _current++);
                      } else {
                        _submit();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
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
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))],
            ),
            child: Center(
              child: Text(
                'স্কোর: $_score / ${_questions.length}',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(_questions.length, (i) {
            final q = _questions[i];
            final userAns = _answers[i];
            final correct = userAns == q.correctIndex;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(correct ? Icons.check_circle : Icons.cancel, size: 18, color: correct ? Colors.green : Colors.red),
                        const SizedBox(width: 6),
                        Expanded(child: Text('${i + 1}. ${q.questionText}', style: const TextStyle(fontWeight: FontWeight.w600))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('সঠিক উত্তর: ${q.options[q.correctIndex]}', style: const TextStyle(color: Colors.green)),
                    if (userAns != null && !correct) Text('আপনার উত্তর: ${q.options[userAns]}', style: const TextStyle(color: Colors.red)),
                    if (userAns == null) const Text('উত্তর দেওয়া হয়নি', style: TextStyle(color: Colors.orange)),
                    const SizedBox(height: 4),
                    Text(q.explanation, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
