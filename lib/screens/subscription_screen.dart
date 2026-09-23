import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/app_style.dart';
import '../services/auth_service.dart';
import '../services/bkash_service.dart';
import '../services/paper_license.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/glass_card.dart';
import '../widgets/problem_dialog.dart';

/// Subscription screen.
///  • Free tutors: what Pro unlocks, the plans, and the bKash buy flow
///    (tap a plan → pay in bKash → Pro turns on automatically).
///  • Pro tutors : a celebratory confirmation, nothing to sell.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  /// ⚠️ Set your own contact details here.
  static const String hotline = '01715041725';

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isPro = false;
  bool _loading = true;

  BkashPlan _plan = BkashService.plans.first;
  bool _buying = false;
  Timer? _poll;
  String? _waitingTrx;

  @override
  void initState() {
    super.initState();
    AppStyle.load();
    _load();
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final pro = await PaperLicense.isPro();
    if (mounted) {
      setState(() {
        _isPro = pro;
        _loading = false;
      });
    }
  }

  Future<void> _problem(String title, String message, {String? detail}) =>
      showProblemDialog(context, title: title, message: message, detail: detail);

  // ── bKash flow ───────────────────────────────────────────────────

  Future<void> _buy() async {
    if (_buying) return;
    if (!AuthService.isLoggedIn) {
      await _problem(
        'Sign in first',
        'Pro is linked to your tutor account, so sign in (or create a free '
            'account) before paying. Your papers work offline either way.',
      );
      return;
    }
    // Confirm the bKash number that will receive the payment.
    final profile = await AuthService.fetchProfile(refresh: false);
    var phone = (profile?['phone']?.toString() ?? '')
        .replaceAll(RegExp(r'[^\d]'), '');
    if (phone.startsWith('880')) phone = phone.substring(3);
    if (phone.startsWith('0')) phone = phone.substring(1);
    final ctrl = TextEditingController(text: phone);
    String? err;
    final saved = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setD) => AlertDialog(
          title: const Text('Pay with bKash'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_plan.label} — ${_plan.periodText}\n'
                'Enter the bKash number that will make the payment.',
                style: const TextStyle(fontSize: 13, height: 1.55),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.phone,
                autofocus: true,
                maxLength: 11,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'bKash number',
                  hintText: '01XXXXXXXXX',
                  counterText: '',
                  prefixText: '+880 ',
                  prefixStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              if (err != null) ...[
                const SizedBox(height: 10),
                Text(err!,
                    style:
                        const TextStyle(color: AppTheme.danger, fontSize: 12.5)),
              ],
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final p = ctrl.text.trim();
                if (!RegExp(r'^01\d{9}$').hasMatch(p)) {
                  setD(() => err = 'Enter a valid bKash number, e.g. 01712345678.');
                  return;
                }
                Navigator.pop(c, true);
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
    if (saved != true || !mounted) return;

    setState(() {
      _buying = true;
      _waitingTrx = null;
    });
    try {
      final (trxId, url) = await BkashService.initiate(
        plan: _plan,
        phone: ctrl.text.trim(),
        name: AuthService.displayName,
        email: AuthService.email ?? '',
      );
      if (!mounted) return;
      // Open bKash, then wait for the money to be confirmed.
      final opened = await BkashService.openCheckout(url);
      if (!mounted) return;
      if (!opened) {
        await _problem('Could not open bKash',
            'bKash did not open. Install the bKash app or check your browser, then tap the plan again.');
        return;
      }
      _showWaiting(trxId);
    } on BkashError catch (e) {
      if (mounted) await _problem('Payment could not be started', e.message);
    } catch (e) {
      if (mounted) {
        await _problem('Payment could not be started',
            'Something went wrong talking to the payment server.', detail: '$e');
      }
    } finally {
      if (mounted) setState(() => _buying = false);
    }
  }

  /// Non-dismissible "paying" dialog with an automatic check every 4 s.
  void _showWaiting(String trxId) {
    _waitingTrx = trxId;
    int attempts = 0;
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(seconds: 4), (_) async {
      attempts++;
      if (!mounted) return;
      try {
        final status = await BkashService.verify(trxId);
        if (!mounted) return;
        if (status == 'active') {
          _poll?.cancel();
          Navigator.of(context).pop(); // close the waiting dialog
          await _activate();
          return;
        }
        if (status == 'failed') {
          _poll?.cancel();
          Navigator.of(context).pop();
          await _problem(
            'This bKash payment failed',
            'bKash rejected this payment — no money left your account. '
                'You can try again straight away.',
          );
          return;
        }
        if (attempts >= 30) {
          _poll?.cancel();
          Navigator.of(context).pop();
          await _problem(
            'Payment not detected yet',
            'bKash has not confirmed the money yet. It can take a little '
                'while — tap "Check again" any time, or contact support if '
                'it still does not activate.',
          );
        }
      } on BkashError {
        // Network blip while polling — just wait for the next tick.
      }
    });
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (c) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Waiting for bKash…'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(strokeWidth: 2.2)),
                const SizedBox(width: 12),
                const Expanded(
                    child: Text(
                        'Complete the payment in bKash, then come back here — the app activates Pro by itself.')),
              ]),
              const SizedBox(height: 14),
              Text(
                'Payment reference: $trxId',
                style: const TextStyle(fontSize: 11.5, color: AppTheme.muted),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                _poll?.cancel();
                Navigator.pop(c);
                _manualCheck(trxId);
              },
              child: const Text('Check now'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _manualCheck(String trxId) async {
    setState(() => _buying = true);
    try {
      final status = await BkashService.verify(trxId);
      if (!mounted) return;
      if (status == 'active') {
        await _activate();
      } else if (status == 'failed') {
        await _problem('This bKash payment failed',
            'bKash rejected this payment — no money left your account.');
      } else {
        await _problem(
          'Still waiting',
          'bKash has not confirmed the payment yet. Try again in a minute, '
              'or contact support with the payment reference.',
        );
      }
    } on BkashError catch (e) {
      if (mounted) await _problem('Could not check the payment', e.message);
    } finally {
      if (mounted) setState(() => _buying = false);
    }
  }

  Future<void> _activate() async {
    try {
      await AuthService.syncProFromServer();
    } catch (_) {}
    if (!mounted) return;
    setState(() => _isPro = true);
    await _load();
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('🎉 Pro is active!'),
        content: const Text(
            'Thank you for supporting Tutor\'s Desk.\n\n'
            'Full papers, no watermark, PDF and printing — every feature '
            'is unlocked.'),
        actions: [
          FilledButton(
              onPressed: () => Navigator.pop(c), child: const Text('Great!')),
        ],
      ),
    );
  }

  // ── UI ───────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_isPro ? "Tutor's Desk Pro" : 'Upgrade to Pro')),
      body: SafeArea(
        child: SoftSwitcher(
          child: _loading
              ? const BusyIndicator(
                  key: ValueKey('loading'), message: 'Checking your licence...')
              : (_isPro ? _proBody() : _buyBody()),
        ),
      ),
    );
  }

  // ══ Pro tutors ══════════════════════════════════════════════════
  Widget _proBody() {
    return Center(
      key: const ValueKey('pro'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FadeSlideIn(
          child: GlassCard(
            highlighted: true,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 110,
                  height: 110,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const HaloRing(size: 110, strokeWidth: 2.6),
                      Pulse(
                        min: .93,
                        max: 1.07,
                        period: const Duration(milliseconds: 1800),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primary.withOpacity(.12),
                            border: Border.all(
                                color: AppTheme.primary.withOpacity(.5),
                                width: 1.4),
                          ),
                          child: const Icon(Icons.verified_rounded,
                              color: AppTheme.accent, size: 44),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'You are on Pro',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .4,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Full papers, no watermark, unlimited PDF export and printing — every feature is unlocked. Thank you!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppTheme.muted, fontSize: 13.5, height: 1.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══ Free tutors ═════════════════════════════════════════════════
  Widget _buyBody() {
    const perks = [
      (Icons.description_rounded, 'Full question papers',
          'Every banked question, no demo cut-off'),
      (Icons.picture_as_pdf_rounded, 'PDF export & printing',
          'Share or print straight from your phone'),
      (Icons.water_drop_outlined, 'No watermark',
          'Clean, classroom-ready papers'),
      (Icons.rocket_launch_rounded, 'New features first',
          'Get every improvement as it ships'),
    ];

    return ListView(
      key: const ValueKey('buy'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
      children: [
        GlassCard(
          highlighted: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Pulse(
                    min: .95,
                    max: 1.06,
                    period: const Duration(milliseconds: 2100),
                    child: const Icon(Icons.workspace_premium_rounded,
                        color: AppTheme.accent, size: 32),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Tutor's Desk Pro",
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Pay with bKash — Pro turns on automatically after payment.',
                style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SectionTitle(
          title: "What's included",
          icon: Icons.check_circle_outline_rounded,
        ),
        for (final perk in perks)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primary.withOpacity(.12),
                      border:
                          Border.all(color: AppTheme.primary.withOpacity(.32)),
                    ),
                    child: Icon(perk.$1, color: AppTheme.accent, size: 19),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          perk.$2,
                          style: const TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          perk.$3,
                          style: TextStyle(
                              color: AppTheme.muted,
                              fontSize: 11.8,
                              height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        const SectionTitle(
          title: 'Choose a plan',
          icon: Icons.receipt_long_rounded,
        ),
        for (final plan in BkashService.plans)
          _planCard(plan),
        const SizedBox(height: 16),
        PressableScale(
          onTap: _buying ? null : _buy,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: AppTheme.primary.withOpacity(.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_buying)
                  const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                else
                  const Icon(Icons.account_balance_wallet_rounded,
                      color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  _buying
                      ? 'Starting bKash payment…'
                      : 'Pay ${_plan.amount.toString().replaceAll(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), r'$1,')} with bKash',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'You will be redirected to bKash. The app activates Pro '
            'automatically as soon as bKash confirms the payment.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppTheme.muted, height: 1.5),
          ),
        ),
        const SizedBox(height: 14),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Support',
                icon: Icons.support_agent_rounded,
              ),
              const Text(
                'Payment problems, refunds or questions — contact support. '
                'Never share your bKash PIN or payment credentials inside '
                'the app.',
                style:
                    TextStyle(fontSize: 12.5, height: 1.6, color: AppTheme.muted),
              ),
              const SizedBox(height: 14),
              PressableScale(
                onTap: () {
                  Clipboard.setData(
                      const ClipboardData(text: SubscriptionScreen.hotline));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Support number copied')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppTheme.primary.withOpacity(.10),
                    border: Border.all(color: AppTheme.primary.withOpacity(.35)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.support_agent_rounded,
                          color: AppTheme.accent, size: 20),
                      const SizedBox(width: 11),
                      const Expanded(
                        child: Text(
                          SubscriptionScreen.hotline,
                          style: TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .6,
                          ),
                        ),
                      ),
                      const Icon(Icons.copy_rounded,
                          color: AppTheme.muted, size: 17),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _planCard(BkashPlan plan) {
    final selected = _plan.id == plan.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PressableScale(
        onTap: _buying ? null : () => setState(() => _plan = plan),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: selected
                ? AppTheme.primary.withOpacity(.08)
                : AppTheme.card,
            border: Border.all(
                color: selected ? AppTheme.primary : AppTheme.border,
                width: selected ? 1.6 : 1),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: AppTheme.primary.withOpacity(.18),
                        blurRadius: 14,
                        offset: const Offset(0, 4))
                  ]
                : null,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: selected ? AppTheme.primary : AppTheme.border,
                      width: 2),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primary),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.label,
                        style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark)),
                    const SizedBox(height: 2),
                    Text(plan.periodText,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.muted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.muted),
            ],
          ),
        ),
      ),
    );
  }
}
