import '../data/questions_data.dart';
import 'ai/question_schema_validator.dart';

/// Shared boundary for bundled/remote questions and paper composition.
/// Invalid remote rows must never replace a healthy local question.
class QuestionValidationService {
  static QuestionValidation validate(Object question) {
    if (question is Question)
      return QuestionSchemaValidator.validateMcq(question);
    final errors = <String>[];
    if (question is ShortQuestion) {
      if (question.id.trim().isEmpty ||
          question.subjectId.trim().isEmpty ||
          question.chapter.trim().isEmpty)
        errors.add('missing question metadata');
      if (question.questionText.trim().isEmpty ||
          question.answer.trim().isEmpty)
        errors.add('short answer needs a question and answer');
    } else if (question is CreativeQuestion) {
      if (question.id.trim().isEmpty ||
          question.subjectId.trim().isEmpty ||
          question.chapter.trim().isEmpty)
        errors.add('missing question metadata');
      if ([
        question.stem,
        question.questionK,
        question.questionKh,
        question.questionG
      ].any((s) => s.trim().isEmpty))
        errors.add('creative question is incomplete');
      final three = question.marks.length == 3 &&
          question.marks[0] == 2 &&
          question.marks[1] == 4 &&
          question.marks[2] == 4 &&
          question.questionGh.isEmpty;
      final four = question.marks.length == 4 &&
          question.marks[0] == 1 &&
          question.marks[1] == 2 &&
          question.marks[2] == 3 &&
          question.marks[3] == 4 &&
          question.questionGh.trim().isNotEmpty;
      if (!three && !four)
        errors.add('CQ must use 2/4/4 or 1/2/3/4 marks with matching parts');
    } else {
      errors.add('unsupported question type');
    }
    return QuestionValidation(errors: errors);
  }
}
