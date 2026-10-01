import 'package:flutter/material.dart';

/// 24 soatlik chiziq: xodimning ish oralig'i va "hozir" belgisi.
///
/// "09:00 – 18:00" matnini o'qib, soatga qarab hisoblash o'rniga bir
/// qarashda ko'rinadi: smena qayerda, hozir uning ichidami. Tungi smena
/// (22:00–06:00) yarim tundan o'tadi — ikki bo'lak bo'lib chiziladi.
class DayTimeline extends StatelessWidget {
  const DayTimeline({
    super.key,
    required this.start,
    required this.end,
    required this.now,
    required this.color,
    required this.trackColor,
    required this.markerColor,
    this.height = 6,
    this.labelStyle,
  });

  /// "HH:mm" ko'rinishida.
  final String start;
  final String end;
  final DateTime now;

  /// Ish oralig'i rangi.
  final Color color;
  final Color trackColor;

  /// "Hozir" nuqtasi rangi.
  final Color markerColor;
  final double height;

  /// Berilsa ostida 00 / 06 / 12 / 18 / 24 belgilari chiziladi.
  final TextStyle? labelStyle;

  static int? _minutes(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return (h * 60 + m).clamp(0, 1440);
  }

  @override
  Widget build(BuildContext context) {
    final bar = SizedBox(
      height: height * 2,
      width: double.infinity,
      child: CustomPaint(
        painter: _TimelinePainter(
          start: _minutes(start),
          end: _minutes(end),
          now: now.hour * 60 + now.minute,
          color: color,
          trackColor: trackColor,
          markerColor: markerColor,
          thickness: height,
        ),
      ),
    );
    if (labelStyle == null) return bar;
    return Column(
      children: [
        bar,
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final h in const ['00', '06', '12', '18', '24'])
              Text(h, style: labelStyle),
          ],
        ),
      ],
    );
  }
}

class _TimelinePainter extends CustomPainter {
  _TimelinePainter({
    required this.start,
    required this.end,
    required this.now,
    required this.color,
    required this.trackColor,
    required this.markerColor,
    required this.thickness,
  });

  final int? start;
  final int? end;
  final int now;
  final Color color;
  final Color trackColor;
  final Color markerColor;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final top = (size.height - thickness) / 2;
    final radius = Radius.circular(thickness / 2);
    double x(int minutes) => size.width * minutes / 1440;

    canvas.drawRRect(
      RRect.fromLTRBR(0, top, size.width, top + thickness, radius),
      Paint()..color = trackColor,
    );

    final s = start;
    final e = end;
    if (s != null && e != null && s != e) {
      final paint = Paint()..color = color;
      void segment(int from, int to) => canvas.drawRRect(
        RRect.fromLTRBR(x(from), top, x(to), top + thickness, radius),
        paint,
      );
      if (s < e) {
        segment(s, e);
      } else {
        // Tungi smena: kun oxirigacha va kun boshidan
        segment(s, 1440);
        segment(0, e);
      }
    }

    // "Hozir" — chiziqdan biroz katta nuqta, oq hoshiya bilan
    final center = Offset(x(now).clamp(thickness, size.width - thickness), size.height / 2);
    canvas.drawCircle(center, thickness * 0.95, Paint()..color = Colors.white);
    canvas.drawCircle(center, thickness * 0.62, Paint()..color = markerColor);
  }

  @override
  bool shouldRepaint(_TimelinePainter old) =>
      old.start != start ||
      old.end != end ||
      old.now != now ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.markerColor != markerColor;
}
