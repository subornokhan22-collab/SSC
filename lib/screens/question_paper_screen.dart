import 'package:flutter/material.dart';

import '../models/paper_draft.dart';
import 'create_paper_screen.dart';

/// Backwards-compatible route; board/chapter/custom no longer own separate UI.
class QuestionPaperScreen extends StatelessWidget {
  final String? initialSubjectId;
  final String? initialMode;
  const QuestionPaperScreen({
    super.key,
    this.initialSubjectId,
    this.initialMode,
  });
  @override
  Widget build(BuildContext context) => CreatePaperScreen(
    initialSubjectId: initialSubjectId,
    initialFormat: initialMode == 'chapter'
        ? PaperFormat.chapter
        : PaperFormat.board,
  );
}
