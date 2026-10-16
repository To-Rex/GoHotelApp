import 'package:equatable/equatable.dart';

import 'finance_summary.dart';

/// Sessiyada qabul qilingan to'lov usuli (`cash_breakdown.methods` qatori).
///
/// Naqdsiz pul kassaga KIRMAYDI va smenadan smenaga o'tmaydi — bu shu
/// sessiya ko'rsatkichi, shuning uchun har yangi smenada tabiiy 0 dan
/// boshlanadi (naqd kassa kabi).
class ShiftMethodRow extends Equatable {
  const ShiftMethodRow({required this.method, required this.income});

  final String method;

  /// Bron to'lovlari + do'kon savdosi (xarajat alohida).
  final double income;

  factory ShiftMethodRow.fromJson(Map<String, dynamic> json) => ShiftMethodRow(
    method: json['method'] as String? ?? '',
    income:
        (json['income'] as num?)?.toDouble() ??
        ((json['payments'] as num?)?.toDouble() ?? 0) +
            ((json['shop'] as num?)?.toDouble() ?? 0),
  );

  @override
  List<Object?> get props => [method, income];
}

/// Kassa smenasi (`GET /shifts/history` qatori).
///
/// Yopilgan sessiyalarda kassa raqamlari ochiq keladi, ochiqlarida yashirin
/// ("ko'r sanash" qoidasi) — shuning uchun ular ixtiyoriy.
class ShiftSession extends Equatable {
  const ShiftSession({
    required this.id,
    required this.userId,
    required this.status,
    required this.openingCash,
    required this.forceClosed,
    this.userName,
    this.startedAt,
    this.endedAt,
    this.expectedCash,
    this.countedCash,
    this.cashDiff,
    this.notes,
    this.acceptedByName,
    this.closedByName,
    this.methods = const [],
    this.nonCashIncome = 0,
    this.pendingApproval,
  });

  final String id;
  final String userId;
  final String? userName;

  /// ACTIVE / PENDING_HANDOVER / CLOSED
  final String status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final double openingCash;
  final double? expectedCash;
  final double? countedCash;
  final double? cashDiff;
  final bool forceClosed;
  final String? notes;
  final String? acceptedByName;
  final String? closedByName;

  /// To'lov usullari tarkibi — backend uni faqat YOPILGAN sessiyalarga
  /// beradi ("ko'r sanash": ochiq sessiyada kassa raqamlari kabi yashiriladi).
  final List<ShiftMethodRow> methods;

  /// Naqd bo'lmagan turlarda jami qabul qilingan summa.
  final double nonCashIncome;

  /// Tasdiq rejimida topshirilgan sessiya kutayotgani:
  /// "close_cash" (kassa topshirildi) | "end_shift" (smena tugallandi).
  /// Faqat admin/menejer tasdiqlagach sessiya yopiladi.
  final String? pendingApproval;

  bool get isPendingApproval => pendingApproval != null;

  bool get isOpen => status == 'ACTIVE' || status == 'PENDING_HANDOVER';
  bool get isPendingHandover => status == 'PENDING_HANDOVER';

  /// Naqdsiz turlar bo'yicha yig'indi — kanonik usullar (eski kodlar ham
  /// qo'shiladi), faqat summa mavjudlari va barqaror tartibda: karta, online,
  /// o'tkazma, boshqa.
  ///
  /// Yangi smenada ro'yxat BO'SH bo'ladi — "har smenada 0 dan boshlanadi"
  /// qoidasi shu tarzda ko'rinadi (0 qatorlar bilan shovqin qilinmaydi).
  List<PaymentMethodShare> get nonCashMethods {
    final sums = <String, double>{};
    for (final row in methods) {
      final key = PaymentMethodShare.canonical(row.method);
      if (key == 'cash') continue;
      sums[key] = (sums[key] ?? 0) + row.income;
    }
    const order = ['card', 'online', 'bank_transfer', 'other'];
    return [
      for (final key in order)
        if ((sums[key] ?? 0) > 0)
          PaymentMethodShare(key: key, total: sums[key]!),
    ];
  }

  /// Smena qancha davom etgan (ochiq bo'lsa — hozirgacha).
  Duration elapsed(DateTime now) {
    final start = startedAt;
    if (start == null) return Duration.zero;
    final end = endedAt ?? now;
    final d = end.difference(start);
    return d.isNegative ? Duration.zero : d;
  }

  static DateTime? _date(dynamic v) =>
      v is String ? DateTime.tryParse(v)?.toLocal() : null;

  static double? _numOrNull(dynamic v) => (v as num?)?.toDouble();

  factory ShiftSession.fromJson(Map<String, dynamic> json) => ShiftSession(
    id: json['id'] as String,
    userId: json['user_id'] as String? ?? '',
    userName: json['user_name'] as String?,
    status: json['status'] as String? ?? 'CLOSED',
    startedAt: _date(json['started_at']),
    endedAt: _date(json['ended_at']),
    openingCash: (json['opening_cash'] as num?)?.toDouble() ?? 0,
    expectedCash: _numOrNull(json['expected_cash']),
    countedCash: _numOrNull(json['counted_cash']),
    cashDiff: _numOrNull(json['cash_diff']),
    forceClosed: json['force_closed'] as bool? ?? false,
    notes: json['notes'] as String?,
    acceptedByName: json['accepted_by_name'] as String?,
    closedByName: json['closed_by_name'] as String?,
    methods: ((json['methods'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ShiftMethodRow.fromJson)
        .toList(),
    nonCashIncome: (json['non_cash_income'] as num?)?.toDouble() ?? 0,
    pendingApproval: json['pending_approval'] as String?,
  );

  @override
  List<Object?> get props => [id, status, endedAt, countedCash, cashDiff];
}
