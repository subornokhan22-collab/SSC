import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';
import 'app_icon.dart';
import 'motion_policy.dart';

@immutable
class FeatureHighlight {
  final Object icon;
  final String title;
  final String description;

  const FeatureHighlight({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// Compact, accessible feature tour for the authentication welcome surface.
///
/// The center card receives the only decorative glow. Auto-play pauses for
/// touch, reduced motion, hidden routes, and background app lifecycle states.
class FeatureCarousel extends StatefulWidget {
  final List<FeatureHighlight> features;
  final Duration interval;

  const FeatureCarousel({
    super.key,
    required this.features,
    this.interval = const Duration(seconds: 4),
  });

  @override
  State<FeatureCarousel> createState() => _FeatureCarouselState();
}

class _FeatureCarouselState extends State<FeatureCarousel>
    with WidgetsBindingObserver {
  static const _initialPage = 10000;
  late final PageController _controller;
  Timer? _timer;
  bool _foreground = true;
  bool _touching = false;
  int _page = _initialPage;

  bool get _canAutoPlay =>
      mounted &&
      widget.features.length > 1 &&
      _foreground &&
      !_touching &&
      !MotionPolicy.reduce(context) &&
      TickerMode.of(context);

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: _initialPage,
      viewportFraction: .82,
    );
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _synchronizeTimer();
  }

  @override
  void didUpdateWidget(covariant FeatureCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _synchronizeTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _synchronizeTimer();
  }

  void _synchronizeTimer() {
    _timer?.cancel();
    _timer = null;
    if (!_canAutoPlay) return;
    _timer = Timer.periodic(widget.interval, (_) {
      if (!_canAutoPlay || !_controller.hasClients) return;
      _controller.nextPage(
        duration: MotionPolicy.duration(context, 340),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _setTouching(bool touching) {
    if (_touching == touching) return;
    _touching = touching;
    _synchronizeTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.features.isEmpty) return const SizedBox.shrink();
    if (MotionPolicy.reduce(context) || widget.features.length == 1) {
      return _FeatureCard(feature: widget.features.first, active: true);
    }

    return Semantics(
      label: 'Tutor’s Desk features',
      child: SizedBox(
        height: 126,
        child: Listener(
          onPointerDown: (_) => _setTouching(true),
          onPointerUp: (_) => _setTouching(false),
          onPointerCancel: (_) => _setTouching(false),
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) {
              final feature = widget.features[index % widget.features.length];
              return AnimatedBuilder(
                animation: _controller,
                child: _FeatureCard(
                  feature: feature,
                  active: index == _page,
                ),
                builder: (context, child) {
                  final current = _controller.hasClients &&
                          _controller.position.haveDimensions
                      ? _controller.page ?? _page.toDouble()
                      : _page.toDouble();
                  final distance = (current - index).abs().clamp(0.0, 1.0);
                  final scale = 1 - distance * .08;
                  final lift = 7 * (1 - distance);
                  return Transform.translate(
                    offset: Offset(0, -lift),
                    child: Transform.scale(scale: scale, child: child),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final FeatureHighlight feature;
  final bool active;

  const _FeatureCard({required this.feature, required this.active});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: MotionPolicy.duration(context, 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(
            color: active ? AppColors.primaryDark : AppColors.border,
            width: active ? 1.4 : 1,
          ),
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0x24000000),
                    blurRadius: 18,
                    offset: Offset(0, 7),
                  ),
                ]
              : null,
        ),
        child: Opacity(
          opacity: active ? 1 : .58,
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadii.compact),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: AppIcon(
                    feature.icon,
                    size: 25,
                    color: AppColors.text,
                    semanticLabel: feature.title,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(feature.title, style: AppTypography.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      feature.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
