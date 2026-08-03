import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_question_generator.dart';
import '../services/chapter_source_service.dart';
import '../widgets/app_button.dart';
import 'quiz_screen.dart';

class AiGenerateScreen extends StatefulWidget {
  final String subjectId;
  final String subjectName;
  final String chapter;

  const AiGenerateScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.chapter,
  });

  @override
  State<AiGenerateScreen> createState() => _AiGenerateScreenState();
}

class _AiGenerateScreenState extends State<AiGenerateScreen> {
  final TextEditingController _countController = TextEditingController(text: '10');
  bool _loading = false;
  bool _loadingSource = true;
  String? _error;
  String? _apiKey;
  String _sourceText = '';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final source = await ChapterSourceService.getSource(widget.subjectId, widget.chapter);
    setState(() {
      _apiKey = prefs.getString('gemini_api_key');
      _sourceText = source;
      _loadingSource = false;
    });
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

  Future<void> _generate() async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      await _promptForKey();
      if (_apiKey == null || _apiKey!.isEmpty) return;
    }
    final count = int.tryParse(_countController.text.trim()) ?? 10;
    setState(() { _loading = true; _error = null; });
    try {
      final questions = await AiQuestionGenerator.generateMcqs(
        apiKey: _apiKey!,
        subjectName: widget.subjectName,
        chapter: widget.chapter,
        sourceText: _sourceText,
        count: count,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizScreen(customQuestions: questions, customTitle: 'AI প্রশ্ন: ${widget.chapter}'),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI দিয়ে প্রশ্ন তৈরি করো')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.subjectName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.chapter, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            if (_loadingSource)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _sourceText.trim().isEmpty ? Colors.orange.withOpacity(0.08) : Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _sourceText.trim().isEmpty ? Colors.orange.shade200 : Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      _sourceText.trim().isEmpty ? Icons.info_outline : Icons.check_circle_outline,
                      color: _sourceText.trim().isEmpty ? Colors.orange : Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _sourceText.trim().isEmpty
                            ? 'এই অধ্যায়ের জন্য এখনো নির্দিষ্ট পাঠ্য উপকরণ যোগ করা হয়নি — সাধারণ SSC জ্ঞান থেকে প্রশ্ন তৈরি হবে।'
                            : 'এই অধ্যায়ের পাঠ্য উপকরণ যুক্ত আছে — সেটির ভিত্তিতে প্রশ্ন তৈরি হবে।',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('প্রশ্ন সংখ্যা:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                SizedBox(
                  width: 70,
                  child: TextField(
                    controller: _countController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            AppButton(
              label: _loading ? 'তৈরি হচ্ছে...' : 'নতুন প্রশ্ন তৈরি করো',
              icon: Icons.auto_awesome,
              onPressed: (_loading || _loadingSource) ? null : _generate,
            ),
          ],
        ),
      ),
    );
  }
}
