import 'package:flutter/material.dart';

/// Raqam "sanab chiqiladi": eski qiymatdan yangisiga silliq o'tadi.
///
/// Boshqaruv ekranidagi raqamlar har daqiqada yangilanadi — sakrab
/// almashgandan ko'ra o'sib borgani ko'zga o'zgarishni ko'rsatadi.
/// [TickerMode] uxlatilgan (ko'rinmas tab) paytda animatsiya ishlamaydi.
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.duration = const Duration(milliseconds: 900),
  });

  final double value;
  final String Function(double value) format;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) => Text(
        format(animated),
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
