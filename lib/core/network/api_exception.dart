import 'package:dio/dio.dart';

/// Backend xatosining bir xil ko'rinishi.
///
/// Server `{"detail": "...", "error_code": "..."}` formatida javob beradi —
/// shu ikkisi UI uchun asosiy manba. Tarmoq muammolari alohida belgilanadi,
/// chunki ular foydalanuvchiga boshqacha ko'rsatiladi.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.isNetwork = false,
  });

  final String message;

  /// Backend `error_code` qiymati (masalan, `DEVICE_PENDING`).
  final String? code;
  final int? statusCode;

  /// Internet/timeout muammosi — server javobi emas.
  final bool isNetwork;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;

  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const ApiException(message: 'Network error', isNetwork: true);
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        String message = 'Server error';
        String? code;
        if (data is Map) {
          final detail = data['detail'];
          if (detail is String && detail.isNotEmpty) message = detail;
          // FastAPI validatsiya xatosi: detail — ro'yxat bo'lib keladi
          if (detail is List && detail.isNotEmpty) {
            final first = detail.first;
            if (first is Map && first['msg'] is String) {
              message = first['msg'] as String;
            }
          }
          final rawCode = data['error_code'];
          if (rawCode is String) code = rawCode;
        }
        return ApiException(
          message: message,
          code: code,
          statusCode: e.response?.statusCode,
        );
      default:
        return ApiException(message: e.message ?? 'Unexpected error');
    }
  }

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}
