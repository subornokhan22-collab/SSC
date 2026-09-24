enum PaperFormat { board, chapter, custom, mcq }

/// Serializable teacher choices, kept separate from widget and PDF state.
class PaperDraft {
  final String subjectId;
  final String title;
  final PaperFormat format;
  final List<String> chapters;
  final int mcqCount;
  final int saqCount;
  final int cqCount;
  final String setCode;
  final bool answerKey;

  const PaperDraft({
    this.subjectId = 'physics',
    this.title = 'মডেল পরীক্ষা — ২০২৭',
    this.format = PaperFormat.board,
    this.chapters = const [],
    this.mcqCount = 25,
    this.saqCount = 7,
    this.cqCount = 7,
    this.setCode = 'ক',
    this.answerKey = false,
  });

  PaperDraft copyWith({
    String? subjectId,
    String? title,
    PaperFormat? format,
    List<String>? chapters,
    int? mcqCount,
    int? saqCount,
    int? cqCount,
    String? setCode,
    bool? answerKey,
  }) =>
      PaperDraft(
        subjectId: subjectId ?? this.subjectId,
        title: title ?? this.title,
        format: format ?? this.format,
        chapters: List.unmodifiable(chapters ?? this.chapters),
        mcqCount: mcqCount ?? this.mcqCount,
        saqCount: saqCount ?? this.saqCount,
        cqCount: cqCount ?? this.cqCount,
        setCode: setCode ?? this.setCode,
        answerKey: answerKey ?? this.answerKey,
      );

  Map<String, dynamic> toJson() => {
        'subjectId': subjectId,
        'title': title,
        'format': format.name,
        'chapters': chapters,
        'mcqCount': mcqCount,
        'saqCount': saqCount,
        'cqCount': cqCount,
        'setCode': setCode,
        'answerKey': answerKey,
      };

  factory PaperDraft.fromJson(Map<String, dynamic> j) => PaperDraft(
        subjectId: j['subjectId'] as String? ?? 'physics',
        title: j['title'] as String? ?? '',
        format: PaperFormat.values.firstWhere(
          (f) => f.name == j['format'],
          orElse: () => PaperFormat.custom,
        ),
        chapters: List<String>.from(j['chapters'] as List? ?? []),
        mcqCount:
            ((j['mcqCount'] as num?)?.toInt() ?? 25).clamp(0, 100).toInt(),
        saqCount: ((j['saqCount'] as num?)?.toInt() ?? 7).clamp(0, 30).toInt(),
        cqCount: ((j['cqCount'] as num?)?.toInt() ?? 7).clamp(0, 15).toInt(),
        setCode: const ['ক', 'খ', 'গ', 'ঘ'].contains(j['setCode'])
            ? j['setCode'] as String
            : 'ক',
        answerKey: j['answerKey'] == true,
      );
}
