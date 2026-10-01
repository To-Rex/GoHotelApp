import 'package:flutter/material.dart';

/// Tushum chizig'i: silliq egri, ostida tekis och rang (gradient emas),
/// oxirgi nuqta belgilangan. Ochilganda chiziq chapdan o'ngga "chiziladi".
///
/// Kutubxonasiz, bitta [CustomPainter] — yengil va mavzuga mos.
class IncomeSparkline extends StatelessWidget {
  const IncomeSparkline({
    super.key,
    required this.values,
    required this.labels,
    required this.color,
    required this.labelStyle,
    this.height = 96,
    this.highlightIndex,
  });

  final List<double> values;
  final List<String> labels;
  final Color color;
  final TextStyle labelStyle;
  final double height;

  /// Alohida ko'rsatiladigan nuqta (odatda bugun — oxirgisi).
  final int? highlightIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeInOutCubic,
            builder: (context, progress, _) => CustomPaint(
              painter: _SparkPainter(
                values: values,
                color: color,
                progress: progress,
                highlightIndex: highlightIndex ?? values.length - 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final label in labels)
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: labelStyle,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({
    required this.values,
    required this.color,
    required this.progress,
    required this.highlightIndex,
  });

  final List<double> values;
  final Color color;
  final double progress;
  final int highlightIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    const padTop = 10.0;
    const padBottom = 8.0;
    final maxValue = values.fold<double>(0, (m, v) => v > m ? v : m);
    // Hamma kun nol bo'lsa chiziq pastda tekis turadi — bo'linish nolga
    // bo'lmasin
    final scale = maxValue <= 0 ? 0.0 : (size.height - padTop - padBottom) / maxValue;
    final step = values.length == 1 ? 0.0 : size.width / (values.length - 1);
    // Bitta ustunda nuqta o'rtada tursin
    final xOffset = values.length == 1 ? size.width / 2 : 0.0;

    final points = [
      for (var i = 0; i < values.length; i++)
        Offset(
          xOffset + step * i,
          size.height - padBottom - values[i] * scale,
        ),
    ];

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      // Katmull-Rom'siz oddiy kubik: nazorat nuqtalari oraliq o'rtasida —
      // egri silliq, lekin qiymatdan oshib "sakramaydi"
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      line.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    // Chizilish animatsiyasi: yo'lning boshidan `progress` ulushi
    final metrics = line.computeMetrics().toList();
    final drawn = Path();
    for (final metric in metrics) {
      drawn.addPath(metric.extractPath(0, metric.length * progress), Offset.zero);
    }

    // Ostidagi tekis och rang — faqat chizilgan qismgacha
    final fill = Path.from(drawn);
    final tail = drawn.computeMetrics().fold<Offset?>(null, (last, m) {
      final t = m.getTangentForOffset(m.length);
      return t?.position ?? last;
    });
    if (tail != null) {
      fill
        ..lineTo(tail.dx, size.height)
        ..lineTo(points.first.dx, size.height)
        ..close();
      canvas.drawPath(fill, Paint()..color = color.withValues(alpha: 0.10));
    }

    canvas.drawPath(
      drawn,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Oxirgi (bugungi) nuqta — chiziq unga yetib kelgach paydo bo'ladi
    if (progress >= 0.999 && highlightIndex >= 0 && highlightIndex < points.length) {
      final p = points[highlightIndex];
      canvas.drawCircle(p, 7, Paint()..color = color.withValues(alpha: 0.22));
      canvas.drawCircle(p, 4, Paint()..color = color);
      canvas.drawCircle(p, 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_SparkPainter old) =>
      old.progress != progress ||
      old.values != values ||
      old.color != color ||
      old.highlightIndex != highlightIndex;
}
