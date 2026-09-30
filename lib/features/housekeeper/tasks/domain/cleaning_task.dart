import 'package:equatable/equatable.dart';

/// Mobil vazifa holatlari (backend `pending / inProgress / completed`).
enum TaskStatus {
  pending,
  inProgress,
  completed;

  static TaskStatus fromApi(String value) => switch (value) {
    'inProgress' => TaskStatus.inProgress,
    'completed' => TaskStatus.completed,
    _ => TaskStatus.pending,
  };
}

class ChecklistItem extends Equatable {
  const ChecklistItem({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  final String id;
  final String title;
  final bool isCompleted;

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    isCompleted: json['is_completed'] as bool? ?? false,
  );

  @override
  List<Object?> get props => [id, title, isCompleted];
}

/// Farrosh mobil vazifasi (`GET /api/v1/tasks` javobi) — xona/qavat/mehmon
/// ma'lumotlari bilan boyitilgan.
class CleaningTask extends Equatable {
  const CleaningTask({
    required this.id,
    required this.roomNumber,
    required this.floor,
    required this.roomType,
    required this.status,
    required this.progress,
    required this.isUrgent,
    required this.checklist,
    this.guest,
    this.guestStatus,
    this.deadline,
    this.note,
  });

  final String id;
  final String roomNumber;
  final String floor;
  final String roomType;
  final TaskStatus status;
  final int progress; // 0..100
  final bool isUrgent;
  final List<ChecklistItem> checklist;
  final String? guest;
  final String? guestStatus;
  final String? deadline; // "14:00" ko'rinishida
  final String? note;

  int get completedCount => checklist.where((i) => i.isCompleted).length;

  factory CleaningTask.fromJson(Map<String, dynamic> json) => CleaningTask(
    id: json['id'] as String,
    roomNumber: json['room_number'] as String? ?? '—',
    floor: json['floor'] as String? ?? '',
    roomType: json['room_type'] as String? ?? '',
    status: TaskStatus.fromApi(json['status'] as String? ?? 'pending'),
    progress: (json['progress'] as num?)?.toInt() ?? 0,
    isUrgent: json['is_urgent'] as bool? ?? false,
    checklist: (json['checklist'] as List<dynamic>? ?? [])
        .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    guest: json['guest'] as String?,
    guestStatus: json['guest_status'] as String?,
    deadline: json['deadline'] as String?,
    note: json['note'] as String?,
  );

  @override
  List<Object?> get props => [id, status, progress, checklist, isUrgent];
}
