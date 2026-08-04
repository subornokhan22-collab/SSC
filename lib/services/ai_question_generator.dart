import 'dart:convert';
import '../data/questions_data.dart';
import 'gemini_client.dart';

class AiQuestionGenerator {
  static Future<List<Question>> generateMcqs({
    required String apiKey,
    required String subjectName,
    required String chapter,
    required String sourceText,
    int count = 10,
  }) async {
    final sourceBlock = sourceText.trim().isEmpty
        ? 'কোনো নির্দিষ্ট উৎস টেক্সট দেওয়া হয়নি; বাংলাদেশ SSC পাঠ্যবই অনুযায়ী সাধারণ জ্ঞান ব্যবহার করো।'
        : 'নিচের পাঠ্য উপকরণের ভিত্তিতে প্রশ্ন তৈরি করো:\n"""\n${sourceText.trim()}\n"""';

    final prompt = '''
তুমি একজন বাংলাদেশি SSC ২০২৭ পরীক্ষার প্রশ্ন প্রণয়নকারী।
বিষয়: $subjectName
অধ্যায়: $chapter

$sourceBlock

$count টি সম্পূর্ণ নতুন ও অনন্য (unique) বহুনির্বাচনি প্রশ্ন (MCQ) বাংলায় তৈরি করো, প্রতিটিতে ৪টি অপশন থাকবে।
নিয়মাবলি (কঠোরভাবে মেনে চলো):
- শুধুমাত্র একটি বৈধ JSON অ্যারে আউটপুট দাও, অন্য কোনো টেক্সট, ব্যাখ্যা, কোড ফেন্স, বা মার্কডাউন নয়।
- প্রতিটি প্রশ্ন অবজেক্টে থাকবে ঠিক এই key গুলো: "question", "options" (৪টি স্ট্রিং এর array), "correct" (0-3 এর মধ্যে সঠিক অপশনের index), "explanation"।
- LaTeX বা মার্কডাউন ব্যবহার করবে না; গাণিতিক রাশি লিখতে ইউনিকোড চিহ্ন ব্যবহার করো (x², √, ×, ÷)।
- প্রতিবার ভিন্ন ভিন্ন প্রশ্ন তৈরি করো।
''';

    final raw = await GeminiClient.generate(
      apiKey: apiKey,
      prompt: prompt,
      temperature: 0.9,
    );
    return _parseMcqs(raw);
  }

  static List<Question> _parseMcqs(String raw) {
    raw = _stripCodeFence(raw);

    final start = raw.indexOf('[');
    final end = raw.lastIndexOf(']');
    if (start == -1 || end == -1 || end < start) {
      throw Exception('AI থেকে সঠিক ফরম্যাটে উত্তর পাওয়া যায়নি। আবার চেষ্টা করো।');
    }
    raw = raw.substring(start, end + 1);

    final List<dynamic> parsed = jsonDecode(raw);
    final questions = <Question>[];
    for (var i = 0; i < parsed.length; i++) {
      final item = parsed[i];
      try {
        final options = List<String>.from(item['options']);
        if (options.length != 4) continue;
        questions.add(Question(
          id: 'ai_gen_${DateTime.now().millisecondsSinceEpoch}_$i',
          subjectId: 'ai_generated',
          chapter: '',
          questionText: item['question'].toString(),
          options: options,
          correctIndex: int.parse(item['correct'].toString()),
          explanation: item['explanation']?.toString() ?? '',
          source: QuestionSource.ai,
        ));
      } catch (_) {
        continue;
      }
    }

    if (questions.isEmpty) {
      throw Exception('কোনো বৈধ প্রশ্ন পার্স করা যায়নি। আবার চেষ্টা করো।');
    }
    return questions;
  }

  static Future<List<String>> generateShortQuestions({
    required String apiKey,
    required String subjectName,
    required String chapter,
    required String sourceText,
    int count = 8,
  }) async {
    final sourceBlock = sourceText.trim().isEmpty
        ? 'কোনো নির্দিষ্ট উৎস টেক্সট দেওয়া হয়নি; বাংলাদেশ SSC পাঠ্যবই অনুযায়ী সাধারণ জ্ঞান ব্যবহার করো।'
        : 'নিচের পাঠ্য উপকরণের ভিত্তিতে প্রশ্ন তৈরি করো:\n"""\n${sourceText.trim()}\n"""';

    final prompt = '''
তুমি একজন বাংলাদেশি SSC ২০২৭ পরীক্ষার প্রশ্ন প্রণয়নকারী।
বিষয়: $subjectName
অধ্যায়: $chapter
$sourceBlock

$count টি সংক্ষিপ্ত প্রশ্ন (জ্ঞানমূলক ও অনুধাবনমূলক) বাংলায় তৈরি করো।
নিয়মাবলি:
- শুধুমাত্র একটি বৈধ JSON স্ট্রিং অ্যারে আউটপুট দাও, অন্য কোনো টেক্সট নয়।
- প্রতিটি স্ট্রিং একটি সম্পূর্ণ প্রশ্ন হবে।
- LaTeX বা মার্কডাউন ব্যবহার করবে না।
''';

    final raw = await GeminiClient.generate(
      apiKey: apiKey,
      prompt: prompt,
      temperature: 0.9,
    );
    return _parseStringArray(raw, 'সঠিক ফরম্যাট পাওয়া যায়নি।');
  }

  static Future<List<CreativeQuestion>> generateCqs({
    required String apiKey,
    required String subjectName,
    required String chapter,
    required String sourceText,
    int count = 3,
  }) async {
    final sourceBlock = sourceText.trim().isEmpty
        ? 'কোনো নির্দিষ্ট উৎস টেক্সট দেওয়া হয়নি; বাংলাদেশ SSC পাঠ্যবই অনুযায়ী সাধারণ জ্ঞান ব্যবহার করো।'
        : 'নিচের পাঠ্য উপকরণের ভিত্তিতে প্রশ্ন তৈরি করো:\n"""\n${sourceText.trim()}\n"""';

    final prompt = '''
তুমি একজন বাংলাদেশি SSC ২০২৭ পরীক্ষার সৃজনশীল প্রশ্ন প্রণয়নকারী।
বিষয়: $subjectName
অধ্যায়: $chapter
$sourceBlock

$count টি সৃজনশীল প্রশ্ন (উদ্দীপক + ক/খ/গ/ঘ) বাংলায় তৈরি করো।
শুধুমাত্র একটি বৈধ JSON অ্যারে আউটপুট দাও, প্রতিটি অবজেক্টে থাকবে: "stem", "k", "kh", "g", "gh"।
LaTeX বা মার্কডাউন ব্যবহার করবে না।
''';

    final raw = await GeminiClient.generate(
      apiKey: apiKey,
      prompt: prompt,
      temperature: 0.9,
    );
    return _parseCqs(raw, chapter);
  }

  static List<String> _parseStringArray(String raw, String errorMsg) {
    raw = _stripCodeFence(raw);
    final start = raw.indexOf('[');
    final end = raw.lastIndexOf(']');
    if (start == -1 || end == -1) throw Exception(errorMsg);
    raw = raw.substring(start, end + 1);

    final List<dynamic> parsed = jsonDecode(raw);
    return parsed.map((e) => e.toString()).toList();
  }

  static List<CreativeQuestion> _parseCqs(String raw, String chapter) {
    raw = _stripCodeFence(raw);
    final start = raw.indexOf('[');
    final end = raw.lastIndexOf(']');
    if (start == -1 || end == -1) throw Exception('সঠিক ফরম্যাট পাওয়া যায়নি।');
    raw = raw.substring(start, end + 1);

    final List<dynamic> parsed = jsonDecode(raw);
    final list = <CreativeQuestion>[];
    for (var i = 0; i < parsed.length; i++) {
      final item = parsed[i];
      try {
        list.add(CreativeQuestion(
          id: 'ai_cq_${DateTime.now().millisecondsSinceEpoch}_$i',
          subjectId: 'ai_generated',
          chapter: chapter,
          stem: item['stem'].toString(),
          questionK: item['k'].toString(),
          questionKh: item['kh'].toString(),
          questionG: item['g'].toString(),
          questionGh: item['gh'].toString(),
          source: QuestionSource.ai,
        ));
      } catch (_) {
        continue;
      }
    }
    return list;
  }

  static String _stripCodeFence(String raw) {
    raw = raw.trim();
    if (raw.startsWith('```')) {
      raw = raw.replaceFirst(RegExp(r'^```[a-zA-Z]*\n?'), '');
      if (raw.endsWith('```')) raw = raw.substring(0, raw.length - 3);
    }
    return raw;
  }
}
