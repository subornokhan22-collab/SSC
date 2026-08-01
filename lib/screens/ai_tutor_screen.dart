import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AITutorScreen extends StatefulWidget {
  const AITutorScreen({super.key});

  @override
  State<AITutorScreen> createState() => _AITutorScreenState();
}

class _AITutorScreenState extends State<AITutorScreen> {
  final String _apiKey = 'YOUR_GEMINI_API_KEY'; // Replace with your actual Gemini API key

  Future<void> _sendMessage(String userMessage) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY') {
      return;
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey',
    );

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": userMessage}
          ]
        }
      ]
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle successful response data here
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Tutor')),
      body: const Center(
        child: Text('AI Tutor Ready'),
      ),
    );
  }
}
