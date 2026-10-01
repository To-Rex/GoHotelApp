import 'package:equatable/equatable.dart';

/// Xona holati — backend `RoomStatus` bilan bir xil satrlar.
///
/// Xarita rangi va tartibi shu ro'yxatdan olinadi: bo'sh → band →
/// bron → tozalanmoqda → texnik holatlar. Noma'lum satr [other] ga tushadi,
/// ilova yiqilmaydi.
enum RoomState {
  available('AVAILABLE'),
  occupied('OCCUPIED'),
  reserved('RESERVED'),
  cleaning('CLEANING'),
  maintenance('MAINTENANCE'),
  inspection('INSPECTION'),
  outOfService('OUT_OF_SERVICE'),
  other('');

  const RoomState(this.api);

  final String api;

  static RoomState fromApi(String? value) => RoomState.values.firstWhere(
    (s) => s.api == (value ?? '').toUpperCase(),
    orElse: () => RoomState.other,
  );

  /// Admin qo'lda o'rnatishi mumkin bo'lgan holatlar. Band va bron qilingan
  /// holatlar bron oqimidan keladi — ularni qo'lda qo'yish ma'lumotni buzadi.
  static const manual = [
    RoomState.available,
    RoomState.cleaning,
    RoomState.maintenance,
    RoomState.inspection,
    RoomState.outOfService,
  ];

  /// Mehmon bor yoki kelishi kutilmoqda.
  bool get isBusy => this == RoomState.occupied || this == RoomState.reserved;
}

/// Xona xaritasidagi bitta katak (`GET /rooms/` javobi).
class RoomTile extends Equatable {
  const RoomTile({
    required this.id,
    required this.number,
    required this.state,
    required this.floorId,
    required this.branchId,
    this.capacity,
    this.basePrice = 0,
    this.notes,
    this.statusChangedAt,
  });

  final String id;
  final String number;
  final RoomState state;
  final String floorId;
  final String branchId;
  final int? capacity;
  final double basePrice;
  final String? notes;

  /// Xona joriy holatga qachon o'tgani — "2 soatdan beri tozalanmoqda".
  final DateTime? statusChangedAt;

  factory RoomTile.fromJson(Map<String, dynamic> json) => RoomTile(
    id: json['id'] as String,
    number: json['room_number'] as String? ?? '—',
    state: RoomState.fromApi(json['current_status'] as String?),
    floorId: json['floor_id'] as String? ?? '',
    branchId: json['branch_id'] as String? ?? '',
    capacity: (json['capacity'] as num?)?.toInt(),
    basePrice: (json['base_price'] as num?)?.toDouble() ?? 0,
    notes: json['notes'] as String?,
    statusChangedAt: json['status_changed_at'] == null
        ? null
        : DateTime.tryParse(json['status_changed_at'] as String)?.toLocal(),
  );

  RoomTile copyWith({RoomState? state, DateTime? statusChangedAt}) => RoomTile(
    id: id,
    number: number,
    state: state ?? this.state,
    floorId: floorId,
    branchId: branchId,
    capacity: capacity,
    basePrice: basePrice,
    notes: notes,
    statusChangedAt: statusChangedAt ?? this.statusChangedAt,
  );

  @override
  List<Object?> get props => [id, number, state, floorId, statusChangedAt];
}

/// Qavat (`GET /floors/`). Nomi bo'lmasa raqamidan yasaladi.
class FloorInfo extends Equatable {
  const FloorInfo({required this.id, required this.number, this.name});

  final String id;
  final int number;
  final String? name;

  factory FloorInfo.fromJson(Map<String, dynamic> json) => FloorInfo(
    id: json['id'] as String,
    number: (json['floor_number'] as num?)?.toInt() ?? 0,
    name: json['name'] as String?,
  );

  @override
  List<Object?> get props => [id, number, name];
}

/// Xonadagi joriy/kelgusi bron (`GET /rooms/{id}/reservations`).
class RoomStay extends Equatable {
  const RoomStay({
    required this.id,
    required this.number,
    required this.status,
    required this.guestName,
    required this.checkIn,
    required this.checkOut,
    required this.adults,
    required this.totalAmount,
    required this.paidAmount,
    this.guestPhone,
    this.companions = const [],
  });

  final String id;
  final String number;
  final String status;
  final String guestName;
  final String checkIn;
  final String checkOut;
  final int adults;
  final double totalAmount;
  final double paidAmount;
  final String? guestPhone;

  /// Hamrohlar ismlari — ketganlari belgisiz qoladi, faqat ichkaridagilar.
  final List<String> companions;

  bool get isActive => status == 'CHECKED_IN' || status == 'CONFIRMED';

  double get debt =>
      (totalAmount - paidAmount) > 0.009 ? totalAmount - paidAmount : 0;

  factory RoomStay.fromJson(Map<String, dynamic> json) => RoomStay(
    id: json['id'] as String,
    number: json['reservation_number'] as String? ?? '—',
    status: json['status'] as String? ?? '',
    guestName: json['guest_name'] as String? ?? '—',
    checkIn: json['check_in_date'] as String? ?? '',
    checkOut: json['check_out_date'] as String? ?? '',
    adults: (json['adults'] as num?)?.toInt() ?? 1,
    totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
    paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
    guestPhone: json['guest_phone'] as String?,
    companions: [
      for (final c in (json['companions'] as List<dynamic>? ?? const []))
        if (c is Map && c['left_at'] == null && (c['name'] as String?) != null)
          c['name'] as String,
    ],
  );

  @override
  List<Object?> get props => [id, status, guestName, paidAmount];
}
