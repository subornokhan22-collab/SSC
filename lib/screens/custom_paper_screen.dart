import 'package:flutter/material.dart';
import '../models/paper_draft.dart';
import 'create_paper_screen.dart';

/// Legacy entry points all use the same autosaved paper workflow.
class CustomPaperScreen extends StatelessWidget {
  final bool mcqOnly;
  const CustomPaperScreen({super.key, this.mcqOnly = false});
  @override
  Widget build(BuildContext context) => CreatePaperScreen(
      initialFormat: mcqOnly ? PaperFormat.mcq : PaperFormat.custom);
}
