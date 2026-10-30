import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gohotels/app/theme/app_theme.dart';
import 'package:gohotels/features/management/data/management_repository.dart';
import 'package:gohotels/features/management/domain/finance_report.dart';
import 'package:gohotels/features/management/domain/finance_summary.dart';
import 'package:gohotels/features/management/domain/guest_feedback.dart';
import 'package:gohotels/features/management/domain/hk_task.dart';
import 'package:gohotels/features/management/domain/management_access.dart';
import 'package:gohotels/features/management/domain/room_tile.dart';
import 'package:gohotels/features/management/domain/shift_session.dart';
import 'package:gohotels/features/management/domain/staff_member.dart';
import 'package:gohotels/features/management/presentation/cubit/pulse_cubit.dart';
import 'package:gohotels/features/management/presentation/cubit/team_cubit.dart';
import 'package:gohotels/features/management/presentation/pages/pulse_page.dart';
import 'package:gohotels/features/management/presentation/widgets/segmented_tabs.dart';
import 'package:gohotels/features/management/presentation/widgets/shift_cash_widgets.dart';
import 'package:gohotels/features/reception/bookings/data/bookings_repository.dart';
import 'package:gohotels/features/reception/bookings/domain/booking.dart';
import 'package:gohotels/l10n/gen/app_localizations.dart';

/// Bosh sahifa (puls) → Moliya kartasi: "Kassada hozir" summasi — moliya
/// sahifasidagi bilan bir manba (`/shifts/cash-overview`). Faqat ruxsati
/// borlarga so'raladi va faqat kassa smenalari yuritilsa ko'rinadi.

const _cash = CashOverview(
  mode: 'cash',
  drawers: [
    CashDrawer(
      id: 's1',
      status: 'ACTIVE',
      openingCash: 500000,
      paymentsCash: 1300000,
      shopCash: 0,
      expensesCash: 0,
      expectedCash: 1800000,
      userName: 'Dilnoza Rahimova',
    ),
    CashDrawer(
      id: 's2',
      status: 'PENDING_HANDOVER',
      openingCash: 0,
      paymentsCash: 450000,
      shopCash: 0,
      expensesCash: 0,
      expectedCash: 450000,
      userName: 'Aziz Karimov',
    ),
  ],
  totalExpected: 2250000,
);

const _adminAccess = ManagementAccess(
  isAdmin: true,
  canBroadcast: true,
  canSetRoomStatus: true,
  canCreateTask: true,
  canAssignTask: true,
  canUpdateTask: true,
  canForceClose: true,
  canViewFeedback: true,
  canManageFeedback: true,
  canResolveProblems: true,
);

/// Kassa nazorati (`shift.force_close`) ruxsati yo'q menejer.
const _managerNoCash = ManagementAccess(
  isAdmin: false,
  canBroadcast: false,
  canSetRoomStatus: true,
  canCreateTask: true,
  canAssignTask: true,
  canUpdateTask: true,
  canForceClose: false,
  canViewFeedback: true,
  canManageFeedback: false,
  canResolveProblems: true,
);

class _PulseRepo extends Fake implements ManagementRepository {
  _PulseRepo({this.cash = _cash});

  final CashOverview cash;
  int cashCalls = 0;

  @override
  Future<CashOverview> getCashOverview() async {
    cashCalls++;
    return cash;
  }

  @override
  Future<List<RoomTile>> getRooms() async => const [];

  @override
  Future<List<HkTask>> getTasks({String? status, int limit = 200}) async => const [];

  @override
  Future<FinanceSummary> getFinanceSummary({
    required DateTime from,
    required DateTime to,
  }) async => FinanceSummary.fromJson({'income': 3100000, 'payment_count': 6});

  @override
  Future<List<IncomeDay>> getIncomeDays(DateTime today, {int days = 7}) async =>
      const [];

  @override
  Future<int> getOverdueRoomCount() async => 0;

  @override
  Future<(List<GuestFeedback>, int)> getFeedback({
    String? status,
    String? type,
    int limit = 200,
  }) async => (const <GuestFeedback>[], 0);

  @override
  Future<(int, double)> getDebtors() async => (0, 0.0);

  @override
  Future<List<StaffProblem>> getProblems({String? status, int limit = 100}) async =>
      const [];

  @override
  Future<String> getShiftMode() async => cash.mode;

  @override
  Future<List<ShiftSession>> getShiftHistory({int limit = 50}) async => const [];

  @override
  Future<List<StaffMember>> getStaff() async => const [];
}

class _Bookings extends Fake implements BookingsRepository {
  @override
  Future<List<Booking>> getBookings({
    required DateTime date,
    String? search,
    bool includeCancelled = false,
  }) async => const [];
}

Future<void> _loadInter() async {
  final loader = FontLoader('Inter');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    final bytes = await File('assets/fonts/Inter-$weight.ttf').readAsBytes();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

Widget _host(Widget child, Locale locale) => MaterialApp(
  theme: AppTheme.light(),
  locale: locale,
  supportedLocales: S.supportedLocales,
  localizationsDelegates: const [
    S.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: Scaffold(body: child),
);

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(360 * 3, 740 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  setUpAll(_loadInter);

  group('PulseCubit: kassada hozir', () {
    test('ruxsat bo\'lsa so\'raladi va pulsga tushadi', () async {
      final repo = _PulseRepo();
      final cubit = PulseCubit(repo, _Bookings(), access: _adminAccess);
      addTearDown(cubit.close);

      await cubit.load();

      expect(repo.cashCalls, 1);
      expect(cubit.state.pulse.cash, _cash);
      expect(cubit.state.failedSections, 0);
    });

    test('ruxsat yo\'q — so\'ralmaydi, "yuklanmadi" ogohlantirishi chiqmaydi', () async {
      final repo = _PulseRepo();
      final cubit = PulseCubit(repo, _Bookings(), access: _managerNoCash);
      addTearDown(cubit.close);

      await cubit.load();

      expect(repo.cashCalls, 0);
      expect(cubit.state.pulse.cash, isNull);
      expect(cubit.state.failedSections, 0);
    });

    test('davr almashganda oxirgi kassa holati saqlanadi', () async {
      final cubit = PulseCubit(_PulseRepo(), _Bookings(), access: _adminAccess);
      addTearDown(cubit.close);

      await cubit.load();
      await cubit.selectPeriod(PulsePeriod.month);

      expect(cubit.state.pulse.cash, _cash);
    });
  });

  for (final locale in S.supportedLocales) {
    group('til: ${locale.languageCode}', () {
      testWidgets('Bosh sahifa: Moliya kartasida kassada hozir summasi ko\'rinadi', (
        tester,
      ) async {
        _phone(tester);
        final l10n = lookupS(locale);
        final repo = _PulseRepo();
        final pulse = PulseCubit(repo, _Bookings(), access: _adminAccess);
        final team = TeamCubit(repo);
        addTearDown(pulse.close);
        addTearDown(team.close);
        await pulse.load();

        await tester.pumpWidget(
          _host(
            MultiBlocProvider(
              providers: [
                BlocProvider.value(value: pulse),
                BlocProvider.value(value: team),
              ],
              child: PulsePage(
                access: _adminAccess,
                onOpenRooms: () {},
                onOpenTeam: (_) {},
              ),
            ),
            locale,
          ),
        );
        // Jonli nuqta animatsiyasi to'xtamaydi — pumpAndSettle o'rniga vaqt
        await tester.pump(const Duration(seconds: 2));
        final strip = find.byType(CashNowStrip);
        // Tashqi ro'yxat — daraxtdagi birinchi Scrollable (ichkilar uning avlodi)
        await tester.scrollUntilVisible(
          strip,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pump(const Duration(seconds: 2));

        expect(strip, findsOneWidget);
        expect(
          find.descendant(of: strip, matching: find.text(l10n.cashNowTitle)),
          findsOneWidget,
        );
        expect(
          find.descendant(of: strip, matching: find.text('2 250 000')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: strip, matching: find.text(l10n.cashDrawersCount(1, 1))),
          findsOneWidget,
        );
        // Davrga bog'liq emas — davr tanlagichidan yuqorida turadi
        expect(
          tester.getTopLeft(strip).dy,
          lessThan(tester.getTopLeft(find.byType(SegmentedTabs)).dy),
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('Ochiq kassa yo\'q — nol va izoh, sig\'adi', (tester) async {
        _phone(tester);
        final l10n = lookupS(locale);

        await tester.pumpWidget(
          _host(
            const Padding(
              padding: EdgeInsets.all(20),
              child: CashNowStrip(
                cash: CashOverview(mode: 'cash', drawers: [], totalExpected: 0),
              ),
            ),
            locale,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('0'), findsOneWidget);
        expect(find.text(l10n.cashNoOpen), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  }

  testWidgets('Oddiy rejim yoki ruxsat yo\'q — kassa qatori chiqmaydi', (tester) async {
    _phone(tester);
    for (final (repo, access) in [
      (_PulseRepo(cash: const CashOverview(mode: 'simple', drawers: [], totalExpected: 0)), _adminAccess),
      (_PulseRepo(), _managerNoCash),
    ]) {
      final pulse = PulseCubit(repo, _Bookings(), access: access);
      final team = TeamCubit(repo);
      await pulse.load();

      await tester.pumpWidget(
        _host(
          MultiBlocProvider(
            key: UniqueKey(),
            providers: [
              BlocProvider.value(value: pulse),
              BlocProvider.value(value: team),
            ],
            child: PulsePage(access: access, onOpenRooms: () {}, onOpenTeam: (_) {}),
          ),
          const Locale('uz'),
        ),
      );
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(CashNowStrip), findsNothing);
      expect(tester.takeException(), isNull);
      await pulse.close();
      await team.close();
    }
  });
}
