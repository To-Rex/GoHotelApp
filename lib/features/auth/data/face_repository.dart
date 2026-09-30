import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

/// Serverdagi yuz profili holati (`GET /auth/face/status`).
class FaceStatus {
  const FaceStatus({
    required this.engineAvailable,
    required this.enrolled,
    required this.count,
  });

  /// Serverda yuz tekshiruvi dvigateli ishlaydimi. Ishlamasa yuz umuman
  /// so'ralmaydi va biriktirish ham talab qilinmaydi (frontend bilan bir xil).
  final bool engineAvailable;
  final bool enrolled;
  final int count;

  factory FaceStatus.fromJson(Map<String, dynamic> json) => FaceStatus(
    engineAvailable: json['engine_available'] as bool? ?? false,
    enrolled: json['enrolled'] as bool? ?? false,
    count: (json['count'] as num?)?.toInt() ?? 0,
  );
}

/// Serverdagi yuz bilan kirish (frontend `features/auth/api/face.ts`ning
/// mobil ekvivalenti): rasm serverga yuboriladi, embedding o'sha yerda
/// hisoblanadi — telefonga model yuklab olinmaydi.
class FaceRepository {
  FaceRepository(this._api);

  final ApiClient _api;

  Future<FaceStatus> getStatus() async {
    final data = await _api.get<Map<String, dynamic>>('/auth/face/status');
    return FaceStatus.fromJson(data);
  }

  /// O'z yuzini biriktirish (3 namunagacha; ortig'ida eng eskisi o'chadi).
  Future<FaceStatus> enroll(String imagePath) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagePath, filename: 'face.jpg'),
    });
    final data = await _api.post<Map<String, dynamic>>(
      '/auth/face/enroll',
      data: form,
    );
    return FaceStatus(
      engineAvailable: true,
      enrolled: data['enrolled'] as bool? ?? true,
      count: (data['count'] as num?)?.toInt() ?? 1,
    );
  }

  /// O'zining barcha yuz profillarini o'chirish — keyingi kirishda tizim
  /// qaytadan biriktirishni talab qiladi.
  Future<void> deleteMyProfiles() async {
    await _api.delete<Map<String, dynamic>>('/auth/face/enroll');
  }
}
