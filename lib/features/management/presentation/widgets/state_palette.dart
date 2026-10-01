import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../domain/room_tile.dart';

/// Xona holati → rang va yozuv. Ranglar mavzuga bog'liq ([AppColors]).
///
/// Bir joyda turadi: halqa, xarita kataklari, filtr chiplari va tafsilot
/// oynasi bir xil rangni ko'rsatadi.
abstract final class RoomStatePalette {
  static Color color(AppColors c, RoomState state) => switch (state) {
    RoomState.available => c.success,
    RoomState.occupied => c.danger,
    RoomState.reserved => c.brand,
    RoomState.cleaning => c.info,
    RoomState.maintenance => c.warning,
    RoomState.inspection => c.violet,
    RoomState.outOfService => c.textMuted,
    RoomState.other => c.textMuted,
  };

  static Color soft(AppColors c, RoomState state) => switch (state) {
    RoomState.available => c.successSoft,
    RoomState.occupied => c.dangerSoft,
    RoomState.reserved => c.brandSoft,
    RoomState.cleaning => c.infoSoft,
    RoomState.maintenance => c.warningSoft,
    RoomState.inspection => c.violetSoft,
    RoomState.outOfService => c.surfaceAlt,
    RoomState.other => c.surfaceAlt,
  };

  static IconData icon(RoomState state) => switch (state) {
    RoomState.available => Icons.check_rounded,
    RoomState.occupied => Icons.person_rounded,
    RoomState.reserved => Icons.event_available_rounded,
    RoomState.cleaning => Icons.cleaning_services_rounded,
    RoomState.maintenance => Icons.build_rounded,
    RoomState.inspection => Icons.search_rounded,
    RoomState.outOfService => Icons.block_rounded,
    RoomState.other => Icons.help_outline_rounded,
  };

  static String label(S l10n, RoomState state) => switch (state) {
    RoomState.available => l10n.roomStateAvailable,
    RoomState.occupied => l10n.roomStateOccupied,
    RoomState.reserved => l10n.roomStateReserved,
    RoomState.cleaning => l10n.roomStateCleaning,
    RoomState.maintenance => l10n.roomStateMaintenance,
    RoomState.inspection => l10n.roomStateInspection,
    RoomState.outOfService => l10n.roomStateOutOfService,
    RoomState.other => l10n.roomStateUnknown,
  };
}

/// Vazifa holati/muhimligi ranglari.
abstract final class TaskPalette {
  static Color statusColor(AppColors c, String status) => switch (status) {
    'OPEN' => c.warning,
    'IN_PROGRESS' => c.brand,
    'COMPLETED' => c.success,
    _ => c.textMuted,
  };

  static Color statusSoft(AppColors c, String status) => switch (status) {
    'OPEN' => c.warningSoft,
    'IN_PROGRESS' => c.brandSoft,
    'COMPLETED' => c.successSoft,
    _ => c.surfaceAlt,
  };

  static String statusLabel(S l10n, String status) => switch (status) {
    'OPEN' => l10n.taskOpen,
    'IN_PROGRESS' => l10n.taskInProgress,
    'COMPLETED' => l10n.taskCompleted,
    'CANCELLED' => l10n.taskCancelled,
    _ => status,
  };

  static String typeLabel(S l10n, String type) => switch (type) {
    'CLEANING' => l10n.taskTypeCleaning,
    'DEEP_CLEANING' => l10n.taskTypeDeepCleaning,
    'MAINTENANCE' => l10n.taskTypeMaintenance,
    'INSPECTION' => l10n.taskTypeInspection,
    'TURN_DOWN' => l10n.taskTypeTurnDown,
    _ => type,
  };

  static String priorityLabel(S l10n, String priority) => switch (priority) {
    'LOW' => l10n.priorityLow,
    'MEDIUM' => l10n.priorityMedium,
    'HIGH' => l10n.priorityHigh,
    'URGENT' => l10n.priorityUrgent,
    _ => priority,
  };

  static Color priorityColor(AppColors c, String priority) => switch (priority) {
    'URGENT' => c.danger,
    'HIGH' => c.warning,
    'LOW' => c.textMuted,
    _ => c.info,
  };
}

/// Murojaat turi/holati ranglari.
abstract final class FeedbackPalette {
  static Color typeColor(AppColors c, String type) => switch (type) {
    'COMPLAINT' => c.danger,
    'SUGGESTION' => c.violet,
    _ => c.brand,
  };

  static Color typeSoft(AppColors c, String type) => switch (type) {
    'COMPLAINT' => c.dangerSoft,
    'SUGGESTION' => c.violetSoft,
    _ => c.brandSoft,
  };

  static String typeLabel(S l10n, String type) => switch (type) {
    'COMPLAINT' => l10n.feedbackComplaint,
    'SUGGESTION' => l10n.feedbackSuggestion,
    _ => l10n.feedbackRequest,
  };

  static String statusLabel(S l10n, String status) => switch (status) {
    'NEW' => l10n.feedbackNew,
    'IN_PROGRESS' => l10n.feedbackInProgress,
    'RESOLVED' => l10n.feedbackResolved,
    'REJECTED' => l10n.feedbackRejected,
    _ => status,
  };

  static Color statusColor(AppColors c, String status) => switch (status) {
    'NEW' => c.warning,
    'IN_PROGRESS' => c.brand,
    'RESOLVED' => c.success,
    'REJECTED' => c.textMuted,
    _ => c.textMuted,
  };

  static Color statusSoft(AppColors c, String status) => switch (status) {
    'NEW' => c.warningSoft,
    'IN_PROGRESS' => c.brandSoft,
    'RESOLVED' => c.successSoft,
    _ => c.surfaceAlt,
  };
}
