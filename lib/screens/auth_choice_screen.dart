import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';

/// অ্যাপ প্রথম খোলার স্বাগত-পর্দা — সাইন ইন / সাইন আপ বাছাই
/// (চলমান গ্রেডিয়েন্ট অ্যানিমেটেড ব্যাকগ্রাউন্ডসহ)
class AuthChoiceScreen extends StatefulWidget {
  const AuthChoiceScreen({super.key});

  @override
  State<AuthChoiceScreen> createState() => _AuthChoiceScreenState();
}

class _AuthChoiceScreenState extends State<AuthChoiceScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1 + t, -1),
                end: Alignment(1 - t, 1),
                colors: const [
                  Color(0xFF0D3B66),
                  Color(0xFF14538C),
                  Color(0xFF1B8A8F),
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // ভাসমান আলোর গোলাকার ঝলক
                  _blob(t, 0.85, 0.12, 150, const Color(0xFF41C4C9).withOpacity(0.35)),
                  _blob(1 - t, 0.05, 0.75, 190, const Color(0xFFF7B733).withOpacity(0.22)),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white30, width: 1.5),
                            ),
                            child: const Icon(Icons.school_rounded,
                                size: 54, color: Colors.white),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'A-Learning',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'SSC 2027 — প্রশ্নব্যাংক, মডেল টেস্ট ও AI টিউটর',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Colors.white.withOpacity(0.85),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 34),
                          if (!AuthService.ready)
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text(
                                'লগইন ব্যবস্থা এখনো কনফিগার হয়নি।\nঅফলাইন সুবিধাগুলো ব্যবহার চালিয়ে যেতে নিচের বোতাম চাপো।',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
                              ),
                            )
                          else ...[
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF0D3B66),
                                  textStyle: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                                ),
                                icon: const Icon(Icons.login_rounded),
                                label: const Text('সাইন ইন'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white70, width: 1.6),
                                  textStyle: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                                ),
                                icon: const Icon(Icons.person_add_alt_1_rounded),
                                label: const Text('সাইন আপ (নতুন অ্যাকাউন্ট)'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _blob(double t, double fx, double fy, double r, Color color) {
    return Align(
      alignment: Alignment(fx * 2 - 1, fy * 2 - 1),
      child: Transform.scale(
        scale: 0.9 + 0.25 * t,
        child: Container(
          width: r,
          height: r,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}
