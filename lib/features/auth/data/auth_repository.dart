import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_store.dart';
import '../domain/staff_user.dart';

/// Parol bosqichining natijasi: yo tokenlar, yo yuz bosqichi talabi.
sealed class LoginOutcome {
  const LoginOutcome();
}

/// Kirish tugallandi — tokenlar saqlandi.
class LoginSuccess extends LoginOutcome {
  const LoginSuccess();
}

/// Parol to'g'ri, endi yuz tasdig'i kerak (`/auth/face/verify-login`).
class FaceRequired extends LoginOutcome {
  const FaceRequired(this.faceToken);

  final String faceToken;
}

class AuthRepository {
  AuthRepository({required this.api, required this.tokens});

  final ApiClient api;
  final TokenStore tokens;

  Future<LoginOutcome> login({
    required String username,
    required String password,
    String? fcmToken,
  }) async {
    final data = await api.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
        'fcm_token': ?fcmToken,
      },
    );
    if (data['face_required'] == true) {
      return FaceRequired(data['face_token'] as String);
    }
    await _saveTokens(data);
    return const LoginSuccess();
  }

  /// Ikkinchi bosqich: yuz surati bilan kirishni yakunlash.
  Future<void> verifyFace({
    required String faceToken,
    required String imagePath,
  }) async {
    final form = FormData.fromMap({
      'face_token': faceToken,
      'file': await MultipartFile.fromFile(imagePath, filename: 'face.jpg'),
    });
    final data = await api.post<Map<String, dynamic>>(
      '/auth/face/verify-login',
      data: form,
    );
    await _saveTokens(data);
  }

  /// Kamerasiz qurilmada ikkinchi bosqichni o'tkazib yuborish.
  Future<void> loginWithoutCamera({
    required String faceToken,
    String? reason,
  }) async {
    final data = await api.post<Map<String, dynamic>>(
      '/auth/login/no-camera',
      data: {'face_token': faceToken, 'reason': ?reason},
    );
    await _saveTokens(data);
  }

  Future<StaffUser> me() async {
    final data = await api.get<Map<String, dynamic>>('/auth/me');
    return StaffUser.fromJson(data);
  }

  Future<void> logout() async {
    try {
      await api.post<Map<String, dynamic>>('/auth/logout');
    } catch (_) {
      // Server bilan xayrlashib bo'lmasa ham lokal sessiya tozalanadi.
    }
    await tokens.clear();
  }

  /// Saqlangan refresh token orqali sessiyani jonlantirish.
  /// Muvaffaqiyatli bo'lsa foydalanuvchini qaytaradi, aks holda null.
  Future<StaffUser?> restoreSession() async {
    if (!await tokens.hasSession) return null;
    try {
      return await me();
    } catch (_) {
      // `me` 401 bersa interceptor refresh qiladi; baribir o'tmasa — sessiya yo'q.
      return null;
    }
  }

  /// FCM tokenni serverga ro'yxatdan o'tkazish (push uchun).
  Future<void> registerFcmToken(String token) async {
    await api.post<Map<String, dynamic>>(
      '/notifications/register-device',
      data: {'fcm_token': token},
    );
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    await tokens.saveTokens(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
    );
  }
}
