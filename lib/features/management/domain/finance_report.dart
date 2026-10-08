import 'package:equatable/equatable.dart';

import '../../../core/debt/debt_reason.dart';

import 'shift_session.dart';

/// Moliya sahifasining davri: bugun, kecha, 7 kun, shu oy yoki ixtiyoriy.
enum FinanceRangeKind { today, yesterday, week, month, custom }

/// Tanlangan davr — kunlar MAHALLIY sana bo'yicha, ikkala chet ham kiradi.
class FinanceRange extends Equatable {
  const FinanceRange._(this.kind, this.from, this.to);

  final FinanceRangeKind kind;
  final DateTime from;
  final DateTime to;

  static DateTime _day(DateTime v) => DateTime(v.year, v.month, v.day);

  factory FinanceRange.of(FinanceRangeKind kind, DateTime now) {
    final today = _day(now);
    return switch (kind) {
      FinanceRangeKind.today => FinanceRange._(kind, today, today),
      FinanceRangeKind.yesterday => FinanceRange._(
        kind,
        DateTime(today.year, today.month, today.day - 1),
        DateTime(today.year, today.month, today.day - 1),
      ),
      FinanceRangeKind.week => FinanceRange._(
        kind,
        DateTime(today.year, today.month, today.day - 6),
        today,
      ),
      FinanceRangeKind.month => FinanceRange._(
        kind,
        DateTime(today.year, today.month, 1),
        today,
      ),
      // Ixtiyoriy davr [FinanceRange.custom] bilan yaratiladi
      FinanceRangeKind.custom => FinanceRange._(kind, today, today),
    };
  }

  /// Ixtiyoriy davr: chetlar tartibi muhim emas, vaqt qismi tashlanadi.
  factory FinanceRange.custom(DateTime a, DateTime b) {
    final x = _day(a);
    final y = _day(b);
    return x.isAfter(y)
        ? FinanceRange._(FinanceRangeKind.custom, y, x)
        : FinanceRange._(FinanceRangeKind.custom, x, y);
  }

  /// Davrdagi kunlar soni (bir kunlik davr — 1).
  int get days => DateTime.utc(to.year, to.month, to.day)
          .difference(DateTime.utc(from.year, from.month, from.day))
          .inDays +
      1;

  bool get isSingleDay => days == 1;

  /// Solishtirish uchun oldingi davr.
  ///
  /// "Shu oy" — o'tgan oyning AYNAN shu kunlari (1–15 oktabr ↔ 1–15
  /// sentabr), aks holda oy boshini oy oxiri bilan solishtirib qo'yardik.
  /// Qolganlari — xuddi shuncha kunlik, darhol oldingi oraliq.
  FinanceRange previous() {
    if (kind == FinanceRangeKind.month) {
      final start = DateTime(from.year, from.month - 1, 1);
      final lastDay = DateTime(from.year, from.month, 0).day;
      final endDay = to.day > lastDay ? lastDay : to.day;
      return FinanceRange._(
        kind,
        start,
        DateTime(start.year, start.month, endDay),
      );
    }
    final end = DateTime(from.year, from.month, from.day - 1);
    final start = DateTime(end.year, end.month, end.day - (days - 1));
    return FinanceRange._(kind, start, end);
  }

  bool contains(DateTime moment) {
    final d = _day(moment);
    return !d.isBefore(from) && !d.isAfter(to);
  }

  @override
  List<Object?> get props => [kind, from, to];
}

/// Bir kunlik qator (`GET /finance/daily`).
class FinanceDay extends Equatable {
  const FinanceDay({
    required this.date,
    required this.income,
    required this.paymentCount,
    required this.refunds,
    required this.expense,
    required this.shop,
  });

  final DateTime date;

  /// Bron to'lovlari (qaytarimlar ayirilgan).
  final double income;
  final int paymentCount;
  final double refunds;
  final double expense;

  /// Do'kon savdosi (to'langan kuni).
  final double shop;

  /// Jami tushum: bron to'lovlari + do'kon (veb bilan bir xil).
  double get revenue => income + shop;

  static double _num(dynamic v) => (v as num?)?.toDouble() ?? 0;

  factory FinanceDay.fromJson(Map<String, dynamic> json) {
    final raw = json['date'] as String? ?? '';
    final parsed = DateTime.tryParse(raw) ?? DateTime(1970);
    return FinanceDay(
      date: DateTime(parsed.year, parsed.month, parsed.day),
      income: _num(json['income']),
      paymentCount: (json['payment_count'] as num?)?.toInt() ?? 0,
      refunds: _num(json['refunds']),
      expense: _num(json['expense']),
      shop: _num(json['shop']),
    );
  }

  @override
  List<Object?> get props => [date, income, expense, shop];
}

/// Grafik ustuni: bir kun yoki (uzun davrda) bir hafta.
class ChartBucket extends Equatable {
  const ChartBucket({
    required this.start,
    required this.end,
    required this.revenue,
    required this.expense,
  });

  final DateTime start;
  final DateTime end;
  final double revenue;
  final double expense;

  bool get isSingleDay => start == end;

  @override
  List<Object?> get props => [start, end, revenue, expense];
}

/// Kunlarni grafik ustunlariga yig'adi: 62 kungacha — har kun alohida,
/// undan uzunida — haftalab (aks holda ustunlar ko'rinmas darajada
/// ingichka bo'lardi).
List<ChartBucket> chartBuckets(List<FinanceDay> days, {int maxDaily = 62}) {
  if (days.isEmpty) return const [];
  if (days.length <= maxDaily) {
    return [
      for (final d in days)
        ChartBucket(start: d.date, end: d.date, revenue: d.revenue, expense: d.expense),
    ];
  }
  final out = <ChartBucket>[];
  for (var i = 0; i < days.length; i += 7) {
    final chunk = days.sublist(i, (i + 7).clamp(0, days.length));
    out.add(
      ChartBucket(
        start: chunk.first.date,
        end: chunk.last.date,
        revenue: chunk.fold(0, (s, d) => s + d.revenue),
        expense: chunk.fold(0, (s, d) => s + d.expense),
      ),
    );
  }
  return out;
}

/// Ochiq kassa — ishlayotgan yoki topshirilayotgan smena
/// (`GET /shifts/cash-overview`).
class CashDrawer extends Equatable {
  const CashDrawer({
    required this.id,
    required this.status,
    required this.openingCash,
    required this.paymentsCash,
    required this.shopCash,
    required this.expensesCash,
    required this.expectedCash,
    this.userName,
    this.branchName,
    this.startedAt,
    this.countedCash,
  });

  final String id;
  final String? userName;
  final String? branchName;
  final String status;
  final DateTime? startedAt;
  final double openingCash;
  final double paymentsCash;
  final double shopCash;
  final double expensesCash;

  /// Hozir kassada bo'lishi kerak bo'lgan summa.
  final double expectedCash;

  /// Topshirilayotgan smenada xodim sanab kiritgan summa.
  final double? countedCash;

  bool get isPendingHandover => status == 'PENDING_HANDOVER';

  /// Sanalgan − kutilgan (faqat topshirilayotganda).
  double? get diff => countedCash == null ? null : countedCash! - expectedCash;

  static double _num(dynamic v) => (v as num?)?.toDouble() ?? 0;

  factory CashDrawer.fromJson(Map<String, dynamic> json) => CashDrawer(
    id: json['id'] as String? ?? '',
    userName: json['user_name'] as String?,
    branchName: json['branch_name'] as String?,
    status: json['status'] as String? ?? 'ACTIVE',
    startedAt: json['started_at'] is String
        ? DateTime.tryParse(json['started_at'] as String)?.toLocal()
        : null,
    openingCash: _num(json['opening_cash']),
    paymentsCash: _num(json['payments_cash']),
    shopCash: _num(json['shop_cash']),
    expensesCash: _num(json['expenses_cash']),
    expectedCash: _num(json['expected_cash']),
    countedCash: (json['counted_cash'] as num?)?.toDouble(),
  );

  @override
  List<Object?> get props => [id, status, expectedCash, countedCash];
}

class CashOverview extends Equatable {
  const CashOverview({
    required this.mode,
    required this.drawers,
    required this.totalExpected,
  });

  /// `cash` — kassa smenalari yuritiladi; `simple` — yo'q.
  final String mode;
  final List<CashDrawer> drawers;
  final double totalExpected;

  bool get isCashMode => mode == 'cash';
  int get activeCount => drawers.where((d) => !d.isPendingHandover).length;
  int get pendingCount => drawers.where((d) => d.isPendingHandover).length;

  factory CashOverview.fromJson(Map<String, dynamic> json) => CashOverview(
    mode: json['mode'] as String? ?? 'simple',
    drawers: [
      for (final d in (json['sessions'] as List<dynamic>? ?? const []))
        if (d is Map<String, dynamic>) CashDrawer.fromJson(d),
    ],
    totalExpected: (json['total_expected'] as num?)?.toDouble() ?? 0,
  );

  @override
  List<Object?> get props => [mode, drawers, totalExpected];
}

/// Qarzdor bron (`GET /finance/debtors` → `items`).
///
/// `reasons` — qarzning SABABI (to'lanmagan haqlar). Eski server bu
/// maydonlarni yubormaydi — ro'yxat bo'sh qoladi.
class DebtorItem extends Equatable {
  const DebtorItem({
    required this.id,
    required this.debt,
    this.guestName,
    this.roomNumber,
    this.reservationNumber,
    this.checkOut,
    this.reasons = const [],
    this.overdueDays,
    this.ackNote,
    this.status,
  });

  final String id;
  final String? guestName;
  final String? roomNumber;
  final String? reservationNumber;
  final DateTime? checkOut;
  final double debt;
  final List<DebtReason> reasons;

  /// Chiqib ketganidan beri necha kun to'lanmagan.
  final int? overdueDays;

  /// Qarz bilan chiqarilgan bo'lsa — sababi.
  final String? ackNote;
  final String? status;

  factory DebtorItem.fromJson(Map<String, dynamic> json) => DebtorItem(
    id: '${json['id'] ?? ''}',
    guestName: json['guest_name'] as String?,
    roomNumber: json['room_number']?.toString(),
    reservationNumber: json['reservation_number'] as String?,
    checkOut: json['check_out_date'] is String
        ? DateTime.tryParse(json['check_out_date'] as String)
        : null,
    debt: (json['debt_amount'] as num?)?.toDouble() ?? 0,
    reasons: DebtReason.listFrom(json['reasons']),
    overdueDays: (json['overdue_days'] as num?)?.toInt(),
    ackNote: (json['acknowledged'] is Map<String, dynamic>)
        ? (json['acknowledged'] as Map<String, dynamic>)['note'] as String?
        : null,
    status: json['status'] as String?,
  );

  @override
  List<Object?> get props => [id, debt, reasons.length, overdueDays, ackNote];
}

class DebtorsReport extends Equatable {
  const DebtorsReport({
    required this.count,
    required this.totalDebt,
    required this.items,
  });

  static const empty = DebtorsReport(count: 0, totalDebt: 0, items: []);

  final int count;
  final double totalDebt;

  /// Eng katta qarz birinchi.
  final List<DebtorItem> items;

  factory DebtorsReport.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? const {};
    final items = [
      for (final i in (json['items'] as List<dynamic>? ?? const []))
        if (i is Map<String, dynamic>) DebtorItem.fromJson(i),
    ]..sort((a, b) => b.debt.compareTo(a.debt));
    return DebtorsReport(
      count: (summary['count'] as num?)?.toInt() ?? items.length,
      totalDebt: (summary['total_debt'] as num?)?.toDouble() ?? 0,
      items: items,
    );
  }

  @override
  List<Object?> get props => [count, totalDebt, items];
}

/// Davrda yopilgan smenalar bo'yicha kassa farqlari.
class ShiftDiffSummary extends Equatable {
  const ShiftDiffSummary({
    required this.closed,
    required this.shortage,
    required this.surplus,
  });

  /// Davrda yopilgan smenalar (eng yangisi birinchi).
  final List<ShiftSession> closed;

  /// Kamomad yig'indisi (musbat son sifatida).
  final double shortage;

  /// Ortiqcha yig'indisi.
  final double surplus;

  factory ShiftDiffSummary.of(List<ShiftSession> sessions, FinanceRange range) {
    final closed = sessions
        .where((s) => s.status == 'CLOSED' && s.endedAt != null && range.contains(s.endedAt!))
        .toList()
      ..sort((a, b) => b.endedAt!.compareTo(a.endedAt!));
    var shortage = 0.0;
    var surplus = 0.0;
    for (final s in closed) {
      final diff = s.cashDiff ?? 0;
      if (diff < 0) shortage += -diff;
      if (diff > 0) surplus += diff;
    }
    return ShiftDiffSummary(closed: closed, shortage: shortage, surplus: surplus);
  }

  @override
  List<Object?> get props => [closed, shortage, surplus];
}

/// O'zgarish ulushi: 0.12 — 12% o'sish. Oldingi davr nol bo'lsa — `null`
/// (foiz ma'nosiz).
double? changeRatio(double current, double previous) {
  if (previous == 0) return null;
  return (current - previous) / previous.abs();
}
