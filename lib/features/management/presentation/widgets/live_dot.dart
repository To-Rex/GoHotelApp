import 'package:flutter/material.dart';

/// "Jonli" belgisi: nafas olayotgan nuqta va yozuv.
///
/// Ma'lumot har daqiqada o'zi yangilanishini bildiradi. Animatsiya kichik
/// (bitta 8 px doira), [RepaintBoundary] ichida — ekranning qolgan qismini
/// qayta chizdirmaydi; ko'rinmas tabda [TickerMode] uni uxlatadi.
class LiveDot extends StatefulWidget {
  const LiveDot({super.key, required this.label, required this.color, this.textStyle});

  final String label;
  final Color color;
  final TextStyle? textStyle;

  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RepaintBoundary(
          child: SizedBox(
            width: 14,
            height: 14,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = Curves.easeOut.transform(_controller.value);
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Tarqalayotgan halqa
                    Container(
                      width: 6 + 8 * t,
                      height: 6 + 8 * t,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.color.withValues(alpha: 0.35 * (1 - t)),
                      ),
                    ),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.color,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(widget.label, style: widget.textStyle),
      ],
    );
  }
}
