import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';
import 'teacher_home_screen.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});
  @override Widget build(BuildContext context)=>Scaffold(body:SafeArea(child:Center(child:SingleChildScrollView(
    padding:const EdgeInsets.all(28),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:440),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Icon(Icons.description_outlined,size:60,color:AppTheme.primary),const SizedBox(height:28),
      Text('Tutor’s Desk',style:Theme.of(context).textTheme.headlineLarge),const SizedBox(height:14),
      Text('Question papers, ready for class.',style:Theme.of(context).textTheme.headlineSmall),const SizedBox(height:12),
      const Text('Choose from the SSC question bank, review a printable paper and grade OMR sheets. Offline paper building works without an account.'),const SizedBox(height:32),
      SizedBox(width:double.infinity,child:FilledButton(onPressed:()=>Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const TeacherHomeScreen())),child:const Text('Start creating a paper'))),
      const SizedBox(height:12),
      if(AuthService.ready)...[
        SizedBox(width:double.infinity,child:OutlinedButton(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const SignInScreen())),child:const Text('Sign in'))),
        Center(child:TextButton(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>const SignUpScreen())),child:const Text('Create a teacher account'))),
        const Text('Sign in to use server AI and sync your Pro access.',style:TextStyle(color:AppTheme.muted,fontSize:12)),
      ]else const Text('Sign-in is not configured. You can still work with the offline question bank.',style:TextStyle(color:AppTheme.muted,fontSize:12)),
    ]))))));
}
