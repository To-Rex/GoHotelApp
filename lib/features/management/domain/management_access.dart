import '../../auth/domain/staff_user.dart';

/// Boshqaruv qobig'i qaysi amallarni ko'rsatishi — backend qoidalarining
/// mobil aksi.
///
/// Admin hammasini ko'radi. Menejer — o'z ruxsat kodlariga qarab: tugma
/// ko'rinmasa, server ham rad etadi (kodlar `require_permission` va
/// servislardagi tekshiruvlar bilan bir xil). Aksi ham to'g'ri: bu yerda
/// yashirilgan amalni server o'tkazmaydi — bu faqat qulaylik, himoya emas.
class ManagementAccess {
  const ManagementAccess({
    required this.isAdmin,
    required this.canBroadcast,
    required this.canSetRoomStatus,
    required this.canCreateTask,
    required this.canAssignTask,
    required this.canUpdateTask,
    required this.canForceClose,
    required this.canViewFeedback,
    required this.canManageFeedback,
    required this.canResolveProblems,
  });

  /// Murojaatlarni ko'rish/boshqarish kodlari — `feedback_service.py` dagi
  /// VIEW_CODES / MANAGE_CODES bilan bir xil.
  static const _feedbackView = [
    'feedback.view',
    'feedback.manage',
    'reservation.read',
    'reservation.create',
    'reservation.update',
    'shift.force_close',
  ];
  static const _feedbackManage = [
    'feedback.manage',
    'reservation.update',
    'shift.force_close',
  ];

  factory ManagementAccess.of(StaffUser user) {
    bool any(List<String> codes) => codes.any(user.hasPermission);
    return ManagementAccess(
      isAdmin: user.isAdmin,
      // E'lon yuborish serverda faqat ADMIN/SUPER_ADMIN uchun
      canBroadcast: user.isAdmin,
      canSetRoomStatus: user.hasPermission('room.update'),
      canCreateTask: user.hasPermission('housekeeping.task.create'),
      canAssignTask: user.hasPermission('housekeeping.task.assign'),
      canUpdateTask: user.hasPermission('housekeeping.task.update'),
      canForceClose: user.isAdmin || user.hasPermission('shift.force_close'),
      canViewFeedback: user.isAdmin || any(_feedbackView),
      canManageFeedback: user.isAdmin || any(_feedbackManage),
      canResolveProblems:
          user.isAdmin || user.hasPermission('housekeeping.task.update'),
    );
  }

  final bool isAdmin;
  final bool canBroadcast;
  final bool canSetRoomStatus;
  final bool canCreateTask;
  final bool canAssignTask;
  final bool canUpdateTask;
  final bool canForceClose;
  final bool canViewFeedback;
  final bool canManageFeedback;
  final bool canResolveProblems;
}
