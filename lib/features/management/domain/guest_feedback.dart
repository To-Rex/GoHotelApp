import 'package:equatable/equatable.dart';

/// Mehmon murojaati (`GET /feedback/` qatori): talab, taklif yoki shikoyat.
class GuestFeedback extends Equatable {
  const GuestFeedback({
    required this.id,
    required this.type,
    required this.status,
    required this.priority,
    required this.subject,
    required this.body,
    required this.createdAt,
    this.roomNumber,
    this.guestName,
    this.guestPhone,
    this.reservationNumber,
    this.assignedToName,
    this.resolution,
    this.resolvedAt,
    this.resolvedByName,
    this.createdByName,
  });

  final String id;

  /// REQUEST / SUGGESTION / COMPLAINT
  final String type;

  /// NEW / IN_PROGRESS / RESOLVED / REJECTED
  final String status;

  /// LOW / MEDIUM / HIGH
  final String priority;
  final String subject;
  final String body;
  final DateTime createdAt;
  final String? roomNumber;
  final String? guestName;
  final String? guestPhone;
  final String? reservationNumber;
  final String? assignedToName;
  final String? resolution;
  final DateTime? resolvedAt;
  final String? resolvedByName;
  final String? createdByName;

  bool get isComplaint => type == 'COMPLAINT';
  bool get isOpen => status == 'NEW' || status == 'IN_PROGRESS';
  bool get isNew => status == 'NEW';

  static DateTime? _date(dynamic v) =>
      v is String ? DateTime.tryParse(v)?.toLocal() : null;

  factory GuestFeedback.fromJson(Map<String, dynamic> json) => GuestFeedback(
    id: json['id'] as String,
    type: json['feedback_type'] as String? ?? 'REQUEST',
    status: json['status'] as String? ?? 'NEW',
    priority: json['priority'] as String? ?? 'MEDIUM',
    subject: json['subject'] as String? ?? '',
    body: json['body'] as String? ?? '',
    createdAt: _date(json['created_at']) ?? DateTime.now(),
    roomNumber: json['room_number'] as String?,
    guestName: json['guest_name'] as String?,
    guestPhone: json['guest_phone'] as String?,
    reservationNumber: json['reservation_number'] as String?,
    assignedToName: json['assigned_to_name'] as String?,
    resolution: json['resolution'] as String?,
    resolvedAt: _date(json['resolved_at']),
    resolvedByName: json['resolved_by_name'] as String?,
    createdByName: json['created_by_name'] as String?,
  );

  @override
  List<Object?> get props => [id, status, priority, resolution];
}

/// Xodim xabar qilgan muammo (`GET /problems`) — farrosh yoki usta
/// mobil ilovadan yuboradi, menejer bu yerda ko'rib hal qiladi.
class StaffProblem extends Equatable {
  const StaffProblem({
    required this.id,
    required this.category,
    required this.description,
    required this.status,
    required this.createdAt,
    this.roomNumber,
    this.reportedByName,
    this.taskId,
  });

  final String id;
  final String category;
  final String description;

  /// OPEN / IN_PROGRESS / RESOLVED
  final String status;
  final DateTime createdAt;
  final String? roomNumber;
  final String? reportedByName;
  final String? taskId;

  bool get isOpen => status != 'RESOLVED';

  factory StaffProblem.fromJson(Map<String, dynamic> json) => StaffProblem(
    id: json['id'] as String,
    category: json['category'] as String? ?? '',
    description: json['description'] as String? ?? '',
    status: json['status'] as String? ?? 'OPEN',
    createdAt:
        (json['created_at'] is String
            ? DateTime.tryParse(json['created_at'] as String)?.toLocal()
            : null) ??
        DateTime.now(),
    roomNumber: json['room_number'] as String?,
    reportedByName: json['reported_by_name'] as String?,
    taskId: json['task_id'] as String?,
  );

  StaffProblem withStatus(String value) => StaffProblem(
    id: id,
    category: category,
    description: description,
    status: value,
    createdAt: createdAt,
    roomNumber: roomNumber,
    reportedByName: reportedByName,
    taskId: taskId,
  );

  @override
  List<Object?> get props => [id, status];
}
