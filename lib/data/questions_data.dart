import 'package:flutter/material.dart';

class Question {
  final String id;
  final String subject;
  final String chapter;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String source; // 'ai' or 'board'
  final String sourceLabel;
  final String explanation; // Added: Detailed solution/explanation

  Question({
    required this.id,
    required this.subject,
    required this.chapter,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.source,
    required this.sourceLabel,
    this.explanation = '',
  });
}

class CQSubPart {
  final String label; // ক, খ, গ, ঘ
  final String prompt;
  final int marks;
  final String modelAnswer; // Added: Model solution for self-assessment

  CQSubPart({
    required this.label,
    required this.prompt,
    required this.marks,
    this.modelAnswer = '',
  });
}

class CreativeQuestion {
  final String id;
  final String subject;
  final String chapter;
  final String stem;
  final List<CQSubPart> subParts;
  final String source;
  final String sourceLabel;

  CreativeQuestion({
    required this.id,
    required this.subject,
    required this.chapter,
    required this.stem,
    required this.subParts,
    required this.source,
    required this.sourceLabel,
  });
}

enum SubjectGroup { all, science, commerce, humanities, general }

class SubjectInfo {
  final String id;
  final String name;
  final String bengaliName;
  final IconData icon;
  final Color color;
  final SubjectGroup group;

  SubjectInfo({
    required this.id,
    required this.name,
    required this.bengaliName,
    required this.icon,
    required this.color,
    this.group = SubjectGroup.general,
  });
}

// Sample Data Setup
class QuestionsData {
  static final List<SubjectInfo> subjects = [
    SubjectInfo(id: 'physics', name: 'Physics', bengaliName: 'পদার্থবিজ্ঞান', icon: Icons.science, color: Colors.indigo, group: SubjectGroup.science),
    SubjectInfo(id: 'chemistry', name: 'Chemistry', bengaliName: 'রসায়ন', icon: Icons.science_outlined, color: Colors.teal, group: SubjectGroup.science),
    SubjectInfo(id: 'higher_math', name: 'Higher Math', bengaliName: 'উচ্চতর গণিত', icon: Icons.functions, color: Colors.deepPurple, group: SubjectGroup.science),
    SubjectInfo(id: 'biology', name: 'Biology', bengaliName: 'জীববিজ্ঞান', icon: Icons.biotech, color: Colors.green, group: SubjectGroup.science),
    SubjectInfo(id: 'general_math', name: 'General Math', bengaliName: 'সাধারণ গণিত', icon: Icons.calculate, color: Colors.blue, group: SubjectGroup.general),
    SubjectInfo(id: 'bangla_1', name: 'Bangla 1st', bengaliName: 'বাংলা ১ম পত্র', icon: Icons.menu_book, color: Colors.red, group: SubjectGroup.general),
    SubjectInfo(id: 'english_1', name: 'English 1st', bengaliName: 'English 1st Paper', icon: Icons.language, color: Colors.orange, group: SubjectGroup.general),
    SubjectInfo(id: 'ict', name: 'ICT', bengaliName: 'তথ্য ও যোগাযোগ প্রযুক্তি', icon: Icons.devices, color: Colors.cyan, group: SubjectGroup.general),
    // Additional subjects can be mapped here similarly...
  ];

  static final List<Question> mcqs = [
    Question(
      id: 'p1',
      subject: 'physics',
      chapter: 'গতি (Motion)',
      questionText: 'কোনো বস্তুর বেগের পরিবর্তনের হারকে কী বলে?',
      options: ['সরণ', 'দ্রুতি', 'ত্বরণ', 'বল'],
      correctOptionIndex: 2,
      source: 'ai',
      sourceLabel: 'AI তৈরি',
      explanation: 'একক সময়ে কোনো বস্তুর বেগের পরিবর্তনের হারকে ত্বরণ ($a = \\frac{v-u}{t}$) বলে।',
    ),
    Question(
      id: 'hm1',
      subject: 'higher_math',
      chapter: 'দ্বিপদী বিস্তৃতি',
      questionText: '$(1+x)^n$ এর বিস্তৃতিতে পদসংখ্যা কত?',
      options: ['n', 'n-1', 'n+1', '2n'],
      correctOptionIndex: 2,
      source: 'ai',
      sourceLabel: 'AI তৈরি',
      explanation: 'দ্বিপদী বিস্তৃতি $(a+b)^n$ এর পদসংখ্যা সবসময় ঘাত $n$ এর চেয়ে ১ বেশি অর্থাৎ $n+1$ হয়।',
    ),
  ];

  static final List<CreativeQuestion> cqs = [
    CreativeQuestion(
      id: 'cq_p1',
      subject: 'physics',
      chapter: 'গতি',
      stem: 'একটি গাড়ি স্থির অবস্থান থেকে $2\\text{ ms}^{-2}$ সুষম ত্বরণে $10\\text{ s}$ চলল।',
      source: 'ai',
      sourceLabel: 'AI তৈরি',
      subParts: [
        CQSubPart(label: 'ক', prompt: 'ত্বরণ কাকে বলে?', marks: 1, modelAnswer: 'সময়ের সাথে বস্তুর বেগ বৃদ্ধির হারকে ত্বরণ বলে।'),
        CQSubPart(label: 'খ', prompt: 'সমবেগ বলতে কী বোঝায়?', marks: 2, modelAnswer: 'যদি গতিশীল কোনো বস্তুর বেগের মান ও দিক পরিবর্তিত না হয়, তবে তাকে সমবেগ বলে।'),
        CQSubPart(label: 'গ', prompt: 'গাড়িটির শেষ বেগ নির্ণয় করো।', marks: 3, modelAnswer: '$v = u + at = 0 + (2 \\times 10) = 20\\text{ ms}^{-1}$'),
        CQSubPart(label: 'ঘ', prompt: 'উক্ত সময়ে অতিক্রান্ত দূরত্ব কত হবে গাণিতিকভাবে বিশ্লেষণ করো।', marks: 4, modelAnswer: '$s = ut + \\frac{1}{2}at^2 = 0 + \\frac{1}{2}(2)(10^2) = 100\\text{ m}$'),
      ],
    ),
  ];
}
