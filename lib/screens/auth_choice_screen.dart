import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/feature_carousel.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                28,
                MediaQuery.sizeOf(context).width >= 900 ? 72 : 48,
                28,
                32,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      MediaQuery.sizeOf(context).width >= 900 ? 560 : 440,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // Keep the account chooser static; animated offsets make
                  // the action buttons appear to duplicate or shake.
                  children: [
                    const Center(
                      child: Column(
                        children: [
                          AppLogo(size: 96),
                          SizedBox(height: 20),
                          AppBrandName(fontSize: 36),
                          SizedBox(height: 8),
                          Text(
                            'YOUR TEACHING WORKSPACE',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.4,
                              color: AppTheme.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const FeatureCarousel(
                      features: [
                        FeatureHighlight(
                          icon: PhosphorIcons.fileTextDuotone,
                          title: 'Paper builder',
                          description:
                              'Compose board-pattern question papers in minutes.',
                        ),
                        FeatureHighlight(
                          icon: PhosphorIcons.scanDuotone,
                          title: 'OMR scanner',
                          description:
                              'Scan answer sheets and get instant, scored results.',
                        ),
                        FeatureHighlight(
                          icon: PhosphorIcons.magicWandDuotone,
                          title: 'AI Tools',
                          description:
                              'Generate, improve, and check questions with AI.',
                        ),
                        FeatureHighlight(
                          icon: PhosphorIcons.filePdfDuotone,
                          title: 'PDF export',
                          description:
                              'Preview, save, print, and share classroom-ready papers.',
                        ),
                        FeatureHighlight(
                          icon: PhosphorIcons.bookmarkSimpleDuotone,
                          title: 'Saved papers',
                          description:
                              'Keep reusable papers organized for every class.',
                        ),
                        FeatureHighlight(
                          icon: PhosphorIcons.chartBarDuotone,
                          title: 'Class insights',
                          description:
                              'Review OMR performance and spot learning gaps.',
                        ),
                        FeatureHighlight(
                          icon: PhosphorIcons.shieldCheck,
                          title: 'Secure workspace',
                          description:
                              'Sync account data with protected teacher access.',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (AuthService.ready) ...[
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignUpScreen()),
                          ),
                          child: const Text('Sign up'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignInScreen()),
                          ),
                          child: const Text('Sign in'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Create an account to sync papers and use server AI. Already have an account? Sign in above.',
                        style: TextStyle(color: AppTheme.muted, fontSize: 12),
                      ),
                    ] else
                      const Text(
                        'Sign-in is not configured. Connect the Tutor\'s Desk account service to create an account.',
                        style: TextStyle(color: AppTheme.muted, fontSize: 12),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
