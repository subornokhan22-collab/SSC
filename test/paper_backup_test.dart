import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutors_desk/services/paper_library.dart';

/// Backups must survive an uninstall: the app-scoped copy Android deletes is
/// not enough, so the shared Download/TutorsDesk copy is what a reinstall
/// restores. These tests drive the real PaperLibrary/PaperBackup code paths
/// with stubbed platform channels only.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const paths = MethodChannel('plugins.flutter.io/path_provider');
  const storage = MethodChannel('com.tutorsdesk.app/storage');

  late Directory appDoc;
  late Directory external;
  late Directory sdcard;
  late List<Map<String, Object?>> calls;
  late bool sharedWritable;

  setUp(() async {
    appDoc = Directory.systemTemp.createTempSync('td_app_');
    external = Directory.systemTemp.createTempSync('td_ext_');
    sdcard = Directory.systemTemp.createTempSync('td_sd_');
    calls = <Map<String, Object?>>[];
    sharedWritable = true;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(paths, (call) async {
      switch (call.method) {
        case 'getApplicationDocumentsDirectory':
        case 'getTemporaryDirectory':
        case 'getApplicationSupportDirectory':
          return appDoc.path;
        case 'getExternalStorageDirectory':
          return external.path;
      }
      return null;
    });
    messenger.setMockMethodCallHandler(storage, (call) async {
      calls.add({
        'method': call.method,
        ...Map<String, Object?>.from(call.arguments as Map? ?? const {}),
      });
      switch (call.method) {
        case 'canManageAllFiles':
          return true;
        case 'externalStorageDir':
          return sdcard.path;
        case 'copyToDownloads':
          if (!sharedWritable) return null;
          // Mirror the real MediaStore route: shared storage, uninstall-safe.
          final args = Map<String, Object?>.from(call.arguments as Map);
          final relative =
              (args['relativePath'] as String?) ?? 'Download/TutorsDeskDebug';
          final folder = relative.replaceFirst(RegExp(r'^Downloads?/'), '');
          Directory('${sdcard.path}/$folder').createSync(recursive: true);
          final name = args['name'] as String;
          File('${sdcard.path}/$folder/$name').writeAsBytesSync(
              File(args['source'] as String).readAsBytesSync());
          return '$folder/$name';
      }
      return null;
    });
  });

  tearDown(() {
    for (final dir in [appDoc, external, sdcard]) {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    }
  });

  SavedPaper paper({String id = 'sp_1'}) => SavedPaper(
        id: id,
        title: 'Physics Model Test',
        subject: 'Physics',
        subjectId: 'physics',
        subjectCode: '109',
        setCode: 'ক',
        total: 1,
        key: const [2],
        questions: const [
          SavedQuestion(
            text: 'ত্বরণের একক কী?',
            options: ['m/s', 'm', 'm/s²', 'kg'],
            answer: 2,
          ),
        ],
        createdAt: DateTime(2026, 9, 26),
        pages: 1,
      );

  /// Path of the in-app copy [PaperBackup] actually wrote, read back from the
  /// platform call it made. Hardcoding an external-storage path would be
  /// wrong: on a non-Android host `_backupPath()` legitimately falls back to
  /// the documents directory.
  String appCopyFromCall() {
    final call = calls.firstWhere((c) => c['method'] == 'copyToDownloads');
    return call['source'] as String;
  }

  File sharedCopy() =>
      File('${sdcard.path}/Download/TutorsDesk/tutors_desk_backup.json');

  test('saving a paper writes the uninstall-surviving Download copy', () async {
    await PaperLibrary.addSavedPaper(paper());
    await PaperBackup.autoSave();

    expect(File(appCopyFromCall()).existsSync(), isTrue,
        reason: 'the in-app copy still keeps working offline');
    expect(sharedCopy().existsSync(), isTrue,
        reason: 'the shared copy is the only one that survives an uninstall');

    final request = calls.firstWhere((c) => c['method'] == 'copyToDownloads');
    expect(request['relativePath'], 'Download/TutorsDesk',
        reason:
            'must not reuse the TutorsDeskDebug folder the restore ignores');
    expect(request['name'], 'tutors_desk_backup.json');
    expect(request['mime'], 'application/json');

    final backup = jsonDecode(sharedCopy().readAsStringSync()) as Map;
    expect(backup['app'], 'tutors_desk');
    expect(backup['entries'], isNotEmpty);
  });

  test('a fresh install restores the paper and its answer key', () async {
    await PaperLibrary.addSavedPaper(paper());
    await PaperBackup.autoSave();
    expect(sharedCopy().existsSync(), isTrue);

    // Uninstall: Android removes the app folders, shared Download stays.
    appDoc.deleteSync(recursive: true);
    external.deleteSync(recursive: true);
    appDoc.createSync(recursive: true);
    external.createSync(recursive: true);

    expect(await PaperLibrary.loadEntries(), isEmpty);
    expect(await PaperBackup.tryAutoRestore(), 1);

    final entries = await PaperLibrary.loadEntries();
    expect(entries.map((e) => e.id), contains('sp_1'));
    final restored = await PaperLibrary.savedPaper('sp_1');
    expect(restored?.key, [2], reason: 'the OMR answer key must come back');
    expect(restored?.questions.single.text, 'ত্বরণের একক কী?');
  });

  test('manual export reports failure honestly when shared storage refuses',
      () async {
    await PaperLibrary.addSavedPaper(paper());
    await PaperBackup.autoSave();
    final appCopy = appCopyFromCall();
    expect(File(appCopy).existsSync(), isTrue);
    sharedWritable = false;
    calls.clear();

    expect(await PaperBackup.exportToDownload(), isNull);
    expect(calls.any((c) => c['method'] == 'copyToDownloads'), isTrue);
    expect(File(appCopy).existsSync(), isTrue,
        reason: 'a failed shared copy must not lose the in-app backup');
  });

  test('restore keeps existing papers instead of duplicating them', () async {
    await PaperLibrary.addSavedPaper(paper());
    await PaperBackup.autoSave();

    expect(await PaperBackup.tryAutoRestore(), 0,
        reason: 'a non-empty library must never be overwritten');
    final entries = await PaperLibrary.loadEntries();
    expect(entries.where((e) => e.id == 'sp_1').length, 1);
  });
}
