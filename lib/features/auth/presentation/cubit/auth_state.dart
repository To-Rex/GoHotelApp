part of 'auth_cubit.dart';

enum AuthStatus {
  /// Ilova endi ochildi — sessiya tekshirilmoqda.
  starting,

  /// Login sahifasi ko'rsatiladi.
  unauthenticated,

  /// Saqlangan sessiya bor, lekin biometrik tasdiq kutilmoqda.
  locked,

  /// Parol to'g'ri — yuz tasdig'i bosqichi.
  faceStep,

  /// Kirish tugallandi.
  authenticated,

  /// Mehmonxona xizmati to'xtatilgan — sabab ekrani ko'rsatiladi.
  ///
  /// Sessiya saqlanadi: xizmat tiklangach xodim qaytadan kirmasdan
  /// ishini davom ettiradi.
  serviceStopped,
}

class AuthState extends Equatable {
  const AuthState({
    required this.status,
    this.user,
    this.faceToken,
    this.submitting = false,
    this.error,
    this.errorCode,
  });

  const AuthState.starting() : this(status: AuthStatus.starting);

  final AuthStatus status;
  final StaffUser? user;
  final String? faceToken;
  final bool submitting;

  /// Foydalanuvchiga ko'rsatiladigan xato (allaqachon lokalizatsiya
  /// qilinmagan bo'lsa — [errorCode] bo'yicha UI o'zi tanlaydi).
  final String? error;

  /// Backend `error_code` (masalan `DEVICE_PENDING`) — UI maxsus holatlarni
  /// shu orqali ajratadi.
  final String? errorCode;

  AuthState copyWith({
    AuthStatus? status,
    StaffUser? user,
    String? faceToken,
    bool? submitting,
    String? error,
    String? errorCode,
    bool clearError = false,
  }) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
    faceToken: faceToken ?? this.faceToken,
    submitting: submitting ?? this.submitting,
    error: clearError ? null : (error ?? this.error),
    errorCode: clearError ? null : (errorCode ?? this.errorCode),
  );

  @override
  List<Object?> get props => [
    status,
    user,
    faceToken,
    submitting,
    error,
    errorCode,
  ];
}
