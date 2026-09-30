import 'package:equatable/equatable.dart';

/// Serverga xabar berilgan kiruvchi qo'ng'iroq natijasi.
class IncomingCall extends Equatable {
  const IncomingCall({
    required this.id,
    required this.phone,
    required this.matched,
    this.guestId,
    this.guestName,
    this.roomNumber,
  });

  final String id;
  final String phone;

  /// Raqam bo'yicha mehmon topildimi.
  final bool matched;
  final String? guestId;
  final String? guestName;

  /// Mehmon hozir turgan xona (bo'lsa).
  final String? roomNumber;

  factory IncomingCall.fromJson(Map<String, dynamic> json) => IncomingCall(
    id: json['id'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    matched: json['matched'] as bool? ?? false,
    guestId: json['guest_id'] as String?,
    guestName: json['guest_name'] as String?,
    roomNumber: json['room_number'] as String?,
  );

  @override
  List<Object?> get props => [id, phone, matched, guestId, roomNumber];
}
