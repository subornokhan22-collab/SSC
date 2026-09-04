import 'package:flutter/material.dart';

import '../services/app_style.dart';
import '../services/auth_service.dart';
import '../services/paper_license.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/glass_card.dart';
import 'custom_paper_screen.dart';
import 'profile_screen.dart';
import 'question_paper_screen.dart';
import 'subscription_screen.dart';
import '../widgets/app_logo.dart';

/// Tutor workspace — the single home of the app.
/// Chapter papers, full model tests, custom MCQ + OMR, profile and Pro.
class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _ctrl;
  String _name = '';
  bool _isPro = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat(reverse: true);
    _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_ctrl.isAnimating) _ctrl.repeat(reverse: true);
      _load();
    } else {
      _ctrl.stop();
    }
  }

  Future<void> _load() async {
    await AppStyle.load();
    final pro = await PaperLicense.isPro();
    String name = '';
    if (AuthService.isLoggedIn) {
      try {
        final p = await AuthService.fetchProfile(refresh: false);
        name = (p?['name'] ?? '').toString().trim();
        if (name.isEmpty) name = AuthService.displayName;
      } catch (_) {
        name = AuthService.displayName;
      }
    }
    if (!mounted) return;
    setState(() {
      _name = name;
      _isPro = pro;
      _loading = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _open(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    if (mounted) _load(); // Pro state / name may have changed.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppTheme.primary,
          backgroundColor: AppTheme.card,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
            children: Stagger.list([
              _header(),
              const SizedBox(height: 20),
              _statusStrip(),
              const SizedBox(height: 22),
              const SectionTitle(
                title: 'Build a paper',
                subtitle: 'Pick a format — every option exports to PDF or print.',
                icon: Icons.auto_awesome_rounded,
              ),
              _ActionTile(
                icon: Icons.menu_book_rounded,
                title: 'Chapter-wise Model Test',
                subtitle: 'Build a paper from one chosen chapter',
                accentIndex: 0,
                onTap: () =>
                    _open(const QuestionPaperScreen(initialMode: 'chapter')),
              ),
              _ActionTile(
                icon: Icons.description_rounded,
                title: 'Full Model Test Paper',
                subtitle: 'Complete paper in the SSC-2027 board format',
                accentIndex: 1,
                onTap: () =>
                    _open(const QuestionPaperScreen(initialMode: 'full')),
              ),
              _ActionTile(
                icon: Icons.fact_check_rounded,
                title: 'Custom MCQ Test + OMR',
                subtitle: 'Chapter-wise counts • up to 100 • OMR sheet included',
                accentIndex: 2,
                onTap: () => _open(const CustomPaperScreen(mcqOnly: true)),
              ),
              _ActionTile(
                icon: Icons.tune_rounded,
                title: 'Customised Test Paper',
                subtitle: 'Mix chapters with MCQ, short-answer and CQ counts',
                accentIndex: 3,
                onTap: () => _open(const CustomPaperScreen()),
              ),
              const SizedBox(height: 20),
              const SectionTitle(
                title: 'Account',
                icon: Icons.manage_accounts_rounded,
              ),
              _ActionTile(
                icon: Icons.person_rounded,
                title: 'Profile & Settings',
                subtitle: 'Details, workspace theme, Pro sync, sign out',
                accentIndex: 4,
                compact: true,
                onTap: () => _open(const ProfileScreen()),
              ),
              if (!_isPro)
                _ActionTile(
                  icon: Icons.workspace_premium_rounded,
                  title: 'Upgrade to Pro',
                  subtitle: 'Unlock full papers, no watermark, PDF & printing',
                  accentIndex: 5,
                  compact: true,
                  highlighted: true,
                  onTap: () => _open(const SubscriptionScreen()),
                ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final greeting = _loading
        ? 'Loading your workspace...'
        : (_name.isEmpty ? 'Tutor workspace' : 'Welcome back, $_name');
    return Row(
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const HaloRing(size: 56, strokeWidth: 1.8),
              const AppLogo(size: 42),
            ],
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tutor's Desk",
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .8,
                ),
              ),
              const SizedBox(height: 2),
              SoftSwitcher(
                child: Text(
                  greeting,
                  key: ValueKey(greeting),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 12.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        StatusPill(
          label: _isPro ? 'PRO' : 'DEMO',
          color: _isPro ? AppTheme.accent : AppTheme.muted,
          icon: _isPro ? Icons.verified_rounded : Icons.lock_outline_rounded,
        ),
      ],
    );
  }

  /// Slim gradient banner that reacts to the animation controller.
  Widget _statusStrip() {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = _ctrl.value;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment(-1 + t * .6, -1),
              end: Alignment(1 - t * .6, 1),
              colors: [
                Color.lerp(Colors.white, AppTheme.primary, .10)!,
                Colors.white,
                Color.lerp(Colors.white, AppTheme.secondary, .09)!,
              ],
            ),
            border: Border.all(color: AppTheme.primary.withOpacity(.28)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(.08 + .05 * t),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Row(
        children: [
          Pulse(
            min: .94,
            max: 1.06,
            period: const Duration(milliseconds: 2000),
            child: const Icon(Icons.bolt_rounded,
                color: AppTheme.accent, size: 24),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SSC 2027 question bank',
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Board-verified patterns across every subject, ready offline.',
                  style: TextStyle(
                      color: AppTheme.muted, fontSize: 11.8, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tappable, animated card for each workspace action.
class _ActionTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int accentIndex;
  final bool compact;
  final bool highlighted;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.accentIndex,
    this.compact = false,
    this.highlighted = false,
  });

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _pressed = false;

  /// Light [tint, ink] pairs — the tint fills the icon badge, the ink is the
  /// saturated version used for borders, shadows and the pressed state.
  static const _accents = <List<Color>>[
    [Color(0xFF6B7BFF), Color(0xFF3D5AFE)],
    [Color(0xFF4FB3F0), Color(0xFF0B84D9)],
    [Color(0xFFF07EA0), Color(0xFFD3446E)],
    [Color(0xFF4FC48A), Color(0xFF12A150)],
    [Color(0xFF9B85EC), Color(0xFF7C5CE0)],
    [Color(0xFF35C6BA), Color(0xFF00897B)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _accents[widget.accentIndex % _accents.length];
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.all(widget.compact ? 14 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.highlighted
              ? [
                  Color.lerp(Colors.white, AppTheme.primary, .10)!,
                  Color.lerp(Colors.white, AppTheme.primary, .04)!,
                ]
              : [
                  Color.lerp(Colors.white, colors[1], _pressed ? .10 : .035)!,
                  Colors.white,
                ],
        ),
        border: Border.all(
          color: widget.highlighted
              ? AppTheme.primary.withOpacity(.5)
              : colors[1].withOpacity(_pressed ? .45 : .20),
          width: widget.highlighted ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors[1].withOpacity(_pressed ? .08 : .15),
            blurRadius: _pressed ? 10 : 18,
            offset: Offset(0, _pressed ? 3 : 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(widget.compact ? 10 : 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: colors[1].withOpacity(.32), blurRadius: 14),
              ],
            ),
            child: Icon(widget.icon,
                color: Colors.white, size: widget.compact ? 20 : 23),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: widget.compact ? 14.5 : 15.5,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.subtitle,
                  style: const TextStyle(
                      color: AppTheme.muted, fontSize: 11.8, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          AnimatedSlide(
            duration: const Duration(milliseconds: 180),
            offset: Offset(_pressed ? .22 : 0, 0),
            child: Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: colors[0].withOpacity(.75)),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? .975 : 1,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: widget.highlighted
              ? ShineSweep(
                  borderRadius: BorderRadius.circular(20),
                  period: const Duration(milliseconds: 3400),
                  child: content,
                )
              : content,
        ),
      ),
    );
  }
}
