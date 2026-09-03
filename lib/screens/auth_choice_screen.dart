import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/molten_gold_river.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';
import 'teacher_home_screen.dart';

/// Welcome screen — the tutor's first impression of the app.
/// Molten-gold backdrop, staggered entrance and a short feature summary.
class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const cream = Color(0xFFFFF5CF);
    return Scaffold(
      body: MoltenGoldRiver(
        child: DecoratedBox(
          // Darkens the animated rivers so the copy stays legible.
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(.62),
                Colors.black.withOpacity(.78),
                Colors.black.withOpacity(.88),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: Stagger.list(
                      [
                        SizedBox(
                          width: 128,
                          height: 128,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const HaloRing(
                                size: 128,
                                strokeWidth: 2.4,
                                color: Color(0xFFFFE080),
                              ),
                              Pulse(
                                min: .96,
                                max: 1.04,
                                period: const Duration(milliseconds: 2200),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(.66),
                                    border: Border.all(
                                        color: const Color(0xFFFFE080),
                                        width: 1.5),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Color(0x66D4A843),
                                          blurRadius: 30),
                                    ],
                                  ),
                                  child: const Icon(Icons.school_rounded,
                                      size: 50, color: Color(0xFFFFE080)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'A-Learning',
                          style: TextStyle(
                            color: cream,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.6,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 14),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.black.withOpacity(.45),
                            border: Border.all(
                                color: const Color(0x99FFD86B), width: 1),
                          ),
                          child: const Text(
                            'TUTOR EDITION',
                            style: TextStyle(
                              color: Color(0xFFFFD86B),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Build SSC 2027 question papers, model tests and OMR '
                          'sheets — print-ready in minutes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(.86),
                            fontSize: 13.5,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 22),
                        const _FeatureStrip(),
                        const SizedBox(height: 28),
                        if (!AuthService.ready)
                          const _OfflineNotice()
                        else ...[
                          _PrimaryAction(
                            icon: Icons.login_rounded,
                            label: 'Sign In',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SignInScreen()),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _SecondaryAction(
                            icon: Icons.person_add_alt_1_rounded,
                            label: 'Create a Tutor Account',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SignUpScreen()),
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        TextButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const TeacherHomeScreen()),
                          ),
                          icon: const Icon(Icons.bolt_rounded, size: 18),
                          label: const Text('Continue offline'),
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.white.withOpacity(.72)),
                        ),
                      ],
                      step: const Duration(milliseconds: 85),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Three compact selling points shown under the tagline.
class _FeatureStrip extends StatelessWidget {
  const _FeatureStrip();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.description_rounded, 'Board-format\npapers'),
      (Icons.tune_rounded, 'Custom MCQ\n+ OMR'),
      (Icons.picture_as_pdf_rounded, 'Instant PDF\n& print'),
    ];
    return Row(
      children: [
        for (final item in items)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.46),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: const Color(0xFFFFD86B).withOpacity(.28)),
                ),
                child: Column(
                  children: [
                    Icon(item.$1, color: const Color(0xFFFFD86B), size: 21),
                    const SizedBox(height: 8),
                    Text(
                      item.$2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.82),
                        fontSize: 11,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PrimaryAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: ShineSweep(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE080), Color(0xFFD4A72C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(.32),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFF241900), size: 20),
              const SizedBox(width: 9),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF241900),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SecondaryAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black.withOpacity(.48),
          border: const Border.fromBorderSide(
              BorderSide(color: Color(0xFFFFD86B), width: 1.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFFFFF0B0), size: 20),
            const SizedBox(width: 9),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFFFF0B0),
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x99FFE080)),
      ),
      child: const Text(
        'Sign-in is not configured yet.\nAll offline paper-building features still work.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFFFFF5CF), fontSize: 13, height: 1.55),
      ),
    );
  }
}
