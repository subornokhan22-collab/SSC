import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/glass_card.dart';
import 'root_gate.dart';
import 'signup_screen.dart';

/// Sign in — email + one-time code, for tutors who already have an account.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  bool _busy = false;
  bool _otpSent = false;
  String? _err;
  String? _msg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _err = null;
      _msg = null;
    });
    try {
      await AuthService.sendOtp(_emailCtrl.text);
      if (!mounted) return;
      setState(() {
        _otpSent = true;
        _msg = 'Code sent! Check your inbox (and spam folder).';
      });
    } catch (e) {
      if (mounted) setState(() => _err = AuthService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      await AuthService.verifyOtp(_emailCtrl.text, _codeCtrl.text);
      // Every A-Learning account is a tutor account; make sure the row exists
      // so returning users are never blocked by a missing profile.
      await AuthService.ensureTeacherProfile();
      await AuthService.syncProFromServer();
      if (!mounted) return;
      RootGate.restart(context);
    } catch (e) {
      if (mounted) setState(() => _err = AuthService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: Stagger.list([
            const AuthHero(
              icon: Icons.login_rounded,
              title: 'Welcome back',
              subtitle:
                  'Enter the email linked to your tutor account — we will send a one-time code. No password needed.',
            ),
            const SizedBox(height: 18),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(
                    title: _otpSent ? 'Enter your code' : 'Your email',
                    icon: _otpSent
                        ? Icons.password_rounded
                        : Icons.alternate_email_rounded,
                  ),
                  TextField(
                    controller: _emailCtrl,
                    enabled: !_otpSent,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.email],
                    onSubmitted: (_) => _busy ? null : _sendOtp(),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@example.com',
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                    ),
                  ),
                  SoftSwitcher(
                    child: _otpSent
                        ? Padding(
                            key: const ValueKey('code'),
                            padding: const EdgeInsets.only(top: 14),
                            child: TextField(
                              controller: _codeCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              maxLength: 8,
                              autofocus: true,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                letterSpacing: 8,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accent,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Code from your email',
                                counterText: '',
                              ),
                              onSubmitted: (_) => _busy ? null : _verify(),
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('empty')),
                  ),
                  const SizedBox(height: 16),
                  SubmitButton(
                    busy: _busy,
                    icon: _otpSent
                        ? Icons.verified_user_rounded
                        : Icons.mark_email_read_rounded,
                    label: _otpSent ? 'Verify & Sign In' : 'Send Code',
                    onPressed: _busy ? null : (_otpSent ? _verify : _sendOtp),
                  ),
                  if (_otpSent)
                    Center(
                      child: TextButton(
                        onPressed: _busy
                            ? null
                            : () => setState(() {
                                  _otpSent = false;
                                  _err = null;
                                  _msg = null;
                                  _codeCtrl.clear();
                                }),
                        child: const Text('Change email / resend code'),
                      ),
                    ),
                ],
              ),
            ),
            if (_msg != null) ...[
              const SizedBox(height: 14),
              InfoBanner.success(_msg!),
            ],
            if (_err != null) ...[
              const SizedBox(height: 14),
              InfoBanner.error(_err!),
            ],
            const SizedBox(height: 20),
            Center(
              child: TextButton.icon(
                onPressed: _busy
                    ? null
                    : () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SignUpScreen(
                                prefillEmail: _emailCtrl.text.trim()),
                          ),
                        ),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('No account yet? Create one'),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
