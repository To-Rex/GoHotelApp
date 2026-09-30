import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// GoHotel brend belgisi — frontend favicon'i bilan bir xil kompozitsiya:
/// ko'k yumaloq kvadrat ichida oq mehmonxona binosi. Kod bilan chiziladi,
/// shuning uchun istalgan o'lchamda tiniq.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _BrandPainter());
  }
}

class _BrandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 48; // favicon 48-birlik koordinatalarida
    final blue = Paint()..color = AppPalette.brand;
    final white = Paint()..color = Colors.white;

    RRect rr(double x, double y, double w, double h, double r) =>
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x * s, y * s, w * s, h * s),
          Radius.circular(r * s),
        );

    // fon
    canvas.drawRRect(rr(0, 0, 48, 48, 10), blue);
    // bino
    canvas.drawRRect(rr(13, 9, 22, 30, 2), white);
    // derazalar
    for (final (x, y) in [
      (17.0, 14.0),
      (27.0, 14.0),
      (17.0, 21.5),
      (27.0, 21.5),
    ]) {
      canvas.drawRRect(rr(x, y, 4, 4.5, 1), blue);
    }
    // eshik (usti yumaloq)
    final door = Path()
      ..moveTo(21.5 * s, 39 * s)
      ..lineTo(21.5 * s, 32.5 * s)
      ..arcToPoint(Offset(23 * s, 31 * s), radius: Radius.circular(1.5 * s))
      ..lineTo(25 * s, 31 * s)
      ..arcToPoint(Offset(26.5 * s, 32.5 * s), radius: Radius.circular(1.5 * s))
      ..lineTo(26.5 * s, 39 * s)
      ..close();
    canvas.drawPath(door, blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
