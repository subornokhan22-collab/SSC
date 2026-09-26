import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/animations.dart';
import '../widgets/aurora_ribbons.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/glass_card.dart';
import 'root_gate.dart';
import 'signup_screen.dart';

/// Sign in — email + password.
///
/// No one-time code is ever sent here. The verification code is only used
/// once, at sign-up, to confirm the address; from then on the tutor simply
/// types their password.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _passFocus = FocusNode();

  bool _busy = false;
  bool _obscure = true;
  String? _err;
  String? _msg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _err = null;
      _msg = null;
    });
    try {
      await AuthService.signInWithPassword(
        email: _emailCtrl.text,
        password: _passCtrl.text,
      );
      // Every Tutor's Desk account is a tutor account; make sure the
      // row exists so returning users are never blocked by a missing profile.
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

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(
        () => _err = 'Type your email first, then tap "Forgot password".',
      );
      return;
    }
    setState(() {
      _busy = true;
      _err = null;
      _msg = null;
    });
    try {
      await AuthService.sendPasswordReset(email);
      if (mounted) {
        setState(
          () => _msg = 'Password reset link sent to $email — check your inbox.',
        );
      }
    } catch (e) {
      if (mounted) setState(() => _err = AuthService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inset = ((MediaQuery.sizeOf(context).width - 520) / 2)
        .clamp(18.0, double.infinity)
        .toDouble();
    // The front door is the one screen that should feel like an arrival, so it
    // gets the ribbons. The scaffold is transparent, so this sits behind the
    // form rather than replacing the workspace paper.
    return AutofillGroup(
        child: AuroraRibbons(
      enabled: true,
      opacity: .5,
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(inset, 12, inset, 28),
          children: Stagger.list([
            const DeskWelcome(),
            const SizedBox(height: 18),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(
                    title: 'Your details',
                    icon: Icons.alternate_email_rounded,
                  ),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.username],
                    onSubmitted: (_) => _passFocus.requestFocus(),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@example.com',
                      prefixIcon: Icon(Icons.alternate_email_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passCtrl,
                    focusNode: _passFocus,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => _busy ? null : _signIn(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        tooltip: _obscure ? 'Show password' : 'Hide password',
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _busy ? null : _forgotPassword,
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SubmitButton(
                    busy: _busy,
                    icon: Icons.login_rounded,
                    label: 'Sign In',
                    onPressed: _busy ? null : _signIn,
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
                              prefillEmail: _emailCtrl.text.trim(),
                            ),
                          ),
                        ),
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('No account yet? Create one'),
              ),
            ),
          ]),
        ),
      ),
    )));
  }
}
