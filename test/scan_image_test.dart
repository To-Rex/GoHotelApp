import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:gohotels/features/reception/scan/data/scan_image.dart';

/// Qirqish xaritasi — sof geometriya.
///
/// Bu hisob noto'g'ri bo'lsa, hujjatning bir cheti kesilib ketadi va
/// skaner "aniqroq" o'rniga umuman o'qimay qo'yadi. Shuning uchun
/// invariantlar alohida tekshiriladi: qirqim ramkadan KENG, surat
/// ichida va markazi ramka markaziga mos.
void main() {
  // Ekran MANTIQIY pikselda (telefonlarda ~360-430): ramka ham, xarita
  // ham shu birlikda ishlaydi, surat esa fizik pikselda bo'laveradi
  const screen = Size(392, 850);
  const photo = Size(3000, 4000); // 4:3 tik kadr (EXIF qo'llangandan keyin)
  const idAspect = 85.6 / 54;
  const passportAspect = 125 / 88;

  group('frameRectFor', () {
    test('ramka ekran markazidan tepada va 90% enda', () {
      final frame = frameRectFor(screen, idAspect);
      expect(frame.width, closeTo(392 * 0.9, 0.001));
      expect(frame.height, closeTo(frame.width / idAspect, 0.001));
      expect(frame.center.dx, closeTo(196, 0.001));
      expect(frame.center.dy, closeTo(850 * 0.42, 0.001));
    });

    test('katta ekranda 560 px bilan chegaralanadi', () {
      final frame = frameRectFor(const Size(800, 1200), passportAspect);
      expect(frame.width, 560);
    });
  });

  group('cropRectFor', () {
    test('qirqim ramkani mo\'l chegara bilan qamrab oladi', () {
      final crop = cropRectFor(
        screen: screen,
        image: photo,
        aspect: idAspect,
      )!;

      // BoxFit.cover xaritasi qo'lda hisoblanadi
      final scale = math.max(
        screen.width / photo.width,
        screen.height / photo.height,
      );
      final offsetX = (photo.width - screen.width / scale) / 2;
      final frame = frameRectFor(screen, idAspect);

      // Ramkaning o'zi surat koordinatalarida
      final frameLeft = offsetX + frame.left / scale;
      final frameRight = offsetX + frame.right / scale;

      expect(crop.left, lessThan(frameLeft));
      expect(crop.right, greaterThan(frameRight));
      // Markazlar mos: ramka gorizontal markazda — qirqim ham
      expect(crop.center.dx, closeTo(photo.width / 2, 1.0));
    });

    test('qirqim surat chegarasidan chiqmaydi', () {
      final crop = cropRectFor(
        screen: screen,
        image: photo,
        aspect: passportAspect,
      )!;
      expect(crop.left, greaterThanOrEqualTo(0));
      expect(crop.top, greaterThanOrEqualTo(0));
      expect(crop.right, lessThanOrEqualTo(photo.width));
      expect(crop.bottom, lessThanOrEqualTo(photo.height));
      expect(crop.width, greaterThan(0));
      expect(crop.height, greaterThan(0));
    });

    test('qirqim to\'liq kadrdan sezilarli kichik — maqsad ham shu', () {
      final crop = cropRectFor(
        screen: screen,
        image: photo,
        aspect: idAspect,
      )!;
      // Hujjat qirqimning asosiy qismini egallashi uchun fon tashlanadi
      expect(crop.height, lessThan(photo.height * 0.6));
    });

    test('yotiq surat — qirqilmaydi (asl kadr ketadi)', () {
      expect(
        cropRectFor(
          screen: screen,
          image: const Size(4000, 3000),
          aspect: idAspect,
        ),
        isNull,
      );
    });

    test("nol o'lchamlar — qirqilmaydi", () {
      expect(
        cropRectFor(screen: Size.zero, image: photo, aspect: idAspect),
        isNull,
      );
      expect(
        cropRectFor(screen: screen, image: Size.zero, aspect: idAspect),
        isNull,
      );
    });

    test('juda tor surat — shubhali qirqim rad etiladi', () {
      // Surat ekranga nisbatan g'ayrioddiy: qirqim juda kichik chiqsa
      // asl kadr afzal
      final crop = cropRectFor(
        screen: screen,
        image: const Size(320, 4000),
        aspect: idAspect,
      );
      expect(crop == null || crop.width >= 320 * 0.3, isTrue);
    });
  });
}
