import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutors_desk/controllers/ai_controller.dart';
import 'package:tutors_desk/services/ai/ai_text_formatter.dart';
import 'package:tutors_desk/services/ai/teacher_attachment.dart';
import 'package:tutors_desk/services/ai/teacher_ai_client.dart';
import 'package:tutors_desk/widgets/teacher_attachment_panel.dart';

class CaptureTeacherClient extends TeacherAiClient {
  Map<String, dynamic>? payload;
  @override
  Future<Map<String, dynamic>> request(
      Map<String, dynamic> p, void Function(String) progress) async {
    payload = p;
    return {
      'kind': 'review',
      'summary': 'ত্বরণ ২ m/s^২',
      'findings': [
        {'title': 'সূত্র ১', 'detail': 'CO_{২}'}
      ]
    };
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  TeacherAttachment pdf() => TeacherAttachment(
      name: 'reference.pdf',
      mimeType: 'application/pdf',
      bytes: Uint8List.fromList(utf8.encode('%PDF-1.7 fixture')));
  test(
      'Dart/server share deterministic English numeral and scientific formatting',
      () {
    final cases =
        jsonDecode(File('test/fixtures/ai_text_format.json').readAsStringSync())
            as List;
    for (final row in cases) {
      expect(AiTextFormatter.format(row[0] as String), row[1]);
      expect(AiTextFormatter.format(row[1] as String), row[1]);
    }
    expect(AiTextFormatter.format('  ১  ', trim: false), '  1  ');
  });
  test('attachments enforce type, count and combined byte limits', () {
    TeacherAttachment.validate([pdf()]);
    expect(() => TeacherAttachment.validate(List.generate(4, (_) => pdf())),
        throwsFormatException);
    expect(
        () => TeacherAttachment.validate([
              TeacherAttachment(
                  name: 'bad.pdf',
                  mimeType: 'application/pdf',
                  bytes: Uint8List.fromList([1, 2, 3]))
            ]),
        throwsFormatException);
    expect(
        () => TeacherAttachment.validate([
              TeacherAttachment(
                  name: 'x.wav', mimeType: 'audio/wav', bytes: pdf().bytes)
            ]),
        throwsFormatException);
    final big = Uint8List(TeacherAttachment.maxBytes + 1)
      ..setRange(0, 5, utf8.encode('%PDF-'));
    expect(
        () => TeacherAttachment.validate([
              TeacherAttachment(
                  name: 'big.pdf', mimeType: 'application/pdf', bytes: big)
            ]),
        throwsFormatException);
    expect(pdf().toJson().keys, unorderedEquals(['mimeType', 'data']));
    expect(() => pdf().bytes[0] = 0, throwsUnsupportedError);
  });
  test('bounded file reader cancels when input is too large', () async {
    await expectLater(readTeacherFile(Stream.value(List.filled(101, 0)), 100),
        throwsFormatException);
    expect(await readTeacherFile(Stream.value([1, 2, 3]), 3), [1, 2, 3]);
  });
  test('photo preprocessing produces a small JPEG with bounded dimensions',
      () async {
    final encoded =
        Uint8List.fromList(img.encodePng(img.Image(width: 1800, height: 100)));
    final photo = await TeacherAttachment.photo('reference.png', encoded);
    expect(photo.mimeType, 'image/jpeg');
    expect(img.decodeJpg(photo.bytes)!.width, 1600);
    TeacherAttachment.validate([photo]);
  });
  test(
      'controller refuses unconsented uploads and supports attachment-only review',
      () async {
    final client = CaptureTeacherClient();
    final c = AiController(bank: [], client: client);
    Future<bool> run(bool consent) => c.execute(
        command: TeacherCommand.check,
        subjectId: 'physics',
        chapters: ['অধ্যায় ১'],
        count: 1,
        level: 'mixed',
        text: '',
        instruction: '',
        attachments: [pdf()],
        attachmentConsent: consent);
    expect(await run(false), false);
    expect(client.payload, isNull);
    expect(await run(true), true);
    expect(client.payload!['attachmentConsent'], true);
    expect((client.payload!['attachments'] as List).single, pdf().toJson());
    expect(c.summary, 'ত্বরণ 2 m/s²');
    expect(c.findings.single['detail'], 'CO₂');
    expect(client.payload!['chapters'], ['অধ্যায় ১']);
    c.dispose();
  });
  test(
      'client blocks stale backend instead of accepting attachment-ignored results',
      () async {
    final client = TeacherAiClient(
        tokenProvider: () => 'fixture-user-token',
        client: MockClient((request) async =>
            http.Response('event: result\ndata: {"kind":"review"}\n\n', 200)));
    await expectLater(
        client.request({
          'attachments': [pdf().toJson()]
        }, (_) {}),
        throwsA(isA<StateError>().having(
            (e) => e.message, 'message', contains('attachment update'))));
    client.close();
  });
  test(
      'client accepts capability header and keeps authentication on attachment requests',
      () async {
    final client = TeacherAiClient(
        tokenProvider: () => 'fixture-user-token',
        client: MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer fixture-user-token');
          expect(jsonDecode(request.body)['attachments'], [pdf().toJson()]);
          return http.Response(
              'event: phase\ndata: {"message":"Reading"}\n\nevent: result\ndata: {"kind":"review","summary":"OK"}\n\n',
              200,
              headers: {'x-teacher-attachments-version': '1'});
        }));
    final phases = <String>[];
    expect(
        (await client.request({
          'attachments': [pdf().toJson()]
        }, phases.add))['summary'],
        'OK');
    expect(phases, ['Reading']);
    client.close();
  });
  testWidgets(
      'PDF reference metadata and removal stay local; busy mode prevents changes',
      (tester) async {
    List<TeacherAttachment>? changed;
    Future<void> show(bool enabled) => tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: TeacherAttachmentPanel(
                files: [pdf()],
                enabled: enabled,
                onChanged: (f) => changed = f,
                onPicking: (_) {}))));
    await show(false);
    expect(find.text('reference.pdf'), findsOneWidget);
    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove attachment 1'));
    expect(changed, isNull);
    await show(true);
    await tester.tap(find.byTooltip('Remove attachment 1'));
    expect(changed, isEmpty);
    expect(tester.takeException(), isNull);
  });
  test('scientific symbol fallback fonts are shipped with the APK', () async {
    expect((await rootBundle.load('assets/fonts/DejaVuSans.ttf')).lengthInBytes,
        greaterThan(1000));
  });
}
