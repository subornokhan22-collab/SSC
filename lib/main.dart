import 'package:flutter/material.dart';

void main() {
  runApp(const ALearningApp());
}

class ALearningApp extends StatelessWidget {
  const ALearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'A-Learning',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MCQScreen(),
    );
  }
}

// 1. Question Model
class Question {
  final int id;
  final String subject;
  final String chapter;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;

  Question({
    required this.id,
    required this.subject,
    required this.chapter,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });
}

// 2. MCQ Screen Widget
class MCQScreen extends StatefulWidget {
  const MCQScreen({super.key});

  @override
  State<MCQScreen> createState() => _MCQScreenState();
}

class _MCQScreenState extends State<MCQScreen> {
  // Raw Question Pool
  final List<Question> _rawQuestions = [
    Question(
      id: 3,
      subject: 'Physics',
      chapter: 'Motion',
      questionText: 'What is the SI unit of velocity?',
      options: ['m/s²', 'm/s', 'kg', 'N'],
      correctOptionIndex: 1,
    ),
    Question(
      id: 1,
      subject: 'Physics',
      chapter: 'Motion',
      questionText: 'Which of the following is a vector quantity?',
      options: ['Speed', 'Distance', 'Displacement', 'Mass'],
      correctOptionIndex: 2,
    ),
    Question(
      id: 2,
      subject: 'Physics',
      chapter: 'Motion',
      questionText: 'What is the acceleration due to gravity on Earth?',
      options: ['9.8 m/s²', '10.5 m/s²', '8.9 m/s²', '9.8 cm/s²'],
      correctOptionIndex: 0,
    ),
  ];

  late List<Question> organizedQuestions;
  int? selectedOption;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Deterministic sorting by ID to maintain strict ordering
    organizedQuestions = List.from(_rawQuestions);
    organizedQuestions.sort((a, b) => a.id.compareTo(b.id));
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = organizedQuestions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('A-Learning • Question ${currentIndex + 1} of ${organizedQuestions.length}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Chapter Header Badge
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text('${currentQ.subject} • ${currentQ.chapter}'),
                backgroundColor: Colors.blue.shade50,
              ),
            ),
            const SizedBox(height: 12),

            // Question Text
            Text(
              'Q${currentQ.id}. ${currentQ.questionText}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Options List
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
                    backgroundColor: isSelected ? Colors.blue : Colors.grey.shade200,
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selectedOption = index;
                    });
                  },
                ),
              );
            }),

            const Spacer(),

            // Navigation Button
            ElevatedButton(
              onPressed: selectedOption == null
                  ? null
                  : () {
                      if (currentIndex < organizedQuestions.length - 1) {
                        setState(() {
                          currentIndex++;
                          selectedOption = null;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Quiz Completed!')),
                        );
                      }
                    },
              child: Text(
                currentIndex == organizedQuestions.length - 1 ? 'Finish' : 'Next Question',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
