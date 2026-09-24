import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutors_desk/services/omr/omr_store.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(()=>SharedPreferences.setMockInitialValues({}));
  OmScanRecord record({int answer=0})=>OmScanRecord(id:'review-1',date:DateTime(2026,9,24),paperTitle:'Physics',subjectName:'Physics',roll:'12',registration:'34',subjectCode:'136',setCode:'ক',total:1,score:answer==0?1:0,correct:answer==0?1:0,wrong:answer==0?0:1,blank:0,ambiguous:0,answers:[answer],key:[0],correctedIndices:answer==0?[]:[0]);
  test('saving a correction replaces the original history record',()async{
    await OmrStore.addRecord(record());await OmrStore.addRecord(record(answer:1));
    final history=await OmrStore.loadHistory();expect(history.length,1);expect(history.single.answers,[1]);expect(history.single.score,0);expect(history.single.correctedIndices,[0]);
  });
  test('legacy history without correction metadata remains readable',(){
    final raw=record().toJson()..remove('correctedIndices');expect(OmScanRecord.fromJson(raw).correctedIndices,isEmpty);
  });
}
