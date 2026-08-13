import 'general_math_chapter_catalog.dart';

/// SSC General Mathematics board divisions and chapter mapping.
class GeneralMathDivisions {
  GeneralMathDivisions._();

  static const String algebra = 'ক বিভাগ — বীজগণিত';
  static const String geometry = 'খ বিভাগ — জ্যামিতি';
  static const String trigonometryMensuration =
      'গ বিভাগ — ত্রিকোণমিতি ও পরিমিতি';
  static const String statistics = 'ঘ বিভাগ — পরিসংখ্যান';

  static const List<int> algebraChapters = <int>[1, 2, 3, 4, 5, 11, 12, 13];
  static const List<int> geometryChapters = <int>[6, 7, 8, 14, 15];
  static const List<int> trigonometryMensurationChapters = <int>[9, 10, 16];
  static const List<int> statisticsChapters = <int>[17];

  static const List<String> names = <String>[
    algebra,
    geometry,
    trigonometryMensuration,
    statistics
  ];

  static List<String> chaptersFor(String division) {
    final numbers = switch (division) {
      algebra => algebraChapters,
      geometry => geometryChapters,
      trigonometryMensuration => trigonometryMensurationChapters,
      statistics => statisticsChapters,
      _ => const <int>[],
    };
    return <String>[
      for (final n in numbers) GeneralMathChapterCatalog.chapters[n - 1]
    ];
  }

  static String divisionForChapter(String chapter) {
    final index = GeneralMathChapterCatalog.chapters.indexOf(chapter);
    if (index < 0)
      throw ArgumentError.value(
          chapter, 'chapter', 'Unknown General Mathematics chapter');
    final number = index + 1;
    if (algebraChapters.contains(number)) return algebra;
    if (geometryChapters.contains(number)) return geometry;
    if (trigonometryMensurationChapters.contains(number))
      return trigonometryMensuration;
    return statistics;
  }
}
