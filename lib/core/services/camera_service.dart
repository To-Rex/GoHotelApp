import 'package:camera/camera.dart';

/// Qurilmadagi kameralar ro'yxati — BIR marta so'raladi.
///
/// `availableCameras()` har chaqiriqda platforma kanali orqali CameraX'dan
/// to'liq ro'yxatni qayta yig'adi — sekin qurilmada bu 100-400 ms va u har
/// kamera ochilishida preview'dan OLDIN turardi. Ro'yxat telefonda
/// o'zgarmaydi, shuning uchun faqat muvaffaqiyatli javob saqlanadi; xatoda
/// keyingi ochilish qayta urinadi.
List<CameraDescription>? _cached;

Future<List<CameraDescription>> cachedCameras() async =>
    _cached ??= await availableCameras();
