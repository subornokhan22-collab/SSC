import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../services/app_style.dart';
import '../services/auth_service.dart';
import '../services/rupantor_pay_service.dart';
import '../services/subscription_state.dart';
import '../services/promotion_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/glass_card.dart';
import '../widgets/problem_dialog.dart';

/// Subscription screen.
///  • Free tutors: what Pro unlocks, the plans, and the Rupantor Pay buy flow
///    (tap a plan → pay in Rupantor Pay → Pro turns on automatically).
///  • Pro tutors : a celebratory confirmation, nothing to sell.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  /// ⚠️ Set your own contact details here.
  static const String hotline = '01715041725';

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with WidgetsBindingObserver {
  bool _hasPaidPlan = false;
  bool _loading = true;

  final RupantorPayService _payments = RupantorPayService();
  List<RupantorPlan> _plans = const [];
  RupantorPlan? _plan;
  bool _buying = false;
  Timer? _poll;
  String? _waitingTrx;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppStyle.load();
    _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      SubscriptionState.instance.refresh().then((_) {
        if (mounted) {
          setState(() => _hasPaidPlan =
              SubscriptionState.instance.entitlement.isPaid);
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final state = SubscriptionState.instance;
    await state.initialize(refresh: false);
    final feed = await PromotionService.load();
    List<RupantorPlan> plans = const [];
    try {
      plans = await _payments.plans();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _hasPaidPlan = state.entitlement.isPaid && !state.isExpired;
        _plans = plans;
        _plan = plans.isEmpty ? null : (_plan ?? plans.first);
        _loading = false;
      });
      // Payment status is reconciled in the background; the cached state is
      // enough to render the pricing screen immediately.
      unawaited(state.refresh());
      if (feed.offers.isNotEmpty) {
        // Promotion content remains available to the existing pricing UI.
      }
    }
  }

  Future<void> _problem(String title, String message, {String? detail}) =>
      showProblemDialog(
        context,
        title: title,
        message: message,
        detail: detail,
      );

  // ── Rupantor Pay flow ───────────────────────────────────────────────────

  Future<void> _buy() async {
    final plan = _plan;
    if (_buying || plan == null) return;
    if (!AuthService.isLoggedIn) {
      await _problem(
        'Sign in first',
        "Subscriptions are linked to your Tutor's Desk account. Sign in before paying",
      );
      return;
    }
    setState(() {
      _buying = true;
      _waitingTrx = null;
    });
    try {
      final payment = await _payments.initiate(plan: plan.plan);
      if (!mounted) return;
      final opened = await RupantorPayService.openCheckout(payment.checkoutUrl);
      if (!mounted) return;
      if (!opened) {
        await _problem(
          'Could not open Rupantor Pay',
          'The payment page could not be opened. Check your browser and try again.',
        );
        return;
      }
      _showWaiting(payment.transactionId);
    } on RupantorPayError catch (e) {
      if (mounted) await _problem('Payment could not be started', e.message);
    } catch (e) {
      if (mounted) {
        await _problem(
          'Payment could not be started',
          'Something went wrong talking to the payment server.',
          detail: '$e',
        );
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
        final status = await _payments.verify(trxId);
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
            'This Rupantor Pay payment failed',
            'Rupantor Pay rejected this payment — no money left your account. '
                'You can try again straight away.',
          );
          return;
        }
        if (attempts >= 30) {
          _poll?.cancel();
          Navigator.of(context).pop();
          await _problem(
            'Payment not detected yet',
            'Rupantor Pay has not confirmed the money yet. It can take a little '
                'while — tap "Check again" any time, or contact support if '
                'it still does not activate.',
          );
        }
      } on RupantorPayError {
        // Network blip while polling — just wait for the next tick.
      }
    });
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (c) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Waiting for Rupantor Pay…'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Complete the payment in Rupantor Pay, then come back here — the app activates Pro by itself.',
                    ),
                  ),
                ],
              ),
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
      final status = await _payments.verify(trxId);
      if (!mounted) return;
      if (status == 'active') {
        await _activate();
      } else if (status == 'failed') {
        await _problem(
          'This Rupantor Pay payment failed',
          'Rupantor Pay rejected this payment — no money left your account.',
        );
      } else {
        await _problem(
          'Still waiting',
          'Rupantor Pay has not confirmed the payment yet. Try again in a minute, '
              'or contact support with the payment reference.',
        );
      }
    } on RupantorPayError catch (e) {
      if (mounted) await _problem('Could not check the payment', e.message);
    } finally {
      if (mounted) setState(() => _buying = false);
    }
  }

  Future<void> _activate() async {
    if (!mounted) return;
    await SubscriptionState.instance.refreshAfterPayment();
    if (mounted) {
      setState(() => _hasPaidPlan = SubscriptionState.instance.entitlement.isPaid);
    }
    await _load();
    if (!mounted) return;
    final planName = SubscriptionState.instance.entitlement.plan.displayName;
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('🎉 $planName is active!'),
        content: const Text(
          'Thank you for supporting Tutor\'s Desk.\n\n'
          'Your verified subscription is now active. Premium features '
          'will refresh without restarting the app.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  // ── UI ───────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_hasPaidPlan ? "Tutor's Desk Pro" : 'Upgrade to Pro'),
      ),
      body: SafeArea(
        child: SoftSwitcher(
          child: _loading
              ? const BusyIndicator(
                  key: ValueKey('loading'),
                  message: 'Checking your licence...',
                )
              : (_hasPaidPlan ? _proBody() : _buyBody()),
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
                              width: 1.4,
                            ),
                          ),
                          child: const Icon(
                            PhosphorIcons.sealCheck,
                            color: AppTheme.accent,
                            size: 44,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Your subscription is active',
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
                    color: AppTheme.muted,
                    fontSize: 13.5,
                    height: 1.7,
                  ),
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
      (
        PhosphorIcons.fileText,
        'Full question papers',
        'Every banked question, no demo cut-off',
      ),
      (
        PhosphorIcons.filePdf,
        'PDF export & printing',
        'Share or print straight from your phone',
      ),
      (
        PhosphorIcons.drop,
        'No watermark',
        'Clean, classroom-ready papers',
      ),
      (
        PhosphorIcons.rocketLaunch,
        'New features first',
        'Get every improvement as it ships',
      ),
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
                    child: const Icon(
                      PhosphorIcons.crown,
                      color: AppTheme.accent,
                      size: 32,
                    ),
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
                'Pay with Rupantor Pay — Pro turns on automatically after payment.',
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
          icon: PhosphorIcons.checkCircle,
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
                      border: Border.all(
                        color: AppTheme.primary.withOpacity(.32),
                      ),
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
                            height: 1.4,
                          ),
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
          icon: PhosphorIcons.receipt,
        ),
        for (final plan in _plans) _planCard(plan),
        if (_plans.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text(
              'Plans are temporarily unavailable. Check your connection and try again.',
              style: TextStyle(color: AppTheme.muted),
            ),
          ),
        const SizedBox(height: 16),
        PressableScale(
          onTap: _buying || _plan == null ? null : _buy,
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
                  offset: const Offset(0, 6),
                ),
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
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  const Icon(
                    PhosphorIcons.wallet,
                    color: Colors.white,
                    size: 20,
                  ),
                const SizedBox(width: 10),
                Text(
                  _buying
                      ? 'Starting Rupantor Pay payment…'
                      : _plan == null
                          ? 'Plans unavailable'
                          : 'Pay ${_plan!.amount.toString().replaceAll(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), r'$1,')} with Rupantor Pay',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'You will be redirected to Rupantor Pay. The app activates Pro '
            'automatically as soon as Rupantor Pay confirms the payment.',
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
                icon: PhosphorIcons.headset,
              ),
              const Text(
                'Payment problems, refunds or questions — contact support. '
                'Never share your Rupantor Pay PIN or payment credentials inside '
                'the app.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.6,
                  color: AppTheme.muted,
                ),
              ),
              const SizedBox(height: 14),
              PressableScale(
                onTap: () {
                  Clipboard.setData(
                    const ClipboardData(text: SubscriptionScreen.hotline),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Support number copied')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppTheme.primary.withOpacity(.10),
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        PhosphorIcons.headset,
                        color: AppTheme.accent,
                        size: 20,
                      ),
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
                      const Icon(
                        PhosphorIcons.copy,
                        color: AppTheme.muted,
                        size: 17,
                      ),
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

  Widget _planCard(RupantorPlan plan) {
    final selected = _plan?.id == plan.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PressableScale(
        onTap: _buying ? null : () => setState(() => _plan = plan),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: selected ? AppTheme.primary.withOpacity(.08) : AppTheme.card,
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.border,
              width: selected ? 1.6 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(.18),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
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
                    width: 2,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primary,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.label,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plan.periodText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(PhosphorIcons.caretRight, color: AppTheme.muted),
            ],
          ),
        ),
      ),
    );
  }
}
