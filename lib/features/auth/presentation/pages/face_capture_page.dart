import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/services/camera_service.dart';
import '../../../../l10n/gen/app_localizations.dart';

/// MyID uslubidagi AVTOMATIK yuz suratga olish.
///
/// Old kamera ochiladi, kadrlar qurilmaning o'zida (ML Kit) tahlil qilinadi.
/// Shartlar bajarilganda — bitta yuz, oval markazida, to'g'ri masofada,
/// kameraga to'g'ri qaragan va ~1.5 soniya qimirlamay turganda — surat
/// O'ZI olinadi; qo'lda tugma bosish yo'q. Har bir holat uchun ekranda
/// yo'naltiruvchi matn ko'rsatiladi ("Yaqinroq keling", "Qimirlamay
/// turing…" va h.k.), oval atrofida esa progress halqasi to'ladi.
class FaceCapturePage extends StatefulWidget {
  const FaceCapturePage({super.key});

  /// Suratni avtomatik olib, fayl yo'lini qaytaradi (bekor qilinsa null).
  static Future<String?> open(BuildContext context) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const FaceCapturePage(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<FaceCapturePage> createState() => _FaceCapturePageState();
}

/// Yo'naltiruvchi xabar turlari.
enum _Hint { place, closer, farther, center, lookStraight, hold }

class _FaceCapturePageState extends State<FaceCapturePage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  late final FaceDetector _detector;

  _Hint _hint = _Hint.place;
  int _stableFrames = 0;
  bool _processing = false;
  bool _capturing = false;
  bool _failed = false;
  DateTime _lastProcessed = DateTime.fromMillisecondsSinceEpoch(0);

  /// Shuncha ketma-ket "yaxshi" kadr → avtomatik surat (~0.3–0.5 s).
  static const int _stableNeeded = 3;

  /// Kadr tahlillari orasidagi minimal oraliq (~11 Hz — reaktiv his).
  static const Duration _throttle = Duration(milliseconds: 90);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _detector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        minFaceSize: 0.15,
      ),
    );
    _start();
  }

  Future<void> _start() async {
    try {
      final cameras = await cachedCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _failed = true);
        return;
      }
      final front = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        front,
        ResolutionPreset.high,
        enableAudio: false,
        // ML Kit Android'da NV21 formatini talab qiladi.
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
      await controller.startImageStream(_onFrame);
    } on CameraException {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _detector.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    // Faqat chinakam fonga o'tishda bo'shatiladi — `inactive` bir
    // lahzalik fokus yo'qotishlarda ham keladi va har safar kamera +
    // ML Kit oqimini qayta ko'tarish soniyalab vaqt olardi.
    if (state == AppLifecycleState.paused) {
      _controller = null;
      controller.dispose();
      if (mounted) setState(() {});
    } else if (state == AppLifecycleState.resumed && _controller == null) {
      _start();
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_processing || _capturing || !mounted) return;
    final now = DateTime.now();
    if (now.difference(_lastProcessed) < _throttle) return;
    _lastProcessed = now;
    _processing = true;
    try {
      final input = _toInputImage(image);
      if (input == null) return;
      final faces = await _detector.processImage(input);
      if (!mounted || _capturing) return;
      _evaluate(faces, image);
    } catch (_) {
      // Bitta kadr tahlili yiqilsa — keyingisi bilan davom etamiz.
    } finally {
      _processing = false;
    }
  }

  InputImage? _toInputImage(CameraImage image) {
    final controller = _controller;
    if (controller == null) return null;
    final rotation = InputImageRotationValue.fromRawValue(
      controller.description.sensorOrientation,
    );
    if (rotation == null || image.planes.isEmpty) return null;
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  /// Kadr bo'yicha shartlarni tekshiradi va hint/progress'ni yangilaydi.
  void _evaluate(List<Face> faces, CameraImage image) {
    final controller = _controller;
    if (controller == null) return;

    // ML Kit natijalari "tik" (rotatsiya qo'llangan) koordinatalarda.
    final rotated =
        controller.description.sensorOrientation == 90 ||
        controller.description.sensorOrientation == 270;
    final upW = (rotated ? image.height : image.width).toDouble();
    final upH = (rotated ? image.width : image.height).toDouble();

    _Hint next;
    if (faces.length != 1) {
      next = _Hint.place;
    } else {
      final face = faces.first;
      final box = face.boundingBox;
      final widthFrac = box.width / upW;
      final cx = (box.center.dx / upW) - 0.5;
      final cy = (box.center.dy / upH) - 0.5;
      final yaw = (face.headEulerAngleY ?? 0).abs();
      final roll = (face.headEulerAngleZ ?? 0).abs();

      // Yumshoq shartlar — tez "ushlanadi", server baribir qat'iy tekshiradi.
      if (widthFrac < 0.22) {
        next = _Hint.closer;
      } else if (widthFrac > 0.80) {
        next = _Hint.farther;
      } else if (cx.abs() > 0.22 || cy.abs() > 0.25) {
        next = _Hint.center;
      } else if (yaw > 22 || roll > 22) {
        next = _Hint.lookStraight;
      } else {
        next = _Hint.hold;
      }
    }

    if (next == _Hint.hold) {
      _stableFrames++;
      if (_stableFrames == 1) HapticFeedback.selectionClick();
      if (_stableFrames >= _stableNeeded) {
        _capture();
        return;
      }
    } else {
      _stableFrames = 0;
    }
    if (next != _hint || next == _Hint.hold) {
      setState(() => _hint = next);
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || _capturing) return;
    _capturing = true;
    setState(() {});
    HapticFeedback.mediumImpact();
    try {
      await controller.stopImageStream();
      final file = await controller.takePicture();
      if (!mounted) return;
      Navigator.of(context).pop(file.path);
    } on CameraException {
      if (!mounted) return;
      _capturing = false;
      _stableFrames = 0;
      setState(() {});
      // Oqim to'xtagan bo'lishi mumkin — qayta ishga tushiramiz.
      try {
        await controller.startImageStream(_onFrame);
      } catch (_) {}
    }
  }

  String _hintText(S l10n) => switch (_hint) {
    _Hint.place => l10n.faceAutoPlace,
    _Hint.closer => l10n.faceAutoCloser,
    _Hint.farther => l10n.faceAutoFarther,
    _Hint.center => l10n.faceAutoCenter,
    _Hint.lookStraight => l10n.faceAutoLookStraight,
    _Hint.hold => l10n.faceAutoHold,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = _controller;
    final ready = controller != null && controller.value.isInitialized;
    final progress = (_stableFrames / _stableNeeded).clamp(0.0, 1.0);
    final holding = _hint == _Hint.hold || _capturing;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (ready)
            Center(
              child: AspectRatio(
                aspectRatio: 1 / controller.value.aspectRatio,
                child: CameraPreview(controller),
              ),
            )
          else if (_failed)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.faceNoCameraReason,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          // Oval niqob + silliq animatsiyali holat (oq → yashil) va progress.
          if (!_failed)
            IgnorePointer(
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: holding ? 1.0 : 0.0),
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                builder: (context, activation, _) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(end: _capturing ? 1.0 : progress),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    // RepaintBoundary: animatsiya har kadrda faqat shu
                    // qatlamni qayta chizsin — yopish tugmasi, matn va
                    // boshqa qo'shnilarni emas.
                    builder: (context, smoothProgress, _) => RepaintBoundary(
                      child: CustomPaint(
                        painter: _OvalMaskPainter(
                          progress: smoothProgress,
                          activation: activation,
                          accent: context.colors.success,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          // Yuqori panel: yopish
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Material(
                  color: Colors.black45,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(11),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Pastki yo'naltiruvchi matn
          if (!_failed)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      key: ValueKey(_capturing ? 'cap' : _hint),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (holding) ...[
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: context.colors.brand,
                                value: _capturing ? null : progress,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Flexible(
                            child: Text(
                              _hintText(l10n),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Qorong'i niqob ichida oval "darcha": holat faollashganda chiziq oqdan
/// yashilga SILLIQ o'tadi, atrofida yumshoq nur (glow) paydo bo'ladi va
/// progress yoyi ravon to'ladi — MyID darajasidagi his.
class _OvalMaskPainter extends CustomPainter {
  const _OvalMaskPainter({
    required this.progress,
    required this.activation,
    required this.accent,
  });

  /// 0..1 — progress yoyi (silliq animatsiyalangan).
  final double progress;

  /// 0..1 — shartlar bajarilganlik darajasi (rang/glow o'tishi).
  final double activation;

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final rx = size.width * 0.36;
    final ry = rx * 1.32;
    final center = Offset(size.width / 2, size.height * 0.42);
    final oval = Rect.fromCenter(center: center, width: rx * 2, height: ry * 2);

    // Niqob: butun ekran qorong'i, oval joyi ochiq. even-odd qoidasi
    // bilan — Path.combine har kadrda Skia'da qimmat boolean amal
    // bajarardi, natija esa piksel-piksel bir xil.
    final mask = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addOval(oval);
    canvas.drawPath(
      mask,
      Paint()..color = Colors.black.withValues(alpha: 0.58),
    );

    final ringColor = Color.lerp(
      Colors.white.withValues(alpha: 0.45),
      accent,
      activation,
    )!;

    // Faollikda oval atrofida yumshoq nur.
    if (activation > 0.05) {
      canvas.drawOval(
        oval,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
          ..color = accent.withValues(alpha: 0.45 * activation),
      );
    }

    // Oval chizig'i (rang silliq o'tadi).
    canvas.drawOval(
      oval,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = ringColor,
    );

    // Progress yoyi (yuqoridan boshlab, ravon).
    if (progress > 0.01) {
      canvas.drawArc(
        oval.inflate(7),
        -1.5708, // -90°
        6.2832 * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.5
          ..strokeCap = StrokeCap.round
          ..color = accent,
      );
    }
  }

  @override
  bool shouldRepaint(_OvalMaskPainter old) =>
      old.progress != progress ||
      old.activation != activation ||
      old.accent != accent;
}
