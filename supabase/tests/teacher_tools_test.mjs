import {test} from 'node:test';
import assert from 'node:assert/strict';
import {toolRequest,questionsFrom,verifyChecks,runTeacherTool} from '../functions/mimi/teacher_tools.ts';
const request=()=>toolRequest({action:'generate',subjectId:'physics',chapters:['Motion'],difficulty:'mixed',count:1,text:'',instruction:''});
const question=()=>({chapter:'Motion',questionText:'দ্রুতির একক কী?',options:['m/s','m','s','kg'],correctIndex:0,explanation:'Speed is distance divided by time.',difficulty:'easy'});
test('bounded teacher request accepts only supported metadata',()=>{
  assert.equal(request().count,1);
  for(const mutation of [{count:0},{count:11},{count:1.5},{chapters:[]},{subjectId:'unknown'},{difficulty:'any'},{text:'x'.repeat(12001)},{action:'explain'}]){
    assert.throws(()=>toolRequest({...request(),...mutation}));
  }
});
test('reject incomplete, out-of-chapter, duplicate option and invalid key batches',()=>{
  for(const rows of [[],[question(),question()],[{...question(),chapter:'Other'}],[{...question(),options:['m','m','s','kg']}],[{...question(),correctIndex:4}],[{...question(),explanation:''}]])assert.throws(()=>questionsFrom({questions:rows},request()));
});
test('independent checker requires exact coverage and agreeing keys',()=>{
  const checks=[{index:0,correctIndex:0,valid:true,reason:'distance / time'}];
  assert.deepEqual(verifyChecks({checks},[question()]),['distance / time']);
  for(const invalid of [[],[{...checks[0],valid:false}],[{...checks[0],index:1}],[{...checks[0],correctIndex:2}]])assert.throws(()=>verifyChecks({checks:invalid},[question()]));
});
test('two actual model passes precede checked status; checker cannot see generated key',async()=>{
  const phases=[];const calls=[];
  const result=await runTeacherTool(request(),async(system,input,schema,validator)=>{
    calls.push({system,input,schema,validator});
    return validator?{checks:[{index:0,correctIndex:0,valid:true,reason:'দূরত্বকে সময় দিয়ে ভাগ করলে দ্রুতি পাওয়া যায়।'}]}:{questions:[question()]};
  },phase=>phases.push(phase));
  assert.equal(calls.length,2);assert.equal(result.checked,true);
  assert.equal(calls[1].input.includes('correctIndex'),false);assert.equal(calls[1].input.includes('explanation'),false);
  assert.deepEqual(phases,['Applying SSC chapter constraints','Generating questions','Checking answers independently']);
});
test('validator failure never returns checked questions',async()=>{
  await assert.rejects(()=>runTeacherTool(request(),async(_s,_i,_sc,validator)=>validator?{checks:[]}:{questions:[question()]},()=>{}));
});
test('Check / Explain use structured findings, not an answer-verification badge',async()=>{
  const result=await runTeacherTool({...request(),action:'explain',text:'Explain speed'},async()=>({summary:'একক সময়ে অতিক্রান্ত দূরত্ব হলো দ্রুতি।',findings:[{title:'সূত্র',detail:'v = d / t'}]}),()=>{});
  assert.equal(result.kind,'review');assert.equal(result.checked,false);
});
