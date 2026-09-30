import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/storage/app_prefs.dart';
import '../../data/auth_repository.dart';
import '../../domain/staff_user.dart';

part 'auth_state.dart';

/// Kirish oqimining yagona boshqaruvchisi.
///
/// Oqim: start → (locked?) → unauthenticated → [login] → (faceStep?) →
/// authenticated. Sessiya kutilmaganda tugasa [sessionExpired] chaqiriladi.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.repository,
    required this.prefs,
    required this.biometrics,
  }) : super(const AuthState.starting());

  final AuthRepository repository;
  final AppPrefs prefs;
  final BiometricService biometrics;

  /// Ilova ochilganda: sessiya bo'lsa (kerak bo'lsa biometrika bilan) kirish.
  Future<void> appStarted() async {
    if (prefs.biometricEnabled && await biometrics.isAvailable) {
      final hasSession = await repository.tokens.hasSession;
      if (hasSession) {
        emit(const AuthState(status: AuthStatus.locked));
        return;
      }
    }
    await _tryRestore();
  }

  /// Qulflangan holatda biometrik tasdiq so'rash.
  Future<void> unlock(String localizedReason) async {
    final ok = await biometrics.authenticate(localizedReason);
    if (!ok) return; // foydalanuvchi bekor qildi — locked'da qolamiz
    await _tryRestore();
  }

  /// Qulf ekranidan "boshqa hisob bilan kirish".
  Future<void> switchAccount() async {
    await repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _tryRestore() async {
    final user = await repository.restoreSession();
    if (user == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } else {
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    }
  }

  Future<void> login(String username, String password) async {
    emit(state.copyWith(submitting: true, clearError: true));
    try {
      final outcome = await repository.login(
        username: username.trim(),
        password: password,
      );
      await prefs.setLastUsername(username.trim());
      switch (outcome) {
        case FaceRequired(:final faceToken):
          emit(AuthState(status: AuthStatus.faceStep, faceToken: faceToken));
        case LoginSuccess():
          await _finishLogin();
      }
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          submitting: false,
          error: e.message,
          errorCode: e.code ?? (e.isUnauthorized ? 'WRONG_CREDENTIALS' : null),
        ),
      );
    }
  }

  /// Yuz bosqichi: olingan surat bilan kirishni yakunlash.
  Future<void> verifyFace(String imagePath) async {
    final token = state.faceToken;
    if (token == null) return;
    emit(state.copyWith(submitting: true, clearError: true));
    try {
      await repository.verifyFace(faceToken: token, imagePath: imagePath);
      await _finishLogin();
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          submitting: false,
          error: e.message,
          errorCode: e.code ?? (e.isUnauthorized ? 'FACE_MISMATCH' : null),
        ),
      );
    }
  }

  Future<void> skipFace(String reason) async {
    final token = state.faceToken;
    if (token == null) return;
    emit(state.copyWith(submitting: true, clearError: true));
    try {
      await repository.loginWithoutCamera(faceToken: token, reason: reason);
      await _finishLogin();
    } on ApiException catch (e) {
      emit(
        state.copyWith(submitting: false, error: e.message, errorCode: e.code),
      );
    }
  }

  /// Mehmonxona xizmati to'xtatildi — sabab ekraniga o'tamiz.
  ///
  /// Faqat kirgan xodim uchun: kirish sahifasidagi xatoni bu ekran bilan
  /// almashtirish kerak emas, u yerda banner ko'rinadi.
  void serviceStopped(String code, String message) {
    if (state.status != AuthStatus.authenticated) return;
    emit(
      state.copyWith(
        status: AuthStatus.serviceStopped,
        error: message,
        errorCode: code,
      ),
    );
  }

  /// "Qayta tekshirish": xizmat tiklangan bo'lsa ish davom etadi.
  void retryService() {
    if (state.status != AuthStatus.serviceStopped) return;
    final user = state.user;
    if (user == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }
    emit(AuthState(status: AuthStatus.authenticated, user: user));
  }

  /// Yuz bosqichidan login sahifasiga qaytish.
  void cancelFaceStep() {
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _finishLogin() async {
    final user = await repository.me();
    emit(AuthState(status: AuthStatus.authenticated, user: user));
  }

  Future<void> logout() async {
    await repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  /// Interceptor refresh'ni eplay olmaganda chaqiriladi.
  void sessionExpired() {
    if (state.status == AuthStatus.authenticated) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  /// Profil sahifasidagi biometrika tumbleri.
  Future<bool> setBiometricEnabled(bool value, String localizedReason) async {
    if (value) {
      if (!await biometrics.isAvailable) return false;
      final ok = await biometrics.authenticate(localizedReason);
      if (!ok) return false;
    }
    await prefs.setBiometricEnabled(value);
    return true;
  }

  /// Birinchi muvaffaqiyatli kirishdan keyin bir marta taklif qilish uchun.
  Future<bool> shouldOfferBiometric() async {
    if (prefs.biometricAsked || prefs.biometricEnabled) return false;
    return biometrics.isAvailable;
  }
}
