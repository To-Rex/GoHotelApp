import 'package:equatable/equatable.dart';

/// Tizimga kirgan xodim (`GET /auth/me` javobi).
class StaffUser extends Equatable {
  const StaffUser({
    required this.id,
    required this.userType,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.permissions,
    this.hotelId,
    this.hotelName,
    this.branchId,
    this.email,
    this.phone,
    this.workStart = '09:00',
    this.workEnd = '18:00',
  });

  final String id;
  final String userType; // SUPER_ADMIN / ADMIN / EMPLOYEE
  final String username;
  final String firstName;
  final String lastName;
  final List<String> permissions;
  final String? hotelId;
  final String? hotelName;
  final String? branchId;
  final String? email;
  final String? phone;
  final String workStart;
  final String workEnd;

  String get fullName => '$firstName $lastName'.trim();

  bool get isAdmin => userType == 'ADMIN' || userType == 'SUPER_ADMIN';

  /// Ruxsat tekshiruvi. `pattern` yulduzchali bo'lishi mumkin
  /// (masalan `housekeeping.*`) — xodimning istalgan mos kodi yetarli.
  bool hasPermission(String pattern) {
    if (isAdmin) return true;
    if (!pattern.contains('*')) return permissions.contains(pattern);
    final regex = RegExp(
      '^${RegExp.escape(pattern).replaceAll(r'\*', '.*')}\$',
    );
    return permissions.any(regex.hasMatch);
  }

  factory StaffUser.fromJson(Map<String, dynamic> json) => StaffUser(
    id: json['id'] as String,
    userType: json['user_type'] as String? ?? 'EMPLOYEE',
    username: json['username'] as String? ?? '',
    firstName: json['first_name'] as String? ?? '',
    lastName: json['last_name'] as String? ?? '',
    permissions: (json['permissions'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList(),
    hotelId: json['hotel_id'] as String?,
    hotelName: json['hotel_name'] as String?,
    branchId: json['branch_id'] as String?,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    workStart: json['work_start'] as String? ?? '09:00',
    workEnd: json['work_end'] as String? ?? '18:00',
  );

  @override
  List<Object?> get props => [id, userType, username, permissions];
}
