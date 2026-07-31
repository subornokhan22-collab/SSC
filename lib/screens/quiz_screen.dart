// lib/screens/quiz_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../data/questions_data.dart';

class QuizScreen extends StatefulWidget {
  final String title;
  final List<Question> questions;
  final Duration? timeLimit; // non-null => "live exam" timed mode

  const QuizScreen({
    super.key,
    required this.title,
    required this.questions,
    this.timeLimit,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentIndex = 0;
  int? selectedOption;
  int score = 0;
  bool finished = false;

  Timer? _timer;
  late int _secondsLeft;

  @override
  void initState() {
    super.initState();
    if (widget.timeLimit != null) {
      _secondsLeft = widget.timeLimit!.inSeconds;
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() {
          _secondsLeft--;
          if (_secondsLeft <= 0) {
            _timer?.cancel();
            _finish();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectOption(int index) {
    if (finished) return;
    setState(() => selectedOption = index);
  }

  void _next() {
    final q = widget.questions[currentIndex];
    if (selectedOption == q.correctOptionIndex) score++;

    if (currentIndex < widget.questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedOption = null;
      });
    } else {
      _finish();
    }
  }

  void _finish() {
    _timer?.cancel();
    setState(() => finished = true);
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('কোনো প্রশ্ন পাওয়া যায়নি।')),
      );
    }

    if (finished) {
      return _buildResultScreen();
    }

    final currentQ = widget.questions[currentIndex];
    final progress = (currentIndex + 1) / widget.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          if (widget.timeLimit != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(_secondsLeft),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: progress, minHeight: 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text('${currentQ.subject} • ${currentQ.chapter}'),
                      backgroundColor: Colors.blue.shade50,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'প্রশ্ন ${currentIndex + 1}/${widget.questions.length}: ${currentQ.questionText}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(currentQ.options.length, (index) {
                    final isSelected = selectedOption == index;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        color: isSelected ? Colors.blue.shade50 : Colors.white,
                      ),
                      child: ListTile(
                        title: Text(currentQ.options[index]),
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              isSelected ? Colors.blue : Colors.grey.shade200,
                          child: Text(
                            String.fromCharCode(65 + index),
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        onTap: () => _selectOption(index),
                      ),
                    );
                  }),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: selectedOption == null ? null : _next,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      currentIndex == widget.questions.length - 1
                          ? 'শেষ করুন'
                          : 'পরবর্তী প্রশ্ন',
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

  Widget _buildResultScreen() {
    final total = widget.questions.length;
    final percent = total == 0 ? 0 : ((score / total) * 100).round();

    return Scaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                percent >= 60 ? Icons.emoji_events : Icons.refresh,
                size: 72,
                color: percent >= 60 ? Colors.amber : Colors.blueGrey,
              ),
              const SizedBox(height: 16),
              const Text(
                'ফলাফল',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '$score / $total সঠিক ($percent%)',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('ফিরে যান'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
