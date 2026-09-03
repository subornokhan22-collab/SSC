import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/paper_license.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/glass_card.dart';

/// Subscription screen.
///  • Free tutors: what Pro unlocks, the price and how to buy.
///  • Pro tutors : a celebratory confirmation, nothing to sell.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  /// ⚠️ Set your own contact details here.
  static const String hotline = '01715041725';
  static const String priceLine = '৳799 — one-time Pro unlock';

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isPro = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isPro ? 'A-Learning Pro' : 'Upgrade to Pro')),
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
      children: Stagger.list([
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
                      'A-Learning Pro',
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
                SubscriptionScreen.priceLine,
                style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
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
                          style: const TextStyle(
                              color: AppTheme.muted, fontSize: 11.8, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'How to buy',
                icon: Icons.shopping_bag_outlined,
              ),
              const Text(
                'Online payment is being set up securely. For now, contact support to arrange payment — never share payment credentials inside the app. Pro is then enabled on your email; open Profile → Sync Pro to activate it here.',
                style: TextStyle(fontSize: 13, height: 1.65, color: AppTheme.muted),
              ),
              const SizedBox(height: 16),
              PressableScale(
                onTap: () {
                  Clipboard.setData(
                      const ClipboardData(text: SubscriptionScreen.hotline));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Support number copied')),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
      ]),
    );
  }
}
