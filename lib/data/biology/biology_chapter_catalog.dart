/// Authoritative SSC Biology textbook chapter catalog.
/// Bengali values are the only values exposed in app chapter UI/data.
class BiologyChapterCatalog {
  BiologyChapterCatalog._();

  static const String subjectId = 'biology';
  static const String displayName = 'জীববিজ্ঞান';

  static const List<String> chapters = <String>[
    'অধ্যায় ১: জীবন পাঠ',
    'অধ্যায় ২: জীবকোষ ও টিস্যু',
    'অধ্যায় ৩: কোষ বিভাজন',
    'অধ্যায় ৪: জীবনীশক্তি',
    'অধ্যায় ৫: খাদ্য, পুষ্টি এবং পরিপাক',
    'অধ্যায় ৬: জীবে পরিবহন',
    'অধ্যায় ৭: গ্যাসীয় বিনিময়',
    'অধ্যায় ৮: রেচন প্রক্রিয়া',
    'অধ্যায় ৯: দৃঢ়তা প্রদান ও চলন',
    'অধ্যায় ১০: সমন্বয়',
    'অধ্যায় ১১: জীবের প্রজনন',
    'অধ্যায় ১২: জীবের বংশগতি ও জৈব অভিব্যক্তি',
    'অধ্যায় ১৩: জীবের পরিবেশ',
    'অধ্যায় ১৪: জীবপ্রযুক্তি',
  ];

  /// Documentation only; never use these labels as Dart chapter values.
  static const List<String> englishDocumentationLabels = <String>[
    'Lessons on Life',
    'Living Cells and Tissues',
    'Cell Division',
    'Bioenergetics',
    'Food, Nutrition and Digestion',
    'Transport in Organisms',
    'Gaseous Exchange',
    'Excretory System',
    'Firmness and Locomotion',
    'Coordination',
    'Reproduction in Organisms',
    'Heredity and Evolution of Organisms',
    'Environment of Organisms',
    'Biotechnology',
  ];

  static bool contains(String chapter) => chapters.contains(chapter.trim());
}
