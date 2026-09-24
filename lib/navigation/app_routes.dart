import 'package:flutter/material.dart';
import '../data/questions_data.dart';
import '../models/paper_draft.dart';
import '../screens/create_paper_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/subscription_screen.dart';
import '../screens/ai_tools_screen.dart';

class CreatePaperArgs {
  final String? subjectId;
  final PaperFormat? format;
  final List<Question>? questions;
  const CreatePaperArgs({this.subjectId, this.format, this.questions});
}

class AppRoutes {
  static const createPaper = '/create-paper';
  static const settings = '/settings';
  static const plans = '/plans';
  static const ai = '/ai-tools';
  static Route<dynamic>? generate(RouteSettings route) {
    Widget screen;
    switch (route.name) {
      case createPaper:
        final a = route.arguments as CreatePaperArgs?;
        screen = CreatePaperScreen(
            initialSubjectId: a?.subjectId,
            initialFormat: a?.format,
            initialQuestions: a?.questions);
        break;
      case settings:
        screen = const SettingsScreen();
        break;
      case plans:
        screen = const SubscriptionScreen();
        break;
      case ai:
        screen = const AiToolsScreen();
        break;
      default:
        return null;
    }
    return MaterialPageRoute(settings: route, builder: (_) => screen);
  }
}
