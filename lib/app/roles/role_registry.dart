import 'package:flutter/material.dart';

import '../../features/admin/admin_home_page.dart';
import '../../features/auth/domain/staff_user.dart';
import '../../features/configurator/configurator_home_page.dart';
import '../../features/housekeeper/home/housekeeper_shell.dart';
import '../../features/maintenance/maintenance_home_page.dart';
import '../../features/manager/manager_home_page.dart';
import '../../features/reception/home/reception_shell.dart';
import '../../features/staff/staff_home_page.dart';
import '../../l10n/gen/app_localizations.dart';

/// Bitta rol moduli: kim ekanini aniqlash qoidasi + bosh sahifasi.
///
/// Yangi rol qo'shish uchun `features/<rol>/` papkasida sahifa yaratib,
/// [RoleRegistry.modules] ro'yxatiga qo'shish kifoya — ilova qolganini
/// o'zi qiladi (birinchi mos kelgan modul tanlanadi).
class RoleModule {
  const RoleModule({
    required this.id,
    required this.matches,
    required this.homeBuilder,
    required this.label,
  });

  final String id;

  /// Xodim shu rolga mos keladimi (user_type + ruxsat kodlari bo'yicha).
  final bool Function(StaffUser user) matches;

  final Widget Function() homeBuilder;

  /// Lokalizatsiya qilingan lavozim nomi.
  final String Function(S l10n) label;
}

/// Rollarni aniqlash tartibi MUHIM: kengroq huquqli rollar birinchi
/// tekshiriladi (menejerda ham housekeeping.* bor — u farrosh emas).
abstract final class RoleRegistry {
  static final List<RoleModule> modules = [
    // Sozlovchi birinchi: u ruxsat kodlarisiz va mehmonxonasiz — boshqa
    // modullar uni umumiy xodim deb olib, ishlamaydigan bo'limga tushirardi
    RoleModule(
      id: 'configurator',
      matches: (u) => u.isConfigurator,
      homeBuilder: ConfiguratorHomePage.new,
      label: (l10n) => l10n.roleConfigurator,
    ),
    RoleModule(
      id: 'admin',
      matches: (u) => u.isAdmin,
      homeBuilder: AdminHomePage.new,
      label: (l10n) => l10n.roleAdmin,
    ),
    RoleModule(
      id: 'manager',
      matches: (u) =>
          u.hasPermission('shift.*') || u.hasPermission('employee.create'),
      homeBuilder: ManagerHomePage.new,
      label: (l10n) => l10n.roleManager,
    ),
    RoleModule(
      id: 'reception',
      // Bron bilan ishlaydigan xodim — yaratish yoki hech bo'lmasa
      // ko'rish huquqi bilan. Ro'yxat serverdagi `RECEPTION_CODES` bilan
      // bir xil: mobil bir joyga qo'yib, server boshqasini talab qilsa
      // xodim ochilmaydigan bo'limga tushib qolardi.
      matches: (u) =>
          u.hasPermission('reservation.create') ||
          u.hasPermission('reservation.read') ||
          u.hasPermission('reservation.update'),
      homeBuilder: ReceptionShell.new,
      label: (l10n) => l10n.roleReception,
    ),
    RoleModule(
      id: 'maintenance',
      matches: (u) =>
          u.hasPermission('housekeeping.task.create') &&
          !u.hasPermission('housekeeping.task.assign'),
      homeBuilder: MaintenanceHomePage.new,
      label: (l10n) => l10n.roleMaintenance,
    ),
    RoleModule(
      id: 'housekeeper',
      matches: (u) =>
          u.hasPermission('housekeeping.*') ||
          u.hasPermission('room.status.update'),
      homeBuilder: HousekeeperShell.new,
      label: (l10n) => l10n.roleHousekeeper,
    ),
  ];

  /// Hech biriga mos kelmasa — umumiy xodim sahifasi (chat + profil).
  static final RoleModule fallback = RoleModule(
    id: 'staff',
    matches: (_) => true,
    homeBuilder: StaffHomePage.new,
    label: (l10n) => l10n.roleStaff,
  );

  static RoleModule resolve(StaffUser user) =>
      modules.firstWhere((m) => m.matches(user), orElse: () => fallback);
}
