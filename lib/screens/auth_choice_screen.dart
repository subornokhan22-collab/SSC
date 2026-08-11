import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/molten_gold_river.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';

/// First welcome screen with the Molten Gold River background.
class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MoltenGoldRiver(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(.62),
                      border: Border.all(color: const Color(0xFFFFE080), width: 1.5),
                      boxShadow: const [BoxShadow(color: Color(0x66D4A843), blurRadius: 24)],
                    ),
                    child: const Icon(Icons.school_rounded, size: 54, color: Color(0xFFFFE080)),
                  ),
                  const SizedBox(height: 18),
                  const Text('A-Learning', style: TextStyle(
                    color: Color(0xFFFFF5CF), fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 1.3,
                    shadows: [Shadow(color: Colors.black, blurRadius: 12)],
                  )),
                  const SizedBox(height: 7),
                  Text('SSC 2027 — Question Bank, Model Tests & AI Tutor', textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(.88), fontSize: 13.5, height: 1.5)),
                  const SizedBox(height: 36),
                  if (!AuthService.ready)
                    _notice()
                  else ...[
                    SizedBox(width: double.infinity, height: 54, child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFFE080), foregroundColor: const Color(0xFF241900),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.login_rounded), label: const Text('Sign In'),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignInScreen())),
                    )),
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, height: 54, child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFFF0B0),
                        side: const BorderSide(color: Color(0xFFFFD86B), width: 1.5),
                        backgroundColor: Colors.black.withOpacity(.42),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.person_add_alt_1_rounded), label: const Text('Sign Up (New Account)'),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                    )),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _notice() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(.6), borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0x99FFE080)),
    ),
    child: const Text('Login is not configured yet.\nYou can keep using the offline features.',
      textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFFFF5CF), fontSize: 13, height: 1.5)),
  );
}
