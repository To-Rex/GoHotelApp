/// Backend manzillari. Muhitga qarab `--dart-define=API_BASE_URL=...` bilan
/// almashtirsa bo'ladi — standart qiymat production backend (frontend bilan
/// bir xil server).
abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://gohotel-gohotel-backend-lhyen5-ecceab-13-140-185-49.sslip.io/api/v1',
  );

  /// 401 kelganda refresh URINILMAYDIGAN yo'llar — bular uchun 401 oddiy
  /// "parol xato" ma'nosini bildiradi (frontend'dagi AUTH_PATHS bilan bir xil).
  static const List<String> authPaths = [
    '/auth/login',
    '/auth/refresh',
    '/auth/face/',
  ];

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
