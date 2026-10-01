import 'package:equatable/equatable.dart';

/// Xo'jalik vazifasi boshqaruv ko'zi bilan (`GET /housekeeping/tasks`).
///
/// Farrosh moduli o'z mobil API'sini (`/tasks`) ishlatadi — bu boshqa
/// ko'rinish: kim biriktirilgan, qachon boshlangan, avtomatik yopilganmi.
class HkTask extends Equatable {
  const HkTask({
    required this.id,
    required this.roomId,
    required this.roomNumber,
    required this.taskType,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.checklistDone,
    required this.checklistTotal,
    required this.autoCompleted,
    this.assignedTo,
    this.assigneeName,
    this.startedAt,
    this.completedAt,
    this.notes,
    this.reservationId,
  });

  final String id;
  final String roomId;
  final String roomNumber;

  /// CLEANING / DEEP_CLEANING / MAINTENANCE / INSPECTION / TURN_DOWN
  final String taskType;

  /// OPEN / IN_PROGRESS / COMPLETED / CANCELLED
  final String status;

  /// LOW / MEDIUM / HIGH / URGENT
  final String priority;
  final DateTime createdAt;
  final String? assignedTo;
  final String? assigneeName;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int checklistDone;
  final int checklistTotal;
  final bool autoCompleted;
  final String? notes;
  final String? reservationId;

  bool get isOpen => status == 'OPEN';
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isDone => status == 'COMPLETED';
  bool get isUrgent => priority == 'URGENT' || priority == 'HIGH';

  /// Vazifa qanchadan beri kutmoqda (ochiq) yoki ishlanmoqda.
  Duration waiting(DateTime now) {
    final since = isInProgress ? (startedAt ?? createdAt) : createdAt;
    final d = now.difference(since);
    return d.isNegative ? Duration.zero : d;
  }

  static DateTime? _date(dynamic v) =>
      v is String ? DateTime.tryParse(v)?.toLocal() : null;

  factory HkTask.fromJson(Map<String, dynamic> json) {
    final room = json['room'] as Map<String, dynamic>?;
    final user = json['assigned_user'] as Map<String, dynamic>?;
    final assignee = user == null
        ? null
        : '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    return HkTask(
      id: json['id'] as String,
      roomId: json['room_id'] as String? ?? '',
      roomNumber: room?['room_number'] as String? ?? '—',
      taskType: json['task_type'] as String? ?? 'CLEANING',
      status: json['status'] as String? ?? 'OPEN',
      priority: json['priority'] as String? ?? 'MEDIUM',
      createdAt: _date(json['created_at']) ?? DateTime.now(),
      assignedTo: json['assigned_to'] as String?,
      assigneeName: assignee == null || assignee.isEmpty ? null : assignee,
      startedAt: _date(json['started_at']),
      completedAt: _date(json['completed_at']),
      checklistDone: (json['checklist_done'] as num?)?.toInt() ?? 0,
      checklistTotal: (json['checklist_total'] as num?)?.toInt() ?? 0,
      autoCompleted: json['auto_completed'] as bool? ?? false,
      notes: json['notes'] as String?,
      reservationId: json['reservation_id'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, status, assignedTo, checklistDone, priority];
}
