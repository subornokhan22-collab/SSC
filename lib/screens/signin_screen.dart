import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../services/auth_service.dart';
import 'root_gate.dart';
import 'signup_screen.dart';

/// সাইন ইন — ইমেইল + OTP (পুরনো ব্যবহারকারী)
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

  String _bnError(Object e) {
    final s = e.toString();
    if (e is AuthException) return e.message;
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

  Future<void> _sendOtp() async {
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
        _msg = '✅ Code sent! Check your inbox (or spam) and enter the code.';
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
      final p = await AuthService.fetchProfile();
      if (!mounted) return;
      if (p == null) {
        // পুরনো অ্যাকাউন্টে প্রোফাইল নেই → সাইন-আপ ফর্মে নিয়ে যাও
        setState(() {
          _err = 'No profile found for this email — please sign up instead.';
        });
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SignUpScreen(prefillEmail: _emailCtrl.text.trim()),
          ),
        );
        return;
      }
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
      appBar: AppBar(title: const Text('Sign In')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Enter the email you used for your account — we will send you a code.',
            style: TextStyle(fontSize: 13.5, height: 1.5, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailCtrl,
            enabled: !_otpSent,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'tumi@example.com',
              prefixIcon: Icon(Icons.alternate_email),
              border: OutlineInputBorder(),
            ),
          ),
          if (_otpSent) ...[
            const SizedBox(height: 12),
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
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _busy ? null : (_otpSent ? _verify : _sendOtp),
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(_otpSent
                      ? Icons.verified_user_outlined
                      : Icons.mark_email_read_outlined),
              label: Text(_busy
                  ? 'Please wait...'
                  : (_otpSent ? 'Verify & Sign In' : 'Send OTP')),
            ),
          ),
          if (_otpSent)
            TextButton(
              onPressed: _busy
                  ? null
                  : () => setState(() {
                        _otpSent = false;
                        _err = null;
                        _msg = null;
                        _codeCtrl.clear();
                      }),
              child: const Text('Back to change email / get a new code'),
            ),
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
