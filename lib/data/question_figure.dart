/// চিত্রের ধরন
enum FigureKind { table, triangle, barChart, image }

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

  /// File name of a picture in assets/question_figures/, e.g. 'heart.png'.
  /// Used by FigureKind.image, where the whole question — figure and all —
  /// is a single scanned/photographed image rather than drawn shapes.
  final String? imagePath;

  /// Width divided by height of that picture. Stored alongside the name so
  /// the paper layout can reserve the right amount of vertical space without
  /// having to decode the file first.
  final double? aspect;

  const QuestionFigure._(
    this.kind, {
    this.headers = const [],
    this.rows = const [],
    this.sides = const [],
    this.angles = const [],
    this.values = const [],
    this.rightAngleAt,
    this.caption,
    this.imagePath,
    this.aspect,
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

  /// A whole question captured as one picture (figure, equations and all).
  const QuestionFigure.image({
    required String imagePath,
    double aspect = 1.4,
    String? caption,
  }) : this._(FigureKind.image,
            imagePath: imagePath, aspect: aspect, caption: caption);
}
