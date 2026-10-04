import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/animations.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: Stagger.list([
                    const AppLogo(size: 64),
                    const SizedBox(height: 28),
                    Text(
                      'Tutor’s Desk',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Question papers, ready for class.',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Create papers, review the SSC question bank and grade OMR sheets with a secure online account.',
                    ),
                    const SizedBox(height: 32),
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
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
}
