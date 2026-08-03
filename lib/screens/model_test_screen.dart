import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/questions_data.dart';
import '../services/ai_question_generator.dart';
import '../services/chapter_source_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import 'subjects_screen.dart';
import 'quiz_screen.dart';

class ModelTestScreen extends StatefulWidget {
  const ModelTestScreen({super.key});

  @override
  State<ModelTestScreen> createState() => _ModelTestScreenState();
}

class _ModelTestScreenState extends State<ModelTestScreen> {
  SubjectInfo? _subject;
  String? _apiKey;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _apiKey = prefs.getString('gemini_api_key'));
  }

  Future<void> _promptForKey() async {
    final controller = TextEditingController(text: _apiKey ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gemini API Key'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'পেস্ট করুন আপনার API Key'), obscureText: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('সংরক্ষণ')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gemini_api_key', result);
      setState(() => _apiKey = result);
    }
  }

  List<String> get _chaptersForSubject {
    if (_subject == null) return [];
    final set = <String>{
      ...allMCQs.where((q) => q.subjectId == _subject!.id).map((q) => q.chapter),
      ...allCQs.where((q) => q.subjectId == _subject!.id).map((q) => q.chapter),
    };
    return set.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ফুল মডেল টেস্ট')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('বিষয় নির্বাচন করো', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            DropdownButtonFormField<SubjectInfo>(
              value: _subject,
              decoration: InputDecoration(
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: allSubjects.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
              onChanged: (s) => setState(() => _subject = s),
              hint: const Text('একটি বিষয় বাছাই করো'),
            ),
            const SizedBox(height: 24),
            if (_subject != null)
              Expanded(
                child: _ModelTestSections(
                  subject: _subject!,
                  chapters: _chaptersForSubject,
                  apiKey: _apiKey,
                  onNeedKey: _promptForKey,
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Text(
                    'একটি বিষয় বেছে নিলে MCQ, সংক্ষিপ্ত প্রশ্ন ও সৃজনশীল প্রশ্ন সহ পূর্ণাঙ্গ টেস্ট তৈরি হবে।',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ModelTestSections extends StatefulWidget {
  final SubjectInfo subject;
  final List<String> chapters;
  final String? apiKey;
  final VoidCallback onNeedKey;

  const _ModelTestSections({
    required this.subject,
    required this.chapters,
    required this.apiKey,
    required this.onNeedKey,
  });

  @override
  State<_ModelTestSections> createState() => _ModelTestSectionsState();
}

class _ModelTestSectionsState extends State<_ModelTestSections> {
  bool _loadingMcq = false;
  bool _loadingSq = false;
  bool _loadingCq = false;
  String? _error;
  List<String> _shortQuestions = [];
  List<CreativeQuestion> _cqs = [];

  Future<String> _combinedSource() async {
    final buffer = StringBuffer();
    for (final chapter in widget.chapters) {
      final src = await ChapterSourceService.getSource(widget.subject.id, chapter);
      if (src.trim().isNotEmpty) {
        buffer.writeln('--- $chapter ---');
        buffer.writeln(src.trim());
      }
    }
    return buffer.toString();
  }

  Future<bool> _ensureKey() async {
    if (widget.apiKey == null || widget.apiKey!.isEmpty) {
      widget.onNeedKey();
      return false;
    }
    return true;
  }

  Future<void> _startMcqSection() async {
    if (!await _ensureKey()) return;
    setState(() { _loadingMcq = true; _error = null; });
    try {
      final existing = allMCQs.where((q) => q.subjectId == widget.subject.id).toList();
      List<Question> combined = List.of(existing)..shuffle();
      if (combined.length < 30) {
        final source = await _combinedSource();
        final needed = 30 - combined.length;
        final generated = await AiQuestionGenerator.generateMcqs(
          apiKey: widget.apiKey!,
          subjectName: widget.subject.name,
          chapter: widget.chapters.isEmpty ? 'সাধারণ' : widget.chapters.join(', '),
          sourceText: source,
          count: needed,
        );
        combined = [...combined, ...generated]..shuffle();
      }
      final finalSet = combined.take(30).toList();
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => QuizScreen(customQuestions: finalSet, customTitle: 'মডেল টেস্ট: ${widget.subject.name}'),
      ));
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingMcq = false);
    }
  }

  Future<void> _loadShortQuestions() async {
    if (!await _ensureKey()) return;
    setState(() { _loadingSq = true; _error = null; });
    try {
      final source = await _combinedSource();
      final qs = await AiQuestionGenerator.generateShortQuestions(
        apiKey: widget.apiKey!,
        subjectName: widget.subject.name,
        chapter: widget.chapters.isEmpty ? 'সাধারণ' : widget.chapters.join(', '),
        sourceText: source,
        count: 8,
      );
      setState(() => _shortQuestions = qs);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingSq = false);
    }
  }

  Future<void> _loadCqs() async {
    if (!await _ensureKey()) return;
    setState(() { _loadingCq = true; _error = null; });
    try {
      final existing = allCQs.where((q) => q.subjectId == widget.subject.id).toList();
      final source = await _combinedSource();
      final generated = await AiQuestionGenerator.generateCqs(
        apiKey: widget.apiKey!,
        subjectName: widget.subject.name,
        chapter: widget.chapters.isEmpty ? 'সাধারণ' : widget.chapters.join(', '),
        sourceText: source,
        count: 3,
      );
      setState(() => _cqs = [...existing, ...generated]);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingCq = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            labelColor: AppTheme.primary,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'MCQ'),
              Tab(text: 'সংক্ষিপ্ত প্রশ্ন'),
              Tab(text: 'সৃজনশীল'),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: TabBarView(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '৩০টি প্রশ্ন, ৩০ মিনিট সময়সীমা।\nবিদ্যমান প্রশ্ন কম থাকলে বাকিগুলো AI দিয়ে তৈরি হবে।',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          label: _loadingMcq ? 'তৈরি হচ্ছে...' : 'MCQ পরীক্ষা শুরু করো',
                          icon: Icons.play_arrow,
                          fullWidth: false,
                          onPressed: _loadingMcq ? null : _startMcqSection,
                        ),
                      ],
                    ),
                  ),
                ),
                _shortQuestions.isEmpty
                    ? Center(
                        child: AppButton(
                          label: _loadingSq ? 'তৈরি হচ্ছে...' : 'সংক্ষিপ্ত প্রশ্ন তৈরি করো',
                          icon: Icons.auto_awesome,
                          fullWidth: false,
                          onPressed: _loadingSq ? null : _loadShortQuestions,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _shortQuestions.length,
                        itemBuilder: (context, i) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text('${i + 1}. ${_shortQuestions[i]}'),
                          ),
                        ),
                      ),
                _cqs.isEmpty
                    ? Center(
                        child: AppButton(
                          label: _loadingCq ? 'তৈরি হচ্ছে...' : 'সৃজনশীল প্রশ্ন তৈরি করো',
                          icon: Icons.auto_awesome,
                          fullWidth: false,
                          onPressed: _loadingCq ? null : _loadCqs,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _cqs.length,
                        itemBuilder: (context, i) {
                          final cq = _cqs[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 14),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cq.chapter, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  const SizedBox(height: 6),
                                  Text(cq.stem, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const Divider(height: 20),
                                  Text('ক. ${cq.questionK}'),
                                  const SizedBox(height: 6),
                                  Text('খ. ${cq.questionKh}'),
                                  const SizedBox(height: 6),
                                  Text('গ. ${cq.questionG}'),
                                  const SizedBox(height: 6),
                                  Text('ঘ. ${cq.questionGh}'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
