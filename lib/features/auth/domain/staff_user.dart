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
    this.branchName,
    this.email,
    this.phone,
    this.workStart = '09:00',
    this.workEnd = '18:00',
    this.allowOutsideWorkHours = false,
    this.workHoursEnforced = false,
    this.workHoursBlocked = false,
  });

  final String id;
  final String userType; // SUPER_ADMIN / ADMIN / EMPLOYEE / CONFIGURATOR
  final String username;
  final String firstName;
  final String lastName;
  final List<String> permissions;
  final String? hotelId;
  final String? hotelName;
  final String? branchId;

  /// Joriy filial nomi: xodimda — o'z filiali, administratorda — tanlagani.
  /// Filiallar to'liq ajratilgan: barcha ma'lumot shu filialniki.
  final String? branchName;
  final String? email;
  final String? phone;
  final String workStart;
  final String workEnd;

  /// Administrator belgilagan istisno: xodim ish vaqtidan tashqari ham
  /// ishlay oladi.
  final bool allowOutsideWorkHours;

  /// Mehmonxona sozlamasi: ish vaqtidan tashqari ishlash cheklanganmi.
  /// Xodim bo'lmaganlar va mehmonxonasizlar uchun doim `false`.
  final bool workHoursEnforced;

  /// Server hisobi: shu daqiqada bu xodimning so'rovlari ish vaqti sababli
  /// to'siladimi (`403 OUTSIDE_WORK_HOURS`). Qaror faqat serverda — ilova
  /// soatni o'zi hisoblamaydi, qurilma vaqti noto'g'ri bo'lishi mumkin.
  final bool workHoursBlocked;

  String get fullName => '$firstName $lastName'.trim();

  bool get isAdmin => userType == 'ADMIN' || userType == 'SUPER_ADMIN';

  /// Sozlovchi — mehmonxonaga bog'lanmagan hisob: mehmonxonani veb-ilovada
  /// tanlab sozlaydi. Mobil ilovada unga faqat yo'riqnoma sahifasi ochiladi.
  bool get isConfigurator => userType == 'CONFIGURATOR';

  /// Administrator o'z mehmonxonasining filiallari orasida o'ta oladi
  /// (`POST /auth/context`). Xodim — faqat o'z filialida.
  bool get canSwitchBranch => userType == 'ADMIN' && hotelId != null;

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
    branchName: json['branch_name'] as String?,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    workStart: json['work_start'] as String? ?? '09:00',
    workEnd: json['work_end'] as String? ?? '18:00',
    // Eski server bu maydonlarni yubormaydi — standart qiymat bugungi
    // xatti-harakatni saqlaydi (hech kim to'silmaydi).
    allowOutsideWorkHours: json['allow_outside_work_hours'] == true,
    workHoursEnforced: json['work_hours_enforced'] == true,
    workHoursBlocked: json['work_hours_blocked'] == true,
  );

  /// Ish vaqti va uning bayroqlari ham tenglikka kiradi: aks holda
  /// `/auth/me` yangilangan foydalanuvchini qaytarsa ham Bloc uni "o'sha
  /// holat" deb tashlab yuborar, ekran esa eski soatni ko'rsatib qolardi.
  /// Mehmonxona va filial ham — filial almashganda butun ekran yangilanadi.
  @override
  List<Object?> get props => [
    id,
    userType,
    username,
    permissions,
    hotelId,
    hotelName,
    branchId,
    branchName,
    workStart,
    workEnd,
    allowOutsideWorkHours,
    workHoursEnforced,
    workHoursBlocked,
  ];
}
