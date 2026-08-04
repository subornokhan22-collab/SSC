import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'main_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoRotate;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<double> _taglineFade;
  late final Animation<double> _glowPulse;
  late final Animation<double> _ring1;
  late final Animation<double> _ring2;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2600));

    _logoScale = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.3, end: 1.12)
              .chain(CurveTween(curve: Curves.easeOutBack)),
          weight: 55),
      TweenSequenceItem(
          tween:
              Tween(begin: 1.12, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
          weight: 20),
    ]).animate(_controller);

    _logoFade = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn));

    _logoRotate = Tween<double>(begin: -0.35, end: 0.0).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic)));

    _titleSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.40, 0.75, curve: Curves.easeOutCubic)));

    _titleFade = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.75, curve: Curves.easeIn));

    _taglineFade = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.95, curve: Curves.easeIn));

    _glowPulse = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 1.0)));

    // Expanding ripple rings around the logo
    _ring1 = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.95, curve: Curves.easeOut));
    _ring2 = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 1.00, curve: Curves.easeOut));

    // One-time shimmer pass across the title
    _shimmer = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 1.00, curve: Curves.easeInOut));

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 3100), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, anim, __) => const MainHomeScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _rippleRing(Animation<double> anim, double baseSize) {
    final t = anim.value;
    if (t <= 0) return const SizedBox.shrink();
    return Opacity(
      opacity: (1 - t) * 0.45,
      child: Container(
        width: baseSize + 150 * t,
        height: baseSize + 150 * t,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.8),
            width: 2.5 * (1 - t) + 0.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              // Animated gradient backdrop
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(AppTheme.primary, const Color(0xFF06263F),
                            _glowPulse.value * 0.3)!,
                        AppTheme.secondary,
                      ],
                    ),
                  ),
                ),
              ),
              // Soft glow behind the logo
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.accent.withOpacity(0.35 * _glowPulse.value),
                        AppTheme.accent.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Expanding ripple rings
              Center(child: _rippleRing(_ring1, 150)),
              Center(child: _rippleRing(_ring2, 190)),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.rotate(
                      angle: _logoRotate.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _logoFade.value.clamp(0.0, 1.0),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.asset('assets/icon/icon.png',
                                  fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SlideTransition(
                      position: _titleSlide,
                      child: FadeTransition(
                        opacity: _titleFade,
                        child: ShaderMask(
                          blendMode: BlendMode.srcATop,
                          shaderCallback: (rect) {
                            final pos = -0.5 + _shimmer.value * 2.0;
                            return LinearGradient(
                              begin: Alignment(pos - 0.35, 0),
                              end: Alignment(pos + 0.35, 0),
                              colors: const [
                                Colors.white,
                                Color(0xFFFFF3C4),
                                Colors.white,
                              ],
                            ).createShader(rect);
                          },
                          child: const Text(
                            'A-Learning',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _taglineFade,
                      child: const Text(
                        'SSC ২০২৭ প্রস্তুতি',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.white70,
                            letterSpacing: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom loading indicator
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _taglineFade,
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.85)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
