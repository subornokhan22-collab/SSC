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
