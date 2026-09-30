import 'dart:async' show unawaited;
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/extensions/context_x.dart';
import '../../../../../core/services/camera_service.dart';
import '../../data/scan_image.dart';

/// Hujjatni suratga olish oynasi.
///
/// Umumiy [CameraCapturePage] dan ATAYLAB alohida: u xotira uchun rasm
/// oladi, bu yerda esa rasm MASHINA o'qiydigan manba. Farq ko'rinishda
/// ham, oqimda ham:
///
/// * Ekranda hujjatning O'ZI chizib qo'yilgan — ramka aynan hujjat
///   nisbatida (ID-1 85.6×54, passport ma'lumot sahifasi 125×88), ichida
///   surat joyi, yozuv qatorlari va passport uchun MRZ chizig'i. Odam
///   hujjatni "chizmaga qo'yadi" va kadr har safar bir xil chiqadi.
/// * ID karta uchun ikki qadam (old va orqa tomon) — server ikkala
///   tomonni solishtirib, o'qishni mustaqil tasdiqlaydi. Orqa tomon
///   IXTIYORIY: old tomon olingach xodim xohlasa shu zahoti jo'natadi —
///   old tomondagi bosma ma'lumot o'zi ham yetarli.
/// * Kadr hujjat nisbatiga QIRQILADI: fonda qolgan stol, qo'l va boshqa
///   narsalar OCR uchun shovqin.
///
/// Natija: rasm yo'llari ro'yxati (`[front]` yoki `[front, back]`) yoki
/// bekor qilinganda `null`.
class DocumentCameraPage extends StatefulWidget {
  const DocumentCameraPage({
    super.key,
    required this.documentType,
    this.mrzOnly = false,
    this.warmup,
  });

  /// `ID_CARD` yoki `PASSPORT`.
  final String documentType;

  /// Sozlamada MRZ rejimi tanlangan: ID kartaning FAQAT ORQA tomoni
  /// olinadi — MRZ o'sha yerda, old tomon bu rejimda o'qilmaydi ham.
  final bool mrzOnly;

  /// Oldindan qizdirilgan kamera (bo'lsa) — sahifa ochilishi bilan
  /// preview darhol ko'rinadi.
  final Future<CameraController?>? warmup;

  static Future<List<String>?> open(
    BuildContext context, {
    required String documentType,
    bool mrzOnly = false,
    Future<CameraController?>? warmup,
  }) {
    return Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => DocumentCameraPage(
          documentType: documentType,
          mrzOnly: mrzOnly,
          warmup: warmup,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  /// Kamerani sahifa ochilishidan OLDIN tayyorlab qo'yish.
  ///
  /// Kamera hujjat turiga bog'liq emas, ochilishi esa qimmat:
  /// `availableCameras` + eng yuqori sifatdagi kontroller 1-3 soniya
  /// oladi. Tur tanlash oynasi ochilgan zahoti shu chaqirilsa,
  /// foydalanuvchi tanlaguncha kamera allaqachon tayyor bo'ladi.
  ///
  /// Natija sahifaga berilmasa, chaqiruvchi kontrollerni O'ZI yopishi
  /// shart — aks holda kamera band bo'lib qoladi.
  static Future<CameraController?> warmUp() => _createController();

  static Future<CameraController?> _createController() async {
    try {
      final cameras = await cachedCameras();
      if (cameras.isEmpty) return null;
      final back = cameras.indexWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
      );
      final controller = CameraController(
        cameras[back == -1 ? 0 : back],
        /* 4K — foydali shift. Qirqilgan rasm baribir 2000 px'gacha
           toraytiriladi (scan_image._maxUploadWidth), server esa 1600 px'da
           o'qiydi — 4K'da qirqim bundan baribir katta chiqadi. `max` esa
           to'liq sensorni (48-108 MP) ochib kamerani sekin ochar, zatvorni
           kechiktirar va dekodlashni sekinlashtirardi — sifatga hech narsa
           qo'shmasdan. */
        ResolutionPreset.ultraHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      /* Avtofokus va avtoekspozitsiya markazga qaratiladi — hujjat aynan
         o'sha yerda turadi. KUTILMAYDI: CameraX bu chaqiriqlarni fokus
         O'RNASHGUNCHA tugatmaydi (xira joyda sekin modulda 1-5 soniya),
         preview esa allaqachon tayyor — kutish faqat spinnerni cho'zardi. */
      unawaited(() async {
        try {
          await controller.setFocusPoint(const Offset(0.5, 0.5));
          await controller.setExposurePoint(const Offset(0.5, 0.5));
        } catch (_) {
          // Nuqta tanlash yo'q yoki kontroller ulgurmasdan yopilgan
          // (bekor qilingan qizdirish) — jim o'tamiz.
        }
      }());
      return controller;
    } catch (_) {
      // Kamera yo'q yoki ochilmadi — sahifa xato holatini ko'rsatadi
      return null;
    }
  }

  @override
  State<DocumentCameraPage> createState() => _DocumentCameraPageState();
}

class _DocumentCameraPageState extends State<DocumentCameraPage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _failed = false;
  bool _taking = false;
  bool _torch = false;
  bool _flashOverlay = false;

  /// Oxirgi kadr olindi, rasm(lar) ramka atrofiga qirqilmoqda.
  bool _processing = false;

  /// Stack'ning haqiqiy o'lchami — qirqish xaritasi uchun. Ramka chizmasi
  /// ham aynan shu o'lchamdan hisoblanadi.
  Size? _stackSize;

  /// ID kartada birinchi qadam — old tomon, ikkinchisi — orqa.
  final List<String> _shots = [];

  /// Har kadrning qirqilgan nusxasi — surat olingan ZAHOTI fonda
  /// tayyorlanadi. ID kartada old tomon xodim orqa tomonni
  /// mo'ljallayotgan paytda qirqiladi, oxirida kutish deyarli qolmaydi.
  final List<Future<String>> _prepared = [];

  /// Qirqishlar NAVBATI: bir vaqtda faqat bitta kadr dekodlanadi.
  /// Ikkita to'liq kadr birga ochilsa, xotirasi kam qurilmalarda ilova
  /// o'ldirilishi mumkin edi. Tartib va natijalar o'zgarmaydi.
  Future<void> _prepareQueue = Future<void>.value();

  bool get _isIdCard => widget.documentType == 'ID_CARD';

  /// Hujjat nisbati: ID-1 karta yoki passport ma'lumot sahifasi.
  double get _aspect => _isIdCard ? 85.6 / 54 : 125 / 88;

  /// ID karta ikki tomonli; passportda bitta ma'lumot sahifasi yetarli.
  /// MRZ rejimida ID kartada ham bitta kadr — faqat orqa tomon.
  /// Oddiy rejimda ikkinchi qadam IXTIYORIY — [_finishNow] bilan
  /// old tomonning o'zi ham jo'natiladi.
  int get _totalSteps => _isIdCard && !widget.mrzOnly ? 2 : 1;

  int get _step => _shots.length;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pendingWarmup = widget.warmup;
    _init();
  }

  /// Qizdirilgan kamera faqat BIR marta olinadi: qayta ochilishlarda
  /// (masalan ilova fondan qaytganda) yangi kontroller ochiladi.
  Future<CameraController?>? _pendingWarmup;

  Future<void> _init() async {
    final pending = _pendingWarmup;
    _pendingWarmup = null;
    var controller = pending == null ? null : await pending;
    controller ??= await DocumentCameraPage._createController();
    if (controller == null) {
      if (mounted) setState(() => _failed = true);
      return;
    }
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() {
      _failed = false;
      // Qizdirilgan kamerada chiroq har doim o'chiq holda keladi
      _torch = false;
      _controller = controller;
    });
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
    /* Faqat chinakam fonga o'tishda (paused) bo'shatiladi. `inactive`
       parda tortish, ruxsat oynasi, qo'ng'iroq kabi BIR LAHZALIK
       holatlarda ham keladi va har qaytishda kamerani qayta ochish
       skan o'rtasida soniyalab spinner ko'rsatardi. */
    if (state == AppLifecycleState.paused) {
      _controller = null;
      controller.dispose();
      if (mounted) setState(() {});
    } else if (state == AppLifecycleState.resumed && _controller == null) {
      _init();
    }
  }

  Future<void> _toggleTorch() async {
    final next = !_torch;
    setState(() => _torch = next);
    try {
      await _controller?.setFlashMode(next ? FlashMode.torch : FlashMode.off);
    } on CameraException {
      // Chiroqsiz kamera — jim o'tamiz.
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
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _flashOverlay = false);
    });
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      _shots.add(file.path);
      /* Yuborishdan oldin kadr ramka atrofiga qirqiladi: hujjat
         yuborilgan rasmning asosiy qismini egallasin — server uni
         kichraytirganda yozuvlar mayda bo'lib qolmaydi va perspektiv
         to'g'rilash ishonchli ishlaydi. Muvaffaqiyatsiz bo'lsa asl
         kadr ketadi — skaner hech qachon shu bosqichda to'xtamaydi.
         Qirqish surat olingan ZAHOTI, alohida izolatda boshlanadi. */
      final screen = _stackSize ?? MediaQuery.sizeOf(context);
      final prepare = _prepareQueue.then(
        (_) => prepareDocumentImage(file.path, screen: screen, aspect: _aspect),
      );
      _prepareQueue = prepare.then((_) {});
      _prepared.add(prepare);
      if (_shots.length >= _totalSteps) {
        setState(() => _processing = true);
        final prepared = await Future.wait(_prepared);
        if (!mounted) return;
        Navigator.of(context).pop(prepared);
        return;
      }
      setState(() => _taking = false);
    } on CameraException {
      if (!mounted) return;
      setState(() => _taking = false);
      context.showSnack(context.l10n.scanCameraFailed, isError: true);
    }
  }

  /// Olingan kadr(lar) bilan hoziroq yakunlash — ID kartada orqa tomonni
  /// kutmasdan. Old tomon qirqish surat olingan zahoti fonda boshlangani
  /// uchun bu yerda kutish deyarli yo'q — tugma bosilishi bilan yopiladi.
  Future<void> _finishNow() async {
    if (_taking || _processing || _shots.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _processing = true);
    final prepared = await Future.wait(_prepared);
    if (!mounted) return;
    Navigator.of(context).pop(prepared);
  }

  String get _stepLabel {
    final l10n = context.l10n;
    if (!_isIdCard) return l10n.scanStepPassport;
    if (widget.mrzOnly) return l10n.scanStepBack;
    return _step == 0 ? l10n.scanStepFront : l10n.scanStepBack;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = _controller;
    final ready = controller != null && controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          _stackSize = Size(constraints.maxWidth, constraints.maxHeight);
          return Stack(
        fit: StackFit.expand,
        children: [
          if (_failed)
            _ScanError(message: l10n.scanCameraFailed)
          else if (!ready)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else
            // Preview ekranni TO'LIQ qoplaydi: chetlarida qora chiziq
            // qolsa, ramka hujjatga nisbatan siljib ko'rinardi.
            _FullPreview(controller: controller),

          if (ready || _failed)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _DocumentFramePainter(
                    aspect: _aspect,
                    // MRZ rejimidagi ID kartada yagona kadr — orqa tomon:
                    // chizmada MRZ chizig'i bor, surat joyi yo'q
                    showMrz: !_isIdCard || widget.mrzOnly || _step == 1,
                    showPhoto: !_isIdCard || (!widget.mrzOnly && _step == 0),
                    accent: context.colors.brand,
                  ),
                ),
              ),
            ),

          if (_flashOverlay)
            const Positioned.fill(child: ColoredBox(color: Colors.white70)),

          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  step: _step,
                  totalSteps: _totalSteps,
                  label: _stepLabel,
                  torch: _torch,
                  onClose: () => Navigator.of(context).pop(),
                  onTorch: ready ? _toggleTorch : null,
                ),
                const Spacer(),
                _Hint(text: l10n.scanGuide),
                const SizedBox(height: 18),
                // Qirqish bir soniyagacha oladi — zatvor o'rnida aylanuvchi
                // belgi turadi, ikkinchi bosishga o'rin qolmaydi
                if (_processing)
                  const SizedBox(
                    width: 78,
                    height: 78,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                else
                  _Shutter(enabled: ready && !_taking, onTap: _take),
                // ID kartada orqa tomon ixtiyoriy: old tomon olingach
                // xodim uni kutmasdan shu yerning o'zida jo'natishi mumkin
                if (_isIdCard &&
                    !widget.mrzOnly &&
                    _step == 1 &&
                    !_processing) ...[
                  const SizedBox(height: 14),
                  _SendNowButton(
                    label: l10n.scanSendOneSide,
                    enabled: !_taking,
                    onTap: _finishNow,
                  ),
                ],
                const SizedBox(height: 22),
              ],
            ),
          ),
        ],
          );
        },
      ),
    );
  }
}

/// Preview'ni ekran bo'yicha kesib ko'rsatadi (BoxFit.cover mantiqi).
class _FullPreview extends StatelessWidget {
  const _FullPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final preview = controller.value.previewSize;
        // Kamera o'lchami LANDSCAPE tartibida keladi — ekran vertikal
        // bo'lgani uchun tomonlar almashtiriladi.
        final ratio = preview == null
            ? constraints.maxWidth / constraints.maxHeight
            : preview.height / preview.width;
        return FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxWidth / ratio,
            child: CameraPreview(controller),
          ),
        );
      },
    );
  }
}

/// Ramka: qorong'i fon, hujjat shaklidagi "oyna" va uning ichidagi chizma.
class _DocumentFramePainter extends CustomPainter {
  _DocumentFramePainter({
    required this.aspect,
    required this.showMrz,
    required this.showPhoto,
    required this.accent,
  });

  /// Hujjat nisbati (eni / bo'yi).
  final double aspect;

  /// Pastdagi MRZ chizig'i ko'rsatilsinmi.
  final bool showMrz;

  /// Chap tomondagi surat joyi ko'rsatilsinmi.
  final bool showPhoto;

  final Color accent;

  // Ramka joyi `scan_image.frameRectFor` da: chizma va yuborishdan
  // oldingi qirqish BITTA formuladan foydalanishi shart — ajralib
  // ketsa, qirqim ekrandagi ramkaga mos kelmay qoladi.
  Rect _frameOf(Size size) => frameRectFor(size, aspect);

  @override
  void paint(Canvas canvas, Size size) {
    final frame = _frameOf(size);
    final rrect = RRect.fromRectAndRadius(frame, const Radius.circular(18));

    // 1. Ramkadan tashqarisi qorayadi — ko'z darhol hujjatga tushadi
    final scrim = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addRRect(rrect),
    );
    canvas.drawPath(scrim, Paint()..color = Colors.black.withValues(alpha: 0.62));

    // 2. Ingichka chegara
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.55),
    );

    // 3. Burchak qisqichlari — hujjatni "tutib turgandek"
    final corner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = accent;
    final len = math.min(frame.width, frame.height) * 0.16;
    void bracket(Offset origin, double dx, double dy) {
      canvas.drawLine(origin, origin.translate(dx * len, 0), corner);
      canvas.drawLine(origin, origin.translate(0, dy * len), corner);
    }

    const inset = 10.0;
    bracket(frame.topLeft.translate(inset, inset), 1, 1);
    bracket(frame.topRight.translate(-inset, inset), -1, 1);
    bracket(frame.bottomLeft.translate(inset, -inset), 1, -1);
    bracket(frame.bottomRight.translate(-inset, -inset), -1, -1);

    // 4. Ichkaridagi CHIZMA: hujjat qanday yotishi kerakligi ko'rinib
    //    tursin. Chiziqlar juda xira — ular yo'l ko'rsatadi, kadrni
    //    to'sib qo'ymaydi.
    final guide = Paint()..color = Colors.white.withValues(alpha: 0.22);
    final pad = frame.width * 0.06;

    if (showPhoto) {
      final photo = Rect.fromLTWH(
        frame.left + pad,
        frame.top + pad,
        frame.width * 0.22,
        frame.height * 0.52,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(photo, const Radius.circular(6)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = Colors.white.withValues(alpha: 0.28),
      );
      // Surat ichidagi odam shakli: bosh va yelka
      final head = Offset(photo.center.dx, photo.top + photo.height * 0.3);
      canvas.drawCircle(head, photo.width * 0.18, guide);
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(head.dx, photo.bottom - photo.height * 0.02),
          width: photo.width * 0.62,
          height: photo.height * 0.5,
        ),
        math.pi,
        math.pi,
        false,
        guide,
      );
    }

    // Yozuv qatorlari
    final textLeft = showPhoto
        ? frame.left + pad + frame.width * 0.22 + pad * 0.8
        : frame.left + pad;
    final textWidth = frame.right - pad - textLeft;
    final lineHeight = frame.height * 0.045;
    for (var i = 0; i < 4; i++) {
      final width = textWidth * (i.isEven ? 0.86 : 0.62);
      final top = frame.top + pad + i * lineHeight * 2.1;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(textLeft, top, width, lineHeight * 0.62),
          Radius.circular(lineHeight),
        ),
        guide,
      );
    }

    // MRZ — pastdagi ikki qator, hujjatning butun eni bo'ylab
    if (showMrz) {
      for (var i = 0; i < 2; i++) {
        final top = frame.bottom - pad - (2 - i) * lineHeight * 1.5;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              frame.left + pad,
              top,
              frame.width - pad * 2,
              lineHeight * 0.55,
            ),
            Radius.circular(lineHeight),
          ),
          Paint()..color = Colors.white.withValues(alpha: 0.16),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DocumentFramePainter old) =>
      old.aspect != aspect ||
      old.showMrz != showMrz ||
      old.showPhoto != showPhoto ||
      old.accent != accent;
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.step,
    required this.totalSteps,
    required this.label,
    required this.torch,
    required this.onClose,
    required this.onTorch,
  });

  final int step;
  final int totalSteps;
  final String label;
  final bool torch;
  final VoidCallback onClose;
  final VoidCallback? onTorch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          _RoundButton(icon: Icons.close_rounded, onTap: onClose),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Ikki qadamli hujjatda qaysi qadamdaligi ko'rinib tursin
                if (totalSteps > 1) ...[
                  const SizedBox(width: 8),
                  for (var i = 0; i < totalSteps; i++)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i <= step
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
          const Spacer(),
          _RoundButton(
            icon: torch ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
            onTap: onTorch,
          ),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.86),
          fontSize: 14,
          height: 1.35,
        ),
      ),
    );
  }
}

class _Shutter extends StatelessWidget {
  const _Shutter({required this.enabled, required this.onTap});

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
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

/// "Old tomoni yetarli — jo'natish": zatvor ostidagi ixtiyoriy yakun.
class _SendNowButton extends StatelessWidget {
  const _SendNowButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 17,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
  final VoidCallback? onTap;

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

class _ScanError extends StatelessWidget {
  const _ScanError({required this.message});

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
