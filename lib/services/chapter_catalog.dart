import '../data/bangla_1st/bangla_1st_catalog.dart';
import '../data/bangla_2nd/bangla_2nd_catalog.dart';
import '../data/biology/biology_chapter_catalog.dart';
import '../data/bgs/bgs_chapter_catalog.dart';
import '../data/chemistry/chemistry_chapter_catalog.dart';
import '../data/general_math/general_math_chapter_catalog.dart';
import '../data/extra_chapter_catalogs.dart';
import '../data/ict/ict_chapter_catalog.dart';

/// One source of truth for chapter ribbons/dropdowns.
/// Textbook order is numeric; combined/generated chapter labels stay hidden.
class ChapterCatalog {
  ChapterCatalog._();

  static const _bn = {
    '০': 0,
    '১': 1,
    '২': 2,
    '৩': 3,
    '৪': 4,
    '৫': 5,
    '৬': 6,
    '৭': 7,
    '৮': 8,
    '৯': 9,
  };

  /// Official Physics chapter sequence supplied from the current contents page.
  static const physics = <String>[
    'অধ্যায় ১: ভৌত রাশি এবং তাদের পরিমাপ',
    'অধ্যায় ২: গতি',
    'অধ্যায় ৩: বল',
    'অধ্যায় ৪: কাজ, ক্ষমতা ও শক্তি',
    'অধ্যায় ৫: পদার্থের অবস্থা ও চাপ',
    'অধ্যায় ৬: বস্তুর ওপর তাপের প্রভাব',
    'অধ্যায় ৭: তরঙ্গ ও শব্দ',
    'অধ্যায় ৮: আলোর প্রতিফলন',
    'অধ্যায় ৯: আলোর প্রতিসরণ',
    'অধ্যায় ১০: স্থির বিদ্যুৎ',
    'অধ্যায় ১১: চল বিদ্যুৎ',
    'অধ্যায় ১২: বিদ্যুতের চৌম্বক ক্রিয়া',
    'অধ্যায় ১৩: তেজস্ক্রিয়তা ও ইলেকট্রনিকস',
  ];

  static bool isSingleChapter(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return false;
    final lower = v.toLowerCase();
    if (v.contains(' ও ') ||
        v.contains('মিলিয়ে') ||
        lower.contains('mixed') ||
        lower.contains('board-style')) return false;
    return RegExp(
      r'(^|\s)(অধ্যায়|chapter)\s*[০-৯0-9]+',
      caseSensitive: false,
    ).hasMatch(v);
  }

  static int numberOf(String raw) {
    final hit = RegExp(
      r'(?:অধ্যায়|chapter)\s*([০-৯0-9]+)',
      caseSensitive: false,
    ).firstMatch(raw);
    if (hit == null) return 9999;
    var value = 0;
    for (final c in hit.group(1)!.split('')) {
      final digit = int.tryParse(c) ?? _bn[c];
      if (digit == null) return 9999;
      value = value * 10 + digit;
    }
    return value;
  }

  static List<String> ordered(Iterable<String> values, {String? subjectId}) {
    // Show each complete official catalog even before every chapter has questions.
    if (subjectId == 'physics') return List<String>.from(physics);
    if (subjectId == BanglaFirstCatalog.subjectId) {
      return List<String>.from(BanglaFirstCatalog.chapters);
    }
    if (subjectId == BanglaSecondCatalog.subjectId) {
      return List<String>.from(BanglaSecondCatalog.grammarChapters);
    }
    if (subjectId == ChemistryChapterCatalog.subjectId) {
      return List<String>.from(ChemistryChapterCatalog.chapters);
    }
    if (subjectId == BiologyChapterCatalog.subjectId) {
      return List<String>.from(BiologyChapterCatalog.chapters);
    }
    if (subjectId == BgsChapterCatalog.subjectId) {
      return List<String>.from(BgsChapterCatalog.chapters);
    }
    if (subjectId == GeneralMathChapterCatalog.subjectId) {
      return List<String>.from(GeneralMathChapterCatalog.chapters);
    }
    if (subjectId == IctChapterCatalog.subjectId) {
      return List<String>.from(IctChapterCatalog.chapters);
    }
    // Subjects that have no bank yet still need their chapters listed, so a
    // tutor can file new questions without typing Bengali names by hand.
    if (subjectId != null) {
      final extra = ExtraChapterCatalogs.forSubject(subjectId);
      if (extra.isNotEmpty) return List<String>.from(extra);
    }

    final clean =
        values.map((e) => e.trim()).where(isSingleChapter).toSet().toList();
    clean.sort((a, b) {
      final byNumber = numberOf(a).compareTo(numberOf(b));
      return byNumber != 0 ? byNumber : a.compareTo(b);
    });
    return clean;
  }
}
