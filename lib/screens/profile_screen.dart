import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../services/app_style.dart';
import '../services/auth_service.dart';
import '../services/subscription_state.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../widgets/animations.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/glass_card.dart';
import 'root_gate.dart';
import 'subscription_screen.dart';

/// Profile & settings — account details, workspace theme, subscription refresh, sign out.
///
/// If Supabase is not configured the screen still works: it simply shows the
/// offline notice and the last verified subscription state, and never throws.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _busy = false;
  bool _obscure = true;
  String? _msg;
  String? _err;
  Map<String, dynamic>? _profile;
  bool _hasPaidSubscription = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final subscription = SubscriptionState.instance;
    if (!subscription.initialized) {
      await subscription.initialize(refresh: false);
    }
    final wasPaid = subscription.entitlement.isPaid;
    Map<String, dynamic>? p;
    if (AuthService.isLoggedIn) {
      try {
        p = await AuthService.fetchProfile();
        await subscription.refresh();
      } catch (_) {
        // Offline — use the last verified entitlement.
      }
    }
    if (!mounted) return;
    final paidNow = subscription.entitlement.isPaid;
    setState(() {
      _profile = p;
      _hasPaidSubscription = paidNow;
      if (paidNow && !wasPaid)
        _msg = 'Your subscription is now active on this device.';
    });
  }

  // ── Auth actions ─────────────────────────────────────────────────
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
      await AuthService.ensureTeacherProfile();
      if (!mounted) return;
      _passCtrl.clear();
      await _refresh();
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

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'Your papers stay on this device. You can sign back in any time with your email.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await AuthService.signOut();
    if (!mounted) return;
    RootGate.restart(context);
  }

  // ── Profile editing ──────────────────────────────────────────────
  String _localPhone(String s) {
    var p = s.replaceAll(RegExp(r'[^\d]'), '');
    if (p.startsWith('880')) p = p.substring(3);
    if (p.startsWith('0')) p = p.substring(1);
    return p;
  }

  Future<void> _editDetails() async {
    final nameCtrl = TextEditingController(
      text: _profile?['name']?.toString() ?? '',
    );
    final phoneCtrl = TextEditingController(
      text: _localPhone(_profile?['phone']?.toString() ?? ''),
    );
    String? err;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setD) => AlertDialog(
          title: const Text('Edit details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(PhosphorIcons.identificationBadge),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 13,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Mobile number',
                  hintText: '1XXXXXXXXX',
                  counterText: '',
                  prefixText: '+880  ',
                  prefixStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accent,
                  ),
                ),
              ),
              if (err != null) ...[
                const SizedBox(height: 10),
                InfoBanner.error(err!),
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
                if (nameCtrl.text.trim().length < 3) {
                  setD(() => err = 'Enter your full name (min 3 characters).');
                  return;
                }
                if (!RegExp(r'^1\d{9}$')
                    .hasMatch(_localPhone(phoneCtrl.text))) {
                  setD(() => err = 'Enter a valid number, e.g. 1XXXXXXXXX.');
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
          name: nameCtrl.text.trim(),
          phone: '+880${_localPhone(phoneCtrl.text)}',
        );
        await _refresh();
        if (mounted) setState(() => _msg = 'Your details were saved.');
      } catch (e) {
        if (mounted) setState(() => _err = AuthService.friendlyError(e));
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    }
    nameCtrl.dispose();
    phoneCtrl.dispose();
  }

  Future<void> _openPlans() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
    );
    if (mounted) await _refresh();
  }

  Future<void> _refreshSubscription() async {
    setState(() {
      _busy = true;
      _err = null;
      _msg = null;
    });
    try {
      final ok = await AuthService.refreshSubscription();
      await _refresh();
      if (!mounted) return;
      setState(
        () => _msg = ok
            ? 'Subscription is now active on this device.'
            : 'No active subscription was found for this account.',
      );
    } catch (e) {
      if (mounted) setState(() => _err = AuthService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ── UI ───────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: AppTheme.primary,
          backgroundColor: AppTheme.card,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
            children: Stagger.list([
              if (!AuthService.ready)
                const EmptyState(
                  icon: PhosphorIcons.cloudSlash,
                  title: 'Sign-in is not configured',
                  message:
                      'Every offline feature keeps working — papers, PDFs and printing are all available.',
                )
              else if (AuthService.isLoggedIn)
                _accountCard()
              else
                _loginCard(),
              if (_msg != null) ...[
                const SizedBox(height: 14),
                InfoBanner.success(_msg!),
              ],
              if (_err != null) ...[
                const SizedBox(height: 14),
                InfoBanner.error(_err!),
              ],
              const SizedBox(height: 16),
              _proCard(),
              // Workspace presets remain stored for compatibility, but the
              // shared rich theme makes the old picker redundant.
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Tutor's Desk — Tutor Edition",
                  style: TextStyle(fontSize: 11.5, color: AppTheme.muted),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _loginCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Sign in',
            subtitle:
                'Use the email and password from your tutor account. Codes are only used when you first sign up.',
            icon: PhosphorIcons.signIn,
          ),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'you@example.com',
              prefixIcon: Icon(PhosphorIcons.at),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passCtrl,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => _busy ? null : _signIn(),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(PhosphorIcons.lock),
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Show password' : 'Hide password',
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? PhosphorIcons.eye : PhosphorIcons.eyeSlash,
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
          SubmitButton(
            busy: _busy,
            icon: PhosphorIcons.signIn,
            label: 'Sign In',
            onPressed: _busy ? null : _signIn,
          ),
        ],
      ),
    );
  }

  Widget _accountCard() {
    final name = _profile?['name']?.toString() ?? '';
    final phone = _profile?['phone']?.toString() ?? '';
    final hasPaidSubscription = _hasPaidSubscription;
    final source = name.isNotEmpty ? name : (AuthService.email ?? 'T');
    final initial =
        (source.isEmpty ? 'T' : source.substring(0, 1)).toUpperCase();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.brandGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(.3),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Tutor' : name,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      AuthService.email ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.muted,
                      ),
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppTheme.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _editDetails,
                  icon: const Icon(PhosphorIcons.pencilSimple, size: 18),
                  label: const Text('Edit details'),
                ),
              ),
              if (!hasPaidSubscription) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _openPlans,
                    icon: const Icon(PhosphorIcons.crown, size: 18),
                    label: const Text('View plans'),
                  ),
                ),
              ],
            ],
          ),
          if (!hasPaidSubscription)
            Center(
              child: TextButton.icon(
                onPressed: _busy ? null : _refreshSubscription,
                icon: _busy
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(PhosphorIcons.arrowsClockwise, size: 17),
                label: const Text('Already paid? Refresh subscription'),
              ),
            ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _busy ? null : _logout,
              icon: const Icon(PhosphorIcons.signOut, size: 18),
              label: const Text('Sign out'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            ),
          ),
        ],
      ),
    );
  }

  Widget _proCard() {
    if (_hasPaidSubscription) {
      return GlassCard(
        highlighted: true,
        child: Row(
          children: [
            Pulse(
              min: .95,
              max: 1.07,
              period: const Duration(milliseconds: 2200),
              child: const Icon(
                PhosphorIcons.crown,
                color: AppTheme.accent,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pro is active',
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Full papers, no watermark, PDF export and printing.',
                    style: TextStyle(
                      color: AppTheme.muted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return GlassCard(
      highlighted: true,
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
        );
        if (mounted) _refresh();
      },
      child: Row(
        children: [
          const Icon(
            PhosphorIcons.crown,
            color: AppTheme.accent,
            size: 30,
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upgrade to Pro',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Unlock every question, remove the watermark, print freely.',
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(PhosphorIcons.caretRight, color: AppTheme.accent),
        ],
      ),
    );
  }
}
