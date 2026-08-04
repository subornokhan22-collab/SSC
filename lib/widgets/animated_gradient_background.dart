import 'package:flutter/material.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget? child;
  final Duration duration;
  final List<Color> colors;

  /// Paints a soft white layer over the flowing gradient so dark text
  /// stays readable. Set to false for the full vivid effect.
  final bool softWash;
  final double washOpacity;

  const AnimatedGradientBackground({
    Key? key,
    this.child,
    this.duration = const Duration(seconds: 4),
    this.colors = const [
      Color(0xFF7C3AED),
      Color(0xFF06B6D4),
      Color(0xFFF59E0B),
      Color(0xFFEC4899),
    ],
    this.softWash = true,
    this.washOpacity = 0.87,
  }) : super(key: key);

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Alignment> _alignments;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _alignments = [
      Alignment.topLeft,
      Alignment.topRight,
      Alignment.bottomRight,
      Alignment.bottomLeft,
    ];
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % _alignments.length;
          });
          _controller.forward(from: 0.0);
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final next = (_currentIndex + 1) % _alignments.length;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.lerp(
                _alignments[_currentIndex],
                _alignments[next],
                _controller.value,
              )!,
              end: Alignment.lerp(
                _alignments[next],
                _alignments[(_currentIndex + 2) % _alignments.length],
                _controller.value,
              )!,
              colors: [
                Color.lerp(
                  widget.colors[_currentIndex % widget.colors.length],
                  widget.colors[next % widget.colors.length],
                  _controller.value,
                )!,
                Color.lerp(
                  widget.colors[next % widget.colors.length],
                  widget.colors[(next + 1) % widget.colors.length],
                  _controller.value,
                )!,
              ],
            ),
          ),
          child: widget.softWash
              ? Container(
                  color: Colors.white.withOpacity(widget.washOpacity),
                  child: widget.child,
                )
              : widget.child,
        );
      },
    );
  }
}
