enum QuestionSource { ai, board }

class Question {
  final String id;
  final String subjectId;
  final String chapter;
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final QuestionSource source;
  final String? sourceLabel;

  const Question({
    required this.id,
    required this.subjectId,
    required this.chapter,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.source = QuestionSource.ai,
    this.sourceLabel,
  });
}

class CreativeQuestion {
  final String id;
  final String subjectId;
  final String chapter;
  final String stem;
  final String questionK;
  final String questionKh;
  final String questionG;
  final String questionGh;
  final List<int> marks;
  final QuestionSource source;
  final String? sourceLabel;

  const CreativeQuestion({
    required this.id,
    required this.subjectId,
    required this.chapter,
    required this.stem,
    required this.questionK,
    required this.questionKh,
    required this.questionG,
    required this.questionGh,
    this.marks = const [1, 2, 3, 4],
    this.source = QuestionSource.ai,
    this.sourceLabel,
  });
}

const List<Question> allMCQs = [
  Question(id: 'phy_c1_1', subjectId: 'physics', chapter: 'অধ্যায় ১: ভৌত রাশি ও পরিমাপ', questionText: 'দৈর্ঘ্যের মৌলিক একক কোনটি?', options: ['সেন্টিমিটার', 'মিটার', 'কিলোমিটার', 'ইঞ্চি'], correctIndex: 1, explanation: 'SI পদ্ধতিতে দৈর্ঘ্যের মৌলিক একক মিটার (m)।'),
  Question(id: 'phy_c1_2', subjectId: 'physics', chapter: 'অধ্যায় ১: ভৌত রাশি ও পরিমাপ', questionText: 'ভরের মাত্রা কোনটি?', options: ['[M]', '[L]', '[T]', '[MLT]'], correctIndex: 0, explanation: 'ভরের মাত্রা হলো [M]।'),
  Question(id: 'phy_c1_3', subjectId: 'physics', chapter: 'অধ্যায় ১: ভৌত রাশি ও পরিমাপ', questionText: 'নিচের কোনটি ভেক্টর রাশি?', options: ['ভর', 'সময়', 'বেগ', 'তাপমাত্রা'], correctIndex: 2, explanation: 'বেগের মান ও দিক উভয়ই আছে, তাই এটি ভেক্টর রাশি।'),
  Question(id: 'phy_c2_1', subjectId: 'physics', chapter: 'অধ্যায় ২: গতি', questionText: 'সমত্বরণে v = u + at — এখানে a কী নির্দেশ করে?', options: ['বেগ', 'ত্বরণ', 'সরণ', 'সময়'], correctIndex: 1, explanation: 'a হলো ত্বরণ (acceleration)।'),
  Question(id: 'phy_c2_2', subjectId: 'physics', chapter: 'অধ্যায় ২: গতি', questionText: 'ত্বরণ শূন্য হলে বস্তুটি —', options: ['সমবেগে চলছে', 'ত্বরিত হচ্ছে', 'মন্দিত হচ্ছে', 'স্থির আছে'], correctIndex: 0, explanation: 'ত্বরণ শূন্য মানে বেগ অপরিবর্তিত, তাই সমবেগে চলছে।'),
  Question(id: 'phy_c2_3', subjectId: 'physics', chapter: 'অধ্যায় ২: গতি', questionText: 'সরণ-সময় লেখের ঢাল কী নির্দেশ করে?', options: ['ত্বরণ', 'বেগ', 'বল', 'ভরবেগ'], correctIndex: 1, explanation: 'সরণ-সময় লেখের ঢাল বেগ নির্দেশ করে।'),
  Question(id: 'phy_c3_1', subjectId: 'physics', chapter: 'অধ্যায় ৩: বল', questionText: 'নিউটনের দ্বিতীয় সূত্র অনুযায়ী F = ?', options: ['ma', 'mv', 'm/a', 'a/m'], correctIndex: 0, explanation: 'F = ma।'),
  Question(id: 'phy_c3_2', subjectId: 'physics', chapter: 'অধ্যায় ৩: বল', questionText: 'ঘর্ষণ বল কাজ করে —', options: ['গতির অনুকূলে', 'গতির প্রতিকূলে', 'লম্ব দিকে', 'কোনো দিকে নয়'], correctIndex: 1, explanation: 'ঘর্ষণ বল সবসময় গতির প্রতিকূল দিকে কাজ করে।'),
  Question(id: 'phy_c3_3', subjectId: 'physics', chapter: 'অধ্যায় ৩: বল', questionText: 'ভরবেগের একক কোনটি?', options: ['kg·m/s', 'kg·m/s²', 'N·m', 'J'], correctIndex: 0, explanation: 'p = mv, একক kg·m/s।'),
  Question(id: 'hmath_c1_1', subjectId: 'higher_math', chapter: 'অধ্যায় ১: সেট ও ফাংশন', questionText: 'A ∩ B = ∅ হলে A, B কে বলা হয় —', options: ['সমান সেট', 'নিশ্ছেদ সেট', 'উপসেট', 'সার্বিক সেট'], correctIndex: 1, explanation: 'ছেদ ফাঁকা হলে নিশ্ছেদ সেট বলে।'),
  Question(id: 'hmath_c1_2', subjectId: 'higher_math', chapter: 'অধ্যায় ১: সেট ও ফাংশন', questionText: 'f(x) = x² হলে f(3) = ?', options: ['6', '9', '3', '12'], correctIndex: 1, explanation: 'f(3) = 3² = 9।'),
  Question(id: 'hmath_c1_3', subjectId: 'higher_math', chapter: 'অধ্যায় ১: সেট ও ফাংশন', questionText: 'n উপাদানবিশিষ্ট সেটের উপসেট সংখ্যা কত?', options: ['n', 'n²', '2ⁿ', '2n'], correctIndex: 2, explanation: 'উপসেট সংখ্যা 2ⁿ।'),
  Question(id: 'hmath_c2_1', subjectId: 'higher_math', chapter: 'অধ্যায় ২: বীজগাণিতিক রাশি', questionText: 'a³ + b³ = (a+b)(a² - ab + b²) — এটি কোন অভেদ?', options: ['ঘন যোগফলের সূত্র', 'ঘন বিয়োগফলের সূত্র', 'বর্গের সূত্র', 'দ্বিপদী উপপাদ্য'], correctIndex: 0, explanation: 'ঘনের যোগফলের উৎপাদক সূত্র।'),
  Question(id: 'hmath_c2_2', subjectId: 'higher_math', chapter: 'অধ্যায় ২: বীজগাণিতিক রাশি', questionText: 'x² - 5x + 6 এর উৎপাদক কোনটি?', options: ['(x-2)(x-3)', '(x+2)(x+3)', '(x-1)(x-6)', '(x-2)(x+3)'], correctIndex: 0, explanation: 'x²-5x+6 = (x-2)(x-3)।'),
  Question(id: 'hmath_c2_3', subjectId: 'higher_math', chapter: 'অধ্যায় ২: বীজগাণিতিক রাশি', questionText: 'a+b=5, ab=6 হলে a²+b² = ?', options: ['13', '25', '19', '11'], correctIndex: 0, explanation: 'a²+b²=(a+b)²-2ab=25-12=13।'),
];

const List<CreativeQuestion> allCQs = [
  CreativeQuestion(
    id: 'phy_cq_1', subjectId: 'physics', chapter: 'অধ্যায় ২: গতি',
    stem: 'একটি গাড়ি স্থির অবস্থা থেকে যাত্রা শুরু করে ৫ সেকেন্ডে ২০ m/s বেগ অর্জন করে। এরপর ১০ সেকেন্ড সমবেগে চলার পর ৪ সেকেন্ডে থেমে যায়।',
    questionK: 'ত্বরণ কাকে বলে?',
    questionKh: 'গাড়িটির প্রথম পর্যায়ের ত্বরণ নির্ণয় কর।',
    questionG: 'গাড়িটির সমগ্র যাত্রায় মোট অতিক্রান্ত দূরত্ব নির্ণয় কর।',
    questionGh: 'গাড়িটির শেষ পর্যায়ের মন্দন প্রথম পর্যায়ের ত্বরণের চেয়ে বেশি না কম— বিশ্লেষণ কর।',
  ),
  CreativeQuestion(
    id: 'hmath_cq_1', subjectId: 'higher_math', chapter: 'অধ্যায় ২: বীজগাণিতিক রাশি',
    stem: 'a = 4, b = 3 দেওয়া আছে।',
    questionK: 'a³ + b³ এর সূত্র লেখ।',
    questionKh: 'a + b এবং ab এর মান নির্ণয় কর।',
    questionG: 'a³ + b³ এর মান নির্ণয় কর।',
    questionGh: 'প্রমাণ কর যে, (a+b)³ = a³ + b³ + 3ab(a+b)।',
  ),
];
