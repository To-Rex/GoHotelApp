import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../extensions/context_x.dart';
import '../services/camera_service.dart';

/// Ilova ichidagi tezkor kamera.
///
/// `image_picker` kamerasi tashqi ilovani intent orqali ochadi — har safar
/// 2–4 soniya kutish. Bu sahifa esa route ochilishi bilan preview'ni o'zi
/// ko'taradi: zatvor bir zumda ishlaydi, ketma-ket bir necha rasm olinadi,
/// hech qanday tashqi ilova ishga tushmaydi.
///
/// Rasmlar 1080p (veryHigh) sifatida olinadi — hisobot uchun yetarli va
/// mehmonxona Wi-Fi'sida tez yuklanadi.
class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({
    super.key,
    required this.multiple,
    this.preferFront = false,
  });

  /// true — bir nechta rasm (pastda lenta, "tayyor" tugmasi bilan qaytadi);
  /// false — birinchi rasmdan keyin darhol qaytadi.
  final bool multiple;

  /// true — OLD kamera bilan ochiladi (yuz tasdig'i/biriktirish uchun).
  final bool preferFront;

  /// Bitta rasm: yo'l yoki null (bekor qilindi / kamera yo'q).
  static Future<String?> openSingle(
    BuildContext context, {
    bool preferFront = false,
  }) async {
    final paths = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) =>
            CameraCapturePage(multiple: false, preferFront: preferFront),
        fullscreenDialog: true,
      ),
    );
    return (paths == null || paths.isEmpty) ? null : paths.first;
  }

  /// Bir nechta rasm: yo'llar ro'yxati yoki null.
  static Future<List<String>?> openMulti(BuildContext context) {
    return Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => const CameraCapturePage(multiple: true),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  FlashMode _flash = FlashMode.off;

  final List<String> _shots = [];
  bool _taking = false;
  bool _failed = false;

  /// Zatvor bosilganda qisqa oq "yalt" effekti.
  bool _flashOverlay = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  bool _lensChosen = false;

  Future<void> _init() async {
    try {
      if (_cameras.isEmpty) {
        _cameras = await cachedCameras();
      }
      if (_cameras.isEmpty) {
        setState(() => _failed = true);
        return;
      }
      // Birinchi ochilishda linza tanlanadi: yuz uchun OLD kamera,
      // xona suratlari uchun orqa (ro'yxatdagi birinchisi).
      if (!_lensChosen) {
        _lensChosen = true;
        if (widget.preferFront) {
          final front = _cameras.indexWhere(
            (cam) => cam.lensDirection == CameraLensDirection.front,
          );
          if (front != -1) _cameraIndex = front;
        }
      }
      if (_cameraIndex >= _cameras.length) _cameraIndex = 0;
      final controller = CameraController(
        _cameras[_cameraIndex],
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      await controller.setFlashMode(_flash);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } on CameraException {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    // Fonda kamera band qilib turilmaydi. Aynan `paused`da: `inactive`
    // parda tortish kabi bir lahzalik holatlarda ham kelib, har safar
    // sekin qayta ochilishga majbur qilardi.
    if (state == AppLifecycleState.paused) {
      _controller = null;
      controller.dispose();
      if (mounted) setState(() {});
    } else if (state == AppLifecycleState.resumed && _controller == null) {
      _init();
    }
  }

  Future<void> _take() async {
    final controller = _controller;
    if (controller == null || _taking || !controller.value.isInitialized) {
      return;
    }
    setState(() {
      _taking = true;
      _flashOverlay = true;
    });
    HapticFeedback.mediumImpact();
    // "Yalt" effekti tez o'chadi — zatvor darhol ishlagani seziladi.
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _flashOverlay = false);
    });
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      if (widget.multiple) {
        setState(() {
          _shots.add(file.path);
          _taking = false;
        });
      } else {
        Navigator.of(context).pop(<String>[file.path]);
      }
    } on CameraException {
      if (mounted) {
        setState(() => _taking = false);
        context.showSnack(context.l10n.faceNoCameraReason, isError: true);
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    final old = _controller;
    setState(() {
      _controller = null;
      _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    });
    await old?.dispose();
    await _init();
  }

  Future<void> _cycleFlash() async {
    final next = switch (_flash) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.torch,
      _ => FlashMode.off,
    };
    setState(() => _flash = next);
    try {
      await _controller?.setFlashMode(next);
    } on CameraException {
      // Ba'zi kameralarda flash yo'q — jim o'tamiz.
    }
  }

  IconData get _flashIcon => switch (_flash) {
    FlashMode.auto => Icons.flash_auto_rounded,
    FlashMode.torch => Icons.flash_on_rounded,
    _ => Icons.flash_off_rounded,
  };

  void _done() => Navigator.of(context).pop(List<String>.from(_shots));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // --- Preview ----------------------------------------------------
            Positioned.fill(
              child: _failed
                  ? _CameraError(message: l10n.faceNoCameraReason)
                  : (controller == null || !controller.value.isInitialized)
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Center(
                      child: AspectRatio(
                        aspectRatio: 1 / controller.value.aspectRatio,
                        child: CameraPreview(controller),
                      ),
                    ),
            ),
            // Zatvor "yalt" effekti
            if (_flashOverlay)
              const Positioned.fill(child: ColoredBox(color: Colors.white70)),
            // --- Yuqori panel: yopish, flash, kamera almashtirish -----------
            Positioned(
              top: 8,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  _RoundButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.of(context).pop(
                      widget.multiple && _shots.isNotEmpty
                          ? List<String>.from(_shots)
                          : null,
                    ),
                  ),
                  const Spacer(),
                  if (!_failed) ...[
                    _RoundButton(icon: _flashIcon, onTap: _cycleFlash),
                    if (_cameras.length > 1) ...[
                      const SizedBox(width: 10),
                      _RoundButton(
                        icon: Icons.cameraswitch_rounded,
                        onTap: _switchCamera,
                      ),
                    ],
                  ],
                ],
              ),
            ),
            // --- Pastki panel: lenta + zatvor + tayyor ----------------------
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.multiple && _shots.isNotEmpty)
                    SizedBox(
                      height: 64,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _shots.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(_shots[i]),
                                width: 64,
                                height: 64,
                                // 1080p kadr 64px katak uchun to'liq
                                // dekodlanmasin — lenta qotib qolardi
                                cacheWidth: 192,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () => setState(() => _shots.removeAt(i)),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
                    child: Row(
                      children: [
                        // chap tomonda joy saqlagich (simmetriya uchun)
                        const SizedBox(width: 56),
                        const Spacer(),
                        _ShutterButton(
                          enabled: !_failed && controller != null && !_taking,
                          onTap: _take,
                        ),
                        const Spacer(),
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: widget.multiple && _shots.isNotEmpty
                              ? FilledButton(
                                  onPressed: _done,
                                  style: FilledButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(56, 56),
                                    shape: const CircleBorder(),
                                    backgroundColor: const Color(0xFF16A34A),
                                  ),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      const Center(
                                        child: Icon(
                                          Icons.check_rounded,
                                          size: 28,
                                        ),
                                      ),
                                      Positioned(
                                        top: -2,
                                        right: -2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              100,
                                            ),
                                          ),
                                          child: Text(
                                            '${_shots.length}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF16A34A),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Katta dumaloq zatvor tugmasi.
class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1 : 0.5,
        child: Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          padding: const EdgeInsets.all(5),
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black45,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_photography_outlined,
              color: Colors.white54,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
