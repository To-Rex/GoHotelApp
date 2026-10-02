import 'package:equatable/equatable.dart';

/// Moliya yig'masi (`GET /finance/summary`) — mehmonxona bo'yicha, davr uchun.
///
/// Raqamlar SERVERDA hisoblanadi; bu yerda faqat o'qiladi. Sof natija ham
/// serverdagi formula bilan bir xil: tushum − xarajat.
class FinanceSummary extends Equatable {
  const FinanceSummary({
    required this.income,
    required this.paymentCount,
    required this.refunds,
    required this.invoiceTotal,
    required this.invoiceCount,
    required this.debt,
    required this.expenseTotal,
    required this.expenseCount,
    required this.shopTotal,
    required this.shopCount,
    required this.methods,
    this.invoicePaid = 0,
    this.invoiceDiscount = 0,
    this.shopDebt = 0,
    this.expenseCategories = const [],
    this.penaltyTotal = 0,
    this.penaltyCount = 0,
  });

  static const empty = FinanceSummary(
    income: 0,
    paymentCount: 0,
    refunds: 0,
    invoiceTotal: 0,
    invoiceCount: 0,
    debt: 0,
    expenseTotal: 0,
    expenseCount: 0,
    shopTotal: 0,
    shopCount: 0,
    methods: [],
  );

  /// Qabul qilingan pul (qaytarimlar allaqachon ayirilgan).
  final double income;
  final int paymentCount;
  final double refunds;
  final double invoiceTotal;
  final int invoiceCount;

  /// To'lanmagan qoldiq — qarzdorlik.
  final double debt;
  final double expenseTotal;
  final int expenseCount;
  final double shopTotal;
  final int shopCount;

  /// To'lov usullari bo'yicha taqsimot.
  final List<PaymentMethodShare> methods;

  /// Hisob-fakturalar bo'yicha to'langan va berilgan chegirma.
  final double invoicePaid;
  final double invoiceDiscount;

  /// Bronga yozilgan, hali to'lanmagan do'kon savdosi (joriy qoldiq).
  final double shopDebt;

  /// Xarajat toifalari — eng kattasi birinchi.
  final List<ExpenseCategory> expenseCategories;

  /// Davrda yozilgan faol jarimalar (kech chiqish, shikast). Pul bron
  /// qarziga qo'shiladi, to'langanda tushumga kiradi. Eski server
  /// javobida bo'lmasa — nol.
  final double penaltyTotal;
  final int penaltyCount;

  /// Jami tushum: bron to'lovlari + do'kon savdosi.
  double get revenue => income + shopTotal;

  /// Sof natija — veb bilan AYNAN bir formula: tushum + do'kon − xarajat.
  double get net => income + shopTotal - expenseTotal;

  /// Bir to'lovning o'rtacha summasi.
  double get averagePayment => paymentCount == 0 ? 0 : income / paymentCount;

  static double _num(dynamic v) => (v as num?)?.toDouble() ?? 0;
  static int _int(dynamic v) => (v as num?)?.toInt() ?? 0;

  factory FinanceSummary.fromJson(Map<String, dynamic> json) => FinanceSummary(
    income: _num(json['income']),
    paymentCount: _int(json['payment_count']),
    refunds: _num(json['refunds']),
    invoiceTotal: _num(json['invoice_total']),
    invoiceCount: _int(json['invoice_count']),
    debt: _num(json['debt']),
    expenseTotal: _num(json['expense_total']),
    expenseCount: _int(json['expense_count']),
    // Server do'kon tushumini `shop_revenue` / `shop_paid_count` deb
    // yuboradi (eski nomlar ham o'qiladi)
    shopTotal: _num(json['shop_revenue'] ?? json['shop_total']),
    shopCount: _int(json['shop_paid_count'] ?? json['shop_count']),
    methods: _groupMethods(json['methods']),
    invoicePaid: _num(json['invoice_paid']),
    invoiceDiscount: _num(json['invoice_discount']),
    shopDebt: _num(json['shop_debt']),
    expenseCategories: [
      for (final c in (json['expense_categories'] as List<dynamic>? ?? const []))
        if (c is Map<String, dynamic>) ExpenseCategory.fromJson(c),
    ],
    penaltyTotal: _num(json['penalty_total']),
    penaltyCount: _int(json['penalty_count']),
  );

  /// Usullar kanonik guruhlarga yig'iladi: eski kodlar (CREDIT_CARD,
  /// DEBIT_CARD, MOBILE_PAYMENT, TRANSFER) o'z usuliga qo'shiladi — veb
  /// bilan bir xil qoida (`paymentMethods.ts`).
  static List<PaymentMethodShare> _groupMethods(dynamic raw) {
    final totals = <String, double>{};
    final expenses = <String, double>{};
    for (final m in (raw as List<dynamic>? ?? const [])) {
      if (m is! Map<String, dynamic>) continue;
      final share = PaymentMethodShare.fromJson(m);
      totals[share.key] = (totals[share.key] ?? 0) + share.total;
      expenses[share.key] = (expenses[share.key] ?? 0) + share.expense;
    }
    return [
      for (final entry in totals.entries)
        PaymentMethodShare(
          key: entry.key,
          total: entry.value,
          expense: expenses[entry.key] ?? 0,
        ),
    ];
  }

  /// Usul bo'yicha yozuv; shu usulda harakat bo'lmagan bo'lsa — nol.
  PaymentMethodShare method(String key) => methods.firstWhere(
    (m) => m.key == key,
    orElse: () => PaymentMethodShare(key: key, total: 0),
  );

  /// Usullar bo'yicha jami tushum — ulush (foiz) shu songa nisbatan.
  double get methodsTotal =>
      methods.fold<double>(0, (sum, m) => sum + (m.total > 0 ? m.total : 0));

  @override
  List<Object?> get props => [
    income,
    paymentCount,
    refunds,
    debt,
    expenseTotal,
    shopTotal,
    methods,
    expenseCategories,
    penaltyTotal,
    penaltyCount,
  ];
}

/// Xarajat toifasi (`expense_categories[]`).
class ExpenseCategory extends Equatable {
  const ExpenseCategory({
    required this.name,
    required this.total,
    required this.count,
  });

  final String name;
  final double total;
  final int count;

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) => ExpenseCategory(
    name: (json['name'] as String?)?.trim().isNotEmpty == true
        ? (json['name'] as String).trim()
        : 'Boshqa',
    total: (json['total'] as num?)?.toDouble() ?? 0,
    count: (json['count'] as num?)?.toInt() ?? 0,
  );

  @override
  List<Object?> get props => [name, total, count];
}

/// Bitta to'lov usulining tushumdagi ulushi (`methods[]`).
///
/// Server har usul uchun uch manbani beradi: `pay` (bron to'lovlari),
/// `shop` (do'kon savdosi) va `expense` (xarajat). Tushum = pay + shop;
/// xarajat bu yerga kirmaydi — u chiqim.
class PaymentMethodShare extends Equatable {
  const PaymentMethodShare({
    required this.key,
    required this.total,
    this.expense = 0,
  });

  final String key; // cash / card / online / bank_transfer / other

  /// Shu usulda qabul qilingan pul (bron to'lovlari + do'kon).
  final double total;

  /// Shu usulda qilingan xarajat — kassadan chiqqan pul.
  final double expense;

  /// Usul kodini kanonik guruhga keltiradi (eski kodlar bilan birga).
  static String canonical(String? method) =>
      switch ((method ?? '').trim().toUpperCase()) {
        'CASH' => 'cash',
        'CARD' || 'CREDIT_CARD' || 'DEBIT_CARD' => 'card',
        'ONLINE' || 'MOBILE_PAYMENT' => 'online',
        'BANK_TRANSFER' || 'TRANSFER' => 'bank_transfer',
        _ => 'other',
      };

  factory PaymentMethodShare.fromJson(Map<String, dynamic> json) {
    double num_(String field) => (json[field] as num?)?.toDouble() ?? 0;
    final hasSources = json.containsKey('pay') || json.containsKey('shop');
    return PaymentMethodShare(
      key: canonical(json['key'] as String?),
      // Eski/boshqa shakl (`total`) ham o'qiladi — javob o'zgarsa ham
      // chiziq yo'qolib qolmasin
      total: hasSources ? num_('pay') + num_('shop') : num_('total'),
      expense: num_('expense'),
    );
  }

  @override
  List<Object?> get props => [key, total, expense];
}

/// Bir kunlik tushum — 7 kunlik chiziq uchun nuqta.
class IncomeDay extends Equatable {
  const IncomeDay({required this.date, required this.income});

  final DateTime date;
  final double income;

  @override
  List<Object?> get props => [date, income];
}
