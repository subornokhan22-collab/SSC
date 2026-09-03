import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/glass_card.dart';
import 'root_gate.dart';

/// Sign up — creates a new tutor account.
/// Form: full name + phone (+880) + email → one-time code → workspace.
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
  final _codeCtrl = TextEditingController();

  bool _busy = false;
  bool _otpSent = false;
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
      await AuthService.sendOtp(_emailCtrl.text);
      if (!mounted) return;
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

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      await AuthService.verifyOtp(_emailCtrl.text, _codeCtrl.text);
      await AuthService.ensureTeacherProfile(
        name: _nameCtrl.text.trim(),
        phone: _fullPhone,
      );
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
                  : 'Fill in your details — a one-time code will be emailed to verify your account.',
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
                  fontWeight: FontWeight.bold, color: AppTheme.accent),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            onSubmitted: (_) => _busy ? null : _next(),
            decoration: const InputDecoration(
              labelText: 'Email address',
              hintText: 'you@example.com',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 18),
          SubmitButton(
            busy: _busy,
            icon: Icons.arrow_forward_rounded,
            label: 'Send Verification Code',
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
              color: AppTheme.accent,
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
              onPressed: _busy
                  ? null
                  : () => setState(() {
                        _otpSent = false;
                        _err = null;
                        _msg = null;
                        _codeCtrl.clear();
                      }),
              child: const Text('Edit details / resend code'),
            ),
          ),
        ],
      ),
    );
  }
}
