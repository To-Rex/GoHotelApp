import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gohotels/app/theme/app_theme.dart';
import 'package:gohotels/core/network/api_exception.dart';
import 'package:gohotels/features/management/data/management_repository.dart';
import 'package:gohotels/features/management/domain/finance_report.dart';
import 'package:gohotels/features/management/domain/finance_summary.dart';
import 'package:gohotels/features/management/domain/shift_session.dart';
import 'package:gohotels/features/management/presentation/cubit/finance_cubit.dart';
import 'package:gohotels/features/management/presentation/pages/finance_page.dart';
import 'package:gohotels/features/management/presentation/widgets/finance_bar_chart.dart';
import 'package:gohotels/l10n/gen/app_localizations.dart';

/// Moliya sahifasi (admin/menejer): davrlar, oldingi davr bilan
/// solishtirish, kassada hozir qancha pul, grafik, qarzdorlar, smenalar.

final _now = DateTime(2026, 10, 15, 14, 30);

FinanceSummary _summary({double income = 4500000, double shop = 350000}) => FinanceSummary.fromJson({
  'income': income,
  'payment_count': 18,
  'refunds': 120000,
  'invoice_total': 6200000,
  'invoice_count': 21,
  'invoice_discount': 250000,
  'debt': 1700000,
  'expense_total': 980000,
  'expense_count': 7,
  'shop_revenue': shop,
  'shop_paid_count': 9,
  'shop_debt': 85000,
  'penalty_total': 200000,
  'penalty_count': 2,
  'expense_categories': [
    {'name': 'Kommunal xizmatlar va internet to\'lovlari', 'total': 600000, 'count': 2},
    {'name': 'Tozalash vositalari', 'total': 380000, 'count': 5},
  ],
  'methods': [
    {'key': 'CASH', 'pay': 2500000, 'shop': 300000, 'expense': 700000},
    {'key': 'CARD', 'pay': 1500000, 'shop': 50000, 'expense': 0},
    {'key': 'ONLINE', 'pay': 500000, 'shop': 0, 'expense': 280000},
  ],
});

class _Repo extends Fake implements ManagementRepository {
  _Repo({this.mode = 'cash', this.cashForbidden = false});

  final String mode;
  final bool cashForbidden;
  final summaryCalls = <(DateTime, DateTime)>[];
  int dailyCalls = 0;

  @override
  Future<FinanceSummary> getFinanceSummary({required DateTime from, required DateTime to}) async {
    summaryCalls.add((from, to));
    // Oldingi davr — kamroq tushum (o'sish ko'rinsin)
    return summaryCalls.length.isEven ? _summary(income: 3800000) : _summary();
  }

  @override
  Future<List<FinanceDay>> getFinanceDaily({required DateTime from, required DateTime to}) async {
    dailyCalls++;
    final days = FinanceRange.custom(from, to).days;
    return [
      for (var i = 0; i < days; i++)
        FinanceDay(
          date: DateTime(from.year, from.month, from.day + i),
          income: (i % 4 + 1) * 400000.0,
          paymentCount: i % 3,
          refunds: 0,
          expense: i.isEven ? 150000 : 0,
          shop: 20000,
        ),
    ];
  }

  @override
  Future<CashOverview> getCashOverview() async {
    if (cashForbidden) {
      throw const ApiException(message: 'no', statusCode: 403, code: 'FORBIDDEN');
    }
    return CashOverview.fromJson({
      'mode': mode,
      'total_expected': mode == 'cash' ? 3480000 : 0,
      'sessions': mode != 'cash'
          ? []
          : [
              {
                'id': 's1',
                'user_name': 'Abdurahmon Abdurahmonov-Toshpoʻlatov',
                'branch_name': 'Markaziy filial — Chilonzor',
                'status': 'ACTIVE',
                'started_at': _now.subtract(const Duration(hours: 6)).toUtc().toIso8601String(),
                'opening_cash': 500000,
                'payments_cash': 2300000,
                'shop_cash': 150000,
                'expenses_cash': 220000,
                'expected_cash': 2730000,
              },
              {
                'id': 's2',
                'user_name': 'Dilnoza Karimova',
                'branch_name': 'Yunusobod',
                'status': 'PENDING_HANDOVER',
                'started_at': _now.subtract(const Duration(hours: 9)).toUtc().toIso8601String(),
                'opening_cash': 100000,
                'payments_cash': 700000,
                'shop_cash': 0,
                'expenses_cash': 50000,
                'expected_cash': 750000,
                'counted_cash': 720000,
              },
            ],
    });
  }

  @override
  Future<DebtorsReport> getDebtorsReport() async => DebtorsReport.fromJson({
    'summary': {'count': 7, 'total_debt': 1700000},
    'items': [
      for (var i = 0; i < 7; i++)
        {
          'id': 'r$i',
          'guest_name': i == 0 ? 'Abdurahmon Abdurahmonov-Toshpoʻlatov' : 'Mehmon $i',
          'room_number': '1${i}04A',
          'reservation_number': 'RES-00313-20260908-9UF$i',
          'check_out_date': '2026-10-1$i',
          'debt_amount': 100000.0 * (i + 1),
        },
    ],
  });

  @override
  Future<String> getShiftMode() async => mode;

  @override
  Future<List<ShiftSession>> getShiftHistory({int limit = 50}) async => [
    ShiftSession(
      id: 'c1',
      userId: '4',
      userName: 'Sardor Rustamov',
      status: 'CLOSED',
      openingCash: 100000,
      countedCash: 1250000,
      cashDiff: -35000,
      forceClosed: false,
      startedAt: _now.subtract(const Duration(hours: 10)),
      endedAt: _now.subtract(const Duration(hours: 1)),
    ),
    ShiftSession(
      id: 'c2',
      userId: '5',
      userName: 'Malika Yusupova',
      status: 'CLOSED',
      openingCash: 100000,
      countedCash: 900000,
      cashDiff: 15000,
      forceClosed: false,
      startedAt: _now.subtract(const Duration(days: 3, hours: 8)),
      endedAt: _now.subtract(const Duration(days: 3)),
    ),
  ];
}

void main() {
  group('FinanceRange', () {
    test('tez tanlovlar', () {
      final today = FinanceRange.of(FinanceRangeKind.today, _now);
      expect(today.from, DateTime(2026, 10, 15));
      expect(today.isSingleDay, isTrue);
      final yesterday = FinanceRange.of(FinanceRangeKind.yesterday, _now);
      expect(yesterday.from, DateTime(2026, 10, 14));
      expect(yesterday.to, DateTime(2026, 10, 14));
      final week = FinanceRange.of(FinanceRangeKind.week, _now);
      expect(week.from, DateTime(2026, 10, 9));
      expect(week.days, 7);
      final month = FinanceRange.of(FinanceRangeKind.month, _now);
      expect(month.from, DateTime(2026, 10, 1));
      expect(month.days, 15);
    });

    test('ixtiyoriy davr: tartib va vaqt qismi ahamiyatsiz', () {
      final r = FinanceRange.custom(DateTime(2026, 9, 30, 23, 59), DateTime(2026, 9, 1, 8));
      expect(r.from, DateTime(2026, 9, 1));
      expect(r.to, DateTime(2026, 9, 30));
      expect(r.days, 30);
      expect(r.contains(DateTime(2026, 9, 30, 22)), isTrue);
      expect(r.contains(DateTime(2026, 10, 1)), isFalse);
    });

    test('oldingi davr', () {
      expect(
        FinanceRange.of(FinanceRangeKind.today, _now).previous().from,
        DateTime(2026, 10, 14),
      );
      final week = FinanceRange.of(FinanceRangeKind.week, _now).previous();
      expect(week.from, DateTime(2026, 10, 2));
      expect(week.to, DateTime(2026, 10, 8));
      // Shu oy — o'tgan oyning aynan shu kunlari
      final month = FinanceRange.of(FinanceRangeKind.month, _now).previous();
      expect(month.from, DateTime(2026, 9, 1));
      expect(month.to, DateTime(2026, 9, 15));
      // 31-mart → fevral oxiri (28 kun)
      final march = FinanceRange.of(FinanceRangeKind.month, DateTime(2027, 3, 31)).previous();
      expect(march.to, DateTime(2027, 2, 28));
      // Ixtiyoriy — xuddi shuncha kun oldin
      final custom = FinanceRange.custom(DateTime(2026, 10, 1), DateTime(2026, 10, 10)).previous();
      expect(custom.from, DateTime(2026, 9, 21));
      expect(custom.to, DateTime(2026, 9, 30));
    });
  });

  group('modellar', () {
    test('grafik: 62 kungacha kunlik, undan uzunida haftalik', () {
      List<FinanceDay> days(int n) => [
        for (var i = 0; i < n; i++)
          FinanceDay(
            date: DateTime(2026, 1, 1 + i),
            income: 100,
            paymentCount: 1,
            refunds: 0,
            expense: 10,
            shop: 5,
          ),
      ];
      expect(chartBuckets(days(31)).length, 31);
      expect(chartBuckets(days(31)).first.revenue, 105);
      final weekly = chartBuckets(days(90));
      expect(weekly.length, 13);
      expect(weekly.first.revenue, 7 * 105);
      expect(weekly.first.isSingleDay, isFalse);
      expect(weekly.last.end, DateTime(2026, 1, 90));
      expect(chartBuckets(const []), isEmpty);
    });

    test('kassalar, qarzdorlar, smena farqlari, o\'zgarish ulushi', () async {
      final repo = _Repo();
      final cash = await repo.getCashOverview();
      expect(cash.isCashMode, isTrue);
      expect(cash.activeCount, 1);
      expect(cash.pendingCount, 1);
      expect(cash.drawers[1].diff, -30000);
      expect(cash.drawers[0].diff, isNull);

      final debtors = await repo.getDebtorsReport();
      expect(debtors.items.first.debt, 700000); // eng kattasi birinchi

      final shifts = ShiftDiffSummary.of(
        await repo.getShiftHistory(),
        FinanceRange.of(FinanceRangeKind.today, _now),
      );
      expect(shifts.closed.length, 1);
      expect(shifts.shortage, 35000);
      expect(shifts.surplus, 0);

      expect(changeRatio(120, 100), closeTo(0.2, 1e-9));
      expect(changeRatio(80, 100), closeTo(-0.2, 1e-9));
      expect(changeRatio(10, 0), isNull);
    });

    test('kunlik qator serverdan o\'qiladi', () {
      final d = FinanceDay.fromJson({
        'date': '2026-10-02', 'income': 100, 'payment_count': 2,
        'refunds': 5, 'expense': 30, 'shop': 7,
      });
      expect(d.date, DateTime(2026, 10, 2));
      expect(d.revenue, 107);
    });

    test('grafik belgilari: ko\'p ustunda birinchi va oxirgisi doim', () {
      expect(FinanceBarChart.labelIndexes(5), [0, 1, 2, 3, 4]);
      final idx = FinanceBarChart.labelIndexes(31);
      expect(idx.first, 0);
      expect(idx.last, 30);
      expect(idx.length, lessThanOrEqualTo(7));
      expect(FinanceBarChart.labelIndexes(0), isEmpty);
    });
  });

  group('FinanceCubit', () {
    test('ochilganda hammasi yuklanadi', () async {
      final repo = _Repo();
      final cubit = FinanceCubit(repo, initial: FinanceRangeKind.week, clock: () => _now);
      addTearDown(cubit.close);
      await cubit.load();
      final s = cubit.state;
      expect(s.loading, isFalse);
      expect(s.summary, isNotNull);
      expect(s.previous, isNotNull);
      expect(s.days!.length, 7);
      expect(s.cash!.totalExpected, 3480000);
      expect(s.debtors!.count, 7);
      expect(s.shifts!.closed, isNotEmpty);
      expect(s.failedSections, 0);
      // Joriy va oldingi davr so'raldi
      expect(repo.summaryCalls.map((c) => c.$1), containsAll([DateTime(2026, 10, 9), DateTime(2026, 10, 2)]));
    });

    test('bir kunlik davrda grafik so\'ralmaydi', () async {
      final repo = _Repo();
      final cubit = FinanceCubit(repo, clock: () => _now);
      addTearDown(cubit.close);
      await cubit.load();
      expect(repo.dailyCalls, 0);
      expect(cubit.state.days, isNull);
    });

    test('kassa ruxsati yo\'q — karta yashiriladi, xato emas', () async {
      final cubit = FinanceCubit(_Repo(cashForbidden: true), clock: () => _now);
      addTearDown(cubit.close);
      await cubit.load();
      expect(cubit.state.cashForbidden, isTrue);
      expect(cubit.state.failedSections, 0);
    });

    test('davr almashadi va ixtiyoriy davr', () async {
      final repo = _Repo();
      final cubit = FinanceCubit(repo, clock: () => _now);
      addTearDown(cubit.close);
      await cubit.load();
      await cubit.selectKind(FinanceRangeKind.month);
      expect(cubit.state.range.kind, FinanceRangeKind.month);
      expect(cubit.state.days!.length, 15);
      await cubit.selectCustom(DateTime(2026, 9, 10), DateTime(2026, 9, 1));
      expect(cubit.state.range.from, DateTime(2026, 9, 1));
      expect(cubit.state.days!.length, 10);
      expect(cubit.state.periodLoading, isFalse);
    });
  });

  group('sahifa kichik ekranda sig\'adi', () {
    setUpAll(_loadFonts);

    for (final locale in const [Locale('uz'), Locale('ru'), Locale('en')]) {
      for (final mode in const ['cash', 'simple']) {
        testWidgets('${locale.languageCode} · $mode', (tester) async {
          tester.view.physicalSize = const Size(360 * 3, 740 * 3);
          tester.view.devicePixelRatio = 3;
          addTearDown(tester.view.reset);

          final cubit = FinanceCubit(
            _Repo(mode: mode),
            initial: FinanceRangeKind.week,
            clock: () => _now,
          );
          addTearDown(cubit.close);
          await cubit.load();

          await tester.pumpWidget(
            MaterialApp(
              theme: AppTheme.light(),
              locale: locale,
              supportedLocales: S.supportedLocales,
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: BlocProvider.value(value: cubit, child: const FinancePage()),
            ),
          );
          await tester.pumpAndSettle();
          await _shot(tester, 'finance-${locale.languageCode}-$mode-1');

          // Butun sahifa bo'ylab aylantirib chiqamiz — har karta chiziladi
          for (var i = 2; i <= 6; i++) {
            await tester.drag(find.byType(Scrollable).first, const Offset(0, -620));
            await tester.pumpAndSettle();
            await _shot(tester, 'finance-${locale.languageCode}-$mode-$i');
          }
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}

Future<void> _shot(WidgetTester tester, String name) async {
  final dir = Platform.environment['GOHOTEL_SHOTS'];
  if (dir == null || dir.isEmpty) return;
  debugDisableShadows = false;
  await expectLater(find.byType(MaterialApp), matchesGoldenFile(Uri.file('$dir/$name.png')));
  debugDisableShadows = true;
}

Future<void> _loadFonts() async {
  final loader = FontLoader('Inter');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    final bytes = await File('assets/fonts/Inter-$weight.ttf').readAsBytes();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
  if ((Platform.environment['GOHOTEL_SHOTS'] ?? '').isEmpty) return;
  Future<void> load(String family, String path) async {
    final file = File(path);
    if (!file.existsSync()) return;
    final bytes = await file.readAsBytes();
    final l = FontLoader(family)..addFont(Future.value(ByteData.view(bytes.buffer)));
    await l.load();
  }

  final root = Platform.environment['FLUTTER_ROOT'] ?? '';
  await load('MaterialIcons', '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  final cache = Platform.environment['PUB_CACHE'] ?? '${Platform.environment['LOCALAPPDATA']}/Pub/Cache';
  final hosted = Directory('$cache/hosted/pub.dev');
  if (!hosted.existsSync()) return;
  for (final entry in hosted.listSync()) {
    final name = entry.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
    if (name.startsWith('cupertino_icons-')) {
      await load('packages/cupertino_icons/CupertinoIcons', '${entry.path}/assets/CupertinoIcons.ttf');
    }
  }
}
