/// Authoritative SSC General Mathematics chapter order.
class GeneralMathChapterCatalog {
  GeneralMathChapterCatalog._();

  static const String subjectId = 'general_math';
  static const String displayName = 'গণিত';

  static const List<String> chapters = <String>[
    'অধ্যায় ১: বাস্তব সংখ্যা',
    'অধ্যায় ২: সেট ও ফাংশন',
    'অধ্যায় ৩: বীজগাণিতিক রাশি',
    'অধ্যায় ৪: সূচক ও লগারিদম',
    'অধ্যায় ৫: এক চলকবিশিষ্ট সমীকরণ',
    'অধ্যায় ৬: রেখা, কোণ ও ত্রিভুজ',
    'অধ্যায় ৭: ব্যবহারিক জ্যামিতি',
    'অধ্যায় ৮: বৃত্ত',
    'অধ্যায় ৯: ত্রিকোণমিতিক অনুপাত',
    'অধ্যায় ১০: দূরত্ব ও উচ্চতা',
    'অধ্যায় ১১: বীজগাণিতিক অনুপাত ও সমানুপাত',
    'অধ্যায় ১২: দুই চলকবিশিষ্ট সরল সহসমীকরণ',
    'অধ্যায় ১৩: সসীম ধারা',
    'অধ্যায় ১৪: অনুপাত, সদৃশতা ও প্রতিসমতা',
    'অধ্যায় ১৫: ক্ষেত্রফল সম্পর্কিত উপপাদ্য ও সম্পাদ্য',
    'অধ্যায় ১৬: পরিমিতি',
    'অধ্যায় ১৭: পরিসংখ্যান',
  ];

  static bool contains(String chapter) => chapters.contains(chapter.trim());
}
