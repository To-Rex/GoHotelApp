import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/app_prefs.dart';
import '../domain/scanned_document.dart';

/// Hujjat rasmini serverga yuborish.
///
/// Rasm SAQLANMAYDI: server uni o'qib, maydonlarni ajratadi va rasmni
/// tashlab yuboradi. Shu sabab yuborishdan boshqa hech narsa qilinmaydi —
/// telefonda hujjat surati qolmasligi kerak.
class ScanRepository {
  ScanRepository(this._api, this._prefs);

  final ApiClient _api;
  final AppPrefs _prefs;

  /// Oxirgi muvaffaqiyatli o'qilgan rejim — server sekin javob berganda
  /// oqim shu bilan davom etadi (repository lazySingleton, qiymat sessiya
  /// davomida yashaydi).
  String _lastKnownMode = 'auto';
  String get lastKnownMode => _lastKnownMode;

  /// Mehmonxonaning skaner rejimi (mrz/visual/auto) — kamera oqimi
  /// nechta kadr olishni shundan biladi. Xato bo'lsa xavfsiz "auto".
  Future<String> scanMode() async {
    try {
      final data = await _api.get<Map<String, dynamic>>(
        '/guests/scan-settings',
      );
      final mode = (data['mode'] as String?) ?? 'auto';
      _lastKnownMode = mode;
      return mode;
    } catch (_) {
      return 'auto';
    }
  }

  /// ID karta uchun (auto/visual rejimda) ikkala tomon yuborilsa BITTA
  /// so'rovda ketadi: server faqat shundagina old tomondagi bosma
  /// ma'lumotni orqadagi MRZ bilan solishtira oladi. Old tomonning o'zi
  /// ham yetarli — server bosma ma'lumotni o'qiyveradi, faqat o'zaro
  /// tasdiqlash bo'lmaydi. MRZ rejimida esa faqat orqa tomon yuboriladi —
  /// old tomon o'qilmaydi ham.
  Future<ScannedDocument> submit({
    required String documentType,
    String? frontPath,
    String? backPath,
  }) async {
    assert(frontPath != null || backPath != null);
    final form = FormData.fromMap({
      'document_type': documentType,
      'device_id': _prefs.deviceId,
    });
    if (frontPath != null) {
      form.files.add(
        MapEntry(
          'front',
          await MultipartFile.fromFile(frontPath, filename: 'front.jpg'),
        ),
      );
    }
    if (backPath != null) {
      form.files.add(
        MapEntry(
          'back',
          await MultipartFile.fromFile(backPath, filename: 'back.jpg'),
        ),
      );
    }
    final data = await _api.post<Map<String, dynamic>>(
      '/reception/scans',
      data: form,
    );
    return ScannedDocument.fromJson(data);
  }
}
