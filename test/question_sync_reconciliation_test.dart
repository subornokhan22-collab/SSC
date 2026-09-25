import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutors_desk/data/question_bank.dart';
import 'package:tutors_desk/data/question_sync.dart';
import 'package:tutors_desk/data/questions_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const base = Question(
      id: 'bundled',
      subjectId: 'physics',
      chapter: 'Chapter 1',
      questionText: 'Original bundled question',
      options: ['A', 'B', 'C', 'D'],
      correctIndex: 1,
      explanation: 'Source');
  const remote = Question(
      id: 'remote',
      subjectId: 'physics',
      chapter: 'Chapter 1',
      questionText: 'Remote question',
      options: ['A', 'B', 'C', 'D'],
      correctIndex: 1,
      explanation: 'Source');
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    QuestionBank.seed(mcqs: [base], saqs: [], cqs: []);
  });
  test(
      'full reconciliation removes a remote archive without deleting bundled content',
      () {
    QuestionBank.replaceRemote(mcqs: [remote]);
    expect(
        QuestionBank.mcqs.map((q) => q.id), containsAll(['bundled', 'remote']));
    QuestionBank.replaceRemote();
    expect(QuestionBank.mcqs.map((q) => q.id), ['bundled']);
  });
  test('clear cache also removes in-memory remote content', () async {
    QuestionBank.replaceRemote(mcqs: [remote]);
    await QuestionSync.clearCache();
    expect(QuestionBank.mcqs.map((q) => q.id), ['bundled']);
  });
}
