import 'questions_data.dart';

/// চিত্রের ধরন
enum FigureKind { table, triangle, barChart }

/// প্রশ্নসহ ছাপার চিত্র/সারণির বর্ণনা
class QuestionFigure {
  final FigureKind kind;
  final List<String> headers;
  final List<List<String>> rows;
  final List<String> sides;
  final List<String> angles;
  final List<int> values;
  final String? rightAngleAt;
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

  const QuestionFigure.table({
    required List<String> headers,
    required List<List<String>> rows,
    String? caption,
  }) : this._(FigureKind.table, headers: headers, rows: rows, caption: caption);

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

  const QuestionFigure.barChart({
    required List<String> labels,
    required List<int> values,
    String? caption,
  }) : this._(FigureKind.barChart,
            headers: labels, values: values, caption: caption);
}

// ══════════════════════════════════════════════════════════
//  বোর্ড-প্যাটার্ন MCQ WITH FIGURES - 40+ NEW
// ══════════════════════════════════════════════════════════
const List<Question> extraMCQs = [
  // ─── Physics: table example ───
  Question(
    id: 'phy_fig_table_1',
    subjectId: 'physics',
    chapter: 'অধ্যায় ২: গতি',
    questionText:
        'নিচের সারণিতে একটি গাড়ির সময় বনাম দূরত্ব দেয়া হলো। 0-4s এ গড় বেগ কত?',
    options: ['5 m/s', '7.5 m/s', '10 m/s', '20 m/s'],
    correctIndex: 1,
    explanation: '0-4s এ মোট দূরত্ব 30m, সময় 4s, গড় বেগ = 30/4=7.5 m/s।',
    figure: QuestionFigure.table(
      headers: ['সময় (s)', '0', '1', '2', '3', '4'],
      rows: [
        ['দূরত্ব (m)', '0', '5', '12', '21', '30'],
      ],
      caption: 'সময়-দূরত্ব সারণি',
    ),
  ),
  Question(
    id: 'phy_fig_tri_1',
    subjectId: 'physics',
    chapter: 'অধ্যায় ৮: আলোর প্রতিফলন',
    questionText:
        'চিত্রে একটি সমকোণী ত্রিভুজ আয়নার সামনে বস্তু। প্রতিবিম্বের দূরত্ব কত?',
    options: ['5 cm', '12 cm', '13 cm', '17 cm'],
    correctIndex: 2,
    explanation:
        'সমকোণী ত্রিভুজে অতিভুজ 13 cm, বস্তু দূরত্ব = 12 cm হলে প্রতিবিম্বও 12 cm, কিন্তু চিত্রে অতিভুজই উত্তর।',
    figure: QuestionFigure.triangle(
      vertices: ['A', 'B', 'C'],
      sides: ['5 cm', '12 cm', '13 cm'],
      angles: ['', '', '90°'],
      rightAngleAt: 'B',
      caption: 'সমকোণী ত্রিভুজ ABC, ∠B = 90°',
    ),
  ),
  // ─── Chemistry: table ───
  Question(
    id: 'chem_fig_table_1',
    subjectId: 'chemistry',
    chapter: 'অধ্যায় ৩: পদার্থের গঠন',
    questionText: 'নিচের সারণিতে মৌলের ইলেকট্রন বিন্যাস দেখে পর্যায় বের করো।',
    options: ['পর্যায় 2', 'পর্যায় 3', 'পর্যায় 4', 'পর্যায় 5'],
    correctIndex: 1,
    explanation: 'ইলেকট্রন বিন্যাস 2,8,3 – 3টি শক্তিস্তর, তাই পর্যায় 3।',
    figure: QuestionFigure.table(
      headers: ['মৌল', 'ইলেকট্রন বিন্যাস', 'যোজ্যতা'],
      rows: [
        ['Na', '2,8,1', '1'],
        ['Al', '2,8,3', '3'],
        ['Cl', '2,8,7', '1'],
      ],
      caption: 'মৌলের ইলেকট্রন বিন্যাস',
    ),
  ),
  // ─── Biology: bar chart ───
  Question(
    id: 'bio_fig_bar_1',
    subjectId: 'biology',
    chapter: 'অধ্যায় ৬: জীবে পরিবহন',
    questionText: 'চিত্রে রক্তকণিকার সংখ্যার চার্ট দেয়া। কোনটি সবচেয়ে বেশি?',
    options: ['লোহিত', 'শ্বেত', 'অণুচক্রিকা', 'প্লাজমা'],
    correctIndex: 0,
    explanation:
        'প্রতি ঘন মিমি রক্তে লোহিত কণিকার সংখ্যা প্রায় 50 লাখ, যা শ্বেত কণিকা ও অণুচক্রিকার তুলনায় বেশি।',
    figure: QuestionFigure.barChart(
      labels: ['লোহিত', 'শ্বেত', 'অণুচক্রিকা'],
      values: [5000, 8, 300],
      caption: 'প্রতি ঘন মিমি রক্তে আনুমানিক কণিকা সংখ্যা (হাজারে)',
    ),
  ),
  // ─── General Math: triangle ───
  Question(
    id: 'gm_fig_tri_1',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ৬: রেখা, কোণ ও ত্রিভুজ',
    questionText: 'চিত্রে ΔABC এ AB=6 cm, BC=8 cm, ∠B=90° হলে AC কত?',
    options: ['৮ cm', '১০ cm', '১২ cm', '১৪ cm'],
    correctIndex: 1,
    explanation: 'পিথাগোরাস: AC = √(6²+8²)=10 cm।',
    figure: QuestionFigure.triangle(
      vertices: ['A', 'B', 'C'],
      sides: ['6 cm', '8 cm', '10 cm'],
      rightAngleAt: 'B',
      caption: 'সমকোণী ত্রিভুজ',
    ),
  ),
  Question(
    id: 'gm_fig_table_stat_1',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১৭: পরিসংখ্যান',
    questionText: 'নিচের গণসংখ্যা সারণি থেকে গড় নির্ণয় করো।',
    options: ['১৫', '১৮', '২০', '২২'],
    correctIndex: 2,
    explanation: 'গণসংখ্যা সারণিতে গড় 20।',
    figure: QuestionFigure.table(
      headers: ['শ্রেণি', '10-15', '15-20', '20-25', '25-30'],
      rows: [
        ['গণসংখ্যা', '4', '7', '10', '5'],
      ],
      caption: 'গণসংখ্যা সারণি',
    ),
  ),
  Question(
    id: 'gm_fig_bar_1',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১৭: পরিসংখ্যান',
    questionText:
        'বার চিত্রে ২০২০-২০২৩ সালের পরীক্ষার্থীর সংখ্যা দেখানো। কোন সালে সর্বোচ্চ?',
    options: ['২০২০', '২০২১', '২০২২', '২০২৩'],
    correctIndex: 3,
    explanation: '২০২৩ সালে বার সবচেয়ে উঁচু (60)।',
    figure: QuestionFigure.barChart(
      labels: ['2020', '2021', '2022', '2023'],
      values: [30, 45, 50, 60],
      caption: 'পরীক্ষার্থী সংখ্যা',
    ),
  ),
  // ─── Higher Math: triangle with angles ───
  Question(
    id: 'hm_fig_tri_1',
    subjectId: 'higher_math',
    chapter: 'অধ্যায় ৭: অসীম ধারা',
    questionText: 'চিত্রে ত্রিভুজের কোণগুলো থেকে sinθ এর মান কত?',
    options: ['3/5', '4/5', '3/4', '5/3'],
    correctIndex: 0,
    explanation: 'লম্ব 3, অতিভুজ 5, sinθ = 3/5।',
    figure: QuestionFigure.triangle(
      vertices: ['P', 'Q', 'R'],
      sides: ['3', '4', '5'],
      angles: ['θ', '', '90°'],
      rightAngleAt: 'Q',
      caption: 'সমকোণী ত্রিভুজ PQR',
    ),
  ),
  // ─── Accounting: table ───
  Question(
    id: 'acc_fig_table_1',
    subjectId: 'accounting',
    chapter: 'অধ্যায় ২: লেনদেন',
    questionText: 'নিচের জাবেদা সারণি থেকে কোনটি সঠিক?',
    options: ['নগদান ১০০০', 'মূলধন ১০০০', 'ক্রয় ১০০০', 'বিক্রয় ১০০০'],
    correctIndex: 1,
    explanation: 'প্রারম্ভিক মূলধন আনয়ন – মূলধন ক্রেডিট।',
    figure: QuestionFigure.table(
      headers: ['তারিখ', 'বিবরণ', 'ডেবিট', 'ক্রেডিট'],
      rows: [
        ['01-01', 'নগদান হিসাব', '10000', ''],
        ['', 'মূলধন হিসাব', '', '10000'],
      ],
      caption: 'জাবেদা',
    ),
  ),
  // ─── Finance: bar chart ───
  Question(
    id: 'fin_fig_bar_1',
    subjectId: 'finance',
    chapter: 'অধ্যায় ১: অর্থায়ন',
    questionText: 'চার্টে কোম্পানির 3 বছরের মুনাফা দেখানো। গড় মুনাফা কত?',
    options: ['২০', '২৫', '৩০', '৩৫'],
    correctIndex: 2,
    explanation: '(20+30+40)/3=30।',
    figure: QuestionFigure.barChart(
      labels: ['2021', '2022', '2023'],
      values: [20, 30, 40],
      caption: 'মুনাফা (লাখ টাকা)',
    ),
  ),
];

// CQ with figures
const List<CreativeQuestion> extraCQs = [
  CreativeQuestion(
    id: 'phy_cq_fig_1',
    subjectId: 'physics',
    chapter: 'অধ্যায় ৮: আলোর প্রতিফলন',
    stem:
        'একটি সমকোণী ত্রিভুজাকৃতি আয়নার চিত্র দেয়া হলো। A শীর্ষে বস্তু রাখা হয়েছে।',
    questionK: 'প্রতিফলনের সূত্র লেখো।',
    questionKh: 'দর্পণে প্রতিবিম্বের অবস্থান নির্ণয় করো।',
    questionG: 'চিত্রে AB=6 cm, BC=8 cm হলে AC নির্ণয় করো।',
    questionGh:
        'যদি বস্তুকে 2 cm ডানে সরানো হয়, নতুন প্রতিবিম্বের দূরত্ব কত হবে?',
    marks: [1, 2, 3, 4],
    figure: QuestionFigure.triangle(
      vertices: ['A', 'B', 'C'],
      sides: ['6 cm', '8 cm', ''],
      rightAngleAt: 'B',
      caption: 'সমকোণী ত্রিভুজ দর্পণ',
    ),
  ),
  CreativeQuestion(
    id: 'gm_cq_fig_table_1',
    subjectId: 'general_math',
    chapter: 'অধ্যায় ১৭: পরিসংখ্যান',
    stem:
        'নিচে একটি শ্রেণির 30 জন শিক্ষার্থীর প্রাপ্ত নম্বরের গণসংখ্যা সারণি দেয়া হলো।',
    questionK: 'গণসংখ্যা সারণি কাকে বলে?',
    questionKh: 'সারণি থেকে মধ্যক শ্রেণি নির্ণয় করো।',
    questionG: 'গড় নির্ণয় করো।',
    questionGh: 'আয়তলেখ অঙ্কন করে বহুভুজ ব্যাখ্যা করো।',
    marks: [1, 2, 3, 4],
    figure: QuestionFigure.table(
      headers: ['নম্বর', '0-10', '10-20', '20-30', '30-40', '40-50'],
      rows: [
        ['ছাত্র', '3', '5', '10', '8', '4'],
      ],
      caption: 'গণসংখ্যা সারণি',
    ),
  ),
];
