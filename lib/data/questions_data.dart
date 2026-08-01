enum SubjectGroup { all, science, business, humanities, general }

class SubjectInfo {
  final String id;
  final String name;
  final String bengaliName;
  final String icon;
  final int colorHex;
  final SubjectGroup group;

  const SubjectInfo({
    required this.id,
    required this.name,
    required this.bengaliName,
    required this.icon,
    required this.colorHex,
    required this.group,
  });
}

class Question {
  final String id;
  final String subject;
  final String chapter;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String source;
  final String sourceLabel;
  final String explanation;

  const Question({
    required this.id,
    required this.subject,
    required this.chapter,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.source,
    required this.sourceLabel,
    required this.explanation,
  });
}

class CQSubPart {
  final String label;
  final String prompt;
  final int marks;
  final String modelAnswer;

  const CQSubPart({
    required this.label,
    required this.prompt,
    required this.marks,
    required this.modelAnswer,
  });
}

class CreativeQuestion {
  final String id;
  final String subject;
  final String chapter;
  final String stem;
  final String source;
  final String sourceLabel;
  final List<CQSubPart> subParts;

  const CreativeQuestion({
    required this.id,
    required this.subject,
    required this.chapter,
    required this.stem,
    required this.source,
    required this.sourceLabel,
    required this.subParts,
  });
}

final List<Question> sampleQuestions = [
  const Question(
    id: 'q1',
    subject: 'physics',
    chapter: 'গতি',
    questionText: 'ত্বরণের একক কোনটি?',
    options: ['ms⁻¹', 'ms⁻²', 'N', 'kg'],
    correctOptionIndex: 1,
    source: 'board',
    sourceLabel: 'ঢাকা বোর্ড ২০২৪',
    explanation: r'একক সময়ে কোনো বস্তুর বেগের পরিবর্তনের হারকে ত্বরণ ($a = \frac{v-u}{t}$) বলে।',
  ),
  const Question(
    id: 'q2',
    subject: 'higher_math',
    chapter: 'দ্বিপদী বিস্তৃতি',
    questionText: r'$(1+x)^n$ এর বিস্তৃতিতে পদসংখ্যা কত?',
    options: ['n', 'n-1', 'n+1', '2n'],
    correctOptionIndex: 2,
    source: 'ai',
    sourceLabel: 'AI Generative',
    explanation: r'দ্বিপদী বিস্তৃতি $(a+b)^n$ এর পদসংখ্যা সবসময় ঘাত $n$ এর চেয়ে ১ বেশি অর্থাৎ $n+1$ হয়।',
  ),
];

final List<CreativeQuestion> sampleCreativeQuestions = [
  const CreativeQuestion(
    id: 'cq1',
    subject: 'physics',
    chapter: 'গতি',
    stem: r'একটি গাড়ি স্থির অবস্থান থেকে $2\text{ ms}^{-2}$ সুষম ত্বরণে $10\text{ s}$ চলল।',
    source: 'board',
    sourceLabel: 'রাজশাহী বোর্ড ২০২৩',
    subParts: [
      CQSubPart(label: 'ক', prompt: 'ত্বরণ কাকে বলে?', marks: 1, modelAnswer: 'সময়ের সাথে বেগের পরিবর্তনের হারকে ত্বরণ বলে।'),
      CQSubPart(label: 'খ', prompt: 'সুষম বেগ বলতে কী বোঝায়?', marks: 2, modelAnswer: 'কোনো বস্তু যদি নির্দিষ্ট দিকে সমান সময়ে সমান দূরত্ব অতিক্রম করে, তবে তার বেগকে সুষম বেগ বলে।'),
      CQSubPart(label: 'গ', prompt: 'গাড়িটির শেষ বেগ নির্ণয় করো।', marks: 3, modelAnswer: r'$v = u + at = 0 + (2 \times 10) = 20\text{ ms}^{-1}$'),
      CQSubPart(label: 'ঘ', prompt: 'উক্ত সময়ে অতিক্রান্ত দূরত্ব কত হবে গাণিতিকভাবে বিশ্লেষণ করো।', marks: 4, modelAnswer: r'$s = ut + \frac{1}{2}at^2 = 0 + \frac{1}{2}(2)(10^2) = 100\text{ m}$'),
    ],
  ),
];
