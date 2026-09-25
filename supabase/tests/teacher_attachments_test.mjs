import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {teacherAttachments,MAX_TEACHER_BYTES} from '../functions/mimi/attachments.ts';
import {formatAiText} from '../functions/mimi/text_format.ts';
import {toolRequest,runTeacherTool,questionsFrom} from '../functions/mimi/teacher_tools.ts';
const file = (mimeType, contents) => ({mimeType,data:Buffer.from(contents,'latin1').toString('base64')});
const pdf = file('application/pdf','%PDF-1.7\nfixture');
const base = {action:'generate',subjectId:'physics',chapters:['অধ্যায় ১'],difficulty:'mixed',count:1,text:'',instruction:''};
const q = {chapter:'অধ্যায় ১',questionText:'১ kg ভরের ত্বরণ কত?',options:['১ m/s^২','২ m/s^২','৩ m/s^২','৪ m/s^২'],correctIndex:0,explanation:'F = m \\times a',difficulty:'easy'};
test('shared AI text fixtures preserve meanings and use English digits',()=>{
 for(const [input,output] of JSON.parse(readFileSync(new URL('../../test/fixtures/ai_text_format.json',import.meta.url)))) {
  assert.equal(formatAiText(input),output);
  assert.equal(formatAiText(output),output,'normalization must be idempotent');
 }
});
test('teacher attachment allowlist accepts photos/PDF and requires informed consent',()=>{
 assert.equal(teacherAttachments([pdf,file('image/jpeg','\xff\xd8\xffmore'),file('image/png','\x89PNG\r\n\x1a\nmore')]).length,3);
 assert.throws(()=>toolRequest({...base,attachments:[pdf]}),/consent/);
 assert.equal(toolRequest({...base,action:'explain',attachments:[pdf],attachmentConsent:true}).attachments.length,1);
 assert.throws(()=>toolRequest({...base,action:'explain'}));
});
test('rejects remote URLs, audio, spoofed types, bad encodings and oversized attachments',()=>{
 for(const attachments of [null,{},[...Array(4)].map(()=>pdf),[file('audio/mp3','audio')],[file('image/svg+xml','<svg>')],[file('image/png','%PDF-')],[{mimeType:'image/png',data:'https://host/file'}],[{...pdf,data:'%%%%'}],[{...pdf,data:'AA='}],[{...pdf,data:'A'.repeat(4*Math.ceil(MAX_TEACHER_BYTES/3)+4)}],[pdf,{...pdf,data:Buffer.alloc(MAX_TEACHER_BYTES,1).toString('base64')}]]) assert.throws(()=>teacherAttachments(attachments));
});
test('normalized content is independently checked; catalog chapter stays unchanged',async()=>{
 let checker;
 const result = await runTeacherTool(toolRequest(base),async(system,input,schema,validator)=>{
  assert.match(system,/English digits/);
  assert.match(system,/untrusted source/);
  if (!validator) return {questions:[q]};
  checker = JSON.parse(input);
  return {checks:[{index:0,valid:true,correctIndex:0,reason:'ত্বরণ ১ m/s^২'}]};
 },()=>{});
 assert.equal(checker[0].chapter,'অধ্যায় ১');
 assert.equal(checker[0].questionText,'1 kg ভরের ত্বরণ কত?');
 assert.equal(checker[0].options[0],'1 m/s²');
 assert.equal(checker[0].correctIndex,undefined);
 assert.equal(result.questions[0].explanation,'ত্বরণ 1 m/s²');
 assert.equal(result.checked,true);
 assert.throws(()=>questionsFrom({questions:[{...q,options:['১','1','3','4']}]},toolRequest(base)),/schema/);
});
test('review findings also normalize math and Bengali digits',async()=>{
 const result = await runTeacherTool(toolRequest({...base,action:'check',text:'test'}),async()=>({summary:'১টি ভুল',findings:[{title:'ঘাত ২',detail:'সঠিক একক m/s^২'}]}),()=>{});
 assert.equal(result.summary,'1টি ভুল');assert.equal(result.findings[0].detail,'সঠিক একক m/s²');
});

test('scientific distractors preserve signs and powers during uniqueness checks',()=>{
 const request=toolRequest(base);
 const rows=questionsFrom({questions:[{...q,options:['-১','+১','10^২','10^৩']}]},request);
 assert.deepEqual(rows[0].options,['-1','+1','10²','10³']);
 assert.throws(()=>questionsFrom({questions:[{...q,options:['m/s^2','m/s²','m/s','m']}]},request),/schema/);
});
