import 'package:equatable/equatable.dart';

/// Smena yakunida kassadagi pul qayerga ketgani (`GET /shifts/handovers`,
/// backend: `handover_kind`).
enum HandoverKind {
  /// Keyingi xodim qabul qildi — summa uning boshlang'ich kassasi.
  handover,

  /// Topshirildi, qabul qilinishi kutilmoqda.
  pending,

  /// Kassa topshirildi (kunlik kesim): pul kassadan chiqdi.
  cashOut,

  /// Majburiy yopildi va pulni rahbar oldi.
  forceTaken;

  static HandoverKind parse(String? raw) => switch (raw) {
    'HANDOVER' => HandoverKind.handover,
    'PENDING' => HandoverKind.pending,
    'FORCE_TAKEN' => HandoverKind.forceTaken,
    _ => HandoverKind.cashOut,
  };

  /// Pul keyingi smenaga o'tadimi (o'tdi yoki o'tishi kutilmoqda).
  bool get passesOn => this == HandoverKind.handover || this == HandoverKind.pending;
}

/// Bitta topshirilgan kassa: kimdan kimga, qancha, kutilgan va farq.
class ShiftHandover extends Equatable {
  const ShiftHandover({
    required this.id,
    required this.kind,
    this.fromName,
    this.toName,
    this.closedByName,
    this.branchName,
    this.endedAt,
    this.acceptedAt,
    this.expectedCash,
    this.countedCash,
    this.cashDiff,
    this.forceClosed = false,
    this.corrected = false,
    this.receivedOpeningCash,
  });

  final String id;
  final HandoverKind kind;
  final String? fromName;
  final String? toName;
  final String? closedByName;
  final String? branchName;
  final DateTime? endedAt;
  final DateTime? acceptedAt;
  final double? expectedCash;

  /// Sanab topshirilgan summa — keyingi smenaga o'tgan (yoki olingan) pul.
  final double? countedCash;
  final double? cashDiff;
  final bool forceClosed;
  final bool corrected;

  /// Qabul qiluvchining yangi sessiyasi boshlang'ich kassasi.
  final double? receivedOpeningCash;

  /// Qabul qiluvchi boshqa summa bilan boshlagan bo'lsa — farq (masalan
  /// sanalgan summa keyin tuzatilgan). Aks holda `null`.
  double? get mismatch {
    if (kind != HandoverKind.handover) return null;
    if (receivedOpeningCash == null || countedCash == null) return null;
    final diff = receivedOpeningCash! - countedCash!;
    return diff.abs() >= 1 ? diff : null;
  }

  static DateTime? _date(dynamic v) =>
      v is String ? DateTime.tryParse(v)?.toLocal() : null;
  static double? _num(dynamic v) => (v as num?)?.toDouble();

  factory ShiftHandover.fromJson(Map<String, dynamic> json) => ShiftHandover(
    id: json['id'] as String? ?? '',
    kind: HandoverKind.parse(json['kind'] as String?),
    fromName: json['from_user_name'] as String?,
    toName: json['to_user_name'] as String?,
    closedByName: json['closed_by_name'] as String?,
    branchName: json['branch_name'] as String?,
    endedAt: _date(json['ended_at']),
    acceptedAt: _date(json['accepted_at']),
    expectedCash: _num(json['expected_cash']),
    countedCash: _num(json['counted_cash']),
    cashDiff: _num(json['cash_diff']),
    forceClosed: json['force_closed'] == true,
    corrected: json['corrected'] == true,
    receivedOpeningCash: _num(json['received_opening_cash']),
  );

  @override
  List<Object?> get props => [id, kind, countedCash, cashDiff, toName, acceptedAt, corrected];
}

/// Davrdagi pul harakati va jamlanmasi.
class HandoverReport extends Equatable {
  const HandoverReport({
    required this.items,
    this.handedOverTotal = 0,
    this.handedOverCount = 0,
    this.takenOutTotal = 0,
    this.takenOutCount = 0,
    this.pendingTotal = 0,
    this.pendingCount = 0,
  });

  static const empty = HandoverReport(items: []);

  /// Eng yangisi birinchi (server tartibi).
  final List<ShiftHandover> items;

  /// Keyingi smenaga o'tgan pul.
  final double handedOverTotal;
  final int handedOverCount;

  /// Kassadan olingan pul (kunlik kesim va majburiy yopish).
  final double takenOutTotal;
  final int takenOutCount;

  /// Qabul kutilayotgan pul.
  final double pendingTotal;
  final int pendingCount;

  factory HandoverReport.fromJson(Map<String, dynamic> json) {
    final s = json['summary'] is Map<String, dynamic>
        ? json['summary'] as Map<String, dynamic>
        : const <String, dynamic>{};
    double n(String k) => (s[k] as num?)?.toDouble() ?? 0;
    int i(String k) => (s[k] as num?)?.toInt() ?? 0;
    return HandoverReport(
      items: [
        for (final item in (json['items'] as List<dynamic>? ?? const []))
          if (item is Map<String, dynamic>) ShiftHandover.fromJson(item),
      ],
      handedOverTotal: n('handed_over_total'),
      handedOverCount: i('handed_over_count'),
      takenOutTotal: n('taken_out_total'),
      takenOutCount: i('taken_out_count'),
      pendingTotal: n('pending_total'),
      pendingCount: i('pending_count'),
    );
  }

  @override
  List<Object?> get props => [items, handedOverTotal, takenOutTotal, pendingTotal];
}
