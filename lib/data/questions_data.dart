// lib/data/questions_data.dart

import 'package:flutter/material.dart';

/// Where a question came from. Real board questions must have an explicit
/// board name + year; never label AI-written content as board-sourced.
enum QuestionSource { ai, board }

class Question {
  final int id;
  final String subject;
  final String chapter;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final QuestionSource source;
  final String? sourceLabel; // e.g. "ঢাকা বোর্ড ২০২৩" — required if source == board

  Question({
    required this.id,
    required this.subject,
    required this.chapter,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.source = QuestionSource.ai,
    this.sourceLabel,
  });
}

/// A Creative Question (সৃজনশীল প্রশ্ন): a stimulus/passage followed by
/// four sub-questions of increasing difficulty (ক, খ, গ, ঘ).
class CQSubPart {
  final String label; // 'ক', 'খ', 'গ', 'ঘ'
  final String prompt;
  final int marks;

  const CQSubPart({required this.label, required this.prompt, required this.marks});
}

class CreativeQuestion {
  final int id;
  final String subject;
  final String chapter;
  final String stem; // the passage / given scenario
  final List<CQSubPart> parts;
  final QuestionSource source;
  final String? sourceLabel;

  CreativeQuestion({
    required this.id,
    required this.subject,
    required this.chapter,
    required this.stem,
    required this.parts,
    this.source = QuestionSource.ai,
    this.sourceLabel,
  });
}

class SubjectInfo {
  final String name;
  final String bengaliName;
  final IconData icon;
  final Color color;

  const SubjectInfo({
    required this.name,
    required this.bengaliName,
    required this.icon,
    required this.color,
  });
}

const List<SubjectInfo> subjects = [
  SubjectInfo(name: 'Physics', bengaliName: 'পদার্থবিজ্ঞান', icon: Icons.bolt, color: Colors.indigo),
  SubjectInfo(name: 'Higher Math', bengaliName: 'উচ্চতর গণিত', icon: Icons.functions, color: Colors.teal),
  SubjectInfo(name: 'English', bengaliName: 'ইংরেজি', icon: Icons.menu_book, color: Colors.deepOrange),
  SubjectInfo(name: 'Chemistry', bengaliName: 'রসায়ন', icon: Icons.science, color: Colors.pink),
];

// NOTE: All MCQs below are AI-generated (source defaults to QuestionSource.ai)
// unless a sourceLabel is explicitly set. Do not change a question's source
// to `board` unless its text has been transcribed from an actual verified
// board paper.
final List<Question> allQuestions = [
  Question(id: 1, subject: 'Physics', chapter: 'Motion', questionText: 'নিচের কোনটি ভেক্টর রাশি?', options: ['দ্রুতি (Speed)', 'দূরত্ব (Distance)', 'সরণ (Displacement)', 'ভর (Mass)'], correctOptionIndex: 2),
  Question(id: 2, subject: 'Physics', chapter: 'Motion', questionText: 'পৃথিবীতে অভিকর্ষজ ত্বরণের মান প্রায় কত?', options: ['9.8 m/s²', '10.5 m/s²', '8.9 m/s²', '9.8 cm/s²'], correctOptionIndex: 0),
  Question(id: 3, subject: 'Physics', chapter: 'Motion', questionText: 'বেগের SI একক কী?', options: ['m/s²', 'm/s', 'kg', 'N'], correctOptionIndex: 1),
  Question(id: 4, subject: 'Physics', chapter: 'Force and Motion', questionText: 'নিউটনের দ্বিতীয় সূত্র বল-কে কোন দুটি রাশির সাথে সম্পর্কিত করে?', options: ['ভর ও বেগ', 'ভর ও ত্বরণ', 'ওজন ও দ্রুতি', 'ভরবেগ ও সময়'], correctOptionIndex: 1),
  Question(id: 5, subject: 'Physics', chapter: 'Work, Energy and Power', questionText: 'ক্ষমতার SI একক কোনটি?', options: ['জুল', 'নিউটন', 'ওয়াট', 'প্যাসকেল'], correctOptionIndex: 2),
  Question(id: 6, subject: 'Physics', chapter: 'Work, Energy and Power', questionText: 'গতিশক্তি কোন কোন রাশির উপর নির্ভর করে?', options: ['শুধু ভর', 'শুধু বেগ', 'ভর ও বেগ উভয়', 'ভর ও উচ্চতা'], correctOptionIndex: 2),
  Question(id: 7, subject: 'Physics', chapter: 'Pressure', questionText: 'চাপের SI একক কোনটি?', options: ['নিউটন', 'প্যাসকেল', 'জুল', 'ওয়াট'], correctOptionIndex: 1),
  Question(id: 8, subject: 'Physics', chapter: 'Heat and Thermodynamics', questionText: 'বরফ গলে পানিতে পরিণত হওয়ার সময় স্থির তাপমাত্রায় যে তাপ শোষিত হয় তাকে বলে-', options: ['আপেক্ষিক তাপ', 'সুপ্ত তাপ', 'বিকিরিত তাপ', 'তাপ শোষণ হয় না'], correctOptionIndex: 1),
  Question(id: 9, subject: 'Physics', chapter: 'Waves', questionText: 'শব্দ তরঙ্গ কোন ধরনের তরঙ্গের উদাহরণ?', options: ['আড় তরঙ্গ', 'অনুদৈর্ঘ্য তরঙ্গ', 'তড়িৎচুম্বকীয় তরঙ্গ', 'স্থির তরঙ্গ'], correctOptionIndex: 1),
  Question(id: 10, subject: 'Physics', chapter: 'Electricity', questionText: 'ওহমের সূত্র অনুযায়ী V এর মান কত?', options: ['I / R', 'I × R', 'R / I', 'I + R'], correctOptionIndex: 1),

  Question(id: 11, subject: 'Higher Math', chapter: 'Set and Function', questionText: 'A = {1, 2, 3} এবং B = {2, 3, 4} হলে A ∩ B = ?', options: ['{1, 2, 3, 4}', '{2, 3}', '{1}', '{4}'], correctOptionIndex: 1),
  Question(id: 12, subject: 'Higher Math', chapter: 'Algebra', questionText: 'x² - 9 এর উৎপাদক কোনটি?', options: ['(x-3)(x+3)', '(x-9)(x+1)', '(x-3)²', '(x+9)(x-1)'], correctOptionIndex: 0),
  Question(id: 13, subject: 'Higher Math', chapter: 'Algebra', questionText: 'x² - 5x + 6 = 0 এর বীজদ্বয় α ও β হলে α + β = ?', options: ['5', '6', '-5', '-6'], correctOptionIndex: 0),
  Question(id: 14, subject: 'Higher Math', chapter: 'Geometry', questionText: 'একটি ত্রিভুজের অন্তঃকোণগুলোর সমষ্টি কত?', options: ['90°', '180°', '270°', '360°'], correctOptionIndex: 1),
  Question(id: 15, subject: 'Higher Math', chapter: 'Geometry', questionText: 'সমকোণী ত্রিভুজের সবচেয়ে বড় বাহুকে কী বলে?', options: ['ভূমি', 'লম্ব', 'অতিভুজ', 'মধ্যমা'], correctOptionIndex: 2),
  Question(id: 16, subject: 'Higher Math', chapter: 'Trigonometry', questionText: 'sin²θ + cos²θ = ?', options: ['0', '1', '2', 'tanθ'], correctOptionIndex: 1),
  Question(id: 17, subject: 'Higher Math', chapter: 'Trigonometry', questionText: 'tan 45° এর মান কত?', options: ['0', '1', '√3', 'অসংজ্ঞায়িত'], correctOptionIndex: 1),
  Question(id: 18, subject: 'Higher Math', chapter: 'Statistics', questionText: 'ক্রমানুসারে সাজানো উপাত্তের মধ্যবর্তী মানকে কী বলে?', options: ['গড়', 'প্রচুরক', 'মধ্যক', 'পরিসর'], correctOptionIndex: 2),
  Question(id: 19, subject: 'Higher Math', chapter: 'Algebra', questionText: '(a+b)² এর সঠিক রূপ কোনটি?', options: ['a² + b²', 'a² - 2ab + b²', 'a² + 2ab + b²', 'a² - b²'], correctOptionIndex: 2),
  Question(id: 20, subject: 'Higher Math', chapter: 'Set and Function', questionText: 'f: A → B ফাংশনটি এক-এক (one-to-one) হয় যখন-', options: ['A এর সব উপাদান B এর একই উপাদানে যায়', 'A এর ভিন্ন উপাদান B এর ভিন্ন উপাদানে যায়', 'B এর প্রতিটি উপাদানের প্রাক-প্রতিরূপ থাকে', 'A ও B এর উপাদান সংখ্যা সমান'], correctOptionIndex: 1),

  Question(id: 21, subject: 'English', chapter: 'Tenses', questionText: 'Choose the correct sentence:', options: ['She go to school every day.', 'She goes to school every day.', 'She going to school every day.', 'She gone to school every day.'], correctOptionIndex: 1),
  Question(id: 22, subject: 'English', chapter: 'Tenses', questionText: 'The past participle form of "write" is:', options: ['wrote', 'written', 'writing', 'writes'], correctOptionIndex: 1),
  Question(id: 23, subject: 'English', chapter: 'Parts of Speech', questionText: 'In "She sings beautifully," the word "beautifully" is a/an:', options: ['Noun', 'Verb', 'Adverb', 'Adjective'], correctOptionIndex: 2),
  Question(id: 24, subject: 'English', chapter: 'Sentence Transformation', questionText: 'Which is the compound form of "Being tired, he sat down"?', options: ['He sat down because he was tired.', 'He was tired and he sat down.', 'Tired, he sat down.', 'He sat down, being tired.'], correctOptionIndex: 1),
  Question(id: 25, subject: 'English', chapter: 'Vocabulary', questionText: 'The antonym of "ancient" is:', options: ['Old', 'Modern', 'Historic', 'Aged'], correctOptionIndex: 1),
  Question(id: 26, subject: 'English', chapter: 'Vocabulary', questionText: 'The synonym of "happy" is:', options: ['Sad', 'Angry', 'Joyful', 'Tired'], correctOptionIndex: 2),
  Question(id: 27, subject: 'English', chapter: 'Grammar', questionText: 'Choose the correctly punctuated sentence:', options: ['Where are you going.', 'Where are you going?', 'where are you going?', 'Where are you going!'], correctOptionIndex: 1),
  Question(id: 28, subject: 'English', chapter: 'Voice Change', questionText: 'The passive form of "He wrote a letter" is:', options: ['A letter is written by him.', 'A letter was written by him.', 'A letter has written by him.', 'A letter written by him.'], correctOptionIndex: 1),

  Question(id: 29, subject: 'Chemistry', chapter: 'Structure of Atom', questionText: 'পরমাণুতে প্রোটনের সংখ্যাকে কী বলে?', options: ['ভরসংখ্যা', 'পারমাণবিক সংখ্যা', 'আইসোটোপ সংখ্যা', 'যোজনী'], correctOptionIndex: 1),
  Question(id: 30, subject: 'Chemistry', chapter: 'Structure of Atom', questionText: 'ইলেকট্রন কোন ধরনের চার্জ বহন করে?', options: ['ধনাত্মক', 'ঋণাত্মক', 'নিরপেক্ষ', 'কোনো চার্জ নেই'], correctOptionIndex: 1),
  Question(id: 31, subject: 'Chemistry', chapter: 'Periodic Table', questionText: 'পর্যায় সারণির একই গ্রুপের মৌলগুলোর কোনটি একই থাকে?', options: ['নিউট্রন সংখ্যা', 'প্রোটন সংখ্যা', 'যোজন ইলেকট্রন সংখ্যা', 'আইসোটোপ সংখ্যা'], correctOptionIndex: 2),
  Question(id: 32, subject: 'Chemistry', chapter: 'Chemical Reactions', questionText: 'যে বিক্রিয়ায় তাপ নির্গত হয় তাকে বলে-', options: ['তাপহারী বিক্রিয়া', 'তাপউৎপাদী বিক্রিয়া', 'সমতাপী বিক্রিয়া', 'নিরপেক্ষ বিক্রিয়া'], correctOptionIndex: 1),
  Question(id: 33, subject: 'Chemistry', chapter: 'Acids and Bases', questionText: 'pH এর মান ৭ এর কম হলে পদার্থটি হয়-', options: ['ক্ষারীয়', 'নিরপেক্ষ', 'অম্লীয়', 'উভধর্মী'], correctOptionIndex: 2),
  Question(id: 34, subject: 'Chemistry', chapter: 'Acids and Bases', questionText: 'নিচের কোনটি একটি সবল ক্ষার?', options: ['NaOH', 'CH3COOH', 'HCl', 'H2CO3'], correctOptionIndex: 0),
  Question(id: 35, subject: 'Chemistry', chapter: 'Chemical Bonding', questionText: 'ইলেকট্রন ভাগাভাগির মাধ্যমে গঠিত বন্ধনকে কী বলে?', options: ['আয়নিক বন্ধন', 'সমযোজী বন্ধন', 'ধাতব বন্ধন', 'হাইড্রোজেন বন্ধন'], correctOptionIndex: 1),
  Question(id: 36, subject: 'Chemistry', chapter: 'Mole Concept', questionText: 'STP-তে ১ মোল যেকোনো গ্যাসের আয়তন কত?', options: ['11.2 L', '22.4 L', '44.8 L', '1 L'], correctOptionIndex: 1),
];

// All AI-generated for now — see note above. Add real ones via
// CreativeQuestion(..., source: QuestionSource.board, sourceLabel: 'যশোর বোর্ড ২০২২')
// once you send me transcribed board paper content.
final List<CreativeQuestion> allCQs = [
  CreativeQuestion(
    id: 1,
    subject: 'Physics',
    chapter: 'Heat and Thermodynamics',
    stem: '৫০ গ্রাম ভরের একটি বরফখণ্ড -১০°C তাপমাত্রায় আছে। এটিকে ধীরে ধীরে উত্তপ্ত করে ১০০°C তাপমাত্রার বাষ্পে পরিণত করা হলো। (বরফের আপেক্ষিক তাপ, গলনের সুপ্ত তাপ, পানির আপেক্ষিক তাপ ও বাষ্পীভবনের সুপ্ত তাপের প্রচলিত মান ব্যবহার করো।)',
    parts: const [
      CQSubPart(label: 'ক', prompt: 'সুপ্ত তাপ কাকে বলে?', marks: 1),
      CQSubPart(label: 'খ', prompt: 'গলনাঙ্কে চাপের প্রভাব ব্যাখ্যা করো।', marks: 2),
      CQSubPart(label: 'গ', prompt: 'বরফখণ্ডটিকে -১০°C থেকে ০°C এ আনতে কী পরিমাণ তাপের প্রয়োজন তা নির্ণয় করো।', marks: 3),
      CQSubPart(label: 'ঘ', prompt: 'সম্পূর্ণ প্রক্রিয়ায় (বরফ থেকে বাষ্পে পরিণত হওয়া পর্যন্ত) মোট তাপের পরিমাণ নির্ণয় করো এবং প্রতিটি ধাপের তাপের অবদান বিশ্লেষণ করো।', marks: 4),
    ],
  ),
  CreativeQuestion(
    id: 2,
    subject: 'Higher Math',
    chapter: 'Algebra',
    stem: 'একটি দ্বিঘাত সমীকরণ x² - 7x + 12 = 0। এর বীজদ্বয় α ও β।',
    parts: const [
      CQSubPart(label: 'ক', prompt: 'দ্বিঘাত সমীকরণের সাধারণ রূপ লেখো।', marks: 1),
      CQSubPart(label: 'খ', prompt: 'α ও β নির্ণয় করো।', marks: 2),
      CQSubPart(label: 'গ', prompt: 'α² + β² এর মান নির্ণয় করো।', marks: 3),
      CQSubPart(label: 'ঘ', prompt: 'একটি নতুন দ্বিঘাত সমীকরণ গঠন করো যার বীজদ্বয় (α+1) ও (β+1)।', marks: 4),
    ],
  ),
  CreativeQuestion(
    id: 3,
    subject: 'Chemistry',
    chapter: 'Acids and Bases',
    stem: 'পরীক্ষাগারে একটি অজানা দ্রবণের pH পরীক্ষা করে দেখা গেল এর pH মান ৩। একই দিনে আরেকটি দ্রবণের pH মান ১১ পাওয়া গেল।',
    parts: const [
      CQSubPart(label: 'ক', prompt: 'pH স্কেল কী?', marks: 1),
      CQSubPart(label: 'খ', prompt: 'উদ্দীপকের দ্রবণ দুটি অম্লীয় না ক্ষারীয় তা ব্যাখ্যা করো।', marks: 2),
      CQSubPart(label: 'গ', prompt: 'দ্রবণ দুটি মেশালে কী ধরনের বিক্রিয়া ঘটবে তা বিক্রিয়াসহ ব্যাখ্যা করো।', marks: 3),
      CQSubPart(label: 'ঘ', prompt: 'দৈনন্দিন জীবনে এই ধরনের বিক্রিয়ার (প্রশমন বিক্রিয়া) দুটি ব্যবহারিক প্রয়োগ বিশ্লেষণ করো।', marks: 4),
    ],
  ),
  CreativeQuestion(
    id: 4,
    subject: 'English',
    chapter: 'Grammar',
    stem: 'Read the following passage and answer the questions below:\n"Rina is a bright student. She goes to school every day and helps her friends with their studies. Her teachers admire her dedication."',
    parts: const [
      CQSubPart(label: 'ক', prompt: 'What kind of student is Rina?', marks: 1),
      CQSubPart(label: 'খ', prompt: 'Why do her teachers admire her?', marks: 2),
      CQSubPart(label: 'গ', prompt: 'Rewrite the passage changing "Rina" to "Rina and Tania" (plural form) throughout.', marks: 3),
      CQSubPart(label: 'ঘ', prompt: 'Write a short paragraph (5-6 sentences) about a student you admire, using at least three sentences in present simple tense.', marks: 4),
    ],
  ),
];

List<Question> questionsFor(String subjectName) =>
    allQuestions.where((q) => q.subject == subjectName).toList()
      ..sort((a, b) => a.id.compareTo(b.id));

List<CreativeQuestion> cqsFor(String subjectName) =>
    allCQs.where((q) => q.subject == subjectName).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
