  Future<String> _fetchGeminiResponse(String prompt) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY') {
      return 'API Key সংযুক্ত করা হয়নি। অনুগ্রহ করে আপনার Google Gemini API Key বসান।';
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey',
    );

    final body = jsonEncode({
      "system_instruction": {
        "parts": [
          {
            "text": "You are an expert Bangladeshi SSC Exam Tutor for A-Learning platform. Your target audience is SSC candidates in Bangladesh. Answer clearly, accurately, and politely in Bengali."
          }
        ]
      },
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": prompt}
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
      throw Exception('Failed to communicate with AI API: ${response.statusCode}');
    }
  }
