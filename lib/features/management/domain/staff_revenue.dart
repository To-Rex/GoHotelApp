import 'package:equatable/equatable.dart';

import 'finance_summary.dart';

/// Davr tushumi xodimlar kesimida (`GET /finance/by-staff`).
///
/// Pul yozuvning o'zidan bog'lanadi: to'lovni kim kiritgan, do'kon
/// savdosini kim qilgan, xarajatni kim yozgan ("Mening hisobotim" va smena
/// kassasi bilan bir xil). Sana ta'rifi `/finance/summary` bilan bir xil —
/// xodimlar tushumi yig'indisi "Jami tushum" ga teng.
class StaffRevenue extends Equatable {
  const StaffRevenue({
    required this.userId,
    required this.name,
    required this.revenue,
    required this.income,
    required this.paymentCount,
    required this.shop,
    required this.shopCount,
    this.userType,
    this.active = true,
    this.refunds = 0,
    this.cash = 0,
    this.expense = 0,
    this.expenseCount = 0,
    this.cashExpense = 0,
    this.methods = const [],
  });

  final String? userId;

  /// Xodim ismi; topilmasa — `null` (sahifada "Noma'lum xodim").
  final String? name;
  final String? userType;

  /// Ishdan ketgan / bloklangan xodim ham ro'yxatda qoladi (pul olgan).
  final bool active;

  /// Jami tushum: bron to'lovlari + do'kon.
  final double revenue;

  /// Bron to'lovlari (qaytarimlar ayirilgan).
  final double income;
  final int paymentCount;
  final double refunds;
  final double shop;
  final int shopCount;

  /// Naqd olingan pul (bron + do'kon).
  final double cash;
  final double expense;
  final int expenseCount;

  /// Naqd xarajat — kassadan chiqqan pul.
  final double cashExpense;

  /// Usullar bo'yicha (kanonik guruh: cash / card / online /
  /// bank_transfer / other) — eng kattasi birinchi.
  final List<PaymentMethodShare> methods;

  /// Shu xodim kassasiga qolgan naqd: naqd tushum − naqd xarajat.
  double get cashNet => cash - cashExpense;

  bool get isAdmin => userType == 'ADMIN' || userType == 'SUPER_ADMIN';

  static double _num(dynamic v) => (v as num?)?.toDouble() ?? 0;
  static int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

  factory StaffRevenue.fromJson(Map<String, dynamic> json) {
    final totals = <String, double>{};
    for (final m in (json['methods'] as List<dynamic>? ?? const [])) {
      if (m is! Map<String, dynamic>) continue;
      final key = PaymentMethodShare.canonical(m['key'] as String?);
      totals[key] = (totals[key] ?? 0) + _num(m['pay']) + _num(m['shop']);
    }
    final methods = [
      for (final e in totals.entries)
        if (e.value != 0) PaymentMethodShare(key: e.key, total: e.value),
    ]..sort((a, b) => b.total.compareTo(a.total));
    final name = (json['name'] as String?)?.trim();
    final income = _num(json['income']);
    final shop = _num(json['shop']);
    return StaffRevenue(
      userId: json['user_id'] as String?,
      name: name == null || name.isEmpty ? null : name,
      userType: json['user_type'] as String?,
      active: (json['status'] as String? ?? 'ACTIVE') == 'ACTIVE',
      // Eski/boshqa javobda `revenue` bo'lmasa — qismlardan
      revenue: json.containsKey('revenue') ? _num(json['revenue']) : income + shop,
      income: income,
      paymentCount: _int(json['payment_count']),
      refunds: _num(json['refunds']),
      shop: shop,
      shopCount: _int(json['shop_count']),
      cash: _num(json['cash']),
      expense: _num(json['expense']),
      expenseCount: _int(json['expense_count']),
      cashExpense: _num(json['cash_expense']),
      methods: methods,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    name,
    userType,
    active,
    revenue,
    income,
    paymentCount,
    refunds,
    shop,
    shopCount,
    cash,
    expense,
    expenseCount,
    cashExpense,
    methods,
  ];
}

class StaffRevenueReport extends Equatable {
  const StaffRevenueReport({required this.items});

  static const empty = StaffRevenueReport(items: []);

  /// Eng ko'p tushum olgan birinchi (server tartibi).
  final List<StaffRevenue> items;

  /// Tushum olgan xodimlar (faqat xarajat qilganlar hisobga kirmaydi).
  List<StaffRevenue> get earners => [
    for (final i in items)
      if (i.revenue != 0 || i.paymentCount > 0 || i.shopCount > 0) i,
  ];

  double get totalRevenue => items.fold<double>(0, (s, i) => s + i.revenue);

  /// Xodimning jami tushumdagi ulushi (0..1). Jami nol yoki manfiy — 0.
  double shareOf(StaffRevenue item) {
    final total = totalRevenue;
    if (total <= 0 || item.revenue <= 0) return 0;
    return (item.revenue / total).clamp(0, 1).toDouble();
  }

  factory StaffRevenueReport.fromJson(Map<String, dynamic> json) =>
      StaffRevenueReport(
        items: [
          for (final i in (json['items'] as List<dynamic>? ?? const []))
            if (i is Map<String, dynamic>) StaffRevenue.fromJson(i),
        ],
      );

  @override
  List<Object?> get props => [items];
}
