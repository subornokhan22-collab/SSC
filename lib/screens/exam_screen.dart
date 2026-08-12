import 'dart:async';
import 'package:flutter/material.dart';
import '../data/questions_data.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({Key? key}) : super(key: key);

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  List<Question> _questions = [];
  Map<int, int> _userAnswers = {};
  int _secondsRemaining = 900; // 15 Minutes
  Timer? _timer;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _startExam();
  }

  void _startExam() {
    final shuffled = List<Question>.from(allMCQs)..shuffle();
    setState(() {
      _questions = shuffled.take(20).toList();
      _userAnswers.clear();
      _secondsRemaining = 900;
      _isSubmitted = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _submitExam();
      }
    });
  }

  void _submitExam() {
    _timer?.cancel();
    setState(() {
      _isSubmitted = true;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int _calculateScore() {
    int score = 0;
    _userAnswers.forEach((index, selected) {
      if (_questions[index].correctIndex == selected) {
        score++;
      }
    });
    return score;
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('লাইভ পরীক্ষা',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A82BB),
        foregroundColor: Colors.white,
        actions: [
          if (!_isSubmitted)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  _formatTime(_secondsRemaining),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: _questions.isEmpty
          ? const Center(child: Text('কোনো প্রশ্ন পাওয়া যায়নি।'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      final q = _questions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${index + 1}. ${q.questionText}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ...List.generate(q.options.length, (optIndex) {
                                return RadioListTile<int>(
                                  title: Text(q.options[optIndex]),
                                  value: optIndex,
                                  groupValue: _userAnswers[index],
                                  onChanged: _isSubmitted
                                      ? null
                                      : (val) {
                                          setState(() {
                                            if (val != null)
                                              _userAnswers[index] = val;
                                          });
                                        },
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_isSubmitted)
                        Text(
                          'স্কোর: ${_calculateScore()} / ${_questions.length}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A82BB)),
                        ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A82BB),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _isSubmitted ? _startExam : _submitExam,
                        child: Text(
                            _isSubmitted ? 'পুনরায় পরীক্ষা দাও' : 'জমা দাও'),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
