import 'package:equatable/equatable.dart';

/// Xodimlar taxtasidagi bitta xabar (`/messages` API).
///
/// Bu 1-ga-1 chat emas — umumiy taxta: farrosh yozadi, resepshn (va barcha
/// xodimlar) ko'radi, istalgan xodim "Bajarildi" deb yopadi.
class StaffMessage extends Equatable {
  const StaffMessage({
    required this.id,
    required this.body,
    required this.status,
    required this.createdBy,
    required this.createdByName,
    this.roomId,
    this.roomNumber,
    this.createdAt,
    this.doneByName,
    this.doneAt,
  });

  final String id;
  final String body;
  final String status; // OPEN / DONE
  final String createdBy;
  final String createdByName;
  final String? roomId;
  final String? roomNumber;
  final DateTime? createdAt;
  final String? doneByName;
  final DateTime? doneAt;

  bool get isOpen => status == 'OPEN';

  factory StaffMessage.fromJson(Map<String, dynamic> json) => StaffMessage(
    id: json['id'] as String,
    body: json['body'] as String? ?? '',
    status: json['status'] as String? ?? 'OPEN',
    createdBy: json['created_by'] as String? ?? '',
    createdByName: json['created_by_name'] as String? ?? '',
    roomId: json['room_id'] as String?,
    roomNumber: json['room_number'] as String?,
    createdAt: json['created_at'] == null
        ? null
        : DateTime.tryParse(json['created_at'] as String),
    doneByName: json['done_by_name'] as String?,
    doneAt: json['done_at'] == null
        ? null
        : DateTime.tryParse(json['done_at'] as String),
  );

  @override
  List<Object?> get props => [id, status, doneByName];
}

/// Xabarga biriktirilgan fayl (rasm) — `/files/by-entity` javobidan.
class MessageAttachment extends Equatable {
  const MessageAttachment({
    required this.fileId,
    required this.entityId,
    required this.mimeType,
  });

  final String fileId;
  final String entityId; // qaysi xabarga tegishli
  final String mimeType;

  bool get isImage => mimeType.startsWith('image/');

  factory MessageAttachment.fromJson(Map<String, dynamic> json) =>
      MessageAttachment(
        fileId: json['id'] as String,
        entityId: json['entity_id'] as String? ?? '',
        mimeType: json['mime_type'] as String? ?? '',
      );

  @override
  List<Object?> get props => [fileId];
}
