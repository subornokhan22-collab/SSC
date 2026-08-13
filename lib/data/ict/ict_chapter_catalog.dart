/// Authoritative SSC ICT MCQ-only chapter catalog.
class IctChapterCatalog {
  IctChapterCatalog._();

  static const String subjectId = 'ict';
  static const String displayName = 'তথ্য ও যোগাযোগ প্রযুক্তি';

  static const List<String> chapters = <String>[
    'অধ্যায় ১: তথ্য ও যোগাযোগ প্রযুক্তি ও আমাদের বাংলাদেশ',
    'অধ্যায় ২: কম্পিউটার রক্ষণাবেক্ষণ ও সাইবার নিরাপত্তা',
    'অধ্যায় ৩: ইন্টারনেট ও ওয়েব পরিচিতি',
    'অধ্যায় ৪: আমার লেখালেখি ও হিসাব',
    'অধ্যায় ৫: মাল্টিমিডিয়া ও গ্রাফিক্স',
    'অধ্যায় ৬: প্রোগ্রামিংয়ের মাধ্যমে সমস্যার সমাধান',
  ];

  static bool contains(String chapter) => chapters.contains(chapter.trim());
}
