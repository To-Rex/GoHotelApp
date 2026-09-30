import 'package:equatable/equatable.dart';

/// Band (yoki bron qilingan) xona — chiqish vaqti bilan
/// (`GET /housekeeping/occupied-rooms` javobi).
class OccupiedRoom extends Equatable {
  const OccupiedRoom({
    required this.roomId,
    required this.roomNumber,
    required this.roomStatus,
    required this.reservationStatus,
    required this.guestName,
    required this.bookingType,
    required this.minutesUntilCheckout,
    required this.isOverdue,
    this.expectedCheckout,
  });

  final String roomId;
  final String roomNumber;
  final String roomStatus; // RoomStatus enum satri (OCCUPIED, ...)
  final String reservationStatus; // CHECKED_IN / CONFIRMED
  final String guestName;
  final String bookingType; // DAILY / HOURLY
  final int minutesUntilCheckout;
  final bool isOverdue;
  final DateTime? expectedCheckout;

  bool get isCheckedIn => reservationStatus == 'CHECKED_IN';

  factory OccupiedRoom.fromJson(Map<String, dynamic> json) => OccupiedRoom(
    roomId: json['room_id'] as String,
    roomNumber: json['room_number'] as String? ?? '—',
    roomStatus: json['room_status'] as String? ?? 'OCCUPIED',
    reservationStatus: json['reservation_status'] as String? ?? 'CHECKED_IN',
    guestName: json['guest_name'] as String? ?? '',
    bookingType: json['booking_type'] as String? ?? 'DAILY',
    minutesUntilCheckout:
        (json['minutes_until_checkout'] as num?)?.toInt() ?? 0,
    isOverdue: json['is_overdue'] as bool? ?? false,
    expectedCheckout: json['expected_checkout'] == null
        ? null
        : DateTime.tryParse(json['expected_checkout'] as String),
  );

  @override
  List<Object?> get props => [roomId, reservationStatus, minutesUntilCheckout];
}
