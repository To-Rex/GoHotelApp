import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Access/refresh tokenlarni xavfsiz saqlash.
///
/// Access token xotirada ham kesh qilinadi — har so'rovda diskka murojaat
/// qilmaslik uchun. Refresh token faqat secure storage'da turadi.
class TokenStore {
  TokenStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  String? _accessCache;

  Future<void> init() async {
    _accessCache = await _storage.read(key: _kAccess);
  }

  String? get accessToken => _accessCache;

  Future<String?> readRefreshToken() => _storage.read(key: _kRefresh);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessCache = accessToken;
    await _storage.write(key: _kAccess, value: accessToken);
    await _storage.write(key: _kRefresh, value: refreshToken);
  }

  Future<void> clear() async {
    _accessCache = null;
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }

  Future<bool> get hasSession async =>
      (await readRefreshToken())?.isNotEmpty ?? false;
}
