/// Qarzning SABABI — to'lanmagan haq (`GET /finance/debtors` → `reasons`,
/// `GET /reservations/{id}/debt` → `items`).
///
/// To'lovlar haqlarni vaqt tartibida yopadi; yopilmay qolgan qismi —
/// sabab: turar joy, chiqishda qayta hisob (uzaytirilgan muddat), xizmat,
/// jarima yoki do'kon. Hisob serverda (`debt_service`).
class DebtReason {
  const DebtReason({
    required this.kind,
    required this.amount,
    this.charged = 0,
    this.roomNumber,
    this.penaltyKind,
    this.note,
    this.name,
    this.products,
  });

  final String kind;

  /// To'lanmagan qismi.
  final double amount;
  final double charged;
  final String? roomNumber;
  final String? penaltyKind;
  final String? note;
  final String? name;
  final String? products;

  factory DebtReason.fromJson(Map<String, dynamic> json) => DebtReason(
    kind: '${json['kind'] ?? ''}',
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    charged: (json['charged'] as num?)?.toDouble() ?? 0,
    roomNumber: json['room_number']?.toString(),
    penaltyKind: json['penalty_kind'] as String?,
    note: json['note'] as String?,
    name: json['name'] as String?,
    products: json['products'] as String?,
  );

  static List<DebtReason> listFrom(Object? raw) => [
    for (final item in (raw is List ? raw : const []))
      if (item is Map<String, dynamic>) DebtReason.fromJson(item),
  ];
}

/// Bron hisob varag'i (`GET /reservations/{id}/debt`): jami qarz (bron +
/// do'kon) va uning sabablari.
class BookingDebt {
  const BookingDebt({
    required this.totalDebt,
    required this.items,
    this.projected = false,
    this.ackNote,
    this.status,
  });

  final double totalDebt;
  final List<DebtReason> items;

  /// Uzaytirilgan muddat — summa chiqishda qayta hisoblanadi.
  final bool projected;
  final String? ackNote;
  final String? status;

  bool get hasDebt => totalDebt > 0.5;

  factory BookingDebt.fromJson(Map<String, dynamic> json) => BookingDebt(
    totalDebt: (json['total_debt'] as num?)?.toDouble() ?? 0,
    items: DebtReason.listFrom(json['items']),
    projected: json['projected'] == true,
    ackNote: (json['acknowledged'] is Map<String, dynamic>)
        ? (json['acknowledged'] as Map<String, dynamic>)['note'] as String?
        : null,
    status: json['status'] as String?,
  );
}
