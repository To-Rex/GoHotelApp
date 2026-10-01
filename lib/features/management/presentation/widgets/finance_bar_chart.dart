import 'package:flutter/material.dart';

/// Davr bo'yicha tushum va xarajat ustunlari — kutubxonasiz, bitta
/// [CustomPainter]. Har ustun juftligi: chapda tushum, o'ngda xarajat.
/// Eng yuqori tushumli ustun to'liq rangda, qolganlari biroz ochroq —
/// "eng yaxshi kun" bir qarashda ko'rinadi. Ochilganda ustunlar o'sib chiqadi.
class FinanceBarChart extends StatelessWidget {
  const FinanceBarChart({
    super.key,
    required this.revenue,
    required this.expense,
    required this.labels,
    required this.revenueColor,
    required this.expenseColor,
    required this.gridColor,
    required this.labelStyle,
    this.height = 150,
  });

  final List<double> revenue;
  final List<double> expense;

  /// Pastdagi belgilar (hammasi emas — sig'ganicha, birinchi va oxirgisi doim).
  final List<String> labels;
  final Color revenueColor;
  final Color expenseColor;
  final Color gridColor;
  final TextStyle labelStyle;
  final double height;

  /// Nechta belgi chiqadi: ustunlar ko'p bo'lsa har n-chisi.
  static List<int> labelIndexes(int count, {int maxLabels = 6}) {
    if (count <= 0) return const [];
    if (count <= maxLabels) return [for (var i = 0; i < count; i++) i];
    final step = ((count - 1) / (maxLabels - 1)).ceil();
    final out = <int>[for (var i = 0; i < count; i += step) i];
    if (out.last != count - 1) {
      // Oxirgi belgi doim — u bilan ustma-ust tushadigan oldingisi olib tashlanadi
      if (count - 1 - out.last < step / 2) out.removeLast();
      out.add(count - 1);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final shown = labelIndexes(labels.length).toSet();
    return Column(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, progress, _) => CustomPaint(
              painter: _BarsPainter(
                revenue: revenue,
                expense: expense,
                revenueColor: revenueColor,
                expenseColor: expenseColor,
                gridColor: gridColor,
                progress: progress,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, box) {
            final n = labels.length;
            if (n == 0) return const SizedBox.shrink();
            final slot = box.maxWidth / n;
            return SizedBox(
              height: 16,
              child: Stack(
                children: [
                  for (final i in shown)
                    Positioned(
                      left: (slot * i + slot / 2 - 24).clamp(0, box.maxWidth - 48),
                      width: 48,
                      child: Text(
                        labels[i],
                        style: labelStyle,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({
    required this.revenue,
    required this.expense,
    required this.revenueColor,
    required this.expenseColor,
    required this.gridColor,
    required this.progress,
  });

  final List<double> revenue;
  final List<double> expense;
  final Color revenueColor;
  final Color expenseColor;
  final Color gridColor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final n = revenue.length;
    if (n == 0) return;
    var maxValue = 0.0;
    var best = -1;
    for (var i = 0; i < n; i++) {
      final r = revenue[i] > 0 ? revenue[i] : 0.0;
      final e = i < expense.length && expense[i] > 0 ? expense[i] : 0.0;
      if (r > maxValue) maxValue = r;
      if (e > maxValue) maxValue = e;
      if (r > 0 && (best < 0 || r > revenue[best])) best = i;
    }

    // Yordamchi chiziqlar: pastki asos va yarim balandlik
    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height - 0.5), Offset(size.width, size.height - 0.5), grid);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), grid..color = gridColor.withValues(alpha: 0.5));
    if (maxValue <= 0) return;

    final slot = size.width / n;
    final gap = (slot * 0.18).clamp(1.0, 8.0);
    final pairWidth = slot - gap;
    final single = expense.isEmpty ? pairWidth : (pairWidth - 1) / 2;
    final radius = Radius.circular((single / 2).clamp(1.0, 4.0));

    void bar(double left, double width, double value, Color color) {
      if (value <= 0) return;
      final h = (value / maxValue) * (size.height - 4) * progress;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, size.height - h, width, h),
        topLeft: radius,
        topRight: radius,
      );
      canvas.drawRRect(rect, Paint()..color = color);
    }

    for (var i = 0; i < n; i++) {
      final left = slot * i + gap / 2;
      final emphasised = i == best;
      bar(
        left,
        single,
        revenue[i],
        emphasised ? revenueColor : revenueColor.withValues(alpha: 0.55),
      );
      if (expense.isNotEmpty && i < expense.length) {
        bar(left + single + 1, single, expense[i], expenseColor.withValues(alpha: 0.75));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter old) =>
      old.progress != progress ||
      old.revenue != revenue ||
      old.expense != expense ||
      old.revenueColor != revenueColor;
}
