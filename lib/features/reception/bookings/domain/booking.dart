import 'package:equatable/equatable.dart';

/// Bron shu kunga qanday tegishli.
///
/// Resepsiya kunni aynan shu uch guruh bilan o'ylaydi: kim keladi, kim
/// turibdi, kim chiqadi.
enum BookingKind {
  arrival,
  inhouse,
  departure;

  static BookingKind fromApi(String value) => switch (value) {
    'arrival' => BookingKind.arrival,
    'departure' => BookingKind.departure,
    _ => BookingKind.inhouse,
  };
}

/// Qabulxona bron qatori (`GET /api/v1/reception/bookings` javobi) —
/// mehmon va xona ma'lumotlari bilan boyitilgan.
class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.reservationNumber,
    required this.guestName,
    required this.roomNumber,
    required this.bookingType,
    required this.checkInDate,
    required this.checkOutDate,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.paidAmount,
    required this.adults,
    required this.children,
    required this.kind,
    this.guestId,
    this.guestPhone,
    this.checkInTime,
    this.checkOutTime,
    this.notes,
  });

  final String id;
  final String reservationNumber;
  final String guestName;
  final String roomNumber;

  /// DAILY yoki HOURLY
  final String bookingType;
  final String checkInDate; // "yyyy-MM-dd"
  final String checkOutDate;

  /// Soatlik bronda kirish/chiqish vaqti ("HH:mm"), aks holda null.
  final String? checkInTime;
  final String? checkOutTime;

  final String status;
  final String paymentStatus;
  final double totalAmount;
  final double paidAmount;
  final int adults;
  final int children;
  final BookingKind kind;
  final String? guestId;
  final String? guestPhone;
  final String? notes;

  bool get isHourly => bookingType == 'HOURLY';

  /// To'lanmagan qoldiq — hech qachon manfiy bo'lmaydi.
  double get remaining =>
      (totalAmount - paidAmount) > 0 ? totalAmount - paidAmount : 0;

  bool get hasDebt => remaining > 0.009;

  /* Vaqt DEVOR SOATI sifatida saqlanadi: xodim tergan vaqt aynan
     shunday ko'rsatilishi kerak. `DateTime.parse` uni mahalliy zonaga
     surib yuborardi va 19:17 kechasi 00:17 bo'lib chiqardi — shuning
     uchun satrdan matn sifatida kesib olinadi. */
  static String? _timeOf(String? iso) {
    if (iso == null || iso.length < 16) return null;
    return iso.substring(11, 16);
  }

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'] as String,
    reservationNumber: json['reservation_number'] as String? ?? '—',
    guestName: json['guest_name'] as String? ?? '—',
    roomNumber: json['room_number'] as String? ?? '—',
    bookingType: json['booking_type'] as String? ?? 'DAILY',
    checkInDate: json['check_in_date'] as String? ?? '',
    checkOutDate: json['check_out_date'] as String? ?? '',
    checkInTime: _timeOf(json['check_in_datetime'] as String?),
    checkOutTime: _timeOf(json['check_out_datetime'] as String?),
    status: json['status'] as String? ?? 'PENDING',
    paymentStatus: json['payment_status'] as String? ?? 'UNPAID',
    totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
    paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
    adults: (json['adults'] as num?)?.toInt() ?? 1,
    children: (json['children'] as num?)?.toInt() ?? 0,
    kind: BookingKind.fromApi(json['kind'] as String? ?? 'inhouse'),
    guestId: json['guest_id'] as String?,
    guestPhone: json['guest_phone'] as String?,
    notes: json['notes'] as String?,
  );

  @override
  List<Object?> get props => [id, status, paymentStatus, paidAmount, kind];
}
