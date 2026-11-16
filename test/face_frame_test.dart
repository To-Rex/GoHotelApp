import 'dart:ui' show Size;

import 'package:camera/camera.dart' show ImageFormatGroup;
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter_test/flutter_test.dart';
import 'package:gohotels/features/auth/presentation/pages/face_frame.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart'
    show InputImageFormat;

void main() {
  group('Android — avvalgidek', () {
    const android = TargetPlatform.android;

    test('NV21 formati', () {
      expect(FaceFrame.streamFormat(android), ImageFormatGroup.nv21);
      expect(FaceFrame.inputFormat(android), InputImageFormat.nv21);
    });

    test('burilish = sensor yo\'nalishi, kadr o\'lchamidan qat\'i nazar', () {
      for (final (w, h) in [(1280, 720), (720, 1280)]) {
        expect(
          FaceFrame.rotationDegrees(
            platform: android,
            sensorOrientation: 270,
            width: w,
            height: h,
          ),
          270,
        );
      }
    });

    test('yonboshlagan kadrning tik o\'lchami', () {
      expect(FaceFrame.uprightSize(1280, 720, 270), const Size(720, 1280));
      expect(FaceFrame.uprightSize(1280, 720, 0), const Size(1280, 720));
    });
  });

  group('iOS', () {
    const ios = TargetPlatform.iOS;

    test('BGRA formati', () {
      expect(FaceFrame.streamFormat(ios), ImageFormatGroup.bgra8888);
      expect(FaceFrame.inputFormat(ios), InputImageFormat.bgra8888);
    });

    test('tik kadr qayta burilmaydi (plagin sensorOrientation=90 desa ham)', () {
      final rotation = FaceFrame.rotationDegrees(
        platform: ios,
        sensorOrientation: 90,
        width: 720,
        height: 1280,
      );
      expect(rotation, 0);
      expect(FaceFrame.uprightSize(720, 1280, rotation), const Size(720, 1280));
    });

    test('yotiq kadr sensor yo\'nalishiga buriladi', () {
      final rotation = FaceFrame.rotationDegrees(
        platform: ios,
        sensorOrientation: 90,
        width: 1280,
        height: 720,
      );
      expect(rotation, 90);
      expect(FaceFrame.uprightSize(1280, 720, rotation), const Size(720, 1280));
    });
  });
}
