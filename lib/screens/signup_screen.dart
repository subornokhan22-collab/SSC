import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../services/auth_service.dart';
import 'root_gate.dart';

/// সাইন আপ — নতুন ব্যবহারকারী
/// ফর্ম: পুরো নাম + পেশা (শিক্ষার্থী/শিক্ষক) + ফোন (+880) + ইমেইল → OTP → প্রবেশ
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

  String _profession = 'student'; // 'student' | 'teacher'
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

  String? _validate() {
    if (_nameCtrl.text.trim().length < 3) return 'Please enter your full name (at least 3 characters)';
    // +880 এর পরে 1 দিয়ে শুরু ১০ সংখ্যা (মোট ১১ সংখ্যা মোবাইল দিলেও মেনে নিই)
    var p = _phoneCtrl.text.replaceAll(RegExp(r'[^\d]'), '');
    if (p.startsWith('880')) p = p.substring(3);
    if (p.startsWith('0')) p = p.substring(1);
    if (!RegExp(r'^1\d{9}$').hasMatch(p)) {
      return 'Enter a valid mobile number (e.g. 1XXXXXXXXX)';
    }
    final e = _emailCtrl.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String get _fullPhone {
    var p = _phoneCtrl.text.replaceAll(RegExp(r'[^\d]'), '');
    if (p.startsWith('880')) p = p.substring(3);
    if (p.startsWith('0')) p = p.substring(1);
    return '+880$p';
  }

  String _bnError(Object e) {
    final s = e.toString();
    if (e is AuthException && e.message.isNotEmpty) return e.message;
    if (s.contains('rate') || s.contains('429') || s.contains('too many')) {
      return 'Too many attempts — please try again later.';
    }
    if (s.contains('SocketException') || s.contains('Failed host lookup')) {
      return 'No internet — please check your connection and try again.';
    }
    if (s.contains('expired') || s.contains('invalid') || s.contains('Token')) {
      return 'The code is wrong or expired — request a new one.';
    }
    return 'Something went wrong — please try again.';
  }

  Future<void> _next() async {
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
        _msg = '✅ Verification code sent! Check your inbox (or spam).';
      });
    } catch (e) {
      if (mounted) setState(() => _err = _bnError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      await AuthService.verifyOtp(_emailCtrl.text, _codeCtrl.text);
      await AuthService.ensureProfile(
        role: _profession,
        name: _nameCtrl.text.trim(),
        phone: _fullPhone,
      );
      await AuthService.syncProFromServer();
      if (!mounted) return;
      RootGate.restart(context);
    } catch (e) {
      if (mounted) setState(() => _err = _bnError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_otpSent ? 'Verify Code' : 'Sign Up')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (!_otpSent) ...[
            Text(
              'Fill in your details — a code will be sent to your email for verification.',
              style: TextStyle(fontSize: 13.5, height: 1.5, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.badge_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Who are you?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                    value: 'student',
                    icon: Icon(Icons.menu_book_outlined),
                    label: Text('Student')),
                ButtonSegment(
                    value: 'teacher',
                    icon: Icon(Icons.school_outlined),
                    label: Text('Teacher')),
              ],
              selected: {_profession},
              onSelectionChanged: (s) => setState(() => _profession = s.first),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d+]'))],
              decoration: const InputDecoration(
                labelText: 'Mobile Number',
                hintText: '1XXXXXXXXX',
                prefix: Text('+880  ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                prefixIcon: Icon(Icons.phone_iphone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'tumi@example.com',
                prefixIcon: Icon(Icons.alternate_email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: _busy ? null : _next,
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.arrow_forward_rounded),
                label: Text(_busy ? 'Please wait...' : 'Next'),
              ),
            ),
          ] else ...[
            Text(
              'A code has been sent to ${_emailCtrl.text.trim()}. Enter it below:',
              style: TextStyle(fontSize: 13.5, height: 1.6, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _codeCtrl,
              keyboardType: TextInputType.number,
              maxLength: 10,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                labelText: 'Code from your email',
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: _busy ? null : _verify,
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.verified_user_outlined),
                label: Text(_busy ? 'Please wait...' : 'Verify & Create Account'),
              ),
            ),
            TextButton(
              onPressed: _busy
                  ? null
                  : () => setState(() {
                        _otpSent = false;
                        _err = null;
                        _msg = null;
                        _codeCtrl.clear();
                      }),
              child: const Text('Back to edit details / get a new code'),
            ),
          ],
          if (_msg != null) ...[
            const SizedBox(height: 10),
            _banner(_msg!, Colors.green.shade700),
          ],
          if (_err != null) ...[
            const SizedBox(height: 10),
            _banner(_err!, Colors.red.shade600),
          ],
        ],
      ),
    );
  }

  Widget _banner(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(text, style: TextStyle(fontSize: 13, height: 1.5, color: color)),
    );
  }
}
