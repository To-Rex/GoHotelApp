import 'package:flutter/material.dart';

/// Kartalar birin-ketin paydo bo'ladi: yengil ko'tarilish + xiralikdan
/// tiniqlikka. Bitta kontroller, har bola o'z oralig'ida.
///
/// Faqat BIRINCHI ko'rinishda ishlaydi (mount) — ro'yxat yangilanganda
/// qayta o'ynamaydi, xodimni bezovta qilmaydi. [TickerMode] o'chiq bo'lsa
/// (ko'rinmas tab) tiker uxlaydi va tab ochilganda davom etadi.
class StaggerIn extends StatefulWidget {
  const StaggerIn({
    super.key,
    required this.children,
    this.interval = const Duration(milliseconds: 55),
    this.duration = const Duration(milliseconds: 420),
    this.offset = 18,
    this.spacing = 12,
  });

  final List<Widget> children;
  final Duration interval;
  final Duration duration;

  /// Boshlang'ich siljish (piksel, pastdan).
  final double offset;
  final double spacing;

  @override
  State<StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<StaggerIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final total = widget.duration + widget.interval * widget.children.length;
    _controller = AnimationController(vsync: this, duration: total)..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _controller.duration!.inMilliseconds.toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < widget.children.length; i++) ...[
          if (i > 0) SizedBox(height: widget.spacing),
          _Item(
            animation: CurvedAnimation(
              parent: _controller,
              curve: Interval(
                (widget.interval.inMilliseconds * i) / total,
                ((widget.interval.inMilliseconds * i) +
                        widget.duration.inMilliseconds) /
                    total,
                curve: Curves.easeOutCubic,
              ),
            ),
            offset: widget.offset,
            child: widget.children[i],
          ),
        ],
      ],
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.animation,
    required this.offset,
    required this.child,
  });

  final Animation<double> animation;
  final double offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      // Bola qayta qurilmaydi — faqat siljish va xiralik o'zgaradi
      child: child,
      builder: (context, child) {
        final t = animation.value;
        if (t >= 1) return child!;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, offset * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }
}
