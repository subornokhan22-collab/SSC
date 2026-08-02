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
  // --- AI-generated template questions (Physics) ---
  Question(id: 'phy_c1_1', subjectId: 'physics', chapter: 'অধ্যায় ১: ভৌত রাশি ও পরিমাপ', questionText: 'দৈর্ঘ্যের মৌলিক একক কোনটি?', options: ['সেন্টিমিটার', 'মিটার', 'কিলোমিটার', 'ইঞ্চি'], correctIndex: 1, explanation: 'SI পদ্ধতিতে দৈর্ঘ্যের মৌলিক একক মিটার (m)।'),
  Question(id: 'phy_c1_2', subjectId: 'physics', chapter: 'অধ্যায় ১: ভৌত রাশি ও পরিমাপ', questionText: 'ভরের মাত্রা কোনটি?', options: ['[M]', '[L]', '[T]', '[MLT]'], correctIndex: 0, explanation: 'ভরের মাত্রা হলো [M]।'),
  Question(id: 'phy_c1_3', subjectId: 'physics', chapter: 'অধ্যায় ১: ভৌত রাশি ও পরিমাপ', questionText: 'নিচের কোনটি ভেক্টর রাশি?', options: ['ভর', 'সময়', 'বেগ', 'তাপমাত্রা'], correctIndex: 2, explanation: 'বেগের মান ও দিক উভয়ই আছে, তাই এটি ভেক্টর রাশি।'),
  Question(id: 'phy_c2_1', subjectId: 'physics', chapter: 'অধ্যায় ২: গতি', questionText: 'সমত্বরণে v = u + at — এখানে a কী নির্দেশ করে?', options: ['বেগ', 'ত্বরণ', 'সরণ', 'সময়'], correctIndex: 1, explanation: 'a হলো ত্বরণ (acceleration)।'),
  Question(id: 'phy_c2_2', subjectId: 'physics', chapter: 'অধ্যায় ২: গতি', questionText: 'ত্বরণ শূন্য হলে বস্তুটি —', options: ['সমবেগে চলছে', 'ত্বরিত হচ্ছে', 'মন্দিত হচ্ছে', 'স্থির আছে'], correctIndex: 0, explanation: 'ত্বরণ শূন্য মানে বেগ অপরিবর্তিত, তাই সমবেগে চলছে।'),
  Question(id: 'phy_c2_3', subjectId: 'physics', chapter: 'অধ্যায় ২: গতি', questionText: 'সরণ-সময় লেখের ঢাল কী নির্দেশ করে?', options: ['ত্বরণ', 'বেগ', 'বল', 'ভরবেগ'], correctIndex: 1, explanation: 'সরণ-সময় লেখের ঢাল বেগ নির্দেশ করে।'),
  Question(id: 'phy_c3_1', subjectId: 'physics', chapter: 'অধ্যায় ৩: বল', questionText: 'নিউটনের দ্বিতীয় সূত্র অনুযায়ী F = ?', options: ['ma', 'mv', 'm/a', 'a/m'], correctIndex: 0, explanation: 'F = ma।'),
  Question(id: 'phy_c3_2', subjectId: 'physics', chapter: 'অধ্যায় ৩: বল', questionText: 'ঘর্ষণ বল কাজ করে —', options: ['গতির অনুকূলে', 'গতির প্রতিকূলে', 'লম্ব দিকে', 'কোনো দিকে নয়'], correctIndex: 1, explanation: 'ঘর্ষণ বল সবসময় গতির প্রতিকূল দিকে কাজ করে।'),
  Question(id: 'phy_c3_3', subjectId: 'physics', chapter: 'অধ্যায় ৩: বল', questionText: 'ভরবেগের একক কোনটি?', options: ['kg·m/s', 'kg·m/s²', 'N·m', 'J'], correctIndex: 0, explanation: 'p = mv, একক kg·m/s।'),

  // --- AI-generated template questions (Higher Math) ---
  Question(id: 'hmath_c1_1', subjectId: 'higher_math', chapter: 'অধ্যায় ১: সেট ও ফাংশন', questionText: 'A ∩ B = ∅ হলে A, B কে বলা হয় —', options: ['সমান সেট', 'নিশ্ছেদ সেট', 'উপসেট', 'সার্বিক সেট'], correctIndex: 1, explanation: 'ছেদ ফাঁকা হলে নিশ্ছেদ সেট বলে।'),
  Question(id: 'hmath_c1_2', subjectId: 'higher_math', chapter: 'অধ্যায় ১: সেট ও ফাংশন', questionText: 'f(x) = x² হলে f(3) = ?', options: ['6', '9', '3', '12'], correctIndex: 1, explanation: 'f(3) = 3² = 9।'),
  Question(id: 'hmath_c1_3', subjectId: 'higher_math', chapter: 'অধ্যায় ১: সেট ও ফাংশন', questionText: 'n উপাদানবিশিষ্ট সেটের উপসেট সংখ্যা কত?', options: ['n', 'n²', '2ⁿ', '2n'], correctIndex: 2, explanation: 'উপসেট সংখ্যা 2ⁿ।'),
  Question(id: 'hmath_c2_1', subjectId: 'higher_math', chapter: 'অধ্যায় ২: বীজগাণিতিক রাশি', questionText: 'a³ + b³ = (a+b)(a² - ab + b²) — এটি কোন অভেদ?', options: ['ঘন যোগফলের সূত্র', 'ঘন বিয়োগফলের সূত্র', 'বর্গের সূত্র', 'দ্বিপদী উপপাদ্য'], correctIndex: 0, explanation: 'ঘনের যোগফলের উৎপাদক সূত্র।'),
  Question(id: 'hmath_c2_2', subjectId: 'higher_math', chapter: 'অধ্যায় ২: বীজগাণিতিক রাশি', questionText: 'x² - 5x + 6 এর উৎপাদক কোনটি?', options: ['(x-2)(x-3)', '(x+2)(x+3)', '(x-1)(x-6)', '(x-2)(x+3)'], correctIndex: 0, explanation: 'x²-5x+6 = (x-2)(x-3)।'),
  Question(id: 'hmath_c2_3', subjectId: 'higher_math', chapter: 'অধ্যায় ২: বীজগাণিতিক রাশি', questionText: 'a+b=5, ab=6 হলে a²+b² = ?', options: ['13', '25', '19', '11'], correctIndex: 0, explanation: 'a²+b²=(a+b)²-2ab=25-12=13।'),

  // --- Real board questions (Physics, verified) ---
  Question(id: 'phy_b_syl_1', subjectId: 'physics', chapter: 'অধ্যায় ১: ভৌত রাশি ও পরিমাপ', questionText: 'নিচের কোনটি ক্লাসিক্যাল পদার্থবিজ্ঞানের অন্তর্ভুক্ত?', options: ['তাপ ও তাপগতি বিজ্ঞান', 'নিউক্লিয়ার পদার্থবিজ্ঞান', 'কঠিন অবস্থার পদার্থবিজ্ঞান', 'পারমাণবিক পদার্থবিজ্ঞান'], correctIndex: 0, explanation: 'তাপ ও তাপগতিবিজ্ঞান ক্লাসিক্যাল পদার্থবিজ্ঞানের অন্তর্ভুক্ত; বাকিগুলো আধুনিক পদার্থবিজ্ঞানের অংশ।', source: QuestionSource.board, sourceLabel: 'সিলেট বোর্ড ২০২৫'),
  Question(id: 'phy_b_syl_2', subjectId: 'physics', chapter: 'অধ্যায় ১: ভৌত রাশি ও পরিমাপ', questionText: '১০ পিকোমিটার = কত মিটার?', options: ['10⁻¹⁸ m', '10⁻¹³ m', '10⁻¹² m', '10⁻¹¹ m'], correctIndex: 3, explanation: 'পিকো = 10⁻¹², তাই ১০ পিকোমিটার = ১০ × ১০⁻¹² = ১০⁻¹¹ মিটার।', source: QuestionSource.board, sourceLabel: 'সিলেট বোর্ড ২০২৫'),
  Question(id: 'phy_b_syl_3', subjectId: 'physics', chapter: 'অধ্যায় ৫: পদার্থের গাঠনিক ধর্ম', questionText: 'নিচের কোনটির একক ভিন্ন?', options: ['প্রবলতা', 'পীড়ন', 'স্থিতিস্থাপক গুণাঙ্ক', 'বাল্ক মডুলাস'], correctIndex: 0, explanation: 'পীড়ন, স্থিতিস্থাপক গুণাঙ্ক ও বাল্ক মডুলাসের একক Pa; প্রবলতার একক W/m²।', source: QuestionSource.board, sourceLabel: 'সিলেট বোর্ড ২০২৫'),
  Question(id: 'phy_b_syl_6', subjectId: 'physics', chapter: 'অধ্যায় ২: গতি', questionText: 'একটি বস্তুকে খাড়া উপরের দিকে 49ms⁻¹ বেগে নিক্ষেপ করলে বস্তুটি কত সময় শূন্যে থাকে?', options: ['10 sec', '5 sec', '0.4 sec', '0.2 sec'], correctIndex: 0, explanation: 'মোট সময় = 2u/g = 2×49/9.8 = 10s।', source: QuestionSource.board, sourceLabel: 'সিলেট বোর্ড ২০২৫'),
  Question(id: 'phy_b_syl_7', subjectId: 'physics', chapter: 'অধ্যায় ৪: কাজ, ক্ষমতা ও শক্তি', questionText: 'সংকুচিত স্প্রিংয়ের ভিতর কোন শক্তি লুকিয়ে থাকে?', options: ['গতিশক্তি', 'স্প্রিং শক্তি', 'যান্ত্রিক শক্তি', 'বিভব শক্তি'], correctIndex: 3, explanation: 'সংকুচিত স্প্রিংয়ে স্থিতিস্থাপক বিভব শক্তি সঞ্চিত থাকে।', source: QuestionSource.board, sourceLabel: 'সিলেট বোর্ড ২০২৫'),
  Question(id: 'phy_b_syl_10', subjectId: 'physics', chapter: 'অধ্যায় ৫: পদার্থের গাঠনিক ধর্ম', questionText: 'ছুরির একপাশ তীক্ষ্ণ হওয়ার কারণ কী?', options: ['বল বৃদ্ধি', 'ঘর্ষণ বৃদ্ধি', 'চাপ বৃদ্ধি', 'ত্বরণ বৃদ্ধি'], correctIndex: 2, explanation: 'ক্ষেত্রফল কমলে একই বলে চাপ (F/A) বেড়ে যায়, তাই ধার তীক্ষ্ণ করলে কাটা সহজ হয়।', source: QuestionSource.board, sourceLabel: 'সিলেট বোর্ড ২০২৫'),
  Question(id: 'phy_b_syl_18', subjectId: 'physics', chapter: 'অধ্যায় ৬: তাপ ও তাপগতিবিদ্যা', questionText: 'তাপমাত্রার পরিবর্তন না করে পদার্থের অবস্থা পরিবর্তনকারী তাপকে কী বলে?', options: ['গলন', 'বাষ্পীভবন', 'সুপ্ততাপ', 'ঘনীভবন'], correctIndex: 2, explanation: 'অবস্থা পরিবর্তনে ব্যয়িত হয় কিন্তু তাপমাত্রা বাড়ায় না এমন তাপকে সুপ্ততাপ বলে।', source: QuestionSource.board, sourceLabel: 'সিলেট বোর্ড ২০২৫'),
  Question(id: 'phy_b_syl_19', subjectId: 'physics', chapter: 'অধ্যায় ৯: আলোর প্রতিফলন ও প্রতিসরণ', questionText: 'চোখের আলোক সংবেদী অংশ কোনটি?', options: ['রেটিনা', 'পিউপিল', 'কর্নিয়া', 'আইরিশ'], correctIndex: 0, explanation: 'রেটিনায় আলোক সংবেদী কোষ (রড ও কোণ) থাকে যা প্রতিবিম্ব গ্রহণ করে।', source: QuestionSource.board, sourceLabel: 'সিলেট বোর্ড ২০২৫'),
  Question(id: 'phy_b_syl_24', subjectId: 'physics', chapter: 'অধ্যায় ১৩: জীবনে বিজ্ঞানের প্রয়োগ', questionText: 'দাঁতের ক্যাভিটি এবং অন্যান্য ক্ষয় বের করার জন্য কোনটি ব্যবহার করা হয়?', options: ['গামা রশ্মি', 'এক্স রশ্মি', 'আলফা রশ্মি', 'বিটা রশ্মি'], correctIndex: 1, explanation: 'দাঁতের এক্স-রে (ডেন্টাল রেডিওগ্রাফি) দিয়ে ক্যাভিটি শনাক্ত করা হয়।', source: QuestionSource.board, sourceLabel: 'সিলেট বোর্ড ২০২৫'),
  Question(id: 'phy_b_syl_25', subjectId: 'physics', chapter: 'অধ্যায় ১১: চল তড়িৎ', questionText: 'পরিবাহীর রোধ তারের দৈর্ঘ্যের সাথে কীভাবে সম্পর্কিত?', options: ['সমান', 'বর্গের সমান', 'সমানুপাতিক', 'বর্গের সমানুপাতিক'], correctIndex: 2, explanation: 'R = ρL/A অনুযায়ী রোধ দৈর্ঘ্যের সমানুপাতিক।', source: QuestionSource.board, sourceLabel: 'সিলেট বোর্ড ২০২৫'),
  Question(id: 'phy_b_syl_12', subjectId: 'physics', chapter: 'অধ্যায় ৭: তরঙ্গ', questionText: 'তরঙ্গটির বেগ কত? (তরঙ্গদৈর্ঘ্য ১৫ cm, কম্পাঙ্ক ১০০ Hz)', options: ['1000 ms⁻¹', '150 ms⁻¹', '15 ms⁻¹', '10 ms⁻¹'], correctIndex: 2, explanation: 'v = fλ = 100 × 0.15 = 15 ms⁻¹।', source: QuestionSource.board, sourceLabel: 'সিলেট বোর্ড ২০২৫'),

  Question(id: 'phy_b_din_1', subjectId: 'physics', chapter: 'অধ্যায় ১: ভৌত রাশি ও পরিমাপ', questionText: 'কোনটি মৌলিক রাশি?', options: ['তাপমাত্রা', 'বেগ', 'তাপ', 'বল'], correctIndex: 0, explanation: 'SI পদ্ধতিতে তাপমাত্রা একটি মৌলিক রাশি; বাকিগুলো লব্ধ রাশি।', source: QuestionSource.board, sourceLabel: 'দিনাজপুর বোর্ড ২০২৫'),
  Question(id: 'phy_b_din_2', subjectId: 'physics', chapter: 'অধ্যায় ২: গতি', questionText: 'N kg⁻¹ কীসের একক?', options: ['বল', 'ত্বরণ', 'দূরত্ব', 'কাজ'], correctIndex: 1, explanation: 'N/kg = kg·m/s²/kg = m/s², যা ত্বরণের একক।', source: QuestionSource.board, sourceLabel: 'দিনাজপুর বোর্ড ২০২৫'),
  Question(id: 'phy_b_din_3', subjectId: 'physics', chapter: 'অধ্যায় ২: গতি', questionText: '50 m উচ্চতা থেকে বস্তুকে নিচে ফেলে দেওয়া হলে কত মি/সে বেগে ভূমিতে আঘাত করবে? [g = 9.8 m/s²]', options: ['22.13', '31.3', '100', '980'], correctIndex: 1, explanation: 'v = √(2gh) = √(2×9.8×50) = √980 ≈ 31.3 ms⁻¹।', source: QuestionSource.board, sourceLabel: 'দিনাজপুর বোর্ড ২০২৫'),
  Question(id: 'phy_b_din_4', subjectId: 'physics', chapter: 'অধ্যায় ২: গতি', questionText: 'সাইকেলের প্যাডেলের গতি কোন ধরনের গতি?', options: ['চলন গতি', 'স্পন্দন গতি', 'দোলন গতি', 'ঘূর্ণন গতি'], correctIndex: 3, explanation: 'প্যাডেল একটি নির্দিষ্ট অক্ষকে কেন্দ্র করে ঘোরে, তাই এটি ঘূর্ণন গতি।', source: QuestionSource.board, sourceLabel: 'দিনাজপুর বোর্ড ২০২৫'),
  Question(id: 'phy_b_din_7', subjectId: 'physics', chapter: 'অধ্যায় ১৩: জীবনে বিজ্ঞানের প্রয়োগ', questionText: 'কোনটি ফসিল জ্বালানি?', options: ['সৌরশক্তি', 'লাকড়ি', 'পরমাণু শক্তি', 'গ্যাস'], correctIndex: 3, explanation: 'প্রাকৃতিক গ্যাস একটি জীবাশ্ম (ফসিল) জ্বালানি।', source: QuestionSource.board, sourceLabel: 'দিনাজপুর বোর্ড ২০২৫'),
  Question(id: 'phy_b_din_13', subjectId: 'physics', chapter: 'অধ্যায় ৬: তাপ ও তাপগতিবিদ্যা', questionText: '2 kg পানির তাপমাত্রা 2°C বাড়াতে প্রয়োজনীয় তাপ কত? [Sw=4200 Jkg⁻¹K⁻¹]', options: ['16800 J', '8400 J', '4000 J', '2000 J'], correctIndex: 0, explanation: 'Q = msΔT = 2 × 4200 × 2 = 16800 J।', source: QuestionSource.board, sourceLabel: 'দিনাজপুর বোর্ড ২০২৫'),
  Question(id: 'phy_b_din_15', subjectId: 'physics', chapter: 'অধ্যায় ৭: তরঙ্গ', questionText: 'একটি তরঙ্গের কম্পাঙ্ক 1100 Hz হলে, এটির 8800টি পূর্ণস্পন্দন দিতে কত সময় লাগবে?', options: ['3 সেকেন্ড', '8 সেকেন্ড', '9 সেকেন্ড', '10 সেকেন্ড'], correctIndex: 1, explanation: 'সময় = স্পন্দন সংখ্যা / কম্পাঙ্ক = 8800/1100 = 8s।', source: QuestionSource.board, sourceLabel: 'দিনাজপুর বোর্ড ২০২৫'),
  Question(id: 'phy_b_din_17', subjectId: 'physics', chapter: 'অধ্যায় ৯: আলোর প্রতিফলন ও প্রতিসরণ', questionText: 'চোখের আলোক সংবেদী অংশ কোনটি?', options: ['রেটিনা', 'পিউপিল', 'কর্নিয়া', 'আইরিশ'], correctIndex: 0, explanation: 'রেটিনা চোখের আলোক সংবেদী অংশ।', source: QuestionSource.board, sourceLabel: 'দিনাজপুর বোর্ড ২০২৫'),
  Question(id: 'phy_b_din_22', subjectId: 'physics', chapter: 'অধ্যায় ১৩: জীবনে বিজ্ঞানের প্রয়োগ', questionText: 'পদার্থের কণিকার মধ্যে সবচেয়ে হালকা কোনটি?', options: ['প্রোটন', 'পজিট্রন', 'নিউট্রন', 'ইলেকট্রন'], correctIndex: 3, explanation: 'ইলেকট্রনের ভর প্রোটন/নিউট্রনের তুলনায় প্রায় ১৮৩৬ গুণ কম।', source: QuestionSource.board, sourceLabel: 'দিনাজপুর বোর্ড ২০২৫'),

  Question(id: 'phy_b_jsh_2', subjectId: 'physics', chapter: 'অধ্যায় ৭: তরঙ্গ', questionText: '150 Hz কম্পাঙ্কের একটি শব্দ বায়ু মাধ্যমে 3 সেকেন্ড সময়ে 1050m পথ অতিক্রম করে, তরঙ্গটির তরঙ্গদৈর্ঘ্য কত?', options: ['0.1428 m', '0.428 m', '2.33 m', '7 m'], correctIndex: 2, explanation: 'বেগ = 1050/3 = 350 ms⁻¹; λ = v/f = 350/150 ≈ 2.33 m।', source: QuestionSource.board, sourceLabel: 'যশোর বোর্ড ২০২৫'),
  Question(id: 'phy_b_jsh_14', subjectId: 'physics', chapter: 'অধ্যায় ১: ভৌত রাশি ও পরিমাপ', questionText: '1 টেরা মিটার = কত মিটার?', options: ['10¹⁸ মিটার', '10¹⁵ মিটার', '10¹² মিটার', '10⁻¹² মিটার'], correctIndex: 2, explanation: 'টেরা (Tera) = 10¹²।', source: QuestionSource.board, sourceLabel: 'যশোর বোর্ড ২০২৫'),
  Question(id: 'phy_b_jsh_19', subjectId: 'physics', chapter: 'অধ্যায় ৪: কাজ, ক্ষমতা ও শক্তি', questionText: 'কোনো বস্তুর অবস্থা বা অবস্থানের জন্য তৈরি হয় কোন শক্তি?', options: ['বিভব শক্তি', 'গতি শক্তি', 'সৌর শক্তি', 'ভূ-তাপীয় শক্তি'], correctIndex: 0, explanation: 'বস্তুর অবস্থান বা অবস্থার কারণে সঞ্চিত শক্তিই বিভব শক্তি।', source: QuestionSource.board, sourceLabel: 'যশোর বোর্ড ২০২৫'),
  Question(id: 'phy_b_jsh_4', subjectId: 'physics', chapter: 'অধ্যায় ৯: আলোর প্রতিফলন ও প্রতিসরণ', questionText: 'লক্ষ্যবস্তু প্রধান ফোকাস ও বক্রতার কেন্দ্রের মাঝে থাকলে অবতল দর্পণে সৃষ্ট প্রতিবিম্ব— i. আকারে লক্ষ্যবস্তু অপেক্ষা বড় হবে ii. পর্দায় গঠন করা যাবে iii. উল্টো হবে। নিচের কোনটি সঠিক?', options: ['i ও ii', 'ii ও iii', 'i ও iii', 'i, ii ও iii'], correctIndex: 3, explanation: 'ফোকাস ও বক্রতাকেন্দ্রের মধ্যে বস্তু থাকলে প্রতিবিম্ব বাস্তব, উল্টো ও বিবর্ধিত হয় — তাই i, ii, iii সবই সঠিক।', source: QuestionSource.board, sourceLabel: 'যশোর বোর্ড ২০২৫'),

  Question(id: 'phy_b_raj_1', subjectId: 'physics', chapter: 'অধ্যায় ৬: তাপ ও তাপগতিবিদ্যা', questionText: 'কোনটির উপর বাষ্পায়ন নির্ভরশীল নয়?', options: ['তরলের প্রকৃতি', 'তরলের উষ্ণতা', 'তরলের আয়তন', 'তরলের উপরিভাগের ক্ষেত্রফল'], correctIndex: 2, explanation: 'বাষ্পায়ন তরলের প্রকৃতি, উষ্ণতা ও উপরিভাগের ক্ষেত্রফলের উপর নির্ভর করে, মোট আয়তনের উপর নয়।', source: QuestionSource.board, sourceLabel: 'রাজশাহী বোর্ড ২০২৫'),
  Question(id: 'phy_b_raj_6', subjectId: 'physics', chapter: 'অধ্যায় ৯: আলোর প্রতিফলন ও প্রতিসরণ', questionText: 'কোনটি পানির প্রতিসরাঙ্ক?', options: ['1.00', '1.33', '1.52', '2.42'], correctIndex: 1, explanation: 'পানির প্রতিসরাঙ্ক প্রায় 1.33।', source: QuestionSource.board, sourceLabel: 'রাজশাহী বোর্ড ২০২৫'),
  Question(id: 'phy_b_raj_9', subjectId: 'physics', chapter: 'অধ্যায় ৯: আলোর প্রতিফলন ও প্রতিসরণ', questionText: '−4D ক্ষমতাসম্পন্ন লেন্সের ফোকাস দূরত্ব কত?', options: ['−25cm', '−4cm', '−0.25cm', '25cm'], correctIndex: 0, explanation: 'f (মিটারে) = 1/P = 1/(−4) = −0.25m = −25cm।', source: QuestionSource.board, sourceLabel: 'রাজশাহী বোর্ড ২০২৫'),
  Question(id: 'phy_b_raj_13', subjectId: 'physics', chapter: 'অধ্যায় ১২: আধুনিক পদার্থবিজ্ঞান', questionText: 'ভ্যাকুয়াম টিউব আবিষ্কার করেন কে?', options: ['জন ফ্লেমিং', 'জন বার্ডিন', 'ওয়াল্টার ব্রাটেইন', 'উইলিয়াম শকলি'], correctIndex: 0, explanation: 'জন অ্যামব্রোজ ফ্লেমিং ভ্যাকুয়াম টিউব (ডায়োড) আবিষ্কার করেন।', source: QuestionSource.board, sourceLabel: 'রাজশাহী বোর্ড ২০২৫'),
  Question(id: 'phy_b_raj_17', subjectId: 'physics', chapter: 'অধ্যায় ১৩: জীবনে বিজ্ঞানের প্রয়োগ', questionText: 'কোন আইসোটোপ ব্যবহার করে ক্যান্সার আক্রান্ত কোষকে গামা-রে দিয়ে ধ্বংস করা হয়?', options: ['¹⁴C', '³²P', '⁶⁰Co', '¹³¹I'], correctIndex: 2, explanation: 'কোবাল্ট-৬০ থেকে নির্গত গামা রশ্মি ক্যান্সার চিকিৎসায় (রেডিওথেরাপি) ব্যবহৃত হয়।', source: QuestionSource.board, sourceLabel: 'রাজশাহী বোর্ড ২০২৫'),

  Question(id: 'phy_b_cum_13', subjectId: 'physics', chapter: 'অধ্যায় ৯: আলোর প্রতিফলন ও প্রতিসরণ', questionText: 'আলোকবিজ্ঞানের স্থপতি হিসেবে নিচের কোন নামটি বিবেচনা করা হয়?', options: ['ইবনে আল হাইছাম', 'থেলিস', 'আল খোয়ারিজমি', 'আল মাসুদী'], correctIndex: 0, explanation: 'ইবনে আল হাইছামকে আলোকবিজ্ঞান (Optics)-এর জনক হিসেবে বিবেচনা করা হয়।', source: QuestionSource.board, sourceLabel: 'কুমিল্লা বোর্ড ২০২৫'),
  Question(id: 'phy_b_cum_14', subjectId: 'physics', chapter: 'অধ্যায় ১: ভৌত রাশি ও পরিমাপ', questionText: 'কোনটি সবচেয়ে ছোট একক?', options: ['ফেমটোমিটার', 'পিকোমিটার', 'ন্যানোমিটার', 'মাইক্রোমিটার'], correctIndex: 0, explanation: 'ফেমটো (10⁻¹⁵) < পিকো (10⁻¹²) < ন্যানো (10⁻⁹) < মাইক্রো (10⁻⁶)।', source: QuestionSource.board, sourceLabel: 'কুমিল্লা বোর্ড ২০২৫'),

  Question(id: 'phy_b_ctg_1', subjectId: 'physics', chapter: 'অধ্যায় ৭: তরঙ্গ', questionText: 'মেয়েদের কোমল কণ্ঠের জন্য কোনটি দায়ী?', options: ['Wind Pipe', 'Larynx', 'Pitch', 'Vocal cord'], correctIndex: 3, explanation: 'ভোকাল কর্ড (স্বরতন্ত্রী)-এর কম্পনের ধরনই কণ্ঠস্বরের সুর নির্ধারণ করে।', source: QuestionSource.board, sourceLabel: 'চট্টগ্রাম বোর্ড ২০২৫'),
  Question(id: 'phy_b_ctg_7', subjectId: 'physics', chapter: 'অধ্যায় ৬: তাপ ও তাপগতিবিদ্যা', questionText: 'নিচের কোনটির চাপ বাড়ালে গলনাঙ্ক কমে?', options: ['মোম', 'বরফ', 'তামা', 'সোনা'], correctIndex: 1, explanation: 'বরফের ক্ষেত্রে ব্যতিক্রমী ধর্ম অনুযায়ী চাপ বৃদ্ধিতে গলনাঙ্ক কমে।', source: QuestionSource.board, sourceLabel: 'চট্টগ্রাম বোর্ড ২০২৫'),
  Question(id: 'phy_b_ctg_13', subjectId: 'physics', chapter: 'অধ্যায় ১২: আধুনিক পদার্থবিজ্ঞান', questionText: 'npn ট্রানজিস্টরের যে অংশে কারেন্ট প্রবেশ করে তার নাম কী?', options: ['বেস', 'ইনপুট', 'এমিটার', 'কালেক্টর'], correctIndex: 2, explanation: 'এমিটার থেকে কারেন্ট ট্রানজিস্টরে প্রবেশ করে।', source: QuestionSource.board, sourceLabel: 'চট্টগ্রাম বোর্ড ২০২৫'),
  Question(id: 'phy_b_ctg_19', subjectId: 'physics', chapter: 'অধ্যায় ৫: পদার্থের গাঠনিক ধর্ম', questionText: 'বিকৃতির একক কোনটি?', options: ['প্যাসকেল', 'N/m²', 'কোনো একক নেই', 'kg/m³'], correctIndex: 2, explanation: 'বিকৃতি (strain) দুটি একই মাত্রার রাশির অনুপাত, তাই এর কোনো একক নেই।', source: QuestionSource.board, sourceLabel: 'চট্টগ্রাম বোর্ড ২০২৫'),
  Question(id: 'phy_b_ctg_20', subjectId: 'physics', chapter: 'অধ্যায় ১: ভৌত রাশি ও পরিমাপ', questionText: 'নিচের কোনটি মৌলিক রাশি?', options: ['আয়তন', 'দীপন তীব্রতা', 'তাপ', 'তড়িৎ বিভব'], correctIndex: 1, explanation: 'দীপন তীব্রতা (luminous intensity) SI-এর ৭টি মৌলিক রাশির একটি।', source: QuestionSource.board, sourceLabel: 'চট্টগ্রাম বোর্ড ২০২৫'),

  Question(id: 'phy_b_bar_1', subjectId: 'physics', chapter: 'অধ্যায় ১২: আধুনিক পদার্থবিজ্ঞান', questionText: 'কোয়ান্টাম তত্ত্ব আবিষ্কার করেন কোন বিজ্ঞানী?', options: ['রাদারফোর্ড', 'আইনস্টাইন', 'ম্যাক্স প্লাংক', 'কোপার্নিকাস'], correctIndex: 2, explanation: 'ম্যাক্স প্লাংক কোয়ান্টাম তত্ত্বের প্রবর্তক।', source: QuestionSource.board, sourceLabel: 'বরিশাল বোর্ড ২০২৫'),
  Question(id: 'phy_b_bar_11', subjectId: 'physics', chapter: 'অধ্যায় ১৩: জীবনে বিজ্ঞানের প্রয়োগ', questionText: 'নিচের কোন যন্ত্রে ট্রান্সডিউসার দেখা যায়?', options: ['এক্স-রে', 'আল্ট্রাসনোগ্রাফি', 'এমআরআই', 'এন্ডোস্কপি'], correctIndex: 1, explanation: 'আল্ট্রাসনোগ্রাফি যন্ত্রে শব্দ তরঙ্গ ও বৈদ্যুতিক সিগন্যালের মধ্যে রূপান্তরের জন্য ট্রান্সডিউসার ব্যবহৃত হয়।', source: QuestionSource.board, sourceLabel: 'বরিশাল বোর্ড ২০২৫'),
  Question(id: 'phy_b_bar_20', subjectId: 'physics', chapter: 'অধ্যায় ৬: তাপ ও তাপগতিবিদ্যা', questionText: 'তাপমাত্রিক পদার্থ নয় কোনটি?', options: ['অ্যালকোহল', 'পানি', 'গ্যাস', 'পারদ'], correctIndex: 1, explanation: 'পানির ব্যতিক্রমী প্রসারণ ধর্মের কারণে এটি তাপমাত্রিক পদার্থ হিসেবে ব্যবহার করা যায় না।', source: QuestionSource.board, sourceLabel: 'বরিশাল বোর্ড ২০২৫'),
  Question(id: 'phy_b_bar_21', subjectId: 'physics', chapter: 'অধ্যায় ১১: চল তড়িৎ', questionText: 'নিচের কোন পদার্থটি উত্তম পরিবাহী?', options: ['গ্রাফাইট', 'সোনা', 'তামা', 'রূপা'], correctIndex: 3, explanation: 'রূপার তড়িৎ পরিবাহিতা তালিকাভুক্ত ধাতুগুলোর মধ্যে সর্বোচ্চ।', source: QuestionSource.board, sourceLabel: 'বরিশাল বোর্ড ২০২৫'),

  Question(id: 'phy_b_mym_1', subjectId: 'physics', chapter: 'অধ্যায় ৭: তরঙ্গ', questionText: 'কোথায় শব্দের বেগ সবচেয়ে বেশি?', options: ['বায়ু', 'পারদ', 'লোহা', 'হীরা'], correctIndex: 3, explanation: 'হীরার স্থিতিস্থাপকতা সবচেয়ে বেশি হওয়ায় শব্দের বেগও সর্বোচ্চ (প্রায় ১২,০০০ m/s)।', source: QuestionSource.board, sourceLabel: 'ময়মনসিংহ বোর্ড ২০২৫'),
  Question(id: 'phy_b_mym_7', subjectId: 'physics', chapter: 'অধ্যায় ৯: আলোর প্রতিফলন ও প্রতিসরণ', questionText: 'দৃশ্যমান আলোর সবচেয়ে কম তরঙ্গদৈর্ঘ্য কোনটির?', options: ['বেগুনি', 'লাল', 'হলুদ', 'নীল'], correctIndex: 0, explanation: 'দৃশ্যমান বর্ণালিতে বেগুনি রঙের তরঙ্গদৈর্ঘ্য সবচেয়ে কম।', source: QuestionSource.board, sourceLabel: 'ময়মনসিংহ বোর্ড ২০২৫'),
  Question(id: 'phy_b_mym_9', subjectId: 'physics', chapter: 'অধ্যায় ৬: তাপ ও তাপগতিবিদ্যা', questionText: 'সুস্থ মানবদেহের তাপমাত্রা কত?', options: ['36.89°C', '98.4°C', '309.89°C', '371.4°C'], correctIndex: 0, explanation: 'স্বাভাবিক মানবদেহের তাপমাত্রা প্রায় ৩৭°C (৩৬.৮৯°C এর কাছাকাছি)।', source: QuestionSource.board, sourceLabel: 'ময়মনসিংহ বোর্ড ২০২৫'),
  Question(id: 'phy_b_mym_21', subjectId: 'physics', chapter: 'অধ্যায় ৩: বল', questionText: 'ক্রিয়া বল F₁ ও প্রতিক্রিয়া বল F₂ হলে নিউটনের ৩য় সূত্রের ক্ষেত্রে কোন সম্পর্কটি সঠিক?', options: ['F₁ > F₂', 'F₁ − F₂ = 0', 'F₁ + F₂ = 0', 'F₁ = F₂'], correctIndex: 2, explanation: 'ক্রিয়া ও প্রতিক্রিয়া বল সমমান কিন্তু বিপরীতমুখী, তাই ভেক্টর যোগফল শূন্য: F₁ + F₂ = 0।', source: QuestionSource.board, sourceLabel: 'ময়মনসিংহ বোর্ড ২০২৫'),
];

const List<CreativeQuestion> allCQs = [
  // --- AI-generated template CQs ---
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

  // --- Real board CQs (Physics) ---
  CreativeQuestion(
    id: 'phy_bcq_dha_1', subjectId: 'physics', chapter: 'অধ্যায় ২: গতি',
    stem: 'একটি কার 2.5 ms⁻² সমত্বরণে স্থিরাবস্থা থেকে যাত্রা শুরু করল এবং একই সময়ে অপর একটি কার প্রথম কারটির 50m পিছন থেকে 63kmh⁻¹ সমবেগে যাত্রা শুরু করল।',
    questionK: 'পিচ (Pitch) কাকে বলে?',
    questionKh: '"দোলন গতি একটি পর্যায়বৃত্ত গতি"— ব্যাখ্যা করো।',
    questionG: 'যাত্রা শুরুর কত সময় পরে কার দুইটির বেগ একই হবে? নির্ণয় করো।',
    questionGh: 'কার দুটি তাদের চলার পথে একবারের অধিক একে অপরকে অতিক্রম করবে কি না? গাণিতিকভাবে বিশ্লেষণ করো।',
    source: QuestionSource.board, sourceLabel: 'ঢাকা বোর্ড ২০২৫',
  ),
  CreativeQuestion(
    id: 'phy_bcq_dha_5', subjectId: 'physics', chapter: 'অধ্যায় ৭: তরঙ্গ',
    stem: 'একটি তরঙ্গ A হতে C তে পৌঁছাতে সময় লাগে 0.2s। (তরঙ্গের চিত্রে প্রবাহের দিকসহ তরঙ্গদৈর্ঘ্য 3m দেখানো আছে।)',
    questionK: 'যান্ত্রিক তরঙ্গ কাকে বলে?',
    questionKh: 'বায়ুতে শব্দের বেগ তাপমাত্রার উপর নির্ভরশীল— ব্যাখ্যা করো।',
    questionG: 'তরঙ্গটির কম্পাঙ্ক নির্ণয় করো।',
    questionGh: 'বিস্তার অপরিবর্তিত রেখে তরঙ্গটির তরঙ্গদৈর্ঘ্য দ্বিগুণ করা হলে কম্পাঙ্কের কী পরিবর্তন হবে তা গাণিতিকভাবে বিশ্লেষণ করো।',
    source: QuestionSource.board, sourceLabel: 'ঢাকা বোর্ড ২০২৫',
  ),
  CreativeQuestion(
    id: 'phy_bcq_raj_3', subjectId: 'physics', chapter: 'অধ্যায় ২ ও ৫: গতি ও স্থিতিস্থাপকতা',
    stem: 'দৃশ্যপট-১: 9.8 ms⁻² অভিকর্ষজ ত্বরণ সম্পন্ন স্থানে একটি বস্তুকে 20 ms⁻¹ বেগে খাড়া উপরের দিকে নিক্ষেপ করা হলো। দৃশ্যপট-২: একই প্রস্থচ্ছেদবিশিষ্ট 100 cm দৈর্ঘ্যের দুটি তার A ও B। তারদ্বয়ের প্রত্যেকটিতে দৈর্ঘ্য বরাবর 5 kg ভরের বস্তু ঝুলিয়ে দিলে দৈর্ঘ্য বৃদ্ধি হয় যথাক্রমে 2 cm ও 3 cm।',
    questionK: 'ঘনত্ব কাকে বলে?',
    questionKh: 'পারদ একটি তাপমাত্রিক পদার্থ— ব্যাখ্যা করো।',
    questionG: 'দৃশ্যপট-১ এর বস্তুটি সর্বোচ্চ কত উচ্চতায় উঠবে? নির্ণয় করো।',
    questionGh: 'দৃশ্যপট-২ এর তারদ্বয়ের মধ্যে কোনটি অধিকতর স্থিতিস্থাপক? বিশ্লেষণের মাধ্যমে মতামত দাও।',
    source: QuestionSource.board, sourceLabel: 'রাজশাহী বোর্ড ২০২৫',
  ),
  CreativeQuestion(
    id: 'phy_bcq_cum_1', subjectId: 'physics', chapter: 'অধ্যায় ২: গতি',
    stem: 'একটি গাড়ির সময়ের সাথে প্রাপ্ত বেগের সারণি: সময়(s): 0,5,10,15,20,25,30,35,40; বেগ(ms⁻¹): 0,2,4,6,8,8,8,6,4।',
    questionK: 'ভার্নিয়ার ধ্রুবক কাকে বলে?',
    questionKh: 'ক্রিয়া ও প্রতিক্রিয়া বল একই বস্তুতে ক্রিয়া করে না— ব্যাখ্যা করো।',
    questionG: 'গাড়িটির 40s এ মোট অতিক্রান্ত দূরত্ব নির্ণয় করো।',
    questionGh: 'গাড়িটির বেগ-সময় লেখচিত্র এঁকে এর বিভিন্ন অংশের গতির প্রকৃতি বিশ্লেষণ করো।',
    source: QuestionSource.board, sourceLabel: 'কুমিল্লা বোর্ড ২০২৫',
  ),
  CreativeQuestion(
    id: 'phy_bcq_bar_2', subjectId: 'physics', chapter: 'অধ্যায় ২: গতি',
    stem: 'P ও Q দুটি নৌকা যথাক্রমে 8ms⁻¹ ও 5ms⁻¹ বেগ এবং 4ms⁻² ও 6ms⁻² ত্বরণ নিয়ে একটি প্রতিযোগিতায় যাত্রা শুরু করে এবং একই সময়ে নদীর অপর তীরে পৌঁছায়।',
    questionK: 'ত্বরণ কাকে বলে?',
    questionKh: '"মুক্তভাবে পড়ন্ত কোনো বস্তুর নির্দিষ্ট সময়ে অতিক্রান্ত দূরত্ব, ঐ সময়ে প্রাপ্ত বেগের বর্গের সমানুপাতিক"— ব্যাখ্যা করো।',
    questionG: 'যাত্রা শুরুর 4s পর নৌকা দুটির মধ্যবর্তী দূরত্ব নির্ণয় করো।',
    questionGh: 'P ও Q নৌকা দুটি অপর তীরে পৌঁছালে নদীর প্রস্থ কত তা নির্ণয় করো।',
    source: QuestionSource.board, sourceLabel: 'বরিশাল বোর্ড ২০২৫',
  ),
  CreativeQuestion(
    id: 'phy_bcq_bar_7', subjectId: 'physics', chapter: 'অধ্যায় ১০: স্থির তড়িৎ',
    stem: '+120C ও −90C চার্জের দুটি বস্তু বায়ু মাধ্যমে পরস্পর 150cm দূরে অবস্থিত। বায়ু মাধ্যমে K = 9 × 10⁹ Nm²C⁻²।',
    questionK: 'তড়িৎ আবেশ কাকে বলে?',
    questionKh: 'একই উপাদানের সমান দৈর্ঘ্যের দুটি তারের মধ্যে চিকন তার অপেক্ষা মোটা তারের রোধ কম কেন? ব্যাখ্যা করো।',
    questionG: 'চার্জ দুটির মধ্যবর্তী ক্রিয়াশীল বলের মান নির্ণয় করো।',
    questionGh: 'চার্জিত বস্তু দুটির সংযোগ রেখার কোথায় তড়িৎ প্রাবল্য শূন্য হবে? চিত্রসহ গাণিতিকভাবে বিশ্লেষণ করো।',
    source: QuestionSource.board, sourceLabel: 'বরিশাল বোর্ড ২০২৫',
  ),
  CreativeQuestion(
    id: 'phy_bcq_mym_5', subjectId: 'physics', chapter: 'অধ্যায় ৭: তরঙ্গ',
    stem: 'রাতুল একটি প্রাচীর থেকে 18m দূরে দাঁড়িয়ে শব্দ করে এবং প্রাচীরের দিকে এগিয়ে যায়। ঐ দিন বায়ুতে ও পানিতে শব্দের বেগ যথাক্রমে 350ms⁻¹ ও 1500ms⁻¹ ছিল। মাধ্যম দুটিতে শব্দের তরঙ্গদৈর্ঘ্যের পার্থক্য 1.6m।',
    questionK: 'তরঙ্গ কাকে বলে?',
    questionKh: 'শব্দের তীব্রতা 80Wm⁻² বলতে কী বোঝায়? ব্যাখ্যা করো।',
    questionG: 'পানিতে শব্দের তরঙ্গদৈর্ঘ্য নির্ণয় করো।',
    questionGh: 'রাতুল প্রাচীরের দিকে সর্বোচ্চ কত বেগে দৌড়ালে প্রতিধ্বনি শুনতে পাবে? গাণিতিক বিশ্লেষণের মাধ্যমে মতামত দাও।',
    source: QuestionSource.board, sourceLabel: 'ময়মনসিংহ বোর্ড ২০২৫',
  ),
  CreativeQuestion(
    id: 'phy_bcq_din_3', subjectId: 'physics', chapter: 'অধ্যায় ৪: কাজ, ক্ষমতা ও শক্তি',
    stem: '2.5kW একটি বৈদ্যুতিক মোটর 12kg ভরের একটি বস্তুকে 20m উপরে তুলে ছেড়ে দিল। বস্তুটি মুক্তভাবে মাটিতে পড়ল।',
    questionK: 'মৌলিক বল কাকে বলে?',
    questionKh: 'কর্দমাক্ত মাটিতে হাঁটা কষ্টকর কেন? ব্যাখ্যা করো।',
    questionG: 'মোটরটির কর্মদক্ষতা নির্ণয় করো।',
    questionGh: 'মুক্তভাবে পড়ন্ত অবস্থায় বস্তুটি ভূ-পৃষ্ঠ থেকে কত উচ্চতায় এর বিভবশক্তি গতিশক্তির এক-চতুর্থাংশ হবে? গাণিতিক বিশ্লেষণের মাধ্যমে মতামত দাও।',
    source: QuestionSource.board, sourceLabel: 'দিনাজপুর বোর্ড ২০২৫',
  ),
  CreativeQuestion(
    id: 'phy_bcq_syl_1', subjectId: 'physics', chapter: 'অধ্যায় ১০: স্থির তড়িৎ',
    stem: 'A গোলকে +1C এবং B গোলকে −2C আধান আছে, দূরত্ব 1m। কুলম্বের ধ্রুবক K = 9 × 10⁹ Nm²C⁻²।',
    questionK: 'ধারক কাকে বলে?',
    questionKh: 'তড়িৎক্ষেত্র ও তড়িৎ তীব্রতা একই নয় কেন? ব্যাখ্যা করো।',
    questionG: 'B-তে চার্জের মান কী পরিবর্তন করলে বল ও কুলম্বের ধ্রুবক একই হবে?',
    questionGh: 'উদ্দীপকের A গোলকে আরও +1C আধান যুক্ত করলে পরিবর্তিত অবস্থার সাথে পূর্বের অবস্থার তড়িৎ বলরেখার বৈশিষ্ট্যের পরিবর্তন চিত্র এঁকে ব্যাখ্যা করো।',
    source: QuestionSource.board, sourceLabel: 'সিলেট বোর্ড ২০২৫',
  ),
  CreativeQuestion(
    id: 'phy_bcq_ctg_1', subjectId: 'physics', chapter: 'অধ্যায় ১ ও ২: পরিমাপ ও গতি',
    stem: 'একটি গোলাকার বস্তুর ব্যাসার্ধ 1.5 cm। স্লাইড ক্যালিপার্সের সাহায্যে এর ব্যাস পরিমাপ করে 3.2 cm পাওয়া গেল। বস্তুটিকে ভূমি থেকে 54 ms⁻¹ বেগে খাড়া উপরের দিকে নিক্ষেপ করলে এটি নির্দিষ্ট সময় পরে ভূপৃষ্ঠে পতিত হয়।',
    questionK: 'ভার্নিয়ার ধ্রুবক কাকে বলে?',
    questionKh: 'সুষম বেগে চলমান বস্তুর গতিপথ শুধুমাত্র সরলরৈখিক— ব্যাখ্যা করো।',
    questionG: 'গোলাকার বস্তুটির ব্যাস পরিমাপের আপেক্ষিক ত্রুটি নির্ণয় করো।',
    questionGh: 'ভূমি থেকে 70 m উচ্চতায় বস্তুটিকে ভিন্ন ভিন্ন সময়ে ভিন্ন বেগে দুইবার দেখা যাবে— গাণিতিকভাবে বিশ্লেষণ করো।',
    source: QuestionSource.board, sourceLabel: 'চট্টগ্রাম বোর্ড ২০২৫',
  ),
];
