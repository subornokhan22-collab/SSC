import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage(this.text, this.isUser);
}

class AITutorScreen extends StatefulWidget {
  const AITutorScreen({super.key});

  @override
  State<AITutorScreen> createState() => _AITutorScreenState();
}

class _AITutorScreenState extends State<AITutorScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _apiKey;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _apiKey = prefs.getString('gemini_api_key'));
  }

  Future<void> _saveKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', key);
    setState(() => _apiKey = key);
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
    if (result != null && result.isNotEmpty) await _saveKey(result);
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (_apiKey == null || _apiKey!.isEmpty) {
      await _promptForKey();
      if (_apiKey == null || _apiKey!.isEmpty) return;
    }

    setState(() {
      _messages.add(ChatMessage(text, true));
      _controller.clear();
      _loading = true;
    });
    _scrollToBottom();

    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent?key=$_apiKey');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'তুমি একজন বাংলাদেশি SSC শিক্ষার্থীর জন্য একজন সহায়ক শিক্ষক। প্রশ্নটির সহজ ও স্পষ্ট বাংলা উত্তর দাও: $text'}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'দুঃখিত, উত্তর পাওয়া যায়নি।';
        setState(() => _messages.add(ChatMessage(reply, false)));
      } else {
        setState(() => _messages.add(ChatMessage('ত্রুটি: ${response.statusCode}। API Key সঠিক কিনা যাচাই করুন।', false)));
      }
    } catch (e) {
      setState(() => _messages.add(ChatMessage('সংযোগ ত্রুটি হয়েছে। ইন্টারনেট চেক করুন।', false)));
    } finally {
      setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI টিউটর'), actions: [IconButton(icon: const Icon(Icons.key), onPressed: _promptForKey)]),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(child: Text('তোমার পড়ার যেকোনো প্রশ্ন করো!', style: TextStyle(color: Colors.grey[500])))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final m = _messages[index];
                      return Align(
                        alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            gradient: m.isUser
                                ? const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary])
                                : null,
                            color: m.isUser ? null : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
                          ),
                          child: Text(m.text, style: TextStyle(color: m.isUser ? Colors.white : Colors.black87)),
                        ),
                      );
                    },
                  ),
          ),
          if (_loading) const LinearProgressIndicator(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'তোমার প্রশ্ন লিখো...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _loading
                          ? null
                          : const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
                      color: _loading ? Colors.grey.shade300 : null,
                      boxShadow: _loading
                          ? []
                          : [BoxShadow(color: AppTheme.primary.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _loading ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
