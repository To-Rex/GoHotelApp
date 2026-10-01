import 'package:equatable/equatable.dart';

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

  bool get isOpen => status == 'ACTIVE' || status == 'PENDING_HANDOVER';
  bool get isPendingHandover => status == 'PENDING_HANDOVER';

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
  );

  @override
  List<Object?> get props => [id, status, endedAt, countedCash, cashDiff];
}
