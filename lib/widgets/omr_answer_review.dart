import 'package:flutter/material.dart';
import '../services/omr/omr_scanner.dart';
import '../theme/app_theme.dart';

/// Confidence is a measured ink gap, never a fabricated probability.
class OmrAnswerReview extends StatelessWidget {
  final OmScanResult result;
  final ValueChanged<OmScanResult> onChanged;
  const OmrAnswerReview({super.key,required this.result,required this.onChanged});
  @override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text('Review the detected answers',style:Theme.of(context).textTheme.titleLarge),const SizedBox(height:8),
    const Text('Compare with the photo. Amber rows need attention. Tap an option to correct a reading; leave real double marks as Double.'),
    const SizedBox(height:14),
    Row(children:[Expanded(child:TextFormField(initialValue:result.roll,decoration:const InputDecoration(labelText:'Roll'),
      onChanged:(v)=>onChanged(result.corrected(roll:v)))),const SizedBox(width:12),
      Expanded(child:TextFormField(initialValue:result.registration,decoration:const InputDecoration(labelText:'Registration'),
        onChanged:(v)=>onChanged(result.corrected(registration:v))))]),const SizedBox(height:12),
    for(var i=0;i<result.total;i++)_row(i),
    const Text('Ink gap is the darkest bubble minus the next darkest. It is a scan-quality signal, not a probability that the answer is correct.',style:TextStyle(color:AppTheme.muted,fontSize:12)),
  ]);
  Widget _row(int i){
    final inks=i<result.inks.length?result.inks[i]:<double>[];
    final sorted=List<double>.of(inks)..sort((a,b)=>b.compareTo(a));
    final gap=sorted.length>=2?sorted[0]-sorted[1]:0.0;
    final uncertain=result.answers[i]<0||gap<OMrScanner.minOptionMargin+0.08;
    final corrected=result.correctedIndices.contains(i);
    return Card(child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[Text('Question ${i+1}',style:const TextStyle(fontWeight:FontWeight.w700)),const Spacer(),
        Icon(corrected?Icons.edit_outlined:uncertain?Icons.warning_amber_rounded:Icons.check_circle_outline,size:16,color:corrected?AppTheme.primary:uncertain?AppTheme.warning:AppTheme.success)]),
      Text(corrected?'Teacher corrected':uncertain?'Review needed · ink gap ${gap.toStringAsFixed(2)}':'Clear mark · ink gap ${gap.toStringAsFixed(2)}',style:TextStyle(fontSize:12,color:uncertain&&!corrected?AppTheme.warning:AppTheme.muted)),
      const SizedBox(height:6),Wrap(spacing:6,children:[for(final answer in [0,1,2,3,-1,-2])ChoiceChip(
        label:Text(answer==-1?'Blank':answer==-2?'Double':['ক','খ','গ','ঘ'][answer]),selected:result.answers[i]==answer,
        onSelected:(_){final next=List<int>.of(result.answers)..[i]=answer;onChanged(result.corrected(answers:next));})]),
      if(inks.length==4)Row(children:[for(var o=0;o<4;o++)Expanded(child:Padding(padding:const EdgeInsets.only(right:8),child:Column(children:[
        LinearProgressIndicator(value:inks[o].clamp(0.0,1.0),backgroundColor:AppTheme.border,minHeight:3),
        Text('${['ক','খ','গ','ঘ'][o]} ${(inks[o]*100).round()}% ink',style:const TextStyle(fontSize:10,color:AppTheme.muted)),
      ])))]),
    ])));
  }
}

Future<OmScanResult?> reviewOmrSheet(BuildContext context,OmScanResult initial,{String title='Review OMR sheet'})=>
  Navigator.push<OmScanResult>(context,MaterialPageRoute(builder:(_)=>_ReviewScreen(initial,title)));
class _ReviewScreen extends StatefulWidget {
  final OmScanResult initial;
  final String title;
  const _ReviewScreen(this.initial,this.title);
  @override State<_ReviewScreen> createState()=>_ReviewScreenState();
}
class _ReviewScreenState extends State<_ReviewScreen>{
  late OmScanResult result=widget.initial;
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(widget.title)),
    body:ListView(padding:const EdgeInsets.all(16),children:[
      if(result.rectifiedJpeg!=null)SizedBox(height:300,child:InteractiveViewer(maxScale:5,child:Image.memory(result.rectifiedJpeg!,fit:BoxFit.contain))),
      OmrAnswerReview(result:result,onChanged:(r)=>setState(()=>result=r)),
    ]),bottomNavigationBar:SafeArea(child:Padding(padding:const EdgeInsets.all(16),child:FilledButton(
      onPressed:()=>Navigator.pop(context,result),child:const Text('Confirm answers & grade')))));
}
