import {test} from 'node:test';
import assert from 'node:assert/strict';
import {assertResponseLanguage,responseLanguageInstruction,isEnglishSubject} from '../functions/mimi/response_language.ts';
import {runTeacherTool,toolRequest} from '../functions/mimi/teacher_tools.ts';
const request=(subjectId='physics',action='generate')=>toolRequest({subjectId,action,chapters:['অধ্যায় ১'],count:1,difficulty:'mixed',text:action==='generate'?'':'Explain in English',instruction:'Use English numbers'});
const question=(english=false)=>({chapter:'অধ্যায় ১',questionText:english?'What is the unit of acceleration?':'ত্বরণের একক কী?',options:['m/s^২','m/s','N','J'],correctIndex:0,explanation:english?'Rate of velocity change.':'সময়ের সাথে বেগের পরিবর্তনের হার।',difficulty:'easy'});
const checks=(english=false)=>({checks:[{index:0,valid:true,correctIndex:0,reason:english?'Acceleration is the rate of velocity change.':'সময়ের সাথে বেগের পরিবর্তনের হার হলো ত্বরণ; একক m/s^২।'}]});
const review=(english=false)=>({summary:english?'Use the acceleration formula.':'ত্বরণের সূত্র ব্যবহার করুন।',findings:[{title:english?'Formula':'সূত্র',detail:'a = (v-u)/t'}]});

test('only English First/Second select English; all other supported subjects select Bengali',()=>{
 for(const id of ['physics','chemistry','biology','higher_math','general_math','ict','bangla_1st','bangla_2nd','bgs','general_science','agriculture','religion','business_ent','accounting','finance','history','civics','economics','geography']) {
  assert.equal(isEnglishSubject(id),false);assert.match(responseLanguageInstruction(id),/OUTPUT LANGUAGE: Bengali/);
 }
 for(const id of ['english_1st','english_2nd']) {assert.equal(isEnglishSubject(id),true);assert.match(responseLanguageInstruction(id),/OUTPUT LANGUAGE: English\./);}
 assert.match(responseLanguageInstruction('physics'),/English digits do NOT mean English prose/);
});
test('language guard permits units, equations and names without mistaking Bengali digits for prose',()=>{
 for(const text of ['m/s²','10⁻³','CO₂','F = ma','Newton','SI','ত্বরণ 2 m/s²']) assert.doesNotThrow(()=>assertResponseLanguage(text,'physics'));
 for(const text of ['Acceleration is the rate of change of velocity.','123','১২৩']) assert.throws(()=>assertResponseLanguage(text,'physics',true));
 assert.throws(()=>assertResponseLanguage('সঠিক। The answer is two.','physics',true));
 assert.doesNotThrow(()=>assertResponseLanguage('The correct answer is 2.','english_1st',true));
 assert.throws(()=>assertResponseLanguage('উত্তর 2।','english_2nd',true));
});
for(const action of ['generate','improve','check','explain']) {
 test(`${action} requests and validates Bengali prose with English digits`,async()=>{
  let calls=0;
  const result=await runTeacherTool(request('physics',action),async(system,input,schema,validator)=>{
   calls++;assert.match(system,/OUTPUT LANGUAGE: Bengali/);assert.match(system,/English digits do NOT mean English prose/);
   if(action==='check'||action==='explain') return review();
   if(validator) {assert.ok(!input.includes('correctIndex'));assert.ok(!input.includes('explanation'));return checks();}
   return {questions:[question()]};
  },()=>{});
  assert.equal(calls,action==='check'||action==='explain'?1:2);
  if(result.kind==='questions') {assert.match(result.questions[0].explanation,/ত্বরণ/);assert.match(result.questions[0].explanation,/m\/s²/);assert.equal(result.questions[0].chapter,'অধ্যায় ১');}
  else assert.match(result.summary,/ত্বরণ/);
 });
}
for(const subject of ['english_1st','english_2nd']) {
 test(`${subject} keeps questions and checked explanations in English`,async()=>{
  const result=await runTeacherTool(request(subject),async(system,_i,_s,validator)=>{
   assert.match(system,/OUTPUT LANGUAGE: English\./);return validator?checks(true):{questions:[question(true)]};
  },()=>{});
  assert.equal(result.checked,true);assert.equal(result.questions[0].questionText,question(true).questionText);assert.equal(result.questions[0].explanation,checks(true).checks[0].reason);
 });
}
test('wrong-language generation is corrected before independent solving, with only one extra call',async()=>{
 const seen=[];const phases=[];
 const result=await runTeacherTool(request(),async(system,input,_s,validator)=>{
  seen.push({system,input,validator});
  if(validator) {assert.match(input,/ত্বরণের/);assert.ok(!input.includes('correctIndex'));return checks();}
  return {questions:[question(seen.length===1)]};
 },p=>phases.push(p));
 assert.equal(result.checked,true);assert.equal(seen.length,3);assert.match(seen[1].system,/previous response used the wrong language/);assert.ok(phases.includes('Correcting response language to Bengali'));
});
test('English checker reasoning is re-solved in Bengali before earning checked status',async()=>{
 let n=0;let solves=0;
 const result=await runTeacherTool(request(),async(_sys,input,_schema,validator)=>{
  n++;if(!validator)return {questions:[question()]};
  solves++;assert.ok(!input.includes('correctIndex'));return checks(solves===1);
 },()=>{});
 assert.equal(n,3);assert.equal(result.checked,true);assert.match(result.checkReasons[0],/ত্বরণ/);
});
test('repeated language drift cannot return a checked result or loop indefinitely',async()=>{
 let calls=0;
 await assert.rejects(()=>runTeacherTool(request(),async()=>{calls++;return {questions:[question(true)]};},()=>{}),/বাংলায়/);
 assert.equal(calls,2);
 calls=0;
 await assert.rejects(()=>runTeacherTool(request(),async(_s,_i,_sc,validator)=>{calls++;return validator?checks(true):{questions:[question(calls===1)]};},()=>{}),/বাংলায়/);
 assert.equal(calls,3,'one shared retry budget, not one per stage');
});
test('review-language repair preserves math and English subject feedback is not translated to Bengali',async()=>{
 let n=0;
 const result=await runTeacherTool(request('physics','explain'),async()=>review(++n===1),()=>{});
 assert.equal(n,2);assert.match(result.summary,/ত্বরণ/);assert.equal(result.findings[0].detail,'a = (v-u)/t');
 const english=await runTeacherTool(request('english_1st','check'),async()=>review(true),()=>{});
 assert.equal(english.summary,review(true).summary);
});

test('an English-subject retry still explicitly requests English prose',async()=>{
 let n=0;
 const result=await runTeacherTool(request('english_2nd'),async(system,_input,_schema,validator)=>{
  n++;assert.match(system,/OUTPUT LANGUAGE: English\./);assert.doesNotMatch(system,/only the digits are English|OUTPUT LANGUAGE: Bengali/);
  return validator?checks(true):{questions:[question(n!==1)]};
 },()=>{});
 assert.equal(n,3);assert.equal(result.checked,true);assert.equal(result.questions[0].questionText,question(true).questionText);
});
