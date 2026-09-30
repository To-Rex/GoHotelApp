import 'package:equatable/equatable.dart';

/// Bildirishnoma (`GET /notifications/` javobi, mobil format).
class StaffNotification extends Equatable {
  const StaffNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.roomNumber,
    this.timestamp,
  });

  final String id;
  final String
  type; // critical / newTask / problemAccepted / inventory / system
  final String title;
  final String message;
  final bool isRead;
  final String? roomNumber;
  final DateTime? timestamp;

  factory StaffNotification.fromJson(Map<String, dynamic> json) =>
      StaffNotification(
        id: json['id'] as String,
        type: json['type'] as String? ?? 'system',
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        isRead: json['is_read'] as bool? ?? false,
        roomNumber: json['room_number'] as String?,
        timestamp: json['timestamp'] == null
            ? null
            : DateTime.tryParse(json['timestamp'] as String),
      );

  @override
  List<Object?> get props => [id, isRead];
}
