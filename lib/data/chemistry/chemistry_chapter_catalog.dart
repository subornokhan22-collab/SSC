/// Official NCTB Class 9–10 Chemistry textbook chapter order.
///
/// Keep this list numeric and authoritative for chapter ribbons/dropdowns.
class ChemistryChapterCatalog {
  ChemistryChapterCatalog._();

  static const String subjectId = 'chemistry';
  static const String displayName = 'রসায়ন';

  static const List<String> chapters = <String>[
    'অধ্যায় ১: রসায়নের ধারণা',
    'অধ্যায় ২: পদার্থের অবস্থা',
    'অধ্যায় ৩: পদার্থের গঠন',
    'অধ্যায় ৪: পর্যায় সারণি',
    'অধ্যায় ৫: রাসায়নিক বন্ধন',
    'অধ্যায় ৬: মোলের ধারণা ও রাসায়নিক গণনা',
    'অধ্যায় ৭: রাসায়নিক বিক্রিয়া',
    'অধ্যায় ৮: রসায়ন ও শক্তি',
    'অধ্যায় ৯: এসিড-ক্ষারক সমতা',
    'অধ্যায় ১০: খনিজ সম্পদ: ধাতু-অধাতু',
    'অধ্যায় ১১: খনিজ সম্পদ: জীবাশ্ম',
    'অধ্যায় ১২: আমাদের জীবনে রসায়ন',
  ];

  static bool contains(String chapter) => chapters.contains(chapter.trim());
}
