import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/gemini_client.dart';
import '../theme/app_theme.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;
  ChatMessage(this.text, this.isUser, {this.isError = false});
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

  /// Strips LaTeX/Markdown artifacts the model sometimes emits and
  /// converts common math notation into plain readable Unicode,
  /// since this chat renders plain Text (no LaTeX engine).
  String _cleanMathText(String raw) {
    String s = raw;

    // Remove markdown bold/italic/headers
    s = s.replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1');
    s = s.replaceAll(RegExp(r'\*(.*?)\*'), r'$1');
    s = s.replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '');

    // Remove LaTeX delimiters: $$...$$, $...$, \( \), \[ \]
    s = s.replaceAll(r'$$', '');
    s = s.replaceAll(r'$', '');
    s = s.replaceAll(r'\(', '').replaceAll(r'\)', '');
    s = s.replaceAll(r'\[', '').replaceAll(r'\]', '');

    // \frac{a}{b} -> (a/b)
    s = s.replaceAllMapped(
      RegExp(r'\\frac\{([^{}]*)\}\{([^{}]*)\}'),
      (m) => '(${m[1]}/${m[2]})',
    );

    // Common LaTeX operators -> Unicode
    final replacements = <String, String>{
      r'\times': '×',
      r'\cdot': '·',
      r'\div': '÷',
      r'\pm': '±',
      r'\sqrt': '√',
      r'\pi': 'π',
      r'\theta': 'θ',
      r'\alpha': 'α',
      r'\beta': 'β',
      r'\gamma': 'γ',
      r'\Delta': 'Δ',
      r'\delta': 'δ',
      r'\lambda': 'λ',
      r'\omega': 'ω',
      r'\leq': '≤',
      r'\geq': '≥',
      r'\neq': '≠',
      r'\approx': '≈',
      r'\infty': '∞',
      r'\rightarrow': '→',
      r'\Rightarrow': '⇒',
      r'\%': '%',
      r'\,': ' ',
      r'\ ': ' ',
    };
    replacements.forEach((k, v) => s = s.replaceAll(k, v));

    // Superscripts for common exponents: x^2 -> x², x^3 -> x³
    s = s.replaceAllMapped(RegExp(r'\^\{?2\}?'), (m) => '²');
    s = s.replaceAllMapped(RegExp(r'\^\{?3\}?'), (m) => '³');
    s = s.replaceAllMapped(RegExp(r'\^\{?(-?\d+)\}?'), (m) => '^${m[1]}');

    // Subscripts for common single-digit indices: x_1 -> x₁ (best-effort)
    const subDigits = {'0':'₀','1':'₁','2':'₂','3':'₃','4':'₄','5':'₅','6':'₆','7':'₇','8':'₈','9':'₉'};
    s = s.replaceAllMapped(RegExp(r'_\{?(\d)\}?'), (m) => subDigits[m[1]] ?? '_${m[1]}');

    // Clean leftover stray backslashes and double spaces
    s = s.replaceAll(RegExp(r'\\(?![a-zA-Z])'), '');
    s = s.replaceAll(RegExp(r' {2,}'), ' ');
    s = s.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return s.trim();
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

    const systemInstruction = 'তুমি একজন বাংলাদেশি SSC শিক্ষার্থীর জন্য একজন সহায়ক শিক্ষক। '
        'প্রশ্নটির সহজ ও স্পষ্ট বাংলা উত্তর দাও। '
        'গুরুত্বপূর্ণ ফরম্যাটিং নিয়ম: '
        'কখনো LaTeX ব্যবহার করবে না (\\frac, \\times, \$...\$, \\(...\\) ইত্যাদি নিষিদ্ধ)। '
        'কখনো markdown ব্যবহার করবে না (** বোল্ড বা # হেডিং নিষিদ্ধ)। '
        'গাণিতিক রাশি লিখতে সাধারণ টেক্সট ও ইউনিকোড চিহ্ন ব্যবহার করো, যেমন: x^2 এর বদলে x², ভগ্নাংশের জন্য a/b, গুণের জন্য ×, বর্গমূলের জন্য √। '
        'প্রতিটি ধাপ আলাদা লাইনে সহজভাবে লেখো, যেন সাধারণ চ্যাট মেসেজে পরিষ্কার দেখায়। '
        'প্রশ্ন: ';

    try {
      final rawReply = await GeminiClient.generate(
        apiKey: _apiKey!,
        prompt: '$systemInstruction$text',
        temperature: 0.6,
      );
      final reply = rawReply.trim().isEmpty
          ? 'দুঃখিত, উত্তর পাওয়া যায়নি।'
          : _cleanMathText(rawReply);
      setState(() => _messages.add(ChatMessage(reply, false)));
    } on Exception catch (e) {
      setState(() => _messages.add(ChatMessage(
        e.toString().replaceFirst('Exception: ', ''),
        false,
        isError: true,
      )));
    } catch (_) {
      setState(() => _messages.add(ChatMessage(
        'অজানা সমস্যা হয়েছে। আবার চেষ্টা করো।',
        false,
        isError: true,
      )));
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

  Widget _buildBubble(ChatMessage m) {
    return Align(
      alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          gradient: m.isUser
              ? const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary])
              : null,
          color: m.isUser
              ? null
              : (m.isError ? Colors.red.withOpacity(0.06) : Colors.white),
          border: m.isError
              ? Border.all(color: Colors.red.withOpacity(0.4))
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (m.isError) ...[
              const Icon(Icons.info_outline, size: 17, color: Colors.red),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: SelectableText(
                m.text,
                style: TextStyle(
                  color: m.isUser
                      ? Colors.white
                      : (m.isError ? Colors.red.shade800 : Colors.black87),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                    itemCount: _messages.length + (_loading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_loading && index == _messages.length) {
                        return const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: _TypingIndicator(),
                          ),
                        );
                      }
                      return _buildBubble(_messages[index]);
                    },
                  ),
          ),
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

/// Three bouncing dots shown while the tutor is "typing".
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              // Each dot bounces with a phase offset.
              final phase = (_c.value * 3 - i).clamp(0.0, 1.0);
              final bounce = phase < 0.5 ? phase * 2 : (1 - phase) * 2;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                width: 8,
                height: 8 + 4 * bounce,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.35 + 0.45 * bounce),
                  shape: BoxShape.circle,
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
