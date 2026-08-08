import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import '../services/auth_service.dart';
import '../services/paper_license.dart';
import 'subscription_screen.dart';
import '../theme/app_theme.dart';

/// প্রোফাইল ট্যাব — ইমেইল OTP লগইন + অ্যাকাউন্ট কার্ড + Pro সিংক
///
/// লগইন ধারা (পুরোটা এই পর্দায়):
///   ইমেইল লেখো → [OTP পাঠাও] → ইমেইলে ৬-সংখ্যার কোড → কোড লেখো →
///   যাচাই → (প্রথমবার হলে) শিক্ষক/শিক্ষার্থী বাছাই → প্রোফাইল + Pro সিংক।
///
/// Supabase কনফিগ না থাকলে শুধু তথ্যমূলক কার্ড দেখায়; অ্যাপ ক্র্যাশ করে না।
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  bool _busy = false;
  bool _otpSent = false; // কোড-ধাপে আছি কিনা
  String? _msg; // সবুজ সফল-বার্তা
  String? _err; // লাল error-বার্তা
  Map<String, dynamic>? _profile;
  bool _devicePro = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final pro = await PaperLicense.isPro();
    Map<String, dynamic>? p;
    if (AuthService.isLoggedIn) {
      p = await AuthService.fetchProfile();
      // সার্ভারে Pro থাকলে এই ডিভাইসেও চালু করো
      if (await AuthService.syncProFromServer()) {
        // সিংক হয়ে গেলে Pro পতাকা আবার পড়ো
        final pro2 = await PaperLicense.isPro();
        if (mounted) {
          setState(() {
            _devicePro = pro2;
            // ✅ Pro নতুন করে চালু হলে স্পষ্ট বার্তা
            if (pro2 && !pro) _msg = '🎉 You are now using the Pro version!';
          });
        }
      }
    }
    if (!mounted) return;
    setState(() {
      _profile = p;
      _devicePro = pro || _devicePro;
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  // ত্রুটি বার্তা বাংলায়
  String _bnError(Object e) {
    final s = e.toString();
    if (s.contains('পাঠাও') || s.contains('লেখো') || s.contains('মেলেনি')) {
      return e is AuthException ? e.message : s;
    }
    if (s.contains('rate') || s.contains('429') || s.contains('too many')) {
      return 'Too many attempts — please try again later.';
    }
    if (s.contains('SocketException') ||
        s.contains('Failed host lookup') ||
        s.contains('Network')) {
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
        _msg = '✅ Email sent! Check your inbox (or spam) for the 6-digit code.';
      });
    } catch (e) {
      if (mounted) setState(() => _err = _bnError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _busy = true;
      _err = null;
      _msg = null;
    });
    try {
      await AuthService.verifyOtp(_emailCtrl.text, _codeCtrl.text);
      // প্রথমবার লগইন হলে (প্রোফাইল নেই) ভূমিকা জিজ্ঞেস করো
      var p = await AuthService.fetchProfile();
      if (p == null && mounted) {
        final role = await _askRole();
        if (role != null) p = await AuthService.ensureProfile(role: role);
      }
      await AuthService.syncProFromServer();
      if (!mounted) return;
      setState(() {
        _otpSent = false;
        _profile = p;
        _msg = null;
      });
      await _refresh();
    } catch (e) {
      if (mounted) setState(() => _err = _bnError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _askRole() {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Who are you?'),
        content: const Text(
          'Choose your account type (it cannot be changed later):',
          style: TextStyle(fontSize: 13.5, height: 1.5),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, 'teacher'),
            icon: const Icon(Icons.school_outlined),
            label: const Text('Teacher'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, 'student'),
            icon: const Icon(Icons.menu_book_outlined),
            label: const Text('Student'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await AuthService.signOut();
    if (!mounted) return;
    setState(() {
      _profile = null;
      _otpSent = false;
      _codeCtrl.clear();
      _msg = 'Signed out.';
    });
  }

  // ── ফোন নম্বর বদলানো ─────────────────────────────────────────────
  String _digitsOnly(String s) {
    var p = s.replaceAll(RegExp(r'[^\d]'), '');
    if (p.startsWith('880')) p = p.substring(3);
    if (p.startsWith('0')) p = p.substring(1);
    return p;
  }

  Future<void> _editPhone() async {
    final phoneCtrl = TextEditingController(
        text: _digitsOnly(_profile?['phone']?.toString() ?? ''));
    String? err;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setD) => AlertDialog(
          title: const Text('Change Phone Number'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 13,
                decoration: const InputDecoration(
                  labelText: 'New mobile number',
                  hintText: '1XXXXXXXXX',
                  counterText: '',
                  prefix: Text('+880  ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  border: OutlineInputBorder(),
                ),
              ),
              if (err != null) ...[
                const SizedBox(height: 8),
                Text(err!,
                    style:
                        TextStyle(fontSize: 12.5, color: Colors.red.shade600)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!RegExp(r'^1\d{9}$')
                    .hasMatch(_digitsOnly(phoneCtrl.text))) {
                  setD(() => err = 'Enter a valid number (e.g. 1XXXXXXXXX)');
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (saved == true && mounted) {
      setState(() {
        _busy = true;
        _err = null;
        _msg = null;
      });
      try {
        await AuthService.updateProfile(
            phone: '+880${_digitsOnly(phoneCtrl.text)}');
        await _refresh();
        if (mounted) setState(() => _msg = '✅ Phone number saved!');
      } catch (_) {
        if (mounted) {
          setState(
              () => _err = 'Could not save — check your internet and try again.');
        }
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    }
    phoneCtrl.dispose();
  }

  // ── UI ───────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Login')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!AuthService.ready)
            _infoCard(
              Icons.settings_suggest_outlined,
              'Login is not configured yet.\nAll other features keep working as usual.',
            )
          else if (AuthService.isLoggedIn)
            _accountCard()
          else
            _loginCard(),
          if (AuthService.isLoggedIn && !_devicePro) ...[
            const SizedBox(height: 14),
            _subscriptionCard(),
          ],
          const SizedBox(height: 14),
          if (_msg != null) _banner(_msg!, Colors.green.shade700),
          if (_err != null) _banner(_err!, Colors.red.shade600),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _infoCard(IconData icon, String text) {
    return _card(
      child: Column(
        children: [
          Icon(icon, size: 44, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _loginCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _otpSent ? 'Enter the Code' : 'Sign in with Email',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            _otpSent
                ? 'A 6-digit code has been sent to your email (valid for ~1 hour).'
                : 'No password needed — sign in with the OTP code from your email.',
            style: TextStyle(fontSize: 12.5, height: 1.5, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _emailCtrl,
            enabled: !_otpSent,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'you@example.com',
              prefixIcon: Icon(Icons.alternate_email),
              border: OutlineInputBorder(),
            ),
          ),
          if (_otpSent) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _codeCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                labelText: '6-digit code',
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _busy ? null : (_otpSent ? _verifyOtp : _sendOtp),
              icon: _busy
                  ? const SizedBox(
                      width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(_otpSent ? Icons.verified_user_outlined : Icons.mark_email_read_outlined),
              label: Text(_busy ? 'Please wait...' : (_otpSent ? 'Verify' : 'Send OTP')),
            ),
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
                child: const Text('Back to change email / get a new code'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _subscriptionCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF17130A), Color(0xFF2A230F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFFF7C948).withOpacity(0.65)),
        ),
        child: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Color(0xFFF7C948), size: 30),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Buy Subscription',
                      style: TextStyle(
                          color: Color(0xFFFFE08A),
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800)),
                  Text('Unlock all Pro features',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Color(0xFFF7C948)),
          ],
        ),
      ),
    );
  }

  Widget _accountCard() {
    final name = _profile?['name']?.toString() ?? '';
    final phone = _profile?['phone']?.toString() ?? '';
    final role = _profile?['role']?.toString() ?? '—';
    final roleBn = role == 'teacher' ? 'Teacher' : (role == 'student' ? 'Student' : '—');
    final serverPro = _profile?['is_pro'] == true;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primary.withOpacity(0.12),
                child: Icon(Icons.person, color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (name.isNotEmpty)
                      Text(name,
                          style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
                    Text(AuthService.email ?? '',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      'Role: $roleBn${phone.isNotEmpty ? '  •  $phone' : ''}',
                      style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(
                serverPro ? 'Pro on server ✓' : 'No Pro on server',
                serverPro ? Colors.green.shade700 : Colors.grey.shade600,
              ),
              _chip(
                _devicePro ? 'Pro active on this phone ✓' : 'DEMO on this phone',
                _devicePro ? AppTheme.accent : Colors.grey.shade600,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'When the tutor admin enables Pro on your email, tap \"Sync Pro\" to activate it on this phone.',
            style: TextStyle(fontSize: 12, height: 1.5, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : () async {
                          setState(() => _busy = true);
                          final ok = await AuthService.syncProFromServer();
                          await _refresh();
                          if (!mounted) return;
                          setState(() {
                            _busy = false;
                            _msg = ok ? '🎉 You are now using the Pro version!' : 'Pro is not enabled on the server yet.';
                          });
                        },
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync Pro'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: _busy ? null : _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _editPhone,
              icon: const Icon(Icons.phone_iphone),
              label: const Text('Change Phone Number'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _banner(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(text, style: TextStyle(fontSize: 12.5, height: 1.5, color: color)),
    );
  }
}
