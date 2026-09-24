import 'package:flutter/material.dart';
import '../models/paper_draft.dart';
import '../navigation/app_routes.dart';
import '../services/auth_service.dart';
import '../services/paper_library.dart';
import '../theme/app_theme.dart';
import 'ai_tools_screen.dart';
import 'omr_scanner_screen.dart';
import 'papers_library_screen.dart';
import 'saved_paper_screen.dart';

/// Four predictable destinations. Lazy tabs avoid permission prompts and
/// network work for tools the teacher has not opened.
class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});
  @override State<TeacherHomeScreen> createState()=>_TeacherHomeScreenState();
}
class _TeacherHomeScreenState extends State<TeacherHomeScreen> with WidgetsBindingObserver {
  int tab=0;
  final visited=<int>{0};
  List<PaperEntry> recent=[];
  bool loading=true;
  String? error;
  @override void initState(){super.initState();WidgetsBinding.instance.addObserver(this);load();}
  @override void dispose(){WidgetsBinding.instance.removeObserver(this);super.dispose();}
  @override void didChangeAppLifecycleState(AppLifecycleState state){if(state==AppLifecycleState.resumed)load();}
  Future<void> load() async {try{final entries=await PaperLibrary.loadEntries();if(mounted)setState((){recent=entries.take(4).toList();loading=false;error=null;});}
    catch(_){if(mounted)setState((){loading=false;error='Your papers could not be loaded. Pull down to retry.';});}}
  Future<void> create({bool quick=false}) async {
    await Navigator.pushNamed(context,AppRoutes.createPaper,arguments:quick?const CreatePaperArgs(subjectId:'physics',format:PaperFormat.board):null);
    if(mounted)load();
  }
  void select(int i){setState((){tab=i;visited.add(i);});if(i==0)load();}
  @override Widget build(BuildContext context)=>PopScope(canPop:tab==0,onPopInvoked:(didPop){if(!didPop)select(0);},
    child:Scaffold(body:IndexedStack(index:tab,children:[home(),
      // Recreate the library on each visit so a just-saved paper is visible.
      tab==1?const PapersLibraryScreen():const SizedBox.shrink(),
      visited.contains(2)?const OMrScannerScreen():const SizedBox.shrink(),
      visited.contains(3)?const AiToolsScreen():const SizedBox.shrink(),
    ]),bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:select,destinations:const[
      NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home),label:'Home'),
      NavigationDestination(icon:Icon(Icons.folder_outlined),selectedIcon:Icon(Icons.folder),label:'My Papers'),
      NavigationDestination(icon:Icon(Icons.document_scanner_outlined),label:'Scan'),
      NavigationDestination(icon:Icon(Icons.auto_awesome_outlined),label:'AI Tools'),
    ])));
  Widget home()=>Scaffold(appBar:AppBar(title:const Text("Tutor’s Desk"),actions:[
    IconButton(tooltip:'Settings',onPressed:()async{await Navigator.pushNamed(context,AppRoutes.settings);if(mounted)load();},icon:const Icon(Icons.settings_outlined)),
  ]),body:RefreshIndicator(onRefresh:load,child:ListView(padding:const EdgeInsets.all(20),children:[
    Text(AuthService.isLoggedIn?'Welcome, ${AuthService.displayName.isEmpty?'teacher':AuthService.displayName}':'Your teaching workspace',style:Theme.of(context).textTheme.headlineSmall),
    const SizedBox(height:8),const Text('Prepare a paper. Review the answers. Start your class.',style:TextStyle(color:AppTheme.muted)),
    const SizedBox(height:24),Card(child:Padding(padding:const EdgeInsets.all(22),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Icon(Icons.description_outlined,color:AppTheme.primary,size:34),const SizedBox(height:14),
      Text('Create a Question Paper',style:Theme.of(context).textTheme.titleLarge),const SizedBox(height:6),
      const Text('Board Pattern, Chapter Test or MCQ + OMR — one guided workflow.'),const SizedBox(height:18),
      SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:()=>create(),icon:const Icon(Icons.add),label:const Text('Create / resume paper'))),
      TextButton(onPressed:()=>create(quick:true),child:const Text('Start a Physics Model Test →')),
    ]))),
    const SizedBox(height:12),Row(children:[Expanded(child:quickAction(Icons.document_scanner_outlined,'Scan OMR','Review & grade',()=>select(2))),
      const SizedBox(width:12),Expanded(child:quickAction(Icons.auto_awesome_outlined,'AI Tools','Create · Improve · Check',()=>select(3)))]),
    const SizedBox(height:24),Row(children:[Text('Recent papers',style:Theme.of(context).textTheme.titleLarge),const Spacer(),TextButton(onPressed:()=>select(1),child:const Text('View all'))]),
    if(loading)const LinearProgressIndicator() else if(error!=null)Text(error!) else if(recent.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(24),child:Text('No saved papers yet. Create your first paper; it will appear here.'))),
    for(final entry in recent)Card(child:ListTile(leading:const Icon(Icons.description_outlined,color:AppTheme.primary),title:Text(entry.title,maxLines:1,overflow:TextOverflow.ellipsis),
      subtitle:Text('${entry.subject} · ${entry.pages} pages · ${entry.createdAt.day}/${entry.createdAt.month}'),trailing:const Icon(Icons.chevron_right),
      onTap:()async{await Navigator.push(context,MaterialPageRoute(builder:(_)=>SavedPaperScreen(entry:entry)));if(mounted)load();})),
  ])));
  Widget quickAction(IconData icon,String title,String subtitle,VoidCallback action)=>Card(child:InkWell(onTap:action,borderRadius:BorderRadius.circular(16),child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Icon(icon,color:AppTheme.primary),const SizedBox(height:10),Text(title,style:const TextStyle(fontWeight:FontWeight.w700)),const SizedBox(height:4),Text(subtitle,style:const TextStyle(color:AppTheme.muted,fontSize:12)),
  ]))));
}
