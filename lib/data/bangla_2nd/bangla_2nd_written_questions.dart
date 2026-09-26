import '../questions_data.dart';

enum Bangla2WrittenType {
  paragraph,
  letterOrReport,
  summaryOrGist,
  thoughtExpansion,
  translation,
  composition,
}

class Bangla2WrittenQuestion {
  final String id;
  final Bangla2WrittenType type;
  final String prompt;
  final String? sourceText;
  final String answerGuide;
  final int marks;
  final QuestionSource source;
  final String? sourceLabel;

  const Bangla2WrittenQuestion({
    required this.id,
    required this.type,
    required this.prompt,
    this.sourceText,
    required this.answerGuide,
    required this.marks,
    this.source = QuestionSource.original,
    this.sourceLabel,
  });
}

const List<Bangla2WrittenQuestion> bangla2ndWrittenQuestions =
    <Bangla2WrittenQuestion>[
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_001',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 1: ‘সময়ানুবর্তিতা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_002',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 2: ‘সময়ানুবর্তিতা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_003',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 3: ‘সময়ানুবর্তিতা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_004',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 4: ‘সময়ানুবর্তিতা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_005',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 5: ‘সময়ানুবর্তিতা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_006',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 1: ‘পরিবেশ সংরক্ষণ’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_007',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 2: ‘পরিবেশ সংরক্ষণ’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_008',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 3: ‘পরিবেশ সংরক্ষণ’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_009',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 4: ‘পরিবেশ সংরক্ষণ’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_010',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 5: ‘পরিবেশ সংরক্ষণ’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_011',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 1: ‘বই পড়ার অভ্যাস’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_012',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 2: ‘বই পড়ার অভ্যাস’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_013',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 3: ‘বই পড়ার অভ্যাস’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_014',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 4: ‘বই পড়ার অভ্যাস’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_015',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 5: ‘বই পড়ার অভ্যাস’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_016',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 1: ‘ডিজিটাল নিরাপত্তা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_017',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 2: ‘ডিজিটাল নিরাপত্তা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_018',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 3: ‘ডিজিটাল নিরাপত্তা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_019',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 4: ‘ডিজিটাল নিরাপত্তা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_020',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 5: ‘ডিজিটাল নিরাপত্তা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_021',
    type: Bangla2WrittenType.paragraph,
    prompt:
        'অনুশীলন 1: ‘শিক্ষায় প্রযুক্তি’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_022',
    type: Bangla2WrittenType.paragraph,
    prompt:
        'অনুশীলন 2: ‘শিক্ষায় প্রযুক্তি’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_023',
    type: Bangla2WrittenType.paragraph,
    prompt:
        'অনুশীলন 3: ‘শিক্ষায় প্রযুক্তি’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_024',
    type: Bangla2WrittenType.paragraph,
    prompt:
        'অনুশীলন 4: ‘শিক্ষায় প্রযুক্তি’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_025',
    type: Bangla2WrittenType.paragraph,
    prompt:
        'অনুশীলন 5: ‘শিক্ষায় প্রযুক্তি’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_026',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 1: ‘সড়ক নিরাপত্তা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_027',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 2: ‘সড়ক নিরাপত্তা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_028',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 3: ‘সড়ক নিরাপত্তা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_029',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 4: ‘সড়ক নিরাপত্তা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_030',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 5: ‘সড়ক নিরাপত্তা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_031',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 1: ‘জলবায়ু পরিবর্তন’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_032',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 2: ‘জলবায়ু পরিবর্তন’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_033',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 3: ‘জলবায়ু পরিবর্তন’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_034',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 4: ‘জলবায়ু পরিবর্তন’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_035',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 5: ‘জলবায়ু পরিবর্তন’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_036',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 1: ‘নারীর ক্ষমতায়ন’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_037',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 2: ‘নারীর ক্ষমতায়ন’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_038',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 3: ‘নারীর ক্ষমতায়ন’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_039',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 4: ‘নারীর ক্ষমতায়ন’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_040',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 5: ‘নারীর ক্ষমতায়ন’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_041',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 1: ‘সামাজিক সম্প্রীতি’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_042',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 2: ‘সামাজিক সম্প্রীতি’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_043',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 3: ‘সামাজিক সম্প্রীতি’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_044',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 4: ‘সামাজিক সম্প্রীতি’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_045',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 5: ‘সামাজিক সম্প্রীতি’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_046',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 1: ‘শ্রমের মর্যাদা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_047',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 2: ‘শ্রমের মর্যাদা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_048',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 3: ‘শ্রমের মর্যাদা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_049',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 4: ‘শ্রমের মর্যাদা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_050',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 5: ‘শ্রমের মর্যাদা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_051',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 1: ‘স্বাস্থ্যকর জীবন’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_052',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 2: ‘স্বাস্থ্যকর জীবন’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_053',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 3: ‘স্বাস্থ্যকর জীবন’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_054',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 4: ‘স্বাস্থ্যকর জীবন’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_055',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 5: ‘স্বাস্থ্যকর জীবন’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_056',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 1: ‘বৃক্ষরোপণ’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_057',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 2: ‘বৃক্ষরোপণ’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_058',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 3: ‘বৃক্ষরোপণ’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_059',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 4: ‘বৃক্ষরোপণ’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_060',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 5: ‘বৃক্ষরোপণ’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_061',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 1: ‘মাতৃভাষার মর্যাদা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_062',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 2: ‘মাতৃভাষার মর্যাদা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_063',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 3: ‘মাতৃভাষার মর্যাদা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_064',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 4: ‘মাতৃভাষার মর্যাদা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_065',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 5: ‘মাতৃভাষার মর্যাদা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_066',
    type: Bangla2WrittenType.paragraph,
    prompt:
        'অনুশীলন 1: ‘মুক্তিযুদ্ধের চেতনা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_067',
    type: Bangla2WrittenType.paragraph,
    prompt:
        'অনুশীলন 2: ‘মুক্তিযুদ্ধের চেতনা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_068',
    type: Bangla2WrittenType.paragraph,
    prompt:
        'অনুশীলন 3: ‘মুক্তিযুদ্ধের চেতনা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_069',
    type: Bangla2WrittenType.paragraph,
    prompt:
        'অনুশীলন 4: ‘মুক্তিযুদ্ধের চেতনা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_070',
    type: Bangla2WrittenType.paragraph,
    prompt:
        'অনুশীলন 5: ‘মুক্তিযুদ্ধের চেতনা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_071',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 1: ‘দুর্নীতি প্রতিরোধ’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_072',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 2: ‘দুর্নীতি প্রতিরোধ’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_073',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 3: ‘দুর্নীতি প্রতিরোধ’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_074',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 4: ‘দুর্নীতি প্রতিরোধ’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_075',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 5: ‘দুর্নীতি প্রতিরোধ’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_076',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 1: ‘কিশোরদের নৈতিকতা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_077',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 2: ‘কিশোরদের নৈতিকতা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_078',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 3: ‘কিশোরদের নৈতিকতা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_079',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 4: ‘কিশোরদের নৈতিকতা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_080',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 5: ‘কিশোরদের নৈতিকতা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_081',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 1: ‘জনসেবায় স্বচ্ছতা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_082',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 2: ‘জনসেবায় স্বচ্ছতা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_083',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 3: ‘জনসেবায় স্বচ্ছতা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_084',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 4: ‘জনসেবায় স্বচ্ছতা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_085',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 5: ‘জনসেবায় স্বচ্ছতা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_086',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 1: ‘গ্রামীণ উন্নয়ন’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_087',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 2: ‘গ্রামীণ উন্নয়ন’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_088',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 3: ‘গ্রামীণ উন্নয়ন’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_089',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 4: ‘গ্রামীণ উন্নয়ন’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_090',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 5: ‘গ্রামীণ উন্নয়ন’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_091',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 1: ‘বিজ্ঞানমনস্কতা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_092',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 2: ‘বিজ্ঞানমনস্কতা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_093',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 3: ‘বিজ্ঞানমনস্কতা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_094',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 4: ‘বিজ্ঞানমনস্কতা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_095',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 5: ‘বিজ্ঞানমনস্কতা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_096',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 1: ‘স্বেচ্ছাসেবা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_097',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 2: ‘স্বেচ্ছাসেবা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_098',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 3: ‘স্বেচ্ছাসেবা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_099',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 4: ‘স্বেচ্ছাসেবা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_paragraph_100',
    type: Bangla2WrittenType.paragraph,
    prompt: 'অনুশীলন 5: ‘স্বেচ্ছাসেবা’ বিষয়ে একটি সুসংগঠিত অনুচ্ছেদ লেখ।',
    answerGuide:
        'একটি কেন্দ্রীয় ভাব, প্রাসঙ্গিক তথ্য, কারণ-প্রভাব, উদাহরণ ও সংক্ষিপ্ত উপসংহারসহ এক অনুচ্ছেদে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_001',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'সময়ানুবর্তিতা প্রসঙ্গে সম্পাদক বরাবর পত্র রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_002',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'সময়ানুবর্তিতা প্রসঙ্গে কর্তৃপক্ষের কাছে আবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_003',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'সময়ানুবর্তিতা প্রসঙ্গে বন্ধুকে ব্যক্তিগত চিঠি রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_004',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'সময়ানুবর্তিতা প্রসঙ্গে বিদ্যালয়ভিত্তিক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_005',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'সময়ানুবর্তিতা প্রসঙ্গে জনসচেতনতামূলক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_006',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'পরিবেশ সংরক্ষণ প্রসঙ্গে সম্পাদক বরাবর পত্র রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_007',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'পরিবেশ সংরক্ষণ প্রসঙ্গে কর্তৃপক্ষের কাছে আবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_008',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'পরিবেশ সংরক্ষণ প্রসঙ্গে বন্ধুকে ব্যক্তিগত চিঠি রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_009',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'পরিবেশ সংরক্ষণ প্রসঙ্গে বিদ্যালয়ভিত্তিক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_010',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'পরিবেশ সংরক্ষণ প্রসঙ্গে জনসচেতনতামূলক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_011',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'বই পড়ার অভ্যাস প্রসঙ্গে সম্পাদক বরাবর পত্র রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_012',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'বই পড়ার অভ্যাস প্রসঙ্গে কর্তৃপক্ষের কাছে আবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_013',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'বই পড়ার অভ্যাস প্রসঙ্গে বন্ধুকে ব্যক্তিগত চিঠি রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_014',
    type: Bangla2WrittenType.letterOrReport,
    prompt:
        'বই পড়ার অভ্যাস প্রসঙ্গে বিদ্যালয়ভিত্তিক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_015',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'বই পড়ার অভ্যাস প্রসঙ্গে জনসচেতনতামূলক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_016',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'ডিজিটাল নিরাপত্তা প্রসঙ্গে সম্পাদক বরাবর পত্র রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_017',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'ডিজিটাল নিরাপত্তা প্রসঙ্গে কর্তৃপক্ষের কাছে আবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_018',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'ডিজিটাল নিরাপত্তা প্রসঙ্গে বন্ধুকে ব্যক্তিগত চিঠি রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_019',
    type: Bangla2WrittenType.letterOrReport,
    prompt:
        'ডিজিটাল নিরাপত্তা প্রসঙ্গে বিদ্যালয়ভিত্তিক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_020',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'ডিজিটাল নিরাপত্তা প্রসঙ্গে জনসচেতনতামূলক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_021',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'শিক্ষায় প্রযুক্তি প্রসঙ্গে সম্পাদক বরাবর পত্র রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_022',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'শিক্ষায় প্রযুক্তি প্রসঙ্গে কর্তৃপক্ষের কাছে আবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_023',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'শিক্ষায় প্রযুক্তি প্রসঙ্গে বন্ধুকে ব্যক্তিগত চিঠি রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_024',
    type: Bangla2WrittenType.letterOrReport,
    prompt:
        'শিক্ষায় প্রযুক্তি প্রসঙ্গে বিদ্যালয়ভিত্তিক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_025',
    type: Bangla2WrittenType.letterOrReport,
    prompt:
        'শিক্ষায় প্রযুক্তি প্রসঙ্গে জনসচেতনতামূলক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_026',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'সড়ক নিরাপত্তা প্রসঙ্গে সম্পাদক বরাবর পত্র রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_027',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'সড়ক নিরাপত্তা প্রসঙ্গে কর্তৃপক্ষের কাছে আবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_028',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'সড়ক নিরাপত্তা প্রসঙ্গে বন্ধুকে ব্যক্তিগত চিঠি রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_029',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'সড়ক নিরাপত্তা প্রসঙ্গে বিদ্যালয়ভিত্তিক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_030',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'সড়ক নিরাপত্তা প্রসঙ্গে জনসচেতনতামূলক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_031',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'জলবায়ু পরিবর্তন প্রসঙ্গে সম্পাদক বরাবর পত্র রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_032',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'জলবায়ু পরিবর্তন প্রসঙ্গে কর্তৃপক্ষের কাছে আবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_033',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'জলবায়ু পরিবর্তন প্রসঙ্গে বন্ধুকে ব্যক্তিগত চিঠি রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_034',
    type: Bangla2WrittenType.letterOrReport,
    prompt:
        'জলবায়ু পরিবর্তন প্রসঙ্গে বিদ্যালয়ভিত্তিক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_035',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'জলবায়ু পরিবর্তন প্রসঙ্গে জনসচেতনতামূলক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_036',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'নারীর ক্ষমতায়ন প্রসঙ্গে সম্পাদক বরাবর পত্র রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_037',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'নারীর ক্ষমতায়ন প্রসঙ্গে কর্তৃপক্ষের কাছে আবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_038',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'নারীর ক্ষমতায়ন প্রসঙ্গে বন্ধুকে ব্যক্তিগত চিঠি রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_039',
    type: Bangla2WrittenType.letterOrReport,
    prompt:
        'নারীর ক্ষমতায়ন প্রসঙ্গে বিদ্যালয়ভিত্তিক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_040',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'নারীর ক্ষমতায়ন প্রসঙ্গে জনসচেতনতামূলক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_041',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'সামাজিক সম্প্রীতি প্রসঙ্গে সম্পাদক বরাবর পত্র রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_042',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'সামাজিক সম্প্রীতি প্রসঙ্গে কর্তৃপক্ষের কাছে আবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_043',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'সামাজিক সম্প্রীতি প্রসঙ্গে বন্ধুকে ব্যক্তিগত চিঠি রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_044',
    type: Bangla2WrittenType.letterOrReport,
    prompt:
        'সামাজিক সম্প্রীতি প্রসঙ্গে বিদ্যালয়ভিত্তিক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_045',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'সামাজিক সম্প্রীতি প্রসঙ্গে জনসচেতনতামূলক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_046',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'শ্রমের মর্যাদা প্রসঙ্গে সম্পাদক বরাবর পত্র রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_047',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'শ্রমের মর্যাদা প্রসঙ্গে কর্তৃপক্ষের কাছে আবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_048',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'শ্রমের মর্যাদা প্রসঙ্গে বন্ধুকে ব্যক্তিগত চিঠি রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_049',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'শ্রমের মর্যাদা প্রসঙ্গে বিদ্যালয়ভিত্তিক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_050',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'শ্রমের মর্যাদা প্রসঙ্গে জনসচেতনতামূলক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_051',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'স্বাস্থ্যকর জীবন প্রসঙ্গে সম্পাদক বরাবর পত্র রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_052',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'স্বাস্থ্যকর জীবন প্রসঙ্গে কর্তৃপক্ষের কাছে আবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_053',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'স্বাস্থ্যকর জীবন প্রসঙ্গে বন্ধুকে ব্যক্তিগত চিঠি রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_054',
    type: Bangla2WrittenType.letterOrReport,
    prompt:
        'স্বাস্থ্যকর জীবন প্রসঙ্গে বিদ্যালয়ভিত্তিক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_055',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'স্বাস্থ্যকর জীবন প্রসঙ্গে জনসচেতনতামূলক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_056',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'বৃক্ষরোপণ প্রসঙ্গে সম্পাদক বরাবর পত্র রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_057',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'বৃক্ষরোপণ প্রসঙ্গে কর্তৃপক্ষের কাছে আবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_058',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'বৃক্ষরোপণ প্রসঙ্গে বন্ধুকে ব্যক্তিগত চিঠি রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_059',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'বৃক্ষরোপণ প্রসঙ্গে বিদ্যালয়ভিত্তিক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_060',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'বৃক্ষরোপণ প্রসঙ্গে জনসচেতনতামূলক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_061',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'মাতৃভাষার মর্যাদা প্রসঙ্গে সম্পাদক বরাবর পত্র রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_062',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'মাতৃভাষার মর্যাদা প্রসঙ্গে কর্তৃপক্ষের কাছে আবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_063',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'মাতৃভাষার মর্যাদা প্রসঙ্গে বন্ধুকে ব্যক্তিগত চিঠি রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_064',
    type: Bangla2WrittenType.letterOrReport,
    prompt:
        'মাতৃভাষার মর্যাদা প্রসঙ্গে বিদ্যালয়ভিত্তিক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_065',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'মাতৃভাষার মর্যাদা প্রসঙ্গে জনসচেতনতামূলক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_066',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'মুক্তিযুদ্ধের চেতনা প্রসঙ্গে সম্পাদক বরাবর পত্র রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_067',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'মুক্তিযুদ্ধের চেতনা প্রসঙ্গে কর্তৃপক্ষের কাছে আবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_068',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'মুক্তিযুদ্ধের চেতনা প্রসঙ্গে বন্ধুকে ব্যক্তিগত চিঠি রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_069',
    type: Bangla2WrittenType.letterOrReport,
    prompt:
        'মুক্তিযুদ্ধের চেতনা প্রসঙ্গে বিদ্যালয়ভিত্তিক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_070',
    type: Bangla2WrittenType.letterOrReport,
    prompt:
        'মুক্তিযুদ্ধের চেতনা প্রসঙ্গে জনসচেতনতামূলক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_071',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'দুর্নীতি প্রতিরোধ প্রসঙ্গে সম্পাদক বরাবর পত্র রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_072',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'দুর্নীতি প্রতিরোধ প্রসঙ্গে কর্তৃপক্ষের কাছে আবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_073',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'দুর্নীতি প্রতিরোধ প্রসঙ্গে বন্ধুকে ব্যক্তিগত চিঠি রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_074',
    type: Bangla2WrittenType.letterOrReport,
    prompt:
        'দুর্নীতি প্রতিরোধ প্রসঙ্গে বিদ্যালয়ভিত্তিক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_075',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'দুর্নীতি প্রতিরোধ প্রসঙ্গে জনসচেতনতামূলক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_076',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'কিশোরদের নৈতিকতা প্রসঙ্গে সম্পাদক বরাবর পত্র রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_077',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'কিশোরদের নৈতিকতা প্রসঙ্গে কর্তৃপক্ষের কাছে আবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_078',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'কিশোরদের নৈতিকতা প্রসঙ্গে বন্ধুকে ব্যক্তিগত চিঠি রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_079',
    type: Bangla2WrittenType.letterOrReport,
    prompt:
        'কিশোরদের নৈতিকতা প্রসঙ্গে বিদ্যালয়ভিত্তিক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_080',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'কিশোরদের নৈতিকতা প্রসঙ্গে জনসচেতনতামূলক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_081',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'জনসেবায় স্বচ্ছতা প্রসঙ্গে সম্পাদক বরাবর পত্র রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_082',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'জনসেবায় স্বচ্ছতা প্রসঙ্গে কর্তৃপক্ষের কাছে আবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_083',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'জনসেবায় স্বচ্ছতা প্রসঙ্গে বন্ধুকে ব্যক্তিগত চিঠি রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_084',
    type: Bangla2WrittenType.letterOrReport,
    prompt:
        'জনসেবায় স্বচ্ছতা প্রসঙ্গে বিদ্যালয়ভিত্তিক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_085',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'জনসেবায় স্বচ্ছতা প্রসঙ্গে জনসচেতনতামূলক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_086',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'গ্রামীণ উন্নয়ন প্রসঙ্গে সম্পাদক বরাবর পত্র রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_087',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'গ্রামীণ উন্নয়ন প্রসঙ্গে কর্তৃপক্ষের কাছে আবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_088',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'গ্রামীণ উন্নয়ন প্রসঙ্গে বন্ধুকে ব্যক্তিগত চিঠি রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_089',
    type: Bangla2WrittenType.letterOrReport,
    prompt:
        'গ্রামীণ উন্নয়ন প্রসঙ্গে বিদ্যালয়ভিত্তিক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_090',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'গ্রামীণ উন্নয়ন প্রসঙ্গে জনসচেতনতামূলক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_091',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'বিজ্ঞানমনস্কতা প্রসঙ্গে সম্পাদক বরাবর পত্র রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_092',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'বিজ্ঞানমনস্কতা প্রসঙ্গে কর্তৃপক্ষের কাছে আবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_093',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'বিজ্ঞানমনস্কতা প্রসঙ্গে বন্ধুকে ব্যক্তিগত চিঠি রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_094',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'বিজ্ঞানমনস্কতা প্রসঙ্গে বিদ্যালয়ভিত্তিক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_095',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'বিজ্ঞানমনস্কতা প্রসঙ্গে জনসচেতনতামূলক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_096',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'স্বেচ্ছাসেবা প্রসঙ্গে সম্পাদক বরাবর পত্র রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_097',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'স্বেচ্ছাসেবা প্রসঙ্গে কর্তৃপক্ষের কাছে আবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_098',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'স্বেচ্ছাসেবা প্রসঙ্গে বন্ধুকে ব্যক্তিগত চিঠি রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_099',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'স্বেচ্ছাসেবা প্রসঙ্গে বিদ্যালয়ভিত্তিক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_letter_100',
    type: Bangla2WrittenType.letterOrReport,
    prompt: 'স্বেচ্ছাসেবা প্রসঙ্গে জনসচেতনতামূলক সংবাদ প্রতিবেদন রচনা কর।',
    answerGuide:
        'নির্বাচিত ধরন অনুযায়ী ঠিকানা/তারিখ/সম্বোধন বা শিরোনাম-স্থান-তারিখ-তথ্যক্রম বজায় রেখে প্রাসঙ্গিক ও শুদ্ধ ভাষায় লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_001',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'সময়ানুবর্তিতা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 1-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'সময়ানুবর্তিতা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_002',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'সময়ানুবর্তিতা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 2-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'সময়ানুবর্তিতা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_003',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'সময়ানুবর্তিতা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 3-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'সময়ানুবর্তিতা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_004',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'সময়ানুবর্তিতা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 4-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'সময়ানুবর্তিতা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_005',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'সময়ানুবর্তিতা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 5-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'সময়ানুবর্তিতা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_006',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'পরিবেশ সংরক্ষণ ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 1-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'পরিবেশ সংরক্ষণ-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_007',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'পরিবেশ সংরক্ষণ ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 2-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'পরিবেশ সংরক্ষণ-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_008',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'পরিবেশ সংরক্ষণ ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 3-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'পরিবেশ সংরক্ষণ-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_009',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'পরিবেশ সংরক্ষণ ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 4-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'পরিবেশ সংরক্ষণ-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_010',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'পরিবেশ সংরক্ষণ ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 5-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'পরিবেশ সংরক্ষণ-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_011',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'বই পড়ার অভ্যাস ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 1-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'বই পড়ার অভ্যাস-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_012',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'বই পড়ার অভ্যাস ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 2-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'বই পড়ার অভ্যাস-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_013',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'বই পড়ার অভ্যাস ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 3-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'বই পড়ার অভ্যাস-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_014',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'বই পড়ার অভ্যাস ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 4-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'বই পড়ার অভ্যাস-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_015',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'বই পড়ার অভ্যাস ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 5-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'বই পড়ার অভ্যাস-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_016',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'ডিজিটাল নিরাপত্তা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 1-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'ডিজিটাল নিরাপত্তা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_017',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'ডিজিটাল নিরাপত্তা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 2-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'ডিজিটাল নিরাপত্তা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_018',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'ডিজিটাল নিরাপত্তা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 3-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'ডিজিটাল নিরাপত্তা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_019',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'ডিজিটাল নিরাপত্তা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 4-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'ডিজিটাল নিরাপত্তা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_020',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'ডিজিটাল নিরাপত্তা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 5-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'ডিজিটাল নিরাপত্তা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_021',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'শিক্ষায় প্রযুক্তি ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 1-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'শিক্ষায় প্রযুক্তি-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_022',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'শিক্ষায় প্রযুক্তি ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 2-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'শিক্ষায় প্রযুক্তি-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_023',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'শিক্ষায় প্রযুক্তি ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 3-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'শিক্ষায় প্রযুক্তি-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_024',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'শিক্ষায় প্রযুক্তি ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 4-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'শিক্ষায় প্রযুক্তি-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_025',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'শিক্ষায় প্রযুক্তি ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 5-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'শিক্ষায় প্রযুক্তি-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_026',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'সড়ক নিরাপত্তা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 1-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'সড়ক নিরাপত্তা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_027',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'সড়ক নিরাপত্তা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 2-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'সড়ক নিরাপত্তা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_028',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'সড়ক নিরাপত্তা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 3-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'সড়ক নিরাপত্তা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_029',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'সড়ক নিরাপত্তা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 4-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'সড়ক নিরাপত্তা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_030',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'সড়ক নিরাপত্তা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 5-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'সড়ক নিরাপত্তা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_031',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'জলবায়ু পরিবর্তন ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 1-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'জলবায়ু পরিবর্তন-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_032',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'জলবায়ু পরিবর্তন ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 2-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'জলবায়ু পরিবর্তন-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_033',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'জলবায়ু পরিবর্তন ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 3-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'জলবায়ু পরিবর্তন-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_034',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'জলবায়ু পরিবর্তন ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 4-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'জলবায়ু পরিবর্তন-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_035',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'জলবায়ু পরিবর্তন ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 5-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'জলবায়ু পরিবর্তন-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_036',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'নারীর ক্ষমতায়ন ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 1-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'নারীর ক্ষমতায়ন-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_037',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'নারীর ক্ষমতায়ন ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 2-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'নারীর ক্ষমতায়ন-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_038',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'নারীর ক্ষমতায়ন ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 3-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'নারীর ক্ষমতায়ন-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_039',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'নারীর ক্ষমতায়ন ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 4-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'নারীর ক্ষমতায়ন-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_040',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'নারীর ক্ষমতায়ন ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 5-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'নারীর ক্ষমতায়ন-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_041',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'সামাজিক সম্প্রীতি ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 1-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'সামাজিক সম্প্রীতি-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_042',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'সামাজিক সম্প্রীতি ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 2-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'সামাজিক সম্প্রীতি-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_043',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'সামাজিক সম্প্রীতি ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 3-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'সামাজিক সম্প্রীতি-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_044',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'সামাজিক সম্প্রীতি ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 4-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'সামাজিক সম্প্রীতি-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_045',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'সামাজিক সম্প্রীতি ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 5-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'সামাজিক সম্প্রীতি-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_046',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'শ্রমের মর্যাদা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 1-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'শ্রমের মর্যাদা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_047',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'শ্রমের মর্যাদা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 2-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'শ্রমের মর্যাদা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_048',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'শ্রমের মর্যাদা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 3-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'শ্রমের মর্যাদা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_049',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'শ্রমের মর্যাদা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 4-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'শ্রমের মর্যাদা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_050',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'শ্রমের মর্যাদা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 5-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'শ্রমের মর্যাদা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_051',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'স্বাস্থ্যকর জীবন ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 1-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'স্বাস্থ্যকর জীবন-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_052',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'স্বাস্থ্যকর জীবন ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 2-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'স্বাস্থ্যকর জীবন-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_053',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'স্বাস্থ্যকর জীবন ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 3-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'স্বাস্থ্যকর জীবন-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_054',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'স্বাস্থ্যকর জীবন ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 4-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'স্বাস্থ্যকর জীবন-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_055',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'স্বাস্থ্যকর জীবন ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 5-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'স্বাস্থ্যকর জীবন-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_056',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'বৃক্ষরোপণ ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 1-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'বৃক্ষরোপণ-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_057',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'বৃক্ষরোপণ ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 2-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'বৃক্ষরোপণ-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_058',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'বৃক্ষরোপণ ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 3-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'বৃক্ষরোপণ-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_059',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'বৃক্ষরোপণ ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 4-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'বৃক্ষরোপণ-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_060',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'বৃক্ষরোপণ ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 5-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'বৃক্ষরোপণ-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_061',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'মাতৃভাষার মর্যাদা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 1-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'মাতৃভাষার মর্যাদা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_062',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'মাতৃভাষার মর্যাদা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 2-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'মাতৃভাষার মর্যাদা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_063',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'মাতৃভাষার মর্যাদা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 3-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'মাতৃভাষার মর্যাদা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_064',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'মাতৃভাষার মর্যাদা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 4-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'মাতৃভাষার মর্যাদা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_065',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'মাতৃভাষার মর্যাদা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 5-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'মাতৃভাষার মর্যাদা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_066',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'মুক্তিযুদ্ধের চেতনা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 1-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'মুক্তিযুদ্ধের চেতনা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_067',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'মুক্তিযুদ্ধের চেতনা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 2-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'মুক্তিযুদ্ধের চেতনা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_068',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'মুক্তিযুদ্ধের চেতনা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 3-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'মুক্তিযুদ্ধের চেতনা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_069',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'মুক্তিযুদ্ধের চেতনা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 4-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'মুক্তিযুদ্ধের চেতনা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_070',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'মুক্তিযুদ্ধের চেতনা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 5-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'মুক্তিযুদ্ধের চেতনা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_071',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'দুর্নীতি প্রতিরোধ ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 1-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'দুর্নীতি প্রতিরোধ-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_072',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'দুর্নীতি প্রতিরোধ ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 2-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'দুর্নীতি প্রতিরোধ-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_073',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'দুর্নীতি প্রতিরোধ ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 3-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'দুর্নীতি প্রতিরোধ-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_074',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'দুর্নীতি প্রতিরোধ ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 4-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'দুর্নীতি প্রতিরোধ-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_075',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'দুর্নীতি প্রতিরোধ ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 5-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'দুর্নীতি প্রতিরোধ-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_076',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'কিশোরদের নৈতিকতা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 1-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'কিশোরদের নৈতিকতা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_077',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'কিশোরদের নৈতিকতা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 2-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'কিশোরদের নৈতিকতা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_078',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'কিশোরদের নৈতিকতা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 3-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'কিশোরদের নৈতিকতা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_079',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'কিশোরদের নৈতিকতা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 4-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'কিশোরদের নৈতিকতা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_080',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'কিশোরদের নৈতিকতা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 5-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'কিশোরদের নৈতিকতা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_081',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'জনসেবায় স্বচ্ছতা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 1-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'জনসেবায় স্বচ্ছতা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_082',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'জনসেবায় স্বচ্ছতা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 2-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'জনসেবায় স্বচ্ছতা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_083',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'জনসেবায় স্বচ্ছতা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 3-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'জনসেবায় স্বচ্ছতা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_084',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'জনসেবায় স্বচ্ছতা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 4-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'জনসেবায় স্বচ্ছতা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_085',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'জনসেবায় স্বচ্ছতা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 5-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'জনসেবায় স্বচ্ছতা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_086',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'গ্রামীণ উন্নয়ন ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 1-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'গ্রামীণ উন্নয়ন-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_087',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'গ্রামীণ উন্নয়ন ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 2-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'গ্রামীণ উন্নয়ন-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_088',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'গ্রামীণ উন্নয়ন ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 3-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'গ্রামীণ উন্নয়ন-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_089',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'গ্রামীণ উন্নয়ন ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 4-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'গ্রামীণ উন্নয়ন-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_090',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'গ্রামীণ উন্নয়ন ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 5-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'গ্রামীণ উন্নয়ন-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_091',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'বিজ্ঞানমনস্কতা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 1-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'বিজ্ঞানমনস্কতা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_092',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'বিজ্ঞানমনস্কতা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 2-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'বিজ্ঞানমনস্কতা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_093',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'বিজ্ঞানমনস্কতা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 3-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'বিজ্ঞানমনস্কতা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_094',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'বিজ্ঞানমনস্কতা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 4-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'বিজ্ঞানমনস্কতা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_095',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'বিজ্ঞানমনস্কতা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 5-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'বিজ্ঞানমনস্কতা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_096',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'স্বেচ্ছাসেবা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 1-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'স্বেচ্ছাসেবা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_097',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'স্বেচ্ছাসেবা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 2-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'স্বেচ্ছাসেবা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_098',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'স্বেচ্ছাসেবা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 3-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'স্বেচ্ছাসেবা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_099',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'স্বেচ্ছাসেবা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 4-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'স্বেচ্ছাসেবা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_summary_100',
    type: Bangla2WrittenType.summaryOrGist,
    prompt: 'নিচের অনুচ্ছেদের সারাংশ অথবা সারমর্ম লেখ।',
    sourceText:
        'স্বেচ্ছাসেবা ব্যক্তি ও সমাজের অগ্রগতিতে গুরুত্বপূর্ণ। অনুশীলন 5-এর প্রেক্ষাপটে দেখা যায়, সচেতনতা ও নিয়মিত চর্চা ইতিবাচক পরিবর্তন আনে। সাময়িক অসুবিধা থাকলেও সম্মিলিত উদ্যোগ দীর্ঘমেয়াদে কল্যাণ নিশ্চিত করে।',
    answerGuide:
        'স্বেচ্ছাসেবা-এর গুরুত্ব, সচেতন চর্চা ও সম্মিলিত উদ্যোগের ফল অপ্রয়োজনীয় উদাহরণ ছাড়া সংক্ষেপে লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_001',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt:
        'অনুশীলন 1: ভাব-সম্প্রসারণ কর—‘সময় ও স্রোত কারও জন্য অপেক্ষা করে না’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_002',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt:
        'অনুশীলন 2: ভাব-সম্প্রসারণ কর—‘সময় ও স্রোত কারও জন্য অপেক্ষা করে না’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_003',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt:
        'অনুশীলন 3: ভাব-সম্প্রসারণ কর—‘সময় ও স্রোত কারও জন্য অপেক্ষা করে না’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_004',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt:
        'অনুশীলন 4: ভাব-সম্প্রসারণ কর—‘সময় ও স্রোত কারও জন্য অপেক্ষা করে না’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_005',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt:
        'অনুশীলন 5: ভাব-সম্প্রসারণ কর—‘সময় ও স্রোত কারও জন্য অপেক্ষা করে না’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_006',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 1: ভাব-সম্প্রসারণ কর—‘শ্রমই সৌভাগ্যের প্রসূতি’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_007',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 2: ভাব-সম্প্রসারণ কর—‘শ্রমই সৌভাগ্যের প্রসূতি’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_008',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 3: ভাব-সম্প্রসারণ কর—‘শ্রমই সৌভাগ্যের প্রসূতি’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_009',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 4: ভাব-সম্প্রসারণ কর—‘শ্রমই সৌভাগ্যের প্রসূতি’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_010',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 5: ভাব-সম্প্রসারণ কর—‘শ্রমই সৌভাগ্যের প্রসূতি’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_011',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 1: ভাব-সম্প্রসারণ কর—‘একতাই বল’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_012',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 2: ভাব-সম্প্রসারণ কর—‘একতাই বল’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_013',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 3: ভাব-সম্প্রসারণ কর—‘একতাই বল’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_014',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 4: ভাব-সম্প্রসারণ কর—‘একতাই বল’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_015',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 5: ভাব-সম্প্রসারণ কর—‘একতাই বল’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_016',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 1: ভাব-সম্প্রসারণ কর—‘জ্ঞানই শক্তি’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_017',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 2: ভাব-সম্প্রসারণ কর—‘জ্ঞানই শক্তি’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_018',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 3: ভাব-সম্প্রসারণ কর—‘জ্ঞানই শক্তি’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_019',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 4: ভাব-সম্প্রসারণ কর—‘জ্ঞানই শক্তি’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_020',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 5: ভাব-সম্প্রসারণ কর—‘জ্ঞানই শক্তি’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_021',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 1: ভাব-সম্প্রসারণ কর—‘স্বাস্থ্যই সম্পদ’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_022',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 2: ভাব-সম্প্রসারণ কর—‘স্বাস্থ্যই সম্পদ’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_023',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 3: ভাব-সম্প্রসারণ কর—‘স্বাস্থ্যই সম্পদ’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_024',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 4: ভাব-সম্প্রসারণ কর—‘স্বাস্থ্যই সম্পদ’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_025',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 5: ভাব-সম্প্রসারণ কর—‘স্বাস্থ্যই সম্পদ’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_026',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 1: ভাব-সম্প্রসারণ কর—‘সততাই সর্বোৎকৃষ্ট পন্থা’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_027',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 2: ভাব-সম্প্রসারণ কর—‘সততাই সর্বোৎকৃষ্ট পন্থা’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_028',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 3: ভাব-সম্প্রসারণ কর—‘সততাই সর্বোৎকৃষ্ট পন্থা’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_029',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 4: ভাব-সম্প্রসারণ কর—‘সততাই সর্বোৎকৃষ্ট পন্থা’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_030',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 5: ভাব-সম্প্রসারণ কর—‘সততাই সর্বোৎকৃষ্ট পন্থা’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_031',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 1: ভাব-সম্প্রসারণ কর—‘মানুষ মানুষের জন্য’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_032',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 2: ভাব-সম্প্রসারণ কর—‘মানুষ মানুষের জন্য’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_033',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 3: ভাব-সম্প্রসারণ কর—‘মানুষ মানুষের জন্য’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_034',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 4: ভাব-সম্প্রসারণ কর—‘মানুষ মানুষের জন্য’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_035',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 5: ভাব-সম্প্রসারণ কর—‘মানুষ মানুষের জন্য’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_036',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 1: ভাব-সম্প্রসারণ কর—‘ইচ্ছা থাকলে উপায় হয়’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_037',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 2: ভাব-সম্প্রসারণ কর—‘ইচ্ছা থাকলে উপায় হয়’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_038',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 3: ভাব-সম্প্রসারণ কর—‘ইচ্ছা থাকলে উপায় হয়’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_039',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 4: ভাব-সম্প্রসারণ কর—‘ইচ্ছা থাকলে উপায় হয়’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_040',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 5: ভাব-সম্প্রসারণ কর—‘ইচ্ছা থাকলে উপায় হয়’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_041',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 1: ভাব-সম্প্রসারণ কর—‘অল্প বিদ্যা ভয়ংকরী’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_042',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 2: ভাব-সম্প্রসারণ কর—‘অল্প বিদ্যা ভয়ংকরী’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_043',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 3: ভাব-সম্প্রসারণ কর—‘অল্প বিদ্যা ভয়ংকরী’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_044',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 4: ভাব-সম্প্রসারণ কর—‘অল্প বিদ্যা ভয়ংকরী’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_045',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 5: ভাব-সম্প্রসারণ কর—‘অল্প বিদ্যা ভয়ংকরী’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_046',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 1: ভাব-সম্প্রসারণ কর—‘স্বদেশের উপকারে নেই যার মন’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_047',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 2: ভাব-সম্প্রসারণ কর—‘স্বদেশের উপকারে নেই যার মন’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_048',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 3: ভাব-সম্প্রসারণ কর—‘স্বদেশের উপকারে নেই যার মন’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_049',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 4: ভাব-সম্প্রসারণ কর—‘স্বদেশের উপকারে নেই যার মন’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_050',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 5: ভাব-সম্প্রসারণ কর—‘স্বদেশের উপকারে নেই যার মন’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_051',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 1: ভাব-সম্প্রসারণ কর—‘শিক্ষাই জাতির মেরুদণ্ড’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_052',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 2: ভাব-সম্প্রসারণ কর—‘শিক্ষাই জাতির মেরুদণ্ড’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_053',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 3: ভাব-সম্প্রসারণ কর—‘শিক্ষাই জাতির মেরুদণ্ড’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_054',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 4: ভাব-সম্প্রসারণ কর—‘শিক্ষাই জাতির মেরুদণ্ড’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_055',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 5: ভাব-সম্প্রসারণ কর—‘শিক্ষাই জাতির মেরুদণ্ড’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_056',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 1: ভাব-সম্প্রসারণ কর—‘পরের কারণে স্বার্থ দিয়া বলি’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_057',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 2: ভাব-সম্প্রসারণ কর—‘পরের কারণে স্বার্থ দিয়া বলি’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_058',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 3: ভাব-সম্প্রসারণ কর—‘পরের কারণে স্বার্থ দিয়া বলি’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_059',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 4: ভাব-সম্প্রসারণ কর—‘পরের কারণে স্বার্থ দিয়া বলি’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_060',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 5: ভাব-সম্প্রসারণ কর—‘পরের কারণে স্বার্থ দিয়া বলি’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_061',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 1: ভাব-সম্প্রসারণ কর—‘অন্যায় যে করে আর অন্যায় যে সহে’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_062',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 2: ভাব-সম্প্রসারণ কর—‘অন্যায় যে করে আর অন্যায় যে সহে’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_063',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 3: ভাব-সম্প্রসারণ কর—‘অন্যায় যে করে আর অন্যায় যে সহে’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_064',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 4: ভাব-সম্প্রসারণ কর—‘অন্যায় যে করে আর অন্যায় যে সহে’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_065',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 5: ভাব-সম্প্রসারণ কর—‘অন্যায় যে করে আর অন্যায় যে সহে’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_066',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 1: ভাব-সম্প্রসারণ কর—‘নদীর এপার কহে ছাড়িয়া নিশ্বাস’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_067',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 2: ভাব-সম্প্রসারণ কর—‘নদীর এপার কহে ছাড়িয়া নিশ্বাস’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_068',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 3: ভাব-সম্প্রসারণ কর—‘নদীর এপার কহে ছাড়িয়া নিশ্বাস’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_069',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 4: ভাব-সম্প্রসারণ কর—‘নদীর এপার কহে ছাড়িয়া নিশ্বাস’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_070',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 5: ভাব-সম্প্রসারণ কর—‘নদীর এপার কহে ছাড়িয়া নিশ্বাস’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_071',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 1: ভাব-সম্প্রসারণ কর—‘সবাই মিলে করি কাজ’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_072',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 2: ভাব-সম্প্রসারণ কর—‘সবাই মিলে করি কাজ’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_073',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 3: ভাব-সম্প্রসারণ কর—‘সবাই মিলে করি কাজ’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_074',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 4: ভাব-সম্প্রসারণ কর—‘সবাই মিলে করি কাজ’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_075',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 5: ভাব-সম্প্রসারণ কর—‘সবাই মিলে করি কাজ’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_076',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt:
        'অনুশীলন 1: ভাব-সম্প্রসারণ কর—‘বিপদে মোরে রক্ষা করো এ নহে মোর প্রার্থনা’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_077',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt:
        'অনুশীলন 2: ভাব-সম্প্রসারণ কর—‘বিপদে মোরে রক্ষা করো এ নহে মোর প্রার্থনা’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_078',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt:
        'অনুশীলন 3: ভাব-সম্প্রসারণ কর—‘বিপদে মোরে রক্ষা করো এ নহে মোর প্রার্থনা’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_079',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt:
        'অনুশীলন 4: ভাব-সম্প্রসারণ কর—‘বিপদে মোরে রক্ষা করো এ নহে মোর প্রার্থনা’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_080',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt:
        'অনুশীলন 5: ভাব-সম্প্রসারণ কর—‘বিপদে মোরে রক্ষা করো এ নহে মোর প্রার্থনা’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_081',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt:
        'অনুশীলন 1: ভাব-সম্প্রসারণ কর—‘যেখানে দেখিবে ছাই উড়াইয়া দেখ তাই’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_082',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt:
        'অনুশীলন 2: ভাব-সম্প্রসারণ কর—‘যেখানে দেখিবে ছাই উড়াইয়া দেখ তাই’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_083',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt:
        'অনুশীলন 3: ভাব-সম্প্রসারণ কর—‘যেখানে দেখিবে ছাই উড়াইয়া দেখ তাই’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_084',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt:
        'অনুশীলন 4: ভাব-সম্প্রসারণ কর—‘যেখানে দেখিবে ছাই উড়াইয়া দেখ তাই’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_085',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt:
        'অনুশীলন 5: ভাব-সম্প্রসারণ কর—‘যেখানে দেখিবে ছাই উড়াইয়া দেখ তাই’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_086',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 1: ভাব-সম্প্রসারণ কর—‘সবার উপরে মানুষ সত্য’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_087',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 2: ভাব-সম্প্রসারণ কর—‘সবার উপরে মানুষ সত্য’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_088',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 3: ভাব-সম্প্রসারণ কর—‘সবার উপরে মানুষ সত্য’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_089',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 4: ভাব-সম্প্রসারণ কর—‘সবার উপরে মানুষ সত্য’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_090',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 5: ভাব-সম্প্রসারণ কর—‘সবার উপরে মানুষ সত্য’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_091',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 1: ভাব-সম্প্রসারণ কর—‘কীর্তিমানের মৃত্যু নেই’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_092',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 2: ভাব-সম্প্রসারণ কর—‘কীর্তিমানের মৃত্যু নেই’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_093',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 3: ভাব-সম্প্রসারণ কর—‘কীর্তিমানের মৃত্যু নেই’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_094',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 4: ভাব-সম্প্রসারণ কর—‘কীর্তিমানের মৃত্যু নেই’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_095',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 5: ভাব-সম্প্রসারণ কর—‘কীর্তিমানের মৃত্যু নেই’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_096',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 1: ভাব-সম্প্রসারণ কর—‘আজকের কাজ আজই করো’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_097',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 2: ভাব-সম্প্রসারণ কর—‘আজকের কাজ আজই করো’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_098',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 3: ভাব-সম্প্রসারণ কর—‘আজকের কাজ আজই করো’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_099',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 4: ভাব-সম্প্রসারণ কর—‘আজকের কাজ আজই করো’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_thought_100',
    type: Bangla2WrittenType.thoughtExpansion,
    prompt: 'অনুশীলন 5: ভাব-সম্প্রসারণ কর—‘আজকের কাজ আজই করো’।',
    answerGuide:
        'মূলভাব ব্যাখ্যা, যুক্তি, জীবনঘনিষ্ঠ উদাহরণ, বিপরীত অবস্থার ক্ষতি এবং তাৎপর্যপূর্ণ মন্তব্যসহ লিখতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_001',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Punctuality is important for a responsible society. In practice set 1, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_002',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Punctuality is important for a responsible society. In practice set 2, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_003',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Punctuality is important for a responsible society. In practice set 3, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_004',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Punctuality is important for a responsible society. In practice set 4, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_005',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Punctuality is important for a responsible society. In practice set 5, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_006',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Environmental protection is important for a responsible society. In practice set 1, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_007',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Environmental protection is important for a responsible society. In practice set 2, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_008',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Environmental protection is important for a responsible society. In practice set 3, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_009',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Environmental protection is important for a responsible society. In practice set 4, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_010',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Environmental protection is important for a responsible society. In practice set 5, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_011',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Reading habit is important for a responsible society. In practice set 1, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_012',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Reading habit is important for a responsible society. In practice set 2, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_013',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Reading habit is important for a responsible society. In practice set 3, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_014',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Reading habit is important for a responsible society. In practice set 4, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_015',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Reading habit is important for a responsible society. In practice set 5, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_016',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Digital safety is important for a responsible society. In practice set 1, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_017',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Digital safety is important for a responsible society. In practice set 2, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_018',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Digital safety is important for a responsible society. In practice set 3, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_019',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Digital safety is important for a responsible society. In practice set 4, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_020',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Digital safety is important for a responsible society. In practice set 5, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_021',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Technology in education is important for a responsible society. In practice set 1, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_022',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Technology in education is important for a responsible society. In practice set 2, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_023',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Technology in education is important for a responsible society. In practice set 3, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_024',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Technology in education is important for a responsible society. In practice set 4, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_025',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Technology in education is important for a responsible society. In practice set 5, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_026',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Road safety is important for a responsible society. In practice set 1, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_027',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Road safety is important for a responsible society. In practice set 2, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_028',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Road safety is important for a responsible society. In practice set 3, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_029',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Road safety is important for a responsible society. In practice set 4, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_030',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Road safety is important for a responsible society. In practice set 5, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_031',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Climate action is important for a responsible society. In practice set 1, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_032',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Climate action is important for a responsible society. In practice set 2, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_033',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Climate action is important for a responsible society. In practice set 3, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_034',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Climate action is important for a responsible society. In practice set 4, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_035',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Climate action is important for a responsible society. In practice set 5, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_036',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Women empowerment is important for a responsible society. In practice set 1, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_037',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Women empowerment is important for a responsible society. In practice set 2, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_038',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Women empowerment is important for a responsible society. In practice set 3, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_039',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Women empowerment is important for a responsible society. In practice set 4, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_040',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Women empowerment is important for a responsible society. In practice set 5, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_041',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Social harmony is important for a responsible society. In practice set 1, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_042',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Social harmony is important for a responsible society. In practice set 2, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_043',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Social harmony is important for a responsible society. In practice set 3, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_044',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Social harmony is important for a responsible society. In practice set 4, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_045',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Social harmony is important for a responsible society. In practice set 5, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_046',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Dignity of labour is important for a responsible society. In practice set 1, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_047',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Dignity of labour is important for a responsible society. In practice set 2, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_048',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Dignity of labour is important for a responsible society. In practice set 3, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_049',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Dignity of labour is important for a responsible society. In practice set 4, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_050',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Dignity of labour is important for a responsible society. In practice set 5, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_051',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Healthy living is important for a responsible society. In practice set 1, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_052',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Healthy living is important for a responsible society. In practice set 2, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_053',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Healthy living is important for a responsible society. In practice set 3, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_054',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Healthy living is important for a responsible society. In practice set 4, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_055',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Healthy living is important for a responsible society. In practice set 5, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_056',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Tree plantation is important for a responsible society. In practice set 1, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_057',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Tree plantation is important for a responsible society. In practice set 2, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_058',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Tree plantation is important for a responsible society. In practice set 3, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_059',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Tree plantation is important for a responsible society. In practice set 4, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_060',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Tree plantation is important for a responsible society. In practice set 5, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_061',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Respect for the mother tongue is important for a responsible society. In practice set 1, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_062',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Respect for the mother tongue is important for a responsible society. In practice set 2, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_063',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Respect for the mother tongue is important for a responsible society. In practice set 3, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_064',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Respect for the mother tongue is important for a responsible society. In practice set 4, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_065',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Respect for the mother tongue is important for a responsible society. In practice set 5, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_066',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Spirit of the liberation war is important for a responsible society. In practice set 1, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_067',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Spirit of the liberation war is important for a responsible society. In practice set 2, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_068',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Spirit of the liberation war is important for a responsible society. In practice set 3, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_069',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Spirit of the liberation war is important for a responsible society. In practice set 4, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_070',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Spirit of the liberation war is important for a responsible society. In practice set 5, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_071',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Prevention of corruption is important for a responsible society. In practice set 1, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_072',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Prevention of corruption is important for a responsible society. In practice set 2, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_073',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Prevention of corruption is important for a responsible society. In practice set 3, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_074',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Prevention of corruption is important for a responsible society. In practice set 4, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_075',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Prevention of corruption is important for a responsible society. In practice set 5, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_076',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Moral growth of teenagers is important for a responsible society. In practice set 1, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_077',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Moral growth of teenagers is important for a responsible society. In practice set 2, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_078',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Moral growth of teenagers is important for a responsible society. In practice set 3, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_079',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Moral growth of teenagers is important for a responsible society. In practice set 4, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_080',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Moral growth of teenagers is important for a responsible society. In practice set 5, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_081',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Transparency in public service is important for a responsible society. In practice set 1, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_082',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Transparency in public service is important for a responsible society. In practice set 2, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_083',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Transparency in public service is important for a responsible society. In practice set 3, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_084',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Transparency in public service is important for a responsible society. In practice set 4, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_085',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Transparency in public service is important for a responsible society. In practice set 5, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_086',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Rural development is important for a responsible society. In practice set 1, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_087',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Rural development is important for a responsible society. In practice set 2, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_088',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Rural development is important for a responsible society. In practice set 3, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_089',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Rural development is important for a responsible society. In practice set 4, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_090',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Rural development is important for a responsible society. In practice set 5, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_091',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Scientific attitude is important for a responsible society. In practice set 1, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_092',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Scientific attitude is important for a responsible society. In practice set 2, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_093',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Scientific attitude is important for a responsible society. In practice set 3, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_094',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Scientific attitude is important for a responsible society. In practice set 4, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_095',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Scientific attitude is important for a responsible society. In practice set 5, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_096',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Voluntary service is important for a responsible society. In practice set 1, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_097',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Voluntary service is important for a responsible society. In practice set 2, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_098',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Voluntary service is important for a responsible society. In practice set 3, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_099',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Voluntary service is important for a responsible society. In practice set 4, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_translation_100',
    type: Bangla2WrittenType.translation,
    prompt: 'নিচের ইংরেজি অংশটি প্রাঞ্জল বাংলায় অনুবাদ কর।',
    sourceText:
        'Voluntary service is important for a responsible society. In practice set 5, students learn that awareness, regular action and cooperation can create lasting positive change.',
    answerGuide:
        'মূল অর্থ, কাল, বাক্যসম্পর্ক ও স্বাভাবিক বাংলা প্রকাশ বজায় রেখে আক্ষরিকতার পরিবর্তে প্রাঞ্জল অনুবাদ করতে হবে।',
    marks: 10,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_001',
    type: Bangla2WrittenType.composition,
    prompt:
        'সময়ানুবর্তিতা: গুরুত্ব ও প্রয়োজনীয়তা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_002',
    type: Bangla2WrittenType.composition,
    prompt:
        'সময়ানুবর্তিতা: বর্তমান অবস্থা ও চ্যালেঞ্জ—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_003',
    type: Bangla2WrittenType.composition,
    prompt: 'সময়ানুবর্তিতা: ব্যক্তিজীবনে ভূমিকা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_004',
    type: Bangla2WrittenType.composition,
    prompt:
        'সময়ানুবর্তিতা: জাতীয় উন্নয়নে অবদান—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_005',
    type: Bangla2WrittenType.composition,
    prompt:
        'সময়ানুবর্তিতা: করণীয় ও ভবিষ্যৎ পরিকল্পনা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_006',
    type: Bangla2WrittenType.composition,
    prompt:
        'পরিবেশ সংরক্ষণ: গুরুত্ব ও প্রয়োজনীয়তা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_007',
    type: Bangla2WrittenType.composition,
    prompt:
        'পরিবেশ সংরক্ষণ: বর্তমান অবস্থা ও চ্যালেঞ্জ—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_008',
    type: Bangla2WrittenType.composition,
    prompt: 'পরিবেশ সংরক্ষণ: ব্যক্তিজীবনে ভূমিকা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_009',
    type: Bangla2WrittenType.composition,
    prompt:
        'পরিবেশ সংরক্ষণ: জাতীয় উন্নয়নে অবদান—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_010',
    type: Bangla2WrittenType.composition,
    prompt:
        'পরিবেশ সংরক্ষণ: করণীয় ও ভবিষ্যৎ পরিকল্পনা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_011',
    type: Bangla2WrittenType.composition,
    prompt:
        'বই পড়ার অভ্যাস: গুরুত্ব ও প্রয়োজনীয়তা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_012',
    type: Bangla2WrittenType.composition,
    prompt:
        'বই পড়ার অভ্যাস: বর্তমান অবস্থা ও চ্যালেঞ্জ—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_013',
    type: Bangla2WrittenType.composition,
    prompt: 'বই পড়ার অভ্যাস: ব্যক্তিজীবনে ভূমিকা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_014',
    type: Bangla2WrittenType.composition,
    prompt:
        'বই পড়ার অভ্যাস: জাতীয় উন্নয়নে অবদান—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_015',
    type: Bangla2WrittenType.composition,
    prompt:
        'বই পড়ার অভ্যাস: করণীয় ও ভবিষ্যৎ পরিকল্পনা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_016',
    type: Bangla2WrittenType.composition,
    prompt:
        'ডিজিটাল নিরাপত্তা: গুরুত্ব ও প্রয়োজনীয়তা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_017',
    type: Bangla2WrittenType.composition,
    prompt:
        'ডিজিটাল নিরাপত্তা: বর্তমান অবস্থা ও চ্যালেঞ্জ—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_018',
    type: Bangla2WrittenType.composition,
    prompt:
        'ডিজিটাল নিরাপত্তা: ব্যক্তিজীবনে ভূমিকা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_019',
    type: Bangla2WrittenType.composition,
    prompt:
        'ডিজিটাল নিরাপত্তা: জাতীয় উন্নয়নে অবদান—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_020',
    type: Bangla2WrittenType.composition,
    prompt:
        'ডিজিটাল নিরাপত্তা: করণীয় ও ভবিষ্যৎ পরিকল্পনা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_021',
    type: Bangla2WrittenType.composition,
    prompt:
        'শিক্ষায় প্রযুক্তি: গুরুত্ব ও প্রয়োজনীয়তা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_022',
    type: Bangla2WrittenType.composition,
    prompt:
        'শিক্ষায় প্রযুক্তি: বর্তমান অবস্থা ও চ্যালেঞ্জ—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_023',
    type: Bangla2WrittenType.composition,
    prompt:
        'শিক্ষায় প্রযুক্তি: ব্যক্তিজীবনে ভূমিকা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_024',
    type: Bangla2WrittenType.composition,
    prompt:
        'শিক্ষায় প্রযুক্তি: জাতীয় উন্নয়নে অবদান—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_025',
    type: Bangla2WrittenType.composition,
    prompt:
        'শিক্ষায় প্রযুক্তি: করণীয় ও ভবিষ্যৎ পরিকল্পনা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_026',
    type: Bangla2WrittenType.composition,
    prompt:
        'সড়ক নিরাপত্তা: গুরুত্ব ও প্রয়োজনীয়তা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_027',
    type: Bangla2WrittenType.composition,
    prompt:
        'সড়ক নিরাপত্তা: বর্তমান অবস্থা ও চ্যালেঞ্জ—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_028',
    type: Bangla2WrittenType.composition,
    prompt: 'সড়ক নিরাপত্তা: ব্যক্তিজীবনে ভূমিকা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_029',
    type: Bangla2WrittenType.composition,
    prompt:
        'সড়ক নিরাপত্তা: জাতীয় উন্নয়নে অবদান—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_030',
    type: Bangla2WrittenType.composition,
    prompt:
        'সড়ক নিরাপত্তা: করণীয় ও ভবিষ্যৎ পরিকল্পনা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_031',
    type: Bangla2WrittenType.composition,
    prompt:
        'জলবায়ু পরিবর্তন: গুরুত্ব ও প্রয়োজনীয়তা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_032',
    type: Bangla2WrittenType.composition,
    prompt:
        'জলবায়ু পরিবর্তন: বর্তমান অবস্থা ও চ্যালেঞ্জ—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_033',
    type: Bangla2WrittenType.composition,
    prompt:
        'জলবায়ু পরিবর্তন: ব্যক্তিজীবনে ভূমিকা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_034',
    type: Bangla2WrittenType.composition,
    prompt:
        'জলবায়ু পরিবর্তন: জাতীয় উন্নয়নে অবদান—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_035',
    type: Bangla2WrittenType.composition,
    prompt:
        'জলবায়ু পরিবর্তন: করণীয় ও ভবিষ্যৎ পরিকল্পনা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_036',
    type: Bangla2WrittenType.composition,
    prompt:
        'নারীর ক্ষমতায়ন: গুরুত্ব ও প্রয়োজনীয়তা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_037',
    type: Bangla2WrittenType.composition,
    prompt:
        'নারীর ক্ষমতায়ন: বর্তমান অবস্থা ও চ্যালেঞ্জ—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_038',
    type: Bangla2WrittenType.composition,
    prompt: 'নারীর ক্ষমতায়ন: ব্যক্তিজীবনে ভূমিকা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_039',
    type: Bangla2WrittenType.composition,
    prompt:
        'নারীর ক্ষমতায়ন: জাতীয় উন্নয়নে অবদান—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_040',
    type: Bangla2WrittenType.composition,
    prompt:
        'নারীর ক্ষমতায়ন: করণীয় ও ভবিষ্যৎ পরিকল্পনা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_041',
    type: Bangla2WrittenType.composition,
    prompt:
        'সামাজিক সম্প্রীতি: গুরুত্ব ও প্রয়োজনীয়তা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_042',
    type: Bangla2WrittenType.composition,
    prompt:
        'সামাজিক সম্প্রীতি: বর্তমান অবস্থা ও চ্যালেঞ্জ—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_043',
    type: Bangla2WrittenType.composition,
    prompt:
        'সামাজিক সম্প্রীতি: ব্যক্তিজীবনে ভূমিকা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_044',
    type: Bangla2WrittenType.composition,
    prompt:
        'সামাজিক সম্প্রীতি: জাতীয় উন্নয়নে অবদান—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_045',
    type: Bangla2WrittenType.composition,
    prompt:
        'সামাজিক সম্প্রীতি: করণীয় ও ভবিষ্যৎ পরিকল্পনা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_046',
    type: Bangla2WrittenType.composition,
    prompt:
        'শ্রমের মর্যাদা: গুরুত্ব ও প্রয়োজনীয়তা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_047',
    type: Bangla2WrittenType.composition,
    prompt:
        'শ্রমের মর্যাদা: বর্তমান অবস্থা ও চ্যালেঞ্জ—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_048',
    type: Bangla2WrittenType.composition,
    prompt: 'শ্রমের মর্যাদা: ব্যক্তিজীবনে ভূমিকা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_049',
    type: Bangla2WrittenType.composition,
    prompt:
        'শ্রমের মর্যাদা: জাতীয় উন্নয়নে অবদান—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_050',
    type: Bangla2WrittenType.composition,
    prompt:
        'শ্রমের মর্যাদা: করণীয় ও ভবিষ্যৎ পরিকল্পনা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_051',
    type: Bangla2WrittenType.composition,
    prompt:
        'স্বাস্থ্যকর জীবন: গুরুত্ব ও প্রয়োজনীয়তা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_052',
    type: Bangla2WrittenType.composition,
    prompt:
        'স্বাস্থ্যকর জীবন: বর্তমান অবস্থা ও চ্যালেঞ্জ—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_053',
    type: Bangla2WrittenType.composition,
    prompt:
        'স্বাস্থ্যকর জীবন: ব্যক্তিজীবনে ভূমিকা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_054',
    type: Bangla2WrittenType.composition,
    prompt:
        'স্বাস্থ্যকর জীবন: জাতীয় উন্নয়নে অবদান—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_055',
    type: Bangla2WrittenType.composition,
    prompt:
        'স্বাস্থ্যকর জীবন: করণীয় ও ভবিষ্যৎ পরিকল্পনা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_056',
    type: Bangla2WrittenType.composition,
    prompt: 'বৃক্ষরোপণ: গুরুত্ব ও প্রয়োজনীয়তা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_057',
    type: Bangla2WrittenType.composition,
    prompt:
        'বৃক্ষরোপণ: বর্তমান অবস্থা ও চ্যালেঞ্জ—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_058',
    type: Bangla2WrittenType.composition,
    prompt: 'বৃক্ষরোপণ: ব্যক্তিজীবনে ভূমিকা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_059',
    type: Bangla2WrittenType.composition,
    prompt: 'বৃক্ষরোপণ: জাতীয় উন্নয়নে অবদান—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_060',
    type: Bangla2WrittenType.composition,
    prompt:
        'বৃক্ষরোপণ: করণীয় ও ভবিষ্যৎ পরিকল্পনা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_061',
    type: Bangla2WrittenType.composition,
    prompt:
        'মাতৃভাষার মর্যাদা: গুরুত্ব ও প্রয়োজনীয়তা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_062',
    type: Bangla2WrittenType.composition,
    prompt:
        'মাতৃভাষার মর্যাদা: বর্তমান অবস্থা ও চ্যালেঞ্জ—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_063',
    type: Bangla2WrittenType.composition,
    prompt:
        'মাতৃভাষার মর্যাদা: ব্যক্তিজীবনে ভূমিকা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_064',
    type: Bangla2WrittenType.composition,
    prompt:
        'মাতৃভাষার মর্যাদা: জাতীয় উন্নয়নে অবদান—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_065',
    type: Bangla2WrittenType.composition,
    prompt:
        'মাতৃভাষার মর্যাদা: করণীয় ও ভবিষ্যৎ পরিকল্পনা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_066',
    type: Bangla2WrittenType.composition,
    prompt:
        'মুক্তিযুদ্ধের চেতনা: গুরুত্ব ও প্রয়োজনীয়তা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_067',
    type: Bangla2WrittenType.composition,
    prompt:
        'মুক্তিযুদ্ধের চেতনা: বর্তমান অবস্থা ও চ্যালেঞ্জ—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_068',
    type: Bangla2WrittenType.composition,
    prompt:
        'মুক্তিযুদ্ধের চেতনা: ব্যক্তিজীবনে ভূমিকা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_069',
    type: Bangla2WrittenType.composition,
    prompt:
        'মুক্তিযুদ্ধের চেতনা: জাতীয় উন্নয়নে অবদান—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_070',
    type: Bangla2WrittenType.composition,
    prompt:
        'মুক্তিযুদ্ধের চেতনা: করণীয় ও ভবিষ্যৎ পরিকল্পনা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_071',
    type: Bangla2WrittenType.composition,
    prompt:
        'দুর্নীতি প্রতিরোধ: গুরুত্ব ও প্রয়োজনীয়তা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_072',
    type: Bangla2WrittenType.composition,
    prompt:
        'দুর্নীতি প্রতিরোধ: বর্তমান অবস্থা ও চ্যালেঞ্জ—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_073',
    type: Bangla2WrittenType.composition,
    prompt:
        'দুর্নীতি প্রতিরোধ: ব্যক্তিজীবনে ভূমিকা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_074',
    type: Bangla2WrittenType.composition,
    prompt:
        'দুর্নীতি প্রতিরোধ: জাতীয় উন্নয়নে অবদান—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_075',
    type: Bangla2WrittenType.composition,
    prompt:
        'দুর্নীতি প্রতিরোধ: করণীয় ও ভবিষ্যৎ পরিকল্পনা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_076',
    type: Bangla2WrittenType.composition,
    prompt:
        'কিশোরদের নৈতিকতা: গুরুত্ব ও প্রয়োজনীয়তা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_077',
    type: Bangla2WrittenType.composition,
    prompt:
        'কিশোরদের নৈতিকতা: বর্তমান অবস্থা ও চ্যালেঞ্জ—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_078',
    type: Bangla2WrittenType.composition,
    prompt:
        'কিশোরদের নৈতিকতা: ব্যক্তিজীবনে ভূমিকা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_079',
    type: Bangla2WrittenType.composition,
    prompt:
        'কিশোরদের নৈতিকতা: জাতীয় উন্নয়নে অবদান—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_080',
    type: Bangla2WrittenType.composition,
    prompt:
        'কিশোরদের নৈতিকতা: করণীয় ও ভবিষ্যৎ পরিকল্পনা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_081',
    type: Bangla2WrittenType.composition,
    prompt:
        'জনসেবায় স্বচ্ছতা: গুরুত্ব ও প্রয়োজনীয়তা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_082',
    type: Bangla2WrittenType.composition,
    prompt:
        'জনসেবায় স্বচ্ছতা: বর্তমান অবস্থা ও চ্যালেঞ্জ—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_083',
    type: Bangla2WrittenType.composition,
    prompt:
        'জনসেবায় স্বচ্ছতা: ব্যক্তিজীবনে ভূমিকা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_084',
    type: Bangla2WrittenType.composition,
    prompt:
        'জনসেবায় স্বচ্ছতা: জাতীয় উন্নয়নে অবদান—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_085',
    type: Bangla2WrittenType.composition,
    prompt:
        'জনসেবায় স্বচ্ছতা: করণীয় ও ভবিষ্যৎ পরিকল্পনা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_086',
    type: Bangla2WrittenType.composition,
    prompt:
        'গ্রামীণ উন্নয়ন: গুরুত্ব ও প্রয়োজনীয়তা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_087',
    type: Bangla2WrittenType.composition,
    prompt:
        'গ্রামীণ উন্নয়ন: বর্তমান অবস্থা ও চ্যালেঞ্জ—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_088',
    type: Bangla2WrittenType.composition,
    prompt: 'গ্রামীণ উন্নয়ন: ব্যক্তিজীবনে ভূমিকা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_089',
    type: Bangla2WrittenType.composition,
    prompt:
        'গ্রামীণ উন্নয়ন: জাতীয় উন্নয়নে অবদান—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_090',
    type: Bangla2WrittenType.composition,
    prompt:
        'গ্রামীণ উন্নয়ন: করণীয় ও ভবিষ্যৎ পরিকল্পনা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_091',
    type: Bangla2WrittenType.composition,
    prompt:
        'বিজ্ঞানমনস্কতা: গুরুত্ব ও প্রয়োজনীয়তা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_092',
    type: Bangla2WrittenType.composition,
    prompt:
        'বিজ্ঞানমনস্কতা: বর্তমান অবস্থা ও চ্যালেঞ্জ—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_093',
    type: Bangla2WrittenType.composition,
    prompt: 'বিজ্ঞানমনস্কতা: ব্যক্তিজীবনে ভূমিকা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_094',
    type: Bangla2WrittenType.composition,
    prompt:
        'বিজ্ঞানমনস্কতা: জাতীয় উন্নয়নে অবদান—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_095',
    type: Bangla2WrittenType.composition,
    prompt:
        'বিজ্ঞানমনস্কতা: করণীয় ও ভবিষ্যৎ পরিকল্পনা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_096',
    type: Bangla2WrittenType.composition,
    prompt:
        'স্বেচ্ছাসেবা: গুরুত্ব ও প্রয়োজনীয়তা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_097',
    type: Bangla2WrittenType.composition,
    prompt:
        'স্বেচ্ছাসেবা: বর্তমান অবস্থা ও চ্যালেঞ্জ—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_098',
    type: Bangla2WrittenType.composition,
    prompt: 'স্বেচ্ছাসেবা: ব্যক্তিজীবনে ভূমিকা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_099',
    type: Bangla2WrittenType.composition,
    prompt: 'স্বেচ্ছাসেবা: জাতীয় উন্নয়নে অবদান—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
  Bangla2WrittenQuestion(
    id: 'bangla2nd_composition_100',
    type: Bangla2WrittenType.composition,
    prompt:
        'স্বেচ্ছাসেবা: করণীয় ও ভবিষ্যৎ পরিকল্পনা—বিষয়ে একটি প্রবন্ধ রচনা কর।',
    answerGuide:
        'ভূমিকা, বিষয়ের সংজ্ঞা ও প্রেক্ষাপট, বিশ্লেষণ, উদাহরণ, সমস্যা, করণীয় এবং সুসংগত উপসংহারসহ অনুচ্ছেদবিন্যাসে লিখতে হবে।',
    marks: 20,
    source: QuestionSource.original,
    sourceLabel: 'Original written practice',
  ),
];
