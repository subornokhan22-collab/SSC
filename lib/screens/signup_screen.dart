import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/glass_card.dart';
import 'root_gate.dart';

/// Sign up — creates a new tutor account.
///
/// Form: full name + phone (+880) + email + password. Supabase emails a
/// one-time code to confirm the address; this is the ONLY point in the app
/// where a code is ever sent. Every later sign-in uses the password.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, this.prefillEmail});

  final String? prefillEmail;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  late final TextEditingController _emailCtrl;
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  bool _busy = false;
  bool _otpSent = false;
  bool _obscure = true;
  String? _err;
  String? _msg;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.prefillEmail ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  String _localPhone(String s) {
    var p = s.replaceAll(RegExp(r'[^\d]'), '');
    if (p.startsWith('880')) p = p.substring(3);
    if (p.startsWith('0')) p = p.substring(1);
    return p;
  }

  String get _fullPhone => '+880${_localPhone(_phoneCtrl.text)}';

  String? _validate() {
    if (_nameCtrl.text.trim().length < 3) {
      return 'Please enter your full name (at least 3 characters).';
    }
    if (!RegExp(r'^1\d{9}$').hasMatch(_localPhone(_phoneCtrl.text))) {
      return 'Enter a valid mobile number, e.g. 1XXXXXXXXX.';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_emailCtrl.text.trim())) {
      return 'Enter a valid email address.';
    }
    if (_passCtrl.text.length < AuthService.minPasswordLength) {
      return 'Password must be at least '
          '${AuthService.minPasswordLength} characters.';
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      return 'The two passwords do not match.';
    }
    return null;
  }

  Future<void> _next() async {
    FocusScope.of(context).unfocus();
    final bad = _validate();
    if (bad != null) {
      setState(() => _err = bad);
      return;
    }
    setState(() {
      _busy = true;
      _err = null;
      _msg = null;
    });
    try {
      await AuthService.signUpWithPassword(
        email: _emailCtrl.text,
        password: _passCtrl.text,
      );
      if (!mounted) return;
      // Projects with email confirmation switched off sign the tutor in
      // straight away — skip the code step entirely.
      if (AuthService.hasSession) {
        await _finish();
        return;
      }
      setState(() {
        _otpSent = true;
        _msg = 'Verification code sent! Check your inbox (and spam folder).';
      });
    } catch (e) {
      if (mounted) setState(() => _err = AuthService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Asks Supabase to send the confirmation code again.
  Future<void> _resend() async {
    setState(() {
      _busy = true;
      _err = null;
      _msg = null;
    });
    try {
      await AuthService.resendSignUpCode(_emailCtrl.text);
      if (!mounted) return;
      setState(() => _msg =
          'Code sent again. If nothing arrives, check spam — the free mail '
          'service only allows a few messages an hour.');
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
      await AuthService.verifySignUpCode(
        email: _emailCtrl.text,
        code: _codeCtrl.text,
      );
      // Confirming by code can create the user without the password being
      // attached yet — set it now so the next sign-in works.
      await AuthService.setPassword(_passCtrl.text);
      await _finish();
    } catch (e) {
      if (mounted) setState(() => _err = AuthService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Shared tail of both paths: create the profile row, sync Pro, go home.
  Future<void> _finish() async {
    await AuthService.ensureTeacherProfile(
      name: _nameCtrl.text.trim(),
      phone: _fullPhone,
    );
    await AuthService.syncProFromServer();
    if (!mounted) return;
    RootGate.restart(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_otpSent ? 'Verify Code' : 'Create Account')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: Stagger.list([
            AuthHero(
              icon: _otpSent
                  ? Icons.mark_email_read_rounded
                  : Icons.person_add_alt_1_rounded,
              title: _otpSent ? 'Almost there' : 'Tutor account',
              subtitle: _otpSent
                  ? 'We sent a code to ${_emailCtrl.text.trim()}. Enter it below to finish setting up your workspace.'
                  : 'Choose a password you will use to sign in. We email a code once, just to confirm this address.',
            ),
            const SizedBox(height: 18),
            SoftSwitcher(
              child: _otpSent ? _codeCard() : _detailsCard(),
            ),
            if (_msg != null) ...[
              const SizedBox(height: 14),
              InfoBanner.success(_msg!),
            ],
            if (_err != null) ...[
              const SizedBox(height: 14),
              InfoBanner.error(_err!),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _detailsCard() {
    return GlassCard(
      key: const ValueKey('details'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Your details',
            subtitle: 'Used on your papers and to recover your account.',
            icon: Icons.badge_outlined,
          ),
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            decoration: const InputDecoration(
              labelText: 'Full name',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            maxLength: 13,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d+]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Mobile number',
              hintText: '1XXXXXXXXX',
              counterText: '',
              prefixIcon: Icon(Icons.phone_iphone_rounded),
              prefixText: '+880  ',
              prefixStyle: TextStyle(
                  fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Email address',
              hintText: 'you@example.com',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 18),
          const SectionTitle(
            title: 'Choose a password',
            subtitle:
                'You will use this every time you sign in — no more codes.',
            icon: Icons.lock_outline_rounded,
          ),
          TextField(
            controller: _passCtrl,
            obscureText: _obscure,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(
              labelText: 'Password',
              helperText:
                  'At least ${AuthService.minPasswordLength} characters.',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Show password' : 'Hide password',
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(_obscure
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _confirmCtrl,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            onSubmitted: (_) => _busy ? null : _next(),
            decoration: const InputDecoration(
              labelText: 'Confirm password',
              prefixIcon: Icon(Icons.lock_reset_rounded),
            ),
          ),
          const SizedBox(height: 18),
          SubmitButton(
            busy: _busy,
            icon: Icons.arrow_forward_rounded,
            label: 'Create Account',
            onPressed: _next,
          ),
        ],
      ),
    );
  }

  Widget _codeCard() {
    return GlassCard(
      key: const ValueKey('code'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Verification code',
            icon: Icons.password_rounded,
          ),
          TextField(
            controller: _codeCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 8,
            autofocus: true,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              letterSpacing: 8,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
            decoration: const InputDecoration(
              labelText: 'Code from your email',
              counterText: '',
            ),
            onSubmitted: (_) => _busy ? null : _verify(),
          ),
          const SizedBox(height: 16),
          SubmitButton(
            busy: _busy,
            icon: Icons.verified_user_rounded,
            label: 'Verify & Create Account',
            onPressed: _verify,
          ),
          Center(
            child: TextButton(
              onPressed: _busy ? null : _resend,
              child: const Text('Send the code again'),
            ),
          ),
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
              child: const Text('Edit details'),
            ),
          ),
        ],
      ),
    );
  }
}
