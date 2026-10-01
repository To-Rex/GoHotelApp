import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Halqadagi bitta bo'lak: qiymat (xonalar soni) va rangi.
class RingSegment {
  const RingSegment({required this.value, required this.color});

  final int value;
  final Color color;
}

/// Bandlik halqasi: bo'laklar (band / bron / tozalanmoqda / texnik) bir
/// aylanada, orasida nozik bo'shliq, uchlari yumaloq. Yangi qiymat kelganda
/// bo'laklar o'sib boradi — sakramaydi.
///
/// Ichiga [child] beriladi (odatda foiz raqami).
class OccupancyRing extends StatelessWidget {
  const OccupancyRing({
    super.key,
    required this.segments,
    required this.total,
    required this.trackColor,
    this.size = 132,
    this.thickness = 13,
    this.child,
  });

  final List<RingSegment> segments;

  /// Umumiy xonalar soni — halqaning to'liq aylanasi.
  final int total;
  final Color trackColor;
  final double size;
  final double thickness;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    // Har bo'lakning ulushi (0..1) — animatsiya shu qiymatlar ustida
    final fractions = [
      for (final s in segments) total == 0 ? 0.0 : s.value / total,
    ];
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOutCubic,
        builder: (context, progress, child) => CustomPaint(
          painter: _RingPainter(
            fractions: fractions,
            colors: [for (final s in segments) s.color],
            progress: progress,
            trackColor: trackColor,
            thickness: thickness,
          ),
          child: Center(child: child),
        ),
        child: child,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fractions,
    required this.colors,
    required this.progress,
    required this.trackColor,
    required this.thickness,
  });

  final List<double> fractions;
  final List<Color> colors;
  final double progress;
  final Color trackColor;
  final double thickness;

  static const _gap = 0.055; // radianda bo'laklar orasidagi bo'shliq

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - thickness) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);

    var start = -math.pi / 2;
    for (var i = 0; i < fractions.length; i++) {
      final sweep = fractions[i] * math.pi * 2 * progress;
      if (sweep <= 0.0001) continue;
      // Bo'lak juda kichik bo'lsa bo'shliqsiz — aks holda yo'qolib qoladi
      final gap = sweep > _gap * 2 ? _gap : 0.0;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, start + gap / 2, sweep - gap, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.fractions != fractions ||
      old.colors != colors ||
      old.trackColor != trackColor;
}
