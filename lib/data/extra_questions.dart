// A-Learning — অতিরিক্ত SSC-মানের (কঠিন/বোর্ড-প্যাটার্ন) প্রশ্ন ব্যাংক
// -------------------------------------------------------------------
// এই ফাইলের সব প্রশ্ন A-Learning-এর জন্য মৌলিকভাবে লেখা — SSC বোর্ড
// প্রশ্নের কাঠামো, দুঃখতা (difficulty) ও মানবণ্টন অনুসরণ করে।
//
// নতুন সুবিধা: প্রশ্নের সাথে চিত্র/সারণি (figure) — সারণি (table),
// ত্রিভুজ চিত্র (triangle), বার-চার্ট (barChart)। প্রিন্ট PDF এবং
// কুইজ স্ক্রিন — দুই জায়গাতেই দেখা যায়।
//
// কীভাবে সংযুক্ত হয়: questions_data.dart-এর allMCQs / allCQs তালিকার
// শুরুতে ...extraMCQs ও ...extraCQs স্প্রেড করা আছে।

import 'questions_data.dart';

/// চিত্রের ধরন
enum FigureKind { table, triangle, barChart }

/// প্রশ্নসহ ছাপার চিত্র/সারণির বর্ণনা
class QuestionFigure {
  final FigureKind kind;

  /// table: কলাম শিরোনাম | triangle: ৩ শীর্ষ [উপরে, বামে-নিচ, ডানে-নিচ]
  /// barChart: বার-এর নিচের লেবেল
  final List<String> headers;

  /// table: তথ্য-সারি (প্রতিটি সারি headers-এর সমান দৈর্ঘ্যের)
  final List<List<String>> rows;

  /// triangle: বাহুর লেবেল [বাম তির্যক, ভূমি, ডান তির্যক]
  final List<String> sides;

  /// triangle: কোণের লেবেল [উপরের শীর্ষ, বাম-নিচ, ডান-নিচ] (খালি '' = নেই)
  final List<String> angles;

  /// barChart: প্রতিটি বারের মান
  final List<int> values;

  /// triangle: কোন শীর্ষে সমকোণ চিহ্ন বসবে (শীর্ষের লেবেল, যেমন 'B')
  final String? rightAngleAt;

  /// চিত্রের নিচে ছোট ক্যাপশন (ঐচ্ছিক)
  final String? caption;

  const QuestionFigure._(
    this.kind, {
    this.headers = const [],
    this.rows = const [],
    this.sides = const [],
    this.angles = const [],
    this.values = const [],
    this.rightAngleAt,
    this.caption,
  });

  /// ছক-তালিকা, যেমন গণসংখ্যা সারণি
  const QuestionFigure.table({
    required List<String> headers,
    required List<List<String>> rows,
    String? caption,
  }) : this._(FigureKind.table, headers: headers, rows: rows, caption: caption);

  /// ত্রিভুজ চিত্র — শীর্ষ [উপরে, বামে-নিচ, ডানে-নিচ]
  const QuestionFigure.triangle({
    required List<String> vertices,
    List<String> sides = const [],
    List<String> angles = const [],
    String? rightAngleAt,
    String? caption,
  }) : this._(
          FigureKind.triangle,
          headers: vertices,
          sides: sides,
          angles: angles,
          rightAngleAt: rightAngleAt,
          caption: caption,
        );

  /// বার-চার্ট (লেভচিত্র)
  const QuestionFigure.barChart({
    required List<String> labels,
    required List<int> values,
    String? caption,
  }) : this._(FigureKind.barChart, headers: labels, values: values, caption: caption);
}

// ══════════════════════════════════════════════════════════════════
//  নতুন কঠিন / বোর্ড-প্যাটার্ন MCQ (সাধারণ গণিত + উচ্চতর গণিত)
// ══════════════════════════════════════════════════════════════════
const List<Question> extraMCQs = [
  // ─── অধ্যায় ১: বাস্তব সংখ্যা ───
  Question(
    id: 'gm_c1_x1',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১: বাস্তব সংখ্যা',
    questionText: '০.২৩২৩২৩... কে সাধারণ ভগ্নাংশে প্রকাশ করলে কোনটি পাওয়া যাবে?',
    options: ['২৩/৯৯', '২৩/১০০', '২৩/৯০', '২৩/৯৪'],
    correctIndex: 0,
    explanation: 'x = 0.232323… হলে 100x = 23.2323… ⇒ 99x = 23 ⇒ x = 23/99। ভগ্নাংশ রেন্ডারারে সাজানো হয়।',
  ),
  Question(
    id: 'gm_c1_x2',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১: বাস্তব সংখ্যা',
    questionText: '(2 + √3)(2 − √3) এর মান কত?',
    options: ['১', '√3', '৫', '৭'],
    correctIndex: 0,
    explanation: '(a + b)(a − b) = a² − b² = 4 − 3 = 1; গুণফল মূলদ সংখ্যা।',
  ),
  Question(
    id: 'gm_c1_x3',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১: বাস্তব সংখ্যা',
    questionText: 'নিচের কোনটি অমূলদ সংখ্যা?',
    options: ['০.১৫', '৭/৩', '√9', '2√5'],
    correctIndex: 3,
    explanation: '0.15 সসীম দশমিক, 7/3 ভগ্নাংশ, √9 = 3 — সবই মূলদ; কিন্তু √5 অমূলদ, তাই 2√5 অমূলদ।',
  ),

  // ─── অধ্যায় ২: সেট ও ফাংশন ───
  Question(
    id: 'gm_c2_x1',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ২: সেট ও ফাংশন',
    questionText: 'A = {x: x স্বাভাবিক সংখ্যা এবং x² < 20}, B = {x: x মৌলিক সংখ্যা এবং x < 10} হলে A ∩ B এর উপাদান সংখ্যা কত?',
    options: ['১টি', '২টি', '৩টি', '৪টি'],
    correctIndex: 1,
    explanation: 'A = {1, 2, 3, 4}, B = {2, 3, 5, 7} ⇒ A ∩ B = {2, 3} — উপাদান ২টি।',
  ),
  Question(
    id: 'gm_c2_x2',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ২: সেট ও ফাংশন',
    questionText: 'f(x) = x² − 3x হলে f(4) − f(2) এর মান কত?',
    options: ['২', '৪', '৬', '৮'],
    correctIndex: 2,
    explanation: 'f(4) = 16 − 12 = 4, f(2) = 4 − 6 = −2 ⇒ f(4) − f(2) = 4 − (−2) = 6।',
  ),
  Question(
    id: 'gm_c2_x3',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ২: সেট ও ফাংশন',
    questionText: 'A = {a, b, c} সেটের সাপেক্ষ উপসেটের (proper subset) সংখ্যা কত?',
    options: ['৬টি', '৭টি', '৮টি', '৯টি'],
    correctIndex: 1,
    explanation: 'n উপাদানের সেটের সাপেক্ষ উপসেট = 2ⁿ − 1 = 2³ − 1 = ৭টি।',
  ),

  // ─── অধ্যায় ৩: বীজগাণিতিক রাশি ───
  Question(
    id: 'gm_c3_x1',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৩: বীজগাণিতিক রাশি',
    questionText: 'x + 1/x = 4 হলে x² + 1/x² এর মান কত?',
    options: ['১২', '১৪', '১৬', '১৮'],
    correctIndex: 1,
    explanation: 'x² + 1/x² = (x + 1/x)² − 2 = 4² − 2 = 14।',
  ),
  Question(
    id: 'gm_c3_x2',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৩: বীজগাণিতিক রাশি',
    questionText: 'x − 1/x = 2 হলে x² + 1/x² এর মান কত?',
    options: ['২', '৪', '৬', '৮'],
    correctIndex: 2,
    explanation: 'x² + 1/x² = (x − 1/x)² + 2 = 2² + 2 = 6।',
  ),
  Question(
    id: 'gm_c3_x3',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৩: বীজগাণিতিক রাশি',
    questionText: 'x + 1/x = 3 হলে x³ + 1/x³ এর মান কত?',
    options: ['৯', '১২', '১৮', '২৭'],
    correctIndex: 2,
    explanation: 'x³ + 1/x³ = (x + 1/x)³ − 3(x + 1/x) = 27 − 9 = 18।',
  ),
  Question(
    id: 'gm_c3_x4',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৩: বীজগাণিতিক রাশি',
    questionText: '(a + b)² − (a − b)² এর মান কোনটি?',
    options: ['2ab', '4ab', 'a² + b²', '০'],
    correctIndex: 1,
    explanation: '(a + b)² − (a − b)² = (a² + 2ab + b²) − (a² − 2ab + b²) = 4ab।',
  ),

  // ─── অধ্যায় ৪: সূচক ও লগারিদম ───
  Question(
    id: 'gm_c4_x1',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৪: সূচক ও লগারিদম',
    questionText: '(√3)⁶ এর মান কত?',
    options: ['৯', '১৮', '২৭', '৮১'],
    correctIndex: 2,
    explanation: '(√3)⁶ = (3¹ᐟ²)⁶ = 3³ = 27।',
  ),
  Question(
    id: 'gm_c4_x2',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৪: সূচক ও লগারিদম',
    questionText: 'log₂ (1/8) এর মান কত?',
    options: ['−৩', '৩', '−২', '১/৩'],
    correctIndex: 0,
    explanation: '1/8 = 2⁻³ ⇒ log₂ (1/8) = −3।',
  ),
  Question(
    id: 'gm_c4_x3',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৪: সূচক ও লগারিদম',
    questionText: '2ˣ⁺¹ = 16 হলে x এর মান কত?',
    options: ['২', '৩', '৪', '৫'],
    correctIndex: 1,
    explanation: '2ˣ⁺¹ = 2⁴ ⇒ x + 1 = 4 ⇒ x = 3।',
  ),

  // ─── অধ্যায় ৫: এক চলকবিশিষ্ট সমীকরণ ───
  Question(
    id: 'gm_c5_x1',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৫: এক চলকবিশিষ্ট সমীকরণ',
    questionText: '3(x − 2) = 2(x + 1) হলে x এর মান কত?',
    options: ['৪', '৬', '৮', '১০'],
    correctIndex: 2,
    explanation: '3x − 6 = 2x + 2 ⇒ x = 8।',
  ),
  Question(
    id: 'gm_c5_x2',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৫: এক চলকবিশিষ্ট সমীকরণ',
    questionText: 'x/2 + x/3 = 5 হলে x এর মান কত?',
    options: ['৪', '৫', '৬', '৮'],
    correctIndex: 2,
    explanation: 'ল.সা.গু 6 দিয়ে গুণ করে: 3x + 2x = 30 ⇒ 5x = 30 ⇒ x = 6।',
  ),
  Question(
    id: 'gm_c5_x3',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৫: এক চলকবিশিষ্ট সমীকরণ',
    questionText: '|x − 3| = 5 হলে x এর সম্ভাব্য বৃহত্তম মান কত?',
    options: ['৮', '৫', '৩', '−২'],
    correctIndex: 0,
    explanation: 'x − 3 = ±5 ⇒ x = 8 অথবা x = −2; বৃহত্তম মান ৮।',
  ),

  // ─── অধ্যায় ৬: রেখা, কোণ ও ত্রিভুজ ───
  Question(
    id: 'gm_c6_x1',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৬: রেখা, কোণ ও ত্রিভুজ',
    questionText: 'একটি সমদ্বিবাহু ত্রিভুজের শীর্ষকোণ ৪০° হলে ভূমির একটি কোণের মান কত?',
    options: ['৪০°', '৬০°', '৭০°', '৮০°'],
    correctIndex: 2,
    explanation: 'ভূমির কোণদ্বয় সমান ⇒ প্রতিটি = (180° − 40°)/2 = 70°।',
  ),
  Question(
    id: 'gm_c6_x2',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৬: রেখা, কোণ ও ত্রিভুজ',
    questionText: 'কোনো কোণ তার পূরক কোণের দ্বিগুণ হলে কোণটির মান কত?',
    options: ['৩০°', '৪৫°', '৬০°', '৭৫°'],
    correctIndex: 2,
    explanation: 'x = 2(90° − x) ⇒ 3x = 180° ⇒ x = 60°।',
  ),
  Question(
    id: 'gm_c6_x3',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৬: রেখা, কোণ ও ত্রিভুজ',
    questionText: 'দুইটি সম্পূরক কোণের অনুপাত ২ঃ৩ হলে ছোট কোণটির মান কত?',
    options: ['৩৬°', '৭২°', '৯০°', '১০৮°'],
    correctIndex: 1,
    explanation: '2x + 3x = 180° ⇒ x = 36° ⇒ ছোট কোণ = 2 × 36° = 72°।',
  ),

  // ─── অধ্যায় ৭: ব্যবহারিক জ্যামিতি ───
  Question(
    id: 'gm_c7_x1',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৭: ব্যবহারিক জ্যামিতি',
    questionText: 'একটি ত্রিভুজ অঙ্কনের জন্য কমপক্ষে কয়টি স্বতন্ত্র উপাত্ত জানা প্রয়োজন?',
    options: ['২টি', '৩টি', '৪টি', '৫টি'],
    correctIndex: 1,
    explanation: 'ত্রিভুজ অঙ্কনে কমপক্ষে তিনটি স্বতন্ত্র উপাত্ত প্রয়োজন (যেমন: তিন বাহু, বা দুই বাহু ও অন্তর্ভুক্ত কোণ)।',
  ),
  Question(
    id: 'gm_c7_x2',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৭: ব্যবহারিক জ্যামিতি',
    questionText: 'সুষম পঞ্চভুজের প্রতিটি অন্তঃস্থ কোণের মান কত?',
    options: ['১০০°', '১০৫°', '১০৮°', '১২০°'],
    correctIndex: 2,
    explanation: 'পঞ্চভুজের অন্তঃস্থ কোণসমষ্টি (5 − 2) × 180° = 540° ⇒ প্রতিটি কোণ = 540°/5 = 108°।',
  ),
  Question(
    id: 'gm_c7_x3',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৭: ব্যবহারিক জ্যামিতি',
    questionText: 'ত্রিভুজের শুধু তিনটি কোণের মান জানা থাকলে নিচের কোনটি আঁকা সম্ভব?',
    options: ['নির্দিষ্ট একটি ত্রিভুজ', 'কোনো ত্রিভুজই নয়', 'অসংখ্য সদৃশ ত্রিভুজ', 'অসংখ্য সর্বসম ত্রিভুজ'],
    correctIndex: 2,
    explanation: 'কোণ তিনটি সমান রেখে বাহুর মান বদলালেই অসংখ্য পারস্পরিক সদৃশ ত্রিভুজ পাওয়া যায়; নির্দিষ্ট আকার ঠিক হয় না।',
  ),

  // ─── অধ্যায় ৮: বৃত্ত ───
  Question(
    id: 'gm_c8_x1',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৮: বৃত্ত',
    questionText: '৫ সেমি ব্যাসার্ধবিশিষ্ট বৃত্তের দীর্ঘতম জ্যা-এর দৈর্ঘ্য কত?',
    options: ['৫ সেমি', '৭.৫ সেমি', '১০ সেমি', '২৫ সেমি'],
    correctIndex: 2,
    explanation: 'বৃত্তের বৃহত্তম জ্যা হলো ব্যাস = 2 × 5 = ১০ সেমি।',
  ),
  Question(
    id: 'gm_c8_x2',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৮: বৃত্ত',
    questionText: 'কোনো চাপের উপর অবস্থিত কেন্দ্রস্থ কোণ ৬০° হলে একই চাপের উপর দণ্ডায়মান পরিধিস্থ কোণ কত?',
    options: ['১৫°', '৩০°', '৬০°', '১২০°'],
    correctIndex: 1,
    explanation: 'একই চাপের পরিধিস্থ কোণ কেন্দ্রস্থ কোণের অর্ধেক = 60°/2 = 30°।',
  ),
  Question(
    id: 'gm_c8_x3',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৮: বৃত্ত',
    questionText: 'অর্ধবৃত্তস্থ কোণের মান কত?',
    options: ['৪৫°', '৬০°', '৯০°', '১৮০°'],
    correctIndex: 2,
    explanation: 'অর্ধবৃত্তস্থ কোণ সর্বদা এক সমকোণ (৯০°)।',
  ),

  // ─── অধ্যায় ৯: ত্রিকোণমিতিক অনুপাত ───
  Question(
    id: 'gm_c9_x1',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৯: ত্রিকোণমিতিক অনুপাত',
    questionText: 'tan 45° + cos 60° এর মান কত?',
    options: ['১', '৩/২', '২', '১/২'],
    correctIndex: 1,
    explanation: 'tan 45° = 1, cos 60° = 1/2 ⇒ যোগফল = 1 + 1/2 = 3/2।',
  ),
  Question(
    id: 'gm_c9_x2',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৯: ত্রিকোণমিতিক অনুপাত',
    questionText: 'sin² 40° + sin² 50° এর মান কত?',
    options: ['০', '১', '২', '√3/2'],
    correctIndex: 1,
    explanation: 'sin 50° = cos 40° ⇒ sin² 40° + cos² 40° = 1।',
  ),
  Question(
    id: 'gm_c9_x3',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৯: ত্রিকোণমিতিক অনুপাত',
    questionText: 'cosec 30° এর মান কত?',
    options: ['১/২', '১', '২', '√3'],
    correctIndex: 2,
    explanation: 'cosec 30° = 1/sin 30° = 1/(1/2) = 2।',
  ),
  Question(
    id: 'gm_c9_x4',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৯: ত্রিকোণমিতিক অনুপাত',
    questionText: '3 tan A = √3 হলে A এর মান কত?',
    options: ['৩০°', '৪৫°', '৬০°', '৯০°'],
    correctIndex: 0,
    explanation: 'tan A = √3/3 = 1/√3 ⇒ A = 30°।',
  ),

  // ─── অধ্যায় ১০: দূরত্ব ও উচ্চতা ───
  Question(
    id: 'gm_c10_x1',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১০: দূরত্ব ও উচ্চতা',
    questionText: 'নিচের চিত্রে ভূতলের A বিন্দু থেকে মিনারের শীর্ষ C এর উন্নতি কোণ ৪৫°; AB = ২০ মিটার হলে মিনারের উচ্চতা কত?',
    options: ['১০ মিটার', '২০ মিটার', '২০√3 মিটার', '৪০ মিটার'],
    correctIndex: 1,
    explanation: 'tan 45° = BC/AB ⇒ 1 = BC/20 ⇒ BC = ২০ মিটার।',
    figure: QuestionFigure.triangle(
      vertices: ['C', 'A', 'B'],
      sides: ['', '২০ মিটার', 'উচ্চতা = ?'],
      angles: ['', '৪৫°', ''],
      rightAngleAt: 'B',
    ),
  ),
  Question(
    id: 'gm_c10_x2',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১০: দূরত্ব ও উচ্চতা',
    questionText: 'ভূতলের একটি বিন্দু থেকে কোনো টাওয়ারের শীর্ষের উন্নতি কোণ ৬০°; বিন্দুটি গোড়া থেকে ৩০ মিটার দূরে হলে টাওয়ারের উচ্চতা কত?',
    options: ['৩০ মিটার', '৩০√3 মিটার', '১০√3 মিটার', '৬০ মিটার'],
    correctIndex: 1,
    explanation: 'উচ্চতা = 30 × tan 60° = 30√3 মিটার।',
  ),
  Question(
    id: 'gm_c10_x3',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১০: দূরত্ব ও উচ্চতা',
    questionText: 'সূর্যের উন্নতি কোণ ৪৫° হলে একটি খুঁটির উচ্চতা ও ছায়ার দৈর্ঘ্যের অনুপাত কত?',
    options: ['১ঃ১', '১ঃ২', '২ঃ১', '১ঃ√3'],
    correctIndex: 0,
    explanation: 'tan 45° = 1 ⇒ উচ্চতা = ছায়ার দৈর্ঘ্য ⇒ অনুপাত ১ঃ১।',
  ),

  // ─── অধ্যায় ১১: বীজগাণিতিক অনুপাত ও সমানুপাত ───
  Question(
    id: 'gm_c11_x1',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১১: বীজগাণিতিক অনুপাত ও সমানুপাত',
    questionText: 'a : b = 2 : 3 এবং b : c = 4 : 5 হলে a : c কত?',
    options: ['২ঃ৫', '৩ঃ৫', '৮ঃ৫', '৮ঃ১৫'],
    correctIndex: 3,
    explanation: 'a/c = (a/b) × (b/c) = (2/3) × (4/5) = 8/15 ⇒ a : c = 8 : 15।',
  ),
  Question(
    id: 'gm_c11_x2',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১১: বীজগাণিতিক অনুপাত ও সমানুপাত',
    questionText: 'দুইটি সংখ্যার অনুপাত ৩ঃ৪ এবং তাদের যোগফল ৩৫ হলে ছোট সংখ্যাটি কত?',
    options: ['১২', '১৫', '২০', '২১'],
    correctIndex: 1,
    explanation: 'অংশদ্বয় 3k, 4k ⇒ 7k = 35 ⇒ k = 5 ⇒ ছোট সংখ্যা = 3k = ১৫।',
  ),
  Question(
    id: 'gm_c11_x3',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১১: বীজগাণিতিক অনুপাত ও সমানুপাত',
    questionText: 'x, 4, 8 ক্রমিক সমানুপাতী হলে x এর মান কত?',
    options: ['১', '২', '৩', '৬'],
    correctIndex: 1,
    explanation: 'x/4 = 4/8 ⇒ 8x = 16 ⇒ x = 2।',
  ),

  // ─── অধ্যায় ১২: দুই চলকবিশিষ্ট সরল সহসমীকরণ ───
  Question(
    id: 'gm_c12_x1',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১২: দুই চলকবিশিষ্ট সরল সহসমীকরণ',
    questionText: 'x + y = 7 এবং x − y = 3 হলে x এর মান কত?',
    options: ['২', '৪', '৫', '৬'],
    correctIndex: 2,
    explanation: 'সমীকরণদ্বয় যোগ করে: 2x = 10 ⇒ x = ৫ (এবং y = 2)।',
  ),
  Question(
    id: 'gm_c12_x2',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১২: দুই চলকবিশিষ্ট সরল সহসমীকরণ',
    questionText: '2x + 3y = 12 এবং x + y = 5 হলে y এর মান কত?',
    options: ['১', '২', '৩', '৪'],
    correctIndex: 1,
    explanation: 'x = 5 − y বসিয়ে: 2(5 − y) + 3y = 12 ⇒ 10 + y = 12 ⇒ y = ২।',
  ),
  Question(
    id: 'gm_c12_x3',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১২: দুই চলকবিশিষ্ট সরল সহসমীকরণ',
    questionText: 'সরল সহসমীকরণ জোটের লেখচিত্রদ্বয় পরস্পর সমান্তরাল হলে সমাধান কয়টি?',
    options: ['একটি', 'দুইটি', 'অসংখ্য', 'কোনোটিই নয়'],
    correctIndex: 3,
    explanation: 'সমান্তরাল রেখাদ্বয় পরস্পরকে ছেদ করে না, তাই সাধারণ বিন্দু অর্থাৎ সমাধান নেই।',
  ),

  // ─── অধ্যায় ১৩: সসীম ধারা ───
  Question(
    id: 'gm_c13_x1',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১৩: সসীম ধারা',
    questionText: '2, 5, 8, 11, ... ধারাটির ১২তম পদ কত?',
    options: ['৩২', '৩৩', '৩৫', '৩৮'],
    correctIndex: 2,
    explanation: 'সাধারণ অন্তর 3 ⇒ ১২তম পদ = 2 + (12 − 1) × 3 = 2 + 33 = ৩৫।',
  ),
  Question(
    id: 'gm_c13_x2',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১৩: সসীম ধারা',
    questionText: '3, 6, 12, 24, ... ধারাটির ৬ষ্ঠ পদ কত?',
    options: ['৪৮', '৭২', '৯৬', '১৯২'],
    correctIndex: 2,
    explanation: 'গুণোত্তর ধারার সাধারণ অনুপাত 2 ⇒ ৬ষ্ঠ পদ = 3 × 2⁵ = ৩ × 32 = ৯৬।',
  ),
  Question(
    id: 'gm_c13_x3',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১৩: সসীম ধারা',
    questionText: '1 + 2 + 3 + ... + 20 ধারাটির সমষ্টি কত?',
    options: ['১৯০', '২০০', '২১০', '২২০'],
    correctIndex: 2,
    explanation: 'সমষ্টি = n(n + 1)/2 = 20 × 21/2 = ২১০।',
  ),

  // ─── অধ্যায় ১৪: অনুপাত, সদৃশতা ও প্রতিসমতা ───
  Question(
    id: 'gm_c14_x1',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১৪: অনুপাত, সদৃশতা ও প্রতিসমতা',
    questionText: 'দুইটি সদৃশ ত্রিভুজের অনুরূপ বাহুগুলোর অনুপাত ২ঃ৩ হলে তাদের ক্ষেত্রফলের অনুপাত কত?',
    options: ['২ঃ৩', '৩ঃ২', '৪ঃ৯', '৮ঃ২৭'],
    correctIndex: 2,
    explanation: 'সদৃশ ক্ষেত্রদ্বয়ের ক্ষেত্রফলের অনুপাত অনুরূপ বাহুর অনুপাতের বর্গের সমান = 2² : 3² = ৪ঃ৯।',
  ),
  Question(
    id: 'gm_c14_x2',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১৪: অনুপাত, সদৃশতা ও প্রতিসমতা',
    questionText: 'ΔABC এর AB ও AC বাহুর উপর D ও E বিন্দুতে DE ∥ BC; AD = ৩ সেমি, DB = ৬ সেমি হলে AE : EC = কত?',
    options: ['১ঃ২', '২ঃ১', '১ঃ৩', '৩ঃ১'],
    correctIndex: 0,
    explanation: 'থেলসের উপপাদ্য অনুযায়ী AD/DB = AE/EC = 3/6 = 1/2 ⇒ AE : EC = ১ঃ২।',
  ),
  Question(
    id: 'gm_c14_x3',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১৪: অনুপাত, সদৃশতা ও প্রতিসমতা',
    questionText: 'যে চতুর্ভুজের চারটি বাহু সমান এবং একটি কোণ সমকোণ, সেটি হলো —',
    options: ['রম্বস', 'আয়তক্ষেত্র', 'বর্গক্ষেত্র', 'সামান্তরিক'],
    correctIndex: 2,
    explanation: 'সব বাহু সমান হলে রম্বস; একটি কোণ 90° হলে সেটি বর্গক্ষেত্র।',
  ),

  // ─── অধ্যায় ১৫: ক্ষেত্রফল সম্পর্কিত উপপাদ্য ও সম্পাদ্য ───
  Question(
    id: 'gm_c15_x1',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১৫: ক্ষেত্রফল সম্পর্কিত উপপাদ্য ও সম্পাদ্য',
    questionText: 'একই ভূমির উপর এবং একই সমান্তরাল রেখাযুগলের মধ্যে অবস্থিত ত্রিভুজক্ষেত্র ও সামান্তরিকক্ষেত্রের ক্ষেত্রফলের অনুপাত কত?',
    options: ['১ঃ১', '১ঃ২', '২ঃ১', '১ঃ৩'],
    correctIndex: 1,
    explanation: 'এরূপ ত্রিভুজক্ষেত্রের ক্ষেত্রফল সামান্তরিকক্ষেত্রের ক্ষেত্রফলের অর্ধেক ⇒ ১ঃ২।',
  ),
  Question(
    id: 'gm_c15_x2',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১৫: ক্ষেত্রফল সম্পর্কিত উপপাদ্য ও সম্পাদ্য',
    questionText: 'ত্রিভুজের যেকোনো মধ্যমা ত্রিভুজক্ষেত্রকে ক্ষেত্রফলে কীভাবে ভাগ করে?',
    options: ['দুই সমান ভাগে', 'তিন সমান ভাগে', 'চার সমান ভাগে', 'দুই অসমান ভাগে'],
    correctIndex: 0,
    explanation: 'মধ্যমা ত্রিভুজক্ষেত্রকে সমান ক্ষেত্রফলবিশিষ্ট দুইটি ত্রিভুজক্ষেত্রে বিভক্ত করে।',
  ),
  Question(
    id: 'gm_c15_x3',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১৫: ক্ষেত্রফল সম্পর্কিত উপপাদ্য ও সম্পাদ্য',
    questionText: 'ত্রিভুজের তিনটি মধ্যমা ত্রিভুজক্ষেত্রকে কয়টি সমান ক্ষেত্রফলবিশিষ্ট ত্রিভুজে ভাগ করে?',
    options: ['৩টি', '৪টি', '৬টি', '৮টি'],
    correctIndex: 2,
    explanation: 'তিন মধ্যমা মূল ত্রিভুজক্ষেত্রকে সমান ক্ষেত্রফলের ছয়টি ছোট ত্রিভুজে ভাগ করে।',
  ),

  // ─── অধ্যায় ১৬: পরিমিতি ───
  Question(
    id: 'gm_c16_x1',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১৬: পরিমিতি',
    questionText: 'একটি বর্গক্ষেত্রের কর্ণের দৈর্ঘ্য 4√2 সেমি হলে এর বাহুর দৈর্ঘ্য কত?',
    options: ['২ সেমি', '৪ সেমি', '৮ সেমি', '১৬ সেমি'],
    correctIndex: 1,
    explanation: 'কর্ণ = বাহু × √2 ⇒ বাহু = 4√2/√2 = ৪ সেমি।',
  ),
  Question(
    id: 'gm_c16_x2',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১৬: পরিমিতি',
    questionText: '৭ সেমি ব্যাসার্ধবিশিষ্ট বৃত্তের ক্ষেত্রফল কত? [π = 22/7]',
    options: ['৪৪ বর্গ সেমি', '৮৮ বর্গ সেমি', '১৫৪ বর্গ সেমি', '৬১৬ বর্গ সেমি'],
    correctIndex: 2,
    explanation: 'ক্ষেত্রফল = πr² = (22/7) × 7 × 7 = ১৫৪ বর্গ সেমি।',
  ),
  Question(
    id: 'gm_c16_x3',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১৬: পরিমিতি',
    questionText: 'একটি আয়তক্ষেত্রের দৈর্ঘ্য ৮ সেমি ও প্রস্থ ৬ সেমি হলে কর্ণের দৈর্ঘ্য কত?',
    options: ['১০ সেমি', '১২ সেমি', '১৪ সেমি', '৪৮ সেমি'],
    correctIndex: 0,
    explanation: 'কর্ণ = √(8² + 6²) = √(64 + 36) = √100 = ১০ সেমি।',
  ),

  // ─── অধ্যায় ১৭: পরিসংখ্যান ───
  Question(
    id: 'gm_c17_x1',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১৭: পরিসংখ্যান',
    questionText: 'নিচের গণসংখ্যা সারণি দেখো — প্রচুরক শ্রেণি কোনটি?',
    options: ['১০–২০', '২০–৩০', '৩০–৪০', '৪০–৫০'],
    correctIndex: 2,
    explanation: 'গণসংখ্যা সর্বোচ্চ (৮) যে শ্রেণিতে, সেটিই প্রচুরক শ্রেণি ⇒ ৩০–৪০।',
    figure: QuestionFigure.table(
      headers: ['শ্রেণি', '১০–২০', '২০–৩০', '৩০–৪০', '৪০–৫০'],
      rows: [
        ['গণসংখ্যা', '৩', '৫', '৮', '৪'],
      ],
    ),
  ),
  Question(
    id: 'gm_c17_x2',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১৭: পরিসংখ্যান',
    questionText: 'প্রথম দশটি স্বাভাবিক সংখ্যার গড় কত?',
    options: ['৫', '৫.৫', '৬', '৫৫'],
    correctIndex: 1,
    explanation: 'গড় = (55)/10 = 5.5 (যোগফল 1+2+...+10 = 55)।',
  ),
  Question(
    id: 'gm_c17_x3',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১৭: পরিসংখ্যান',
    questionText: '৪, ৮, ৬, ১০, ২ উপাত্তগুলোর মধ্যক কত?',
    options: ['৪', '৬', '৮', '১০'],
    correctIndex: 1,
    explanation: 'মানের ক্রমে সাজালে: ২, ৪, ৬, ৮, ১০ ⇒ মধ্যপদ ৬ ই মধ্যক।',
  ),

  // ─── উচ্চতর গণিত ───
  Question(
    id: 'hmath_c1_x1',
    subjectId: 'higher_math',
    chapter: 'অধ্যায় ১: সেট ও ফাংশন',
    questionText: 'f(x) = 1/x ফাংশনটির ডোমেইন কোনটি?',
    options: ['সকল বাস্তব সংখ্যা', 'শূন্য ছাড়া সকল বাস্তব সংখ্যা', 'শুধু ধনাত্মক সংখ্যা', 'শুধু স্বাভাবিক সংখ্যা'],
    correctIndex: 1,
    explanation: 'x = 0 হলে 1/x অসংজ্ঞায়িত; তাই ডোমেইন = ℝ − {0}।',
  ),
  Question(
    id: 'hmath_c1_x2',
    subjectId: 'higher_math',
    chapter: 'অধ্যায় ১: সেট ও ফাংশন',
    questionText: 'A = {1, 2, 3} এবং B = {a, b} হলে A × B এর উপাদান সংখ্যা কত?',
    options: ['৩টি', '৫টি', '৬টি', '৯টি'],
    correctIndex: 2,
    explanation: 'n(A × B) = n(A) × n(B) = 3 × 2 = ৬টি।',
  ),
  Question(
    id: 'hmath_c1_x3',
    subjectId: 'higher_math',
    chapter: 'অধ্যায় ১: সেট ও ফাংশন',
    questionText: 'f(x) = 3x − 2 হলে f⁻¹(7) এর মান কত?',
    options: ['২', '৩', '৭', '১৯'],
    correctIndex: 1,
    explanation: 'f⁻¹(7) = x যেখানে 3x − 2 = 7 ⇒ x = 3।',
  ),
  Question(
    id: 'hmath_c2_x1',
    subjectId: 'higher_math',
    chapter: 'অধ্যায় ২: বীজগাণিতিক রাশি',
    questionText: 'x² − 7x + 12 রাশিটির উৎপাদক কোনটি?',
    options: ['(x − 3)(x − 4)', '(x + 3)(x − 4)', '(x − 2)(x − 6)', '(x + 2)(x + 6)'],
    correctIndex: 0,
    explanation: 'যুগল −3 ও −4 এর যোগফল −7 ও গুণফল 12 ⇒ উৎপাদক (x − 3)(x − 4)।',
  ),
  Question(
    id: 'hmath_c2_x2',
    subjectId: 'higher_math',
    chapter: 'অধ্যায় ২: বীজগাণিতিক রাশি',
    questionText: 'a − b = 3 এবং ab = 10 হলে a² + b² এর মান কত?',
    options: ['১৯', '২৩', '২৯', '৩৯'],
    correctIndex: 2,
    explanation: 'a² + b² = (a − b)² + 2ab = 9 + 20 = 29।',
  ),
  Question(
    id: 'hmath_c2_x3',
    subjectId: 'higher_math',
    chapter: 'অধ্যায় ২: বীজগাণিতিক রাশি',
    questionText: 'x³ + 3x²y + 3xy² + y³ এর সংক্ষিপ্ত রূপ কোনটি?',
    options: ['(x − y)³', '(x + y)³', 'x³ + y³', '(x + y)²'],
    correctIndex: 1,
    explanation: 'এটি (a + b)³ = a³ + 3a²b + 3ab² + b³ সূত্রের বিস্তৃতি ⇒ (x + y)³।',
  ),
];

// ══════════════════════════════════════════════════════════════════
//  নতুন কঠিন / বোর্ড-প্যাটার্ন সৃজনশীল প্রশ্ন (উদ্দীপকসহ)
// ══════════════════════════════════════════════════════════════════
const List<CreativeQuestion> extraCQs = [
  CreativeQuestion(
    id: 'gm_c3_cq6',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৩: বীজগাণিতিক রাশি',
    stem: 'x + 1/x = 4 একটি বীজগাণিতিক সম্পর্ক।',
    questionK: '(a + b)³ এর বিস্তৃতি সূত্রটি লেখো।',
    questionKh: 'উদ্দীপকের সাহায্যে x² + 1/x² এর মান নির্ণয় করো।',
    questionG: 'x³ + 1/x³ এর মান নির্ণয় করো।',
    questionGh: 'x⁴ + 1/x⁴ এর মান নির্ণয় করে x² + 1/x² এর সাথে তুলনা করো।',
    sourceLabel: 'A-Learning Original',
  ),
  CreativeQuestion(
    id: 'gm_c9_cq6',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৯: ত্রিকোণমিতিক অনুপাত',
    stem: 'tan θ = 4/3, যেখানে θ একটি সূক্ষ্মকোণ।',
    questionK: 'ত্রিকোণমিতিক অনুপাত বলতে কী বোঝায়?',
    questionKh: 'উদ্দীপকের শর্ত ব্যবহার করে sin θ ও cos θ এর মান নির্ণয় করো।',
    questionG: '(2 sin θ + cos θ)/(2 sin θ − cos θ) এর মান নির্ণয় করো।',
    questionGh: 'দেখাও যে, sec θ + tan θ = 3 এবং এর সাহায্যে sec θ − tan θ এর মান বের করো।',
    sourceLabel: 'A-Learning Original',
  ),
  CreativeQuestion(
    id: 'gm_c10_cq6',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১০: দূরত্ব ও উচ্চতা',
    stem: 'ভূতলের P বিন্দু থেকে ৬০ মিটার উঁচু QT টাওয়ারের শীর্ষ T এর উন্নতি কোণ ৩০°।',
    questionK: 'উন্নতি কোণ কাকে বলে?',
    questionKh: 'P বিন্দু থেকে টাওয়ারের গোড়া Q এর দূরত্ব নির্ণয় করো।',
    questionG: 'পর্যবেক্ষকের অবস্থান P থেকে টাওয়ারের শীর্ষের উন্নতি কোণ ৪৫° হতে হলে টাওয়ারের উচ্চতা কত হতে হবে — নির্ণয় করো।',
    questionGh: 'উচ্চতা অপরিবর্তিত রেখে উন্নতি কোণ ৬০° করতে হলে পর্যবেক্ষককে গোড়া থেকে কত দূরে দাঁড়াতে হবে তা নির্ণয় করে খ) এর ফলের সাথে তুলনা করো।',
    sourceLabel: 'A-Learning Original',
    figure: QuestionFigure.triangle(
      vertices: ['T', 'P', 'Q'],
      sides: ['', 'x মিটার', '৬০ মিটার'],
      angles: ['', '৩০°', ''],
      rightAngleAt: 'Q',
    ),
  ),
  CreativeQuestion(
    id: 'gm_c16_cq6',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১৬: পরিমিতি',
    stem: 'একটি আয়তাকার বাগানের দৈর্ঘ্য ৪০ মিটার ও প্রস্থ ৩০ মিটার। বাগানের ভেতরের চারপাশে ৩ মিটার চওড়া একটি পথ আছে।',
    questionK: 'আয়তক্ষেত্রের ক্ষেত্রফলের সূত্রটি লেখো।',
    questionKh: 'পথসহ বাগানের বাইরের দৈর্ঘ্য ও প্রস্থ নির্ণয় করো।',
    questionG: 'পথটির ক্ষেত্রফল নির্ণয় করো।',
    questionGh: 'পথটিতে প্রতি বর্গ মিটারে ২৫০ টাকা হারে ইট লাগাতে মোট কত খরচ হবে তা নির্ণয় করো।',
    sourceLabel: 'A-Learning Original',
  ),
  CreativeQuestion(
    id: 'gm_c17_cq6',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১৭: পরিসংখ্যান',
    stem: 'একটি বিদ্যালয়ের ৫০ জন শিক্ষার্থীর গণিতে প্রাপ্ত নম্বরের গণসংখ্যা সারণি নিচে দেওয়া হলো —',
    questionK: 'গণসংখ্যা সারণি কাকে বলে?',
    questionKh: 'প্রতিটি শ্রেণির মধ্যমান নির্ণয় করো।',
    questionG: 'মধ্যমানের সাহায্যে শিক্ষার্থীদের প্রাপ্ত নম্বরের গড় নির্ণয় করো।',
    questionGh: 'ক্রমযোজিত গণসংখ্যা ব্যবহার করে মধ্যক শ্রেণি ও প্রচুরক শ্রেণি চিহ্নিত করে উপাত্তের প্রকৃতি বিশ্লেষণ করো।',
    sourceLabel: 'A-Learning Original',
    figure: QuestionFigure.table(
      headers: ['নম্বর', '১০–১৯', '২০–২৯', '৩০–৩৯', '৪০–৪৯', '৫০–৫৯', '৬০–৬৯', '৭০–৭৯'],
      rows: [
        ['গণসংখ্যা', '৪', '৫', '৯', '১২', '১০', '৬', '৪'],
      ],
      caption: 'গণসংখ্যা সারণি',
    ),
  ),
  CreativeQuestion(
    id: 'gm_c5_cq6',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৫: এক চলকবিশিষ্ট সমীকরণ',
    stem: 'দুই অঙ্কবিশিষ্ট একটি সংখ্যার অঙ্কদ্বয়ের সমষ্টি ৯; অঙ্কদ্বয় স্থান বদলালে সংখ্যাটি ২৭ বেড়ে যায়।',
    questionK: 'স্থানীয় মান বলতে কী বোঝায়?',
    questionKh: 'দশক স্থানের অঙ্ক x ও একক স্থানের অঙ্ক y ধরে শর্তমতে সমীকরণ জোট গঠন করো।',
    questionG: 'সংখ্যাটি নির্ণয় করো।',
    questionGh: 'স্থান বদলানো নতুন সংখ্যাটি নির্ণয় করে উদ্দীপকের উভয় শর্ত পূরণ হয় কি না যাচাই করো।',
    sourceLabel: 'A-Learning Original',
  ),
  CreativeQuestion(
    id: 'gm_c4_cq6',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৪: সূচক ও লগারিদম',
    stem: '8ˣ = 32 একটি সূচকীয় সমীকরণ।',
    questionK: 'সূচকীয় রাশি কাকে বলে?',
    questionKh: 'x এর মান নির্ণয় করো।',
    questionG: 'দেখাও যে, 2^(6x − 5) = 32।',
    questionGh: 'প্রমাণ করো যে, 4^(3x) = 2¹⁰ এবং উদ্দীপকের সাথে সম্পর্ক ব্যাখ্যা করো।',
    sourceLabel: 'A-Learning Original',
  ),
  CreativeQuestion(
    id: 'gm_c2_cq6',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ২: সেট ও ফাংশন',
    stem: 'একটি শ্রেণির ৫০ জন শিক্ষার্থীর মধ্যে ৩০ জন ক্রিকেট, ২৫ জন ফুটবল এবং ১০ জন উভয় খেলা পছন্দ করে।',
    questionK: 'সেট কাকে বলে?',
    questionKh: 'অন্তত একটি খেলা পছন্দকারী শিক্ষার্থীর সংখ্যা নির্ণয় করো।',
    questionG: 'কোনো খেলাই পছন্দ করে না এমন শিক্ষার্থীর সংখ্যা নির্ণয় করে ভেনচিত্রে দেখাও।',
    questionGh: 'শুধু ক্রিকেট পছন্দকারী শিক্ষার্থী মোট শিক্ষার্থীর শতকরা কত ভাগ — নির্ণয় করে ফলাফল মন্তব্য করো।',
    sourceLabel: 'A-Learning Original',
  ),
  CreativeQuestion(
    id: 'gm_c6_cq6',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৬: রেখা, কোণ ও ত্রিভুজ',
    stem: 'ΔABC এর ∠A = ৬০° এবং ∠B = ৭০°; BC বাহুকে D পর্যন্ত বর্ধিত করা হয়েছে।',
    questionK: 'ত্রিভুজের তিনটি অন্তঃস্থ কোণের সমষ্টি কত?',
    questionKh: '∠C এর মান নির্ণয় করো।',
    questionG: 'প্রমাণ করো যে, ত্রিভুজের যেকোনো বহিঃকোণ বিপরীত অন্তঃস্থ কোণদ্বয়ের সমষ্টির সমান।',
    questionGh: '∠ACD এর মান নির্ণয় করে গ) নম্বরের প্রমাণ যাচাই করো।',
    sourceLabel: 'A-Learning Original',
    figure: QuestionFigure.triangle(
      vertices: ['A', 'B', 'C'],
      sides: ['', '', ''],
      angles: ['৬০°', '৭০°', ''],
    ),
  ),
  CreativeQuestion(
    id: 'gm_c8_cq6',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৮: বৃত্ত',
    stem: 'O কেন্দ্রবিশিষ্ট বৃত্তের AB একটি জ্যা এবং কেন্দ্র O থেকে AB এর উপর অঙ্কিত OC লম্ব; বৃত্তের ব্যাসার্ধ ১০ সেমি এবং AB = ১৬ সেমি।',
    questionK: 'বৃত্তের জ্যা বলতে কী বোঝায়?',
    questionKh: 'বৃত্তের কেন্দ্র থেকে AB জ্যা-এর দূরত্ব OC নির্ণয় করো।',
    questionG: 'প্রমাণ করো যে, বৃত্তের কেন্দ্র থেকে কোনো জ্যা-এর উপর অঙ্কিত লম্ব ঐ জ্যা-কে সমদ্বিখণ্ডিত করে।',
    questionGh: 'একই বৃত্তে AB এর সমান আরেকটি জ্যা AD হলে AD এর কেন্দ্র থেকে দূরত্ব নির্ণয় করে "সমান জ্যা কেন্দ্র থেকে সমদূরবর্তী" — উক্তিটি যাচাই করো।',
    sourceLabel: 'A-Learning Original',
  ),
  CreativeQuestion(
    id: 'gm_c11_cq6',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১১: বীজগাণিতিক অনুপাত ও সমানুপাত',
    stem: 'দুইটি সংখ্যার অনুপাত ৫ঃ৭; সংখ্যা দুটির প্রতিটির সাথে ৮ যোগ করলে অনুপাতটি হয় ৩ঃ৪।',
    questionK: 'ক্রমিক সমানুপাত কাকে বলে?',
    questionKh: 'সংখ্যা দুটিকে 5x ও 7x ধরে শর্ত অনুযায়ী সমীকরণ গঠন করো।',
    questionG: 'সংখ্যা দুটি নির্ণয় করো।',
    questionGh: 'সংখ্যা দুটির গ.সা.গু ও ল.সা.গু নির্ণয় করে "দুই সংখ্যার গুণফল = গ.সা.গু × ল.সা.গু" সম্পর্কটি যাচাই করো।',
    sourceLabel: 'A-Learning Original',
  ),
  CreativeQuestion(
    id: 'gm_c14_cq6',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১৪: অনুপাত, সদৃশতা ও প্রতিসমতা',
    stem: 'ΔABC ও ΔDEF সদৃশ; AB = ৬ সেমি, BC = ৮ সেমি, CA = ১০ সেমি এবং AB এর অনুরূপ বাহু DE = ৯ সেমি।',
    questionK: 'সদৃশকোণী ত্রিভুজ কাকে বলে?',
    questionKh: 'EF ও DF এর দৈর্ঘ্য নির্ণয় করো।',
    questionG: 'ত্রিভুজ দুটির পরিসীমা নির্ণয় করে পরিসীমার অনুপাত সাধৃতার অনুপাতের সমান কি না দেখাও।',
    questionGh: 'ত্রিভুজ দুটির ক্ষেত্রফল নির্ণয় করে ক্ষেত্রফলের অনুপাত বাহুর অনুপাতের বর্গের সমান কি না যাচাই করো।',
    sourceLabel: 'A-Learning Original',
  ),
  CreativeQuestion(
    id: 'hmath_cq2',
    subjectId: 'higher_math',
    chapter: 'অধ্যায় ২: বীজগাণিতিক রাশি',
    stem: 'f(x) = x³ − 3x² + 4 একটি বহুপদ রাশি।',
    questionK: 'বহুপদ কাকে বলে?',
    questionKh: 'উৎপাদক উপপাদ্য ব্যবহার করে দেখাও যে, (x − 2) রাশিটির একটি উৎপাদক।',
    questionG: 'রাশিটিকে পূর্ণ উৎপাদকে বিশ্লেষণ করো।',
    questionGh: 'f(x) = 0 সমীকরণের সমাধান সেট নির্ণয় করে মূলগুলোর প্রকৃতি ব্যাখ্যা করো।',
    sourceLabel: 'A-Learning Original',
  ),
  CreativeQuestion(
    id: 'hmath_cq3',
    subjectId: 'higher_math',
    chapter: 'অধ্যায় ১: সেট ও ফাংশন',
    stem: 'f(x) = 2x + 5 একটি ফাংশন।',
    questionK: 'ফাংশন কাকে বলে?',
    questionKh: 'f(0) ও f(−2) এর মান নির্ণয় করো।',
    questionG: 'f(a) = 11 হলে a এর মান নির্ণয় করো।',
    questionGh: 'y = f(x) লেখচিত্রের y-অক্ষের খন্ডিতাংশ ও x-অক্ষের খন্ডিতাংশ নির্ণয় করে রেখাটির অবস্থান মন্তব্য করো।',
    sourceLabel: 'A-Learning Original',
  ),
];
