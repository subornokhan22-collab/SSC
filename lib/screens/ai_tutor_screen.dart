import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AITutorScreen extends StatefulWidget {
  const AITutorScreen({Key? key}) : super(key: key);

  @override
  State<AITutorScreen> createState() => _AITutorScreenState();
}

class _AITutorScreenState extends State<AITutorScreen> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'হ্যালো! আমি তোমার SSC AI টিউটর। পদার্থ, রসায়ন, উচ্চতর গণিত বা যেকোনো বিষয় নিয়ে প্রশ্ন করো, আমি সাহায্য করতে প্রস্তুত!',
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  // Embedded Gemini API Key
  static const String _apiKey = 'AQ.Ab8RN6JGuLGb3n0-eyKsvx7Vo2YJ7Q4i-yrBLcEdMRvjAS6nrw';

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final responseText = await _fetchGeminiResponse(text);
      setState(() {
        _messages.add(ChatMessage(
          text: responseText,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'দুঃখিত, কোনো একটি সমস্যা হয়েছে। অনুগ্রহ করে তোমার ইন্টারনেটের সংযোগ পরীক্ষা করে আবার চেষ্টা করো।',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Future<String> _fetchGeminiResponse(String prompt) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY') {
      return 'API Key সংযুক্ত করা হয়নি। অনুগ্রহ করে `ai_tutor_screen.dart` ফাইলে আপনার Google Gemini API Key বসান।';
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey',
    );

    final systemInstruction = '''
    You are an expert Bangladeshi SSC Exam Tutor for "A-Learning" platform.
    Your target audience is SSC 2027 candidates in Bangladesh.
    Answer all queries clearly, accurately, and politely in Bengali (or English if requested).
    Follow NCTB textbook guidelines and curriculum. Provide step-by-step mathematical derivations when solving problems.
    ''';

    final body = jsonEncode({
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": "$systemInstruction\n\nStudent Question: $prompt"}
          ]
        }
      ]
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      return text ?? 'উত্তর খুঁজে পাওয়া যায়নি।';
    } else {
      throw Exception('Failed to communicate with AI API');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI টিউটর (SSC Assistant)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A82BB),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Chat',
            onPressed: () {
              setState(() {
                _messages.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Bubbles List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildChatBubble(message);
              },
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A82BB)),
                  ),
                  SizedBox(width: 8),
                  Text('AI টিউটর উত্তর তৈরি করছে...', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),

          // Message Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'আপনার প্রশ্ন লিখুন (যেমন: ত্বরণের একক কী?)...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        fillColor: Colors.grey.shade100,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF1A82BB),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
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

  Widget _buildChatBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF1A82BB) : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isUser ? 12 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 12),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}
