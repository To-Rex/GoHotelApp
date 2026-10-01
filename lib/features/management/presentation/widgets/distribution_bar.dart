import 'package:flutter/material.dart';

/// Taqsimot chizig'idagi bitta bo'lak.
class DistributionSegment {
  const DistributionSegment({required this.value, required this.color});

  final int value;
  final Color color;
}

/// Yig'ma taqsimot chizig'i: bo'laklar ulushiga qarab kenglik oladi,
/// ochilganda chapdan o'ngga "to'ladi". Tekis ranglar, gradient yo'q.
///
/// Xonalar holati (bo'sh / band / tozalanmoqda ...) va shunga o'xshash
/// "jami nimadan iborat" savollari uchun.
class DistributionBar extends StatelessWidget {
  const DistributionBar({
    super.key,
    required this.segments,
    required this.trackColor,
    this.height = 8,
  });

  final List<DistributionSegment> segments;
  final Color trackColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final visible = segments.where((s) => s.value > 0).toList();
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: trackColor),
            if (visible.isNotEmpty)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 750),
                curve: Curves.easeOutCubic,
                builder: (context, t, child) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: t,
                  child: child,
                ),
                child: Row(
                  // Bolasi yo'q ColoredBox o'z holicha 0 balandlik oladi —
                  // cho'zilmasa bo'laklar ko'rinmay qoladi
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < visible.length; i++)
                      Expanded(
                        flex: visible[i].value,
                        child: Padding(
                          // Bo'laklar orasida ingichka bo'shliq
                          padding: EdgeInsets.only(
                            right: i == visible.length - 1 ? 0 : 2,
                          ),
                          child: ColoredBox(color: visible[i].color),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
