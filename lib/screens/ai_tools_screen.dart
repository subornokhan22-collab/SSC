import 'package:flutter/material.dart';
import '../controllers/ai_controller.dart';
import '../data/questions_data.dart';
import '../models/subject_info.dart';
import '../navigation/app_routes.dart';
import '../services/chapter_catalog.dart';
import '../theme/app_theme.dart';
import '../widgets/paper_question_card.dart';
import '../widgets/workflow_progress.dart';
import 'ai_tutor_screen.dart';

class AiToolsScreen extends StatefulWidget {
  final String? subjectId;
  final String? chapter;
  final List<Question> currentPaper;
  final bool forSelection;
  final TeacherCommand initialCommand;
  final String initialText;
  const AiToolsScreen({super.key,this.subjectId,this.chapter,this.currentPaper=const [],this.forSelection=false,
    this.initialCommand=TeacherCommand.create,this.initialText=''});
  @override State<AiToolsScreen> createState()=>_AiToolsScreenState();
}
class _AiToolsScreenState extends State<AiToolsScreen>{
  late final AiController c;
  late TeacherCommand command;
  late String subject;
  String? chapter;
  String level='mixed';
  int count=5;
  final input=TextEditingController();
  final instruction=TextEditingController();
  @override void initState(){super.initState();c=AiController(bank:allMCQs,currentPaper:widget.currentPaper)..addListener(refresh);
    subject=widget.subjectId??'physics';command=widget.initialCommand;input.text=widget.initialText;chapter=widget.chapter;
    if(chapter!=null&&!chapters.contains(chapter))chapter=null;
    chapter??=chapters.isEmpty?null:chapters.first;
  }
  List<String> get chapters=>ChapterCatalog.ordered({
    ...allMCQs.where((q)=>q.subjectId==subject).map((q)=>q.chapter),
    ...allCQs.where((q)=>q.subjectId==subject).map((q)=>q.chapter),
    ...allSAQs.where((q)=>q.subjectId==subject).map((q)=>q.chapter),
  },subjectId:subject);
  void refresh(){if(mounted)setState((){});}
  @override void dispose(){c.removeListener(refresh);c.dispose();input.dispose();instruction.dispose();super.dispose();}
  Future<void> run()=>c.execute(command:command,subjectId:subject,chapters:chapter==null?[]:[chapter!],count:count,
    level:level,text:input.text.trim(),instruction:instruction.text.trim());
  String label(TeacherCommand cmd)=>switch(cmd){TeacherCommand.create=>'Create',TeacherCommand.improve=>'Improve',TeacherCommand.check=>'Check',TeacherCommand.explain=>'Explain'};
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('AI Tools'),actions:[
    PopupMenuButton<String>(enabled:!c.busy,onSelected:(_)=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const AiTutorScreen())),
      itemBuilder:(_)=>const[PopupMenuItem(value:'chat',child:Text('Open chat & attachments'))]),
  ]),body:ListView(padding:const EdgeInsets.all(20),children:[
    Text('A teaching task, not a chat prompt.',style:Theme.of(context).textTheme.titleLarge),const SizedBox(height:6),
    const Text('AI practice is not an official board paper. Always review wording and answers before use.',style:TextStyle(color:AppTheme.muted)),const SizedBox(height:18),
    Wrap(spacing:8,children:[for(final cmd in TeacherCommand.values)ChoiceChip(label:Text(label(cmd)),selected:command==cmd,
      onSelected:c.busy?null:(_)=>setState(()=>command=cmd))]),const SizedBox(height:16),
    AbsorbPointer(absorbing:c.busy,child:Column(children:[
      DropdownButtonFormField<String>(value:subject,decoration:const InputDecoration(labelText:'SSC subject'),
        items:[for(final s in allSubjects)DropdownMenuItem(value:s.id,child:Text(s.name))],
        onChanged:widget.forSelection?null:(s)=>setState((){subject=s!;chapter=chapters.isEmpty?null:chapters.first;})),const SizedBox(height:14),
      DropdownButtonFormField<String>(value:chapter,isExpanded:true,decoration:const InputDecoration(labelText:'NCTB chapter · from your bank'),
        items:[for(final ch in chapters)DropdownMenuItem(value:ch,child:Text(ch,overflow:TextOverflow.ellipsis))],onChanged:(v)=>setState(()=>chapter=v)),
      if(chapters.isEmpty)const Padding(padding:EdgeInsets.all(8),child:Text('No local chapter metadata is available for this subject. Choose another subject.')),
      if(command==TeacherCommand.create||command==TeacherCommand.improve)...[
        const SizedBox(height:14),Row(children:[Expanded(child:DropdownButtonFormField<int>(value:count,decoration:const InputDecoration(labelText:'MCQs · 1 mark each'),
          items:[for(var i=1;i<=10;i++)DropdownMenuItem(value:i,child:Text('$i questions'))],onChanged:(v)=>setState(()=>count=v!))),
          const SizedBox(width:12),Expanded(child:DropdownButtonFormField<String>(value:level,decoration:const InputDecoration(labelText:'Difficulty'),
            items:[for(final l in const ['easy','mixed','hard'])DropdownMenuItem(value:l,child:Text(l))],onChanged:(v)=>setState(()=>level=v!)))]),
      ],
      if(command!=TeacherCommand.create)...[const SizedBox(height:14),TextField(controller:input,minLines:3,maxLines:8,maxLength:12000,
        decoration:const InputDecoration(labelText:'Question or paper excerpt',alignLabelWithHint:true))],
      const SizedBox(height:14),TextField(controller:instruction,minLines:1,maxLines:3,maxLength:1000,
        decoration:InputDecoration(labelText:command==TeacherCommand.improve?'How should it improve?':'Additional instruction (optional)',hintText:'Harder reasoning, clearer distractors…')),
      if(command==TeacherCommand.improve)Wrap(spacing:6,children:[for(final hint in ['Make it harder','Replace duplicates','Balance difficulty','Stay within this chapter'])ActionChip(label:Text(hint),onPressed:()=>instruction.text=hint)]),
    ])),
    const SizedBox(height:12),FilledButton.icon(onPressed:c.busy||chapter==null?null:run,
      icon:c.busy?const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.auto_awesome_outlined,size:18),
      label:Text(c.busy?'Working…':'${label(command)} with AI')),
    OperationNotice(error:c.error,activity:c.activity),
    if(c.historyWarning!=null)Text(c.historyWarning!,style:const TextStyle(color:AppTheme.warning)),
    if(c.summary!=null)...[const Divider(height:30),Text(c.summary!,style:Theme.of(context).textTheme.titleMedium),
      for(final f in c.findings)Card(child:ListTile(title:Text(f['title']!),subtitle:Text(f['detail']!)))],
    if(c.questions.isNotEmpty)...[
      const Divider(height:30),Text('${c.questions.length} MCQs · ${c.checkedIds.length} AI checked · ${c.duplicates.length} similar',style:Theme.of(context).textTheme.titleMedium),
      const Text('AI checked = a separate answer-solving pass, not a guarantee. Edited questions lose that label.',style:TextStyle(color:AppTheme.muted,fontSize:12)),
      const SizedBox(height:10),Wrap(spacing:8,children:[for(final d in const ['easy','medium','hard'])Chip(label:Text('$d: ${c.questions.where((q)=>c.difficulty[q.id]==d).length}'))]),
      for(var i=0;i<c.questions.length;i++)Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        if(c.duplicates.any((h)=>h.generated.id==c.questions[i].id))const Padding(padding:EdgeInsets.all(8),child:Text('⚠ Similar to your bank, previous AI questions or this paper. Edit, replace or remove before use.',style:TextStyle(color:AppTheme.warning))),
        PaperQuestionCard(question:c.questions[i],number:i+1,onEdit:c.busy?null:(q)=>c.edit(i,q),onDelete:c.busy?null:()=>c.remove(i),
          onReplace:c.busy?null:()=>c.replace(i)),

      ]),
      const SizedBox(height:10),FilledButton.icon(onPressed:!c.canUse?null:(){
        if(widget.forSelection)Navigator.pop(context,c.questions);
        else Navigator.pushNamed(context,AppRoutes.createPaper,arguments:CreatePaperArgs(subjectId:subject,questions:c.questions));
      },icon:const Icon(Icons.description_outlined),label:Text(widget.forSelection?'Add reviewed questions':'Use in Create Paper')),
    ],
  ]));
}
