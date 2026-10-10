import 'package:flutter/material.dart';

import 'motion_policy.dart';

/// Keeps visited tools (and unsent AI attachments) alive without letting
/// hidden tabs tick, accept input, hold keyboard focus or announce semantics.
class AliveTabStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  const AliveTabStack({super.key, required this.index, required this.children});
  @override
  State<AliveTabStack> createState() => _AliveTabStackState();
}

class _AliveTabStackState extends State<AliveTabStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  int? previous;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      value: 1,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => previous = null);
        }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MotionPolicy.reduce(context)) controller.value = 1;
  }

  @override
  void didUpdateWidget(covariant AliveTabStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      previous = oldWidget.index;
      if (MotionPolicy.reduce(context)) {
        previous = null;
        controller.value = 1;
      } else {
        controller.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final t = Curves.easeOutCubic.transform(controller.value);
          final direction = widget.index >= (previous ?? widget.index) ? 1 : -1;
          return Stack(
            fit: StackFit.expand,
            children: [
              for (var i = 0; i < widget.children.length; i++)
                Offstage(
                  offstage: i != widget.index && i != previous,
                  child: TickerMode(
                    enabled: i == widget.index,
                    child: ExcludeFocus(
                      excluding: i != widget.index,
                      child: ExcludeSemantics(
                        excluding: i != widget.index,
                        child: IgnorePointer(
                          ignoring: i != widget.index,
                          child: Opacity(
                            opacity: i == widget.index ? t : 1 - t,
                            child: Transform.translate(
                              offset: Offset(
                                (i == widget.index ? 1 - t : -t) *
                                    8 *
                                    direction,
                                0,
                              ),
                              child: RepaintBoundary(child: widget.children[i]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
}
