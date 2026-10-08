import 'dart:async';

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
/// Server xodimning ish vaqti emasligini aytsa (kirishda `/auth/me` yoki
/// ish paytida 403) — outsideWorkHours, sessiya saqlangan holda.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.repository,
    required this.prefs,
    required this.biometrics,
  }) : super(const AuthState.starting());

  final AuthRepository repository;
  final AppPrefs prefs;
  final BiometricService biometrics;

  /// Filial hozirgina almashtirildi — ilova darvozasi ustidagi sahifalarni
  /// yopadi (bir martalik belgi).
  bool branchJustSwitched = false;

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

  /// Administrator: boshqa filialga o'tish. Muvaffaqiyatli bo'lsa yangi
  /// foydalanuvchi (yangi filial) holatga yoziladi — qobiq butunlay qayta
  /// quriladi va barcha ekranlar shu filial ma'lumotini oladi. Xato bo'lsa
  /// matni qaytadi (holat o'zgarmaydi).
  Future<String?> switchBranch(String branchId) async {
    final user = state.user;
    final hotelId = user?.hotelId;
    if (user == null || hotelId == null || !user.canSwitchBranch) {
      return null;
    }
    if (branchId == user.branchId) return null;
    try {
      final next = await repository.switchBranch(
        hotelId: hotelId,
        branchId: branchId,
      );
      branchJustSwitched = true;
      emit(_signedIn(next));
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
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
      emit(_signedIn(user));
    }
  }

  /// Kirgan foydalanuvchi uchun holat. Server "hozir ish vaqti emas" desa
  /// (`work_hours_blocked`) — darhol ish vaqti ekrani: aks holda qobiq
  /// ochilib, uning har bir so'rovi 403 bilan qaytardi.
  AuthState _signedIn(StaffUser user) => AuthState(
    status: user.workHoursBlocked
        ? AuthStatus.outsideWorkHours
        : AuthStatus.authenticated,
    user: user,
  );

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

  /// Ish vaqti tugadi — so'rov 403 `OUTSIDE_WORK_HOURS` bilan qaytdi.
  ///
  /// Faqat ishlayotgan xodim uchun: parallel so'rovlar buni bir necha marta
  /// chaqirsa ham o'tish bitta bo'ladi. Ekrandagi soat eskirgan bo'lishi
  /// mumkin (administrator o'zgartirgan) — profil jim yangilanadi.
  void outsideWorkHours(String message) {
    if (state.status != AuthStatus.authenticated) return;
    emit(
      state.copyWith(
        status: AuthStatus.outsideWorkHours,
        error: message,
        errorCode: ApiException.outsideWorkHoursCode,
      ),
    );
    unawaited(_refreshBlockedUser());
  }

  Future<void> _refreshBlockedUser() async {
    try {
      final user = await repository.me();
      if (isClosed || state.status != AuthStatus.outsideWorkHours) return;
      // Faqat ma'lumot yangilanadi: ekrandan chiqish — server tasdig'i
      // bilan, [recheckWorkHours] orqali.
      emit(state.copyWith(user: user));
    } catch (_) {
      // Eski ma'lumot bilan qolamiz — keyingi tekshiruv baribir so'raydi.
    }
  }

  /// "Qayta tekshirish" — tugma, har daqiqadagi va ilova qayta ochilgandagi
  /// tekshiruv.
  ///
  /// Ish faqat server (`/auth/me`) to'siq yo'qligini tasdiqlasa davom
  /// etadi. Ko'r-ko'rona qaytish ([retryService] kabi) qobiqni ochib, darhol
  /// yana 403 olib, ekranni miltillatardi.
  ///
  /// `true` — ish davom etdi; `false` — hali ish vaqti emas. Tarmoq/server
  /// xatosi chaqiruvchiga qaytariladi, holat esa o'zgarmaydi.
  ///
  /// [silent] — avtomatik tekshiruv: tugma "kutilmoqda" holatiga o'tmaydi
  /// (har daqiqada miltillamasin). Bir vaqtda faqat bitta so'rov ketadi —
  /// tugma avtomatik tekshiruv ustiga bosilsa, o'sha javobni kutadi.
  Future<bool> recheckWorkHours({bool silent = false}) {
    if (state.status != AuthStatus.outsideWorkHours) return Future.value(false);
    if (!silent && !state.submitting) emit(state.copyWith(submitting: true));
    return _workHoursCheck ??= _askWorkHours().whenComplete(
      () => _workHoursCheck = null,
    );
  }

  Future<bool>? _workHoursCheck;

  Future<bool> _askWorkHours() async {
    try {
      final user = await repository.me();
      if (isClosed || state.status != AuthStatus.outsideWorkHours) {
        return false;
      }
      if (user.workHoursBlocked) {
        emit(state.copyWith(user: user, submitting: false));
        return false;
      }
      emit(AuthState(status: AuthStatus.authenticated, user: user));
      return true;
    } catch (_) {
      if (!isClosed && state.status == AuthStatus.outsideWorkHours) {
        emit(state.copyWith(submitting: false));
      }
      rethrow;
    }
  }

  /// Yuz bosqichidan login sahifasiga qaytish.
  void cancelFaceStep() {
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _finishLogin() async {
    final user = await repository.me();
    emit(_signedIn(user));
  }

  Future<void> logout() async {
    await repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  /// Interceptor refresh'ni eplay olmaganda chaqiriladi.
  ///
  /// Ish vaqti ekranida ham: u yerdagi tekshiruv tokenlar o'lganini
  /// bilsa, xodim abadiy shu ekranda qolib ketmasin.
  void sessionExpired() {
    if (state.status == AuthStatus.authenticated ||
        state.status == AuthStatus.outsideWorkHours) {
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
