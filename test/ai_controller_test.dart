import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutors_desk/controllers/ai_controller.dart';
import 'package:tutors_desk/data/questions_data.dart';
import 'package:tutors_desk/services/ai/teacher_ai_client.dart';

class FakeTeacherClient extends TeacherAiClient {
  final Future<Map<String, dynamic>> Function() reply;
  bool closed = false;
  FakeTeacherClient(this.reply);
  @override
  Future<Map<String, dynamic>> request(
      Map<String, dynamic> payload, void Function(String) progress) async {
    progress('Checking answers independently');
    return reply();
  }

  @override
  void close() {
    closed = true;
    super.close();
  }
}

Map<String, dynamic> result({bool checked = true}) => {
      'kind': 'questions',
      'checked': checked,
      'questions': [
        {
          'chapter': 'Motion',
          'questionText': 'Which unit measures speed?',
          'options': ['m/s', 'm', 's', 'kg'],
          'correctIndex': 0,
          'explanation': 'Speed is distance per unit time.',
          'difficulty': 'easy'
        }
      ]
    };
Future<bool> execute(AiController c) => c.execute(
    command: TeacherCommand.create,
    subjectId: 'physics',
    chapters: ['Motion'],
    count: 1,
    level: 'mixed',
    text: '',
    instruction: '');
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('only a completed independent check earns an AI checked label',
      () async {
    final c =
        AiController(bank: [], client: FakeTeacherClient(() async => result()));
    expect(await execute(c), isTrue);
    expect(c.canUse, isTrue);
    expect(c.checkedIds.length, 1);
    final q = c.questions.single;
    c.edit(
        0,
        Question(
            id: q.id,
            subjectId: q.subjectId,
            chapter: q.chapter,
            questionText: q.questionText,
            options: q.options,
            correctIndex: 0,
            explanation: 'Distance divided by elapsed time.'));
    expect(c.checkedIds, isEmpty);
    expect(c.canUse, isTrue);
    c.dispose();
  });
  test('unchecked or incomplete batches never reach paper selection', () async {
    final c = AiController(
        bank: [],
        client: FakeTeacherClient(() async => result(checked: false)));
    expect(await execute(c), isFalse);
    expect(c.questions, isEmpty);
    expect(c.canUse, isFalse);
    expect(c.error, contains('independent'));
    c.dispose();
  });
  test('previous AI questions remain in the duplicate gate across controllers',
      () async {
    final first =
        AiController(bank: [], client: FakeTeacherClient(() async => result()));
    expect(await execute(first), isTrue);
    first.dispose();
    final second =
        AiController(bank: [], client: FakeTeacherClient(() async => result()));
    expect(await execute(second), isTrue);
    expect(second.duplicates, isNotEmpty);
    expect(second.canUse, isFalse);
    second.dispose();
  });
  test('late network results after disposal cannot mutate question selection',
      () async {
    final completer = Completer<Map<String, dynamic>>();
    final client = FakeTeacherClient(() => completer.future);
    final c = AiController(bank: [], client: client);
    final pending = execute(c);
    await Future<void>.delayed(Duration.zero);
    c.dispose();
    completer.complete(result());
    expect(await pending, isFalse);
    expect(c.questions, isEmpty);
    expect(client.closed, isTrue);
  });
  test(
      'signed-out server access gives an actionable error without a network request',
      () async {
    final client = TeacherAiClient();
    await expectLater(client.request({}, (_) {}), throwsStateError);
    client.close();
  });
}
