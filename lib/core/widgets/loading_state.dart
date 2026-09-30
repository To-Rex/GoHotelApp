import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../extensions/context_x.dart';

/// Ro'yxat yuklanayotganda ko'rsatiladigan "skelet" kartalar.
class ListSkeleton extends StatefulWidget {
  const ListSkeleton({super.key, this.itemHeight = 108, this.count = 5});

  final double itemHeight;
  final int count;

  @override
  State<ListSkeleton> createState() => _ListSkeletonState();
}

class _ListSkeletonState extends State<ListSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    /* Pulsatsiya RANG orqali: FadeTransition butun ro'yxatni har kadrda
       saveLayer bilan qoplab chizardi — aynan yuklanish (eng band) paytida
       rastr ipiga to'liq ekranlik qatlam tushardi. Skelet doim tekis
       to'liq-xira `background` ustida turadi va ranglarining hammasi ham
       to'liq xira — shuning uchun qatlam shaffofligi fonga oldindan
       aralashtirilgan tekis rangga piksel-piksel teng. DIQQAT: bu tenglik
       fon gradient yoki yarim shaffof bo'lsa buziladi. */
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final alpha = 0.45 + 0.55 * _controller.value;
        Color pulse(Color color) =>
            Color.alphaBlend(color.withValues(alpha: alpha), c.background);
        final surface = pulse(c.surface);
        final surfaceAlt = pulse(c.surfaceAlt);
        final outline = pulse(c.outline);
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.count,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, _) => Container(
            height: widget.itemHeight,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: outline),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _block(surfaceAlt, 56, 56, radius: 16),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _block(surfaceAlt, double.infinity, 16),
                      const SizedBox(height: 10),
                      _block(surfaceAlt, 140, 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _block(Color color, double w, double h, {double radius = 8}) =>
      Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}
