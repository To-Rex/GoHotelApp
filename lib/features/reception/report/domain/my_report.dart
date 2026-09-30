import 'package:equatable/equatable.dart';

/// Xodimning shaxsiy hisoboti (`GET /api/v1/reports/my-summary`).
///
/// Barcha raqamlar SERVERDA hisoblanadi va bu yerda qayta hisoblanmaydi:
/// "tushum" va "sof natija" ta'rifi bitta joyda turishi kerak, aks holda
/// veb va mobil bir xil kunga ikki xil raqam ko'rsatib qo'yardi.
class MyReport extends Equatable {
  const MyReport({
    required this.dateFrom,
    required this.dateTo,
    required this.reservationCount,
    required this.cancelledCount,
    required this.reservationTotal,
    required this.paymentsTotal,
    required this.paymentsCash,
    required this.refunds,
    required this.shopTotal,
    required this.shopCount,
    required this.shopUnpaidTotal,
    required this.expenseTotal,
    required this.expenseCount,
    required this.incomeTotal,
    required this.netTotal,
    required this.netCash,
    required this.incomeByMethod,
  });

  final String dateFrom;
  final String dateTo;

  final int reservationCount;
  final int cancelledCount;
  final double reservationTotal;

  /// Xodim HAQIQATDA qabul qilgan pul — qaytarimlar allaqachon ayirilgan.
  final double paymentsTotal;
  final double paymentsCash;
  final double refunds;

  final double shopTotal;
  final int shopCount;

  /// Bronga yozilgan, hali to'lanmagan do'kon savdosi.
  final double shopUnpaidTotal;

  final double expenseTotal;
  final int expenseCount;

  /// Bron to'lovlari + do'kon savdosi.
  final double incomeTotal;

  /// Tushum − xarajat. Manfiy bo'lishi mumkin.
  final double netTotal;
  final double netCash;

  /// Usul kodi -> summa ("cash", "card", "online", "bank_transfer", "other").
  final Map<String, double> incomeByMethod;

  bool get netPositive => netTotal >= 0;

  static double _num(dynamic value) => (value as num?)?.toDouble() ?? 0;
  static int _int(dynamic value) => (value as num?)?.toInt() ?? 0;

  static Map<String, dynamic> _obj(Map<String, dynamic> json, String key) =>
      (json[key] as Map<String, dynamic>?) ?? const {};

  factory MyReport.fromJson(Map<String, dynamic> json) {
    final reservations = _obj(json, 'reservations');
    final payments = _obj(json, 'payments');
    final shop = _obj(json, 'shop');
    final expenses = _obj(json, 'expenses');
    final income = _obj(json, 'income');
    final net = _obj(json, 'net');
    final byMethod = (income['by_method'] as Map<String, dynamic>?) ?? const {};

    return MyReport(
      dateFrom: json['date_from'] as String? ?? '',
      dateTo: json['date_to'] as String? ?? '',
      reservationCount: _int(reservations['count']),
      cancelledCount: _int(reservations['cancelled_count']),
      reservationTotal: _num(reservations['total_amount']),
      paymentsTotal: _num(payments['total']),
      paymentsCash: _num(
        (payments['by_method'] as Map<String, dynamic>?)?['cash'],
      ),
      refunds: _num(payments['refunds']),
      shopTotal: _num(shop['total']),
      shopCount: _int(shop['count']),
      shopUnpaidTotal: _num(shop['unpaid_total']),
      expenseTotal: _num(expenses['total']),
      expenseCount: _int(expenses['count']),
      incomeTotal: _num(income['total']),
      netTotal: _num(net['total']),
      netCash: _num(json['net_cash']),
      incomeByMethod: {
        for (final entry in byMethod.entries) entry.key: _num(entry.value),
      },
    );
  }

  @override
  List<Object?> get props => [dateFrom, dateTo, incomeTotal, netTotal];
}
