import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gohotels/core/widgets/debt_reasons.dart';
import 'package:gohotels/l10n/gen/app_localizations.dart';

/// Qarz sababi: nima uchun qarz — mobil ilovada ham aniq ko'rinsin.
void main() {
  test('server javobi o\'qiladi, eski shakl buzilmaydi', () {
    final debt = BookingDebt.fromJson({
      'total_debt': 74000,
      'projected': true,
      'status': 'CHECKED_IN',
      'acknowledged': {'note': 'ertaga'},
      'items': [
        {'kind': 'penalty', 'amount': 50000, 'charged': 50000, 'penalty_kind': 'LATE_CHECKOUT', 'note': '1 soat'},
        {'kind': 'shop', 'amount': 24000, 'products': 'Cola ×2'},
        'noto\'g\'ri element',
      ],
    });
    expect(debt.hasDebt, isTrue);
    expect(debt.projected, isTrue);
    expect(debt.ackNote, 'ertaga');
    expect(debt.items.length, 2);
    expect(debt.items.first.penaltyKind, 'LATE_CHECKOUT');
    expect(BookingDebt.fromJson({}).hasDebt, isFalse);
    expect(DebtReason.listFrom(null), isEmpty);
  });

  test('har uchala tilda sarlavha', () async {
    final uz = await S.delegate.load(const Locale('uz'));
    final ru = await S.delegate.load(const Locale('ru'));
    const penalty = DebtReason(kind: 'penalty', amount: 1, penaltyKind: 'DAMAGE', note: 'stakan');
    expect(debtReasonTitle(uz, penalty), 'Jarima (shikast, stakan)');
    expect(debtReasonTitle(ru, penalty), 'Штраф (ущерб, stakan)');
    expect(debtReasonTitle(uz, const DebtReason(kind: 'room', amount: 1, roomNumber: '101')), 'Turar joy (101-xona)');
    expect(debtReasonTitle(uz, const DebtReason(kind: 'shop', amount: 1)), "Do'kon");
    expect(debtReasonTitle(uz, const DebtReason(kind: 'extension', amount: 1)), contains('uzaytirilgan'));
  });
}
