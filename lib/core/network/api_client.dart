import 'dart:async';

import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../storage/app_prefs.dart';
import '../storage/token_store.dart';
import 'api_exception.dart';

/// Sessiya kutilmaganda tugaganda (refresh ham o'tmadi) xabar berish uchun.
typedef SessionExpiredCallback = void Function();

/// Mehmonxona xizmati to'xtatilganda (403 + `HOTEL_*`) xabar berish uchun.
typedef ServiceStoppedCallback = void Function(String code, String message);

/// Dio ustidagi yagona kirish nuqtasi.
///
/// - Har so'rovga `Authorization` va `X-Device-Id` qo'shadi.
/// - 401 kelganda (auth yo'llaridan tashqari) tokenni BIR MARTA yangilab,
///   so'rovni qaytaradi. Parallel so'rovlar bitta refresh'ni kutadi.
/// - Dio xatolarini [ApiException] ko'rinishiga keltiradi.
class ApiClient {
  ApiClient({required this._tokenStore, required this._prefs}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );
  }

  late final Dio _dio;
  final TokenStore _tokenStore;
  final AppPrefs _prefs;

  SessionExpiredCallback? onSessionExpired;

  /// Panel mehmonxonani to'xtatganda chaqiriladi. Sessiya tozalanmaydi:
  /// xizmat tiklangach xodim o'sha yerdan ishini davom ettiradi.
  ServiceStoppedCallback? onServiceStopped;

  /// Bir vaqtda faqat bitta refresh — qolganlari shu future'ni kutadi.
  Future<bool>? _refreshing;

  Dio get raw => _dio;

  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenStore.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['X-Device-Id'] = _prefs.deviceId;
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final status = error.response?.statusCode;
    final path = error.requestOptions.path;
    final isAuthPath = ApiConfig.authPaths.any(path.contains);
    final alreadyRetried = error.requestOptions.extra['retried'] == true;

    /* Mehmonxona xizmati to'xtatilgan.

       Bu oddiy 403 emas: xodimning aybi yo'q va qayta urinish ham
       yordam bermaydi. Sabab aytilmasa, ekranlar bittalab bo'sh qolib,
       ilova buzilgandek ko'rinardi. */
    if (status == 403 && !isAuthPath) {
      final data = error.response?.data;
      final code = data is Map ? data['error_code'] : null;
      if (code is String && code.startsWith('HOTEL_')) {
        final detail = data is Map ? data['detail'] : null;
        onServiceStopped?.call(code, detail is String ? detail : '');
      }
    }

    if (status == 401 && !isAuthPath && !alreadyRetried) {
      /* Token eskirganda bir nechta so'rov birga yiqiladi. Birinchisi
         refresh'ni tugatib ulgurgach kelgan 401'lar YANGI refresh
         boshlamaydi — do'kondagi token allaqachon so'rov yuborgandagidan
         boshqa, demak shunchaki o'sha token bilan qaytariladi. */
      final current = _tokenStore.accessToken;
      final sent = error.requestOptions.headers['Authorization'];
      if (current != null &&
          current.isNotEmpty &&
          sent is String &&
          sent != 'Bearer $current') {
        try {
          return handler.resolve(await _retry(error.requestOptions));
        } on DioException catch (e) {
          return handler.next(e);
        }
      }
      final refreshed = await (_refreshing ??= _refreshToken()).whenComplete(
        () => _refreshing = null,
      );
      if (refreshed) {
        try {
          final response = await _retry(error.requestOptions);
          return handler.resolve(response);
        } on DioException catch (e) {
          return handler.next(e);
        }
      }
      await _tokenStore.clear();
      onSessionExpired?.call();
    }
    handler.next(error);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await _tokenStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      /* Alohida Dio — interceptor zanjiriga tushmasligi uchun. Muddatlar
         asosiy mijozdagidek SHART: barcha 401 so'rovlar shu bitta refresh
         future'ni kutadi — u muddatsiz osilib qolsa, butun ilova abadiy
         spinnerda qolardi. */
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
        ),
      );
      final response = await dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = response.data;
      final access = data?['access_token'] as String?;
      final refresh = data?['refresh_token'] as String?;
      if (access == null || refresh == null) return false;
      await _tokenStore.saveTokens(accessToken: access, refreshToken: refresh);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions options) {
    options.extra['retried'] = true;
    options.headers['Authorization'] = 'Bearer ${_tokenStore.accessToken}';
    return _dio.fetch(options);
  }

  // --- Qulay o'ramalar ------------------------------------------------------

  Future<T> get<T>(String path, {Map<String, dynamic>? query}) => _wrap(
    () async => (await _dio.get<T>(path, queryParameters: query)).data as T,
  );

  Future<T> post<T>(String path, {Object? data, Map<String, dynamic>? query}) =>
      _wrap(
        () async =>
            (await _dio.post<T>(path, data: data, queryParameters: query)).data
                as T,
      );

  Future<T> put<T>(String path, {Object? data}) =>
      _wrap(() async => (await _dio.put<T>(path, data: data)).data as T);

  Future<T> patch<T>(String path, {Object? data}) =>
      _wrap(() async => (await _dio.patch<T>(path, data: data)).data as T);

  Future<T> delete<T>(String path, {Object? data}) =>
      _wrap(() async => (await _dio.delete<T>(path, data: data)).data as T);

  Future<T> _wrap<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
