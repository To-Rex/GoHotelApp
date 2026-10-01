import 'package:equatable/equatable.dart';

/// Xodim (`GET /users/`) — jamoa ro'yxati uchun.
class StaffMember extends Equatable {
  const StaffMember({
    required this.id,
    required this.userType,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.status,
    required this.workStart,
    required this.workEnd,
    this.phone,
    this.email,
    this.lastLoginAt,
    this.hireDate,
  });

  final String id;
  final String userType;
  final String username;
  final String firstName;
  final String lastName;

  /// ACTIVE / INACTIVE / TERMINATED
  final String status;
  final String workStart; // "09:00"
  final String workEnd; // "18:00"
  final String? phone;
  final String? email;
  final DateTime? lastLoginAt;
  final String? hireDate;

  String get fullName => '$firstName $lastName'.trim();

  bool get isActive => status == 'ACTIVE';
  bool get isAdmin => userType == 'ADMIN' || userType == 'SUPER_ADMIN';

  /// Hozir ish vaqtidami. Tungi smena (22:00–06:00) ham to'g'ri hisoblanadi:
  /// boshlanish tugashdan katta bo'lsa oraliq yarim tundan o'tadi.
  bool isOnDuty(DateTime now) {
    final start = _minutes(workStart);
    final end = _minutes(workEnd);
    if (start == null || end == null || start == end) return true;
    final current = now.hour * 60 + now.minute;
    if (start < end) return current >= start && current < end;
    return current >= start || current < end;
  }

  /// Oxirgi kirish 15 daqiqa ichida bo'lsa — "hozir ilovada".
  bool wasRecentlyOnline(DateTime now) =>
      lastLoginAt != null && now.difference(lastLoginAt!).inMinutes <= 15;

  static int? _minutes(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  factory StaffMember.fromJson(Map<String, dynamic> json) => StaffMember(
    id: json['id'] as String,
    userType: json['user_type'] as String? ?? 'EMPLOYEE',
    username: json['username'] as String? ?? '',
    firstName: json['first_name'] as String? ?? '',
    lastName: json['last_name'] as String? ?? '',
    status: json['status'] as String? ?? 'ACTIVE',
    workStart: json['work_start'] as String? ?? '09:00',
    workEnd: json['work_end'] as String? ?? '18:00',
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    lastLoginAt: json['last_login_at'] == null
        ? null
        : DateTime.tryParse(json['last_login_at'] as String)?.toLocal(),
    hireDate: json['hire_date'] as String?,
  );

  @override
  List<Object?> get props => [id, status, lastLoginAt, workStart, workEnd];
}
