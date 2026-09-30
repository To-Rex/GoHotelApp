import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Qurilmaning o'z biometrikasi (Face Unlock / barmoq izi) — ilovani tez
/// ochish uchun. Bu serverdagi yuz tekshiruvidan alohida: server yuzni
/// login paytida tekshiradi, bu esa telefonning o'z qulfi.
class BiometricService {
  BiometricService(this._auth);

  final LocalAuthentication _auth;

  Future<bool> get isAvailable async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return supported && canCheck;
    } on PlatformException {
      return false;
    }
  }

  /// true — tasdiqlandi. Bekor qilinsa yoki xato bo'lsa false.
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // PIN/parol zaxira yo'l bo'lib qoladi
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
