import 'dart:ui' show Size;

import 'package:camera/camera.dart' show ImageFormatGroup;
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart'
    show InputImageFormat;

/// Kamera kadrini ML Kit'ga uzatish qoidalari: ular platformaga qarab
/// farq qiladi.
///
/// * **Android** kadrni sensorning o'z yo'nalishida (odatda yonboshlab)
///   NV21 formatida beradi. ML Kit uni `sensorOrientation` gradusga
///   burib o'qiydi.
/// * **iOS** kadrni BGRA formatida va ekran yo'nalishiga allaqachon
///   burilgan holda beradi (tik ekranda eni bo'yidan kichik). Kamera
///   plagini esa `sensorOrientation` uchun doim 90 qaytaradi. Kadr
///   yana 90° burilsa, yuz yonboshlab ko'rinadi va ML Kit uni topmaydi.
abstract final class FaceFrame {
  /// Kadr oqimi formati: Android uchun NV21, iOS uchun BGRA. ML Kit shu
  /// ikkisini qabul qiladi.
  static ImageFormatGroup streamFormat(TargetPlatform platform) =>
      platform == TargetPlatform.iOS
      ? ImageFormatGroup.bgra8888
      : ImageFormatGroup.nv21;

  /// [streamFormat] ga mos ML Kit formati.
  static InputImageFormat inputFormat(TargetPlatform platform) =>
      platform == TargetPlatform.iOS
      ? InputImageFormat.bgra8888
      : InputImageFormat.nv21;

  /// Kadrni tik holatga keltiradigan burilish (gradus).
  static int rotationDegrees({
    required TargetPlatform platform,
    required int sensorOrientation,
    required int width,
    required int height,
  }) {
    if (platform == TargetPlatform.iOS && width <= height) return 0;
    return sensorOrientation;
  }

  /// ML Kit natijalari tik koordinatalarda keladi: 90° va 270° burilishda
  /// kadrning eni va bo'yi o'rin almashadi.
  static Size uprightSize(int width, int height, int rotation) {
    final swap = rotation == 90 || rotation == 270;
    return Size(
      (swap ? height : width).toDouble(),
      (swap ? width : height).toDouble(),
    );
  }
}
