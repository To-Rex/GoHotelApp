import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:gohotels/app/theme/app_theme.dart';
import 'package:gohotels/features/management/data/management_repository.dart';
import 'package:gohotels/features/management/domain/guest_feedback.dart';
import 'package:gohotels/features/management/domain/hk_task.dart';
import 'package:gohotels/features/management/domain/management_access.dart';
import 'package:gohotels/features/management/domain/room_tile.dart';
import 'package:gohotels/features/management/domain/shift_session.dart';
import 'package:gohotels/features/management/domain/staff_member.dart';
import 'package:gohotels/features/management/presentation/cubit/room_map_cubit.dart';
import 'package:gohotels/features/management/presentation/cubit/team_cubit.dart';
import 'package:gohotels/features/management/presentation/pages/room_map_page.dart';
import 'package:gohotels/features/management/presentation/pages/team_page.dart';
import 'package:gohotels/features/management/presentation/widgets/broadcast_sheet.dart';
import 'package:gohotels/features/management/presentation/widgets/force_close_sheet.dart';
import 'package:gohotels/features/management/presentation/widgets/task_create_sheet.dart';
import 'package:gohotels/l10n/gen/app_localizations.dart';

/// Boshqaruv sahifalari KICHIK telefon ekranida (360×740) va uch tilda
/// sig'adimi — RenderFlex toshishi testni yiqitadi.
///
/// Haqiqiy Inter shrifti yuklanadi: sinov shrifti har harfni kvadrat qilib
/// chizadi va matn kengligi haqiqatdan ikki barobar chiqardi — toshish
/// tekshiruvi ma'nosiz bo'lardi.
const _access = ManagementAccess(
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

final _now = DateTime.now();

StaffMember _staff(String id, String first, String last, {String status = 'ACTIVE'}) =>
    StaffMember(
      id: id,
      userType: 'EMPLOYEE',
      username: 'login_$id',
      firstName: first,
      lastName: last,
      status: status,
      workStart: '00:00',
      workEnd: '23:59',
      phone: '+998 90 123 45 67',
      lastLoginAt: _now.subtract(const Duration(minutes: 3)),
    );

HkTask _task(String id, String status, {String? to, String? name, String priority = 'MEDIUM'}) =>
    HkTask(
      id: id,
      roomId: 'r$id',
      roomNumber: '10$id',
      taskType: 'DEEP_CLEANING',
      status: status,
      priority: priority,
      createdAt: _now.subtract(const Duration(hours: 2, minutes: 15)),
      checklistDone: 3,
      checklistTotal: 7,
      autoCompleted: false,
      assignedTo: to,
      assigneeName: name,
      startedAt: status == 'OPEN' ? null : _now.subtract(const Duration(minutes: 40)),
      completedAt: status == 'COMPLETED' ? _now : null,
      notes: 'Mehmon soat 14:00 da keladi, shoshilinch tayyorlash kerak',
    );

class _FakeRepo extends Fake implements ManagementRepository {
  final rooms = [
    for (final (n, floor, state) in [
      ('101', 'f1', RoomState.occupied),
      ('102', 'f1', RoomState.available),
      ('103', 'f1', RoomState.cleaning),
      ('104', 'f1', RoomState.reserved),
      ('105', 'f1', RoomState.maintenance),
      ('201', 'f2', RoomState.inspection),
      ('202', 'f2', RoomState.outOfService),
      ('1204A', 'f2', RoomState.occupied),
    ])
      RoomTile(
        id: n,
        number: n,
        state: state,
        floorId: floor,
        branchId: 'b1',
        capacity: 3,
        basePrice: 450000,
        notes: 'Balkonli, dengiz tomonga qaragan xona',
        statusChangedAt: _now.subtract(const Duration(hours: 26, minutes: 5)),
      ),
  ];

  final staff = [
    _staff('1', 'Abdurahmon', 'Abdurahmonov-Toshpoʻlatov'),
    _staff('2', 'Dilnoza', 'Karimova'),
    _staff('3', 'Vali', 'Aliyev', status: 'TERMINATED'),
    _staff('4', 'Sardor', 'Rustamov'),
    _staff('5', 'Malika', 'Yusupova'),
    _staff('6', 'Jasur', 'Qodirov'),
  ];

  @override
  Future<List<RoomTile>> getRooms() async => rooms;

  @override
  Future<List<FloorInfo>> getFloors() async => const [
    FloorInfo(id: 'f1', number: 1),
    FloorInfo(id: 'f2', number: 2, name: 'Ikkinchi qavat — lyuks xonalar'),
  ];

  @override
  Future<List<RoomStay>> getRoomStays(String roomId) async => const [
    RoomStay(
      id: 's1',
      number: 'RES-00313-20260908-9UF5',
      status: 'CHECKED_IN',
      guestName: 'Abdurahmon Abdurahmonov-Toshpoʻlatov',
      checkIn: '2026-09-28',
      checkOut: '2026-10-03',
      adults: 3,
      totalAmount: 2500000,
      paidAmount: 1000000,
      guestPhone: '+998 90 123 45 67',
      companions: ['Dilnoza Karimova', 'Vali Aliyev'],
    ),
  ];

  @override
  Future<List<StaffMember>> getStaff() async => staff;

  @override
  Future<String> getShiftMode() async => 'cash';

  @override
  Future<List<ShiftSession>> getShiftHistory({int limit = 50}) async => [
    ShiftSession(
      id: 'o1',
      userId: '1',
      userName: 'Abdurahmon Abdurahmonov-Toshpoʻlatov',
      status: 'PENDING_HANDOVER',
      openingCash: 12500000,
      countedCash: 13750000,
      forceClosed: false,
      startedAt: _now.subtract(const Duration(hours: 9, minutes: 12)),
    ),
    ShiftSession(
      id: 'o2',
      userId: '2',
      userName: 'Dilnoza Karimova',
      status: 'ACTIVE',
      openingCash: 0,
      forceClosed: false,
      startedAt: _now.subtract(const Duration(minutes: 35)),
    ),
    ShiftSession(
      id: 'c1',
      userId: '4',
      userName: 'Sardor Rustamov',
      status: 'CLOSED',
      openingCash: 100000,
      countedCash: 1250000,
      cashDiff: -35000,
      forceClosed: true,
      startedAt: _now.subtract(const Duration(days: 1, hours: 9)),
      endedAt: _now.subtract(const Duration(days: 1)),
    ),
    ShiftSession(
      id: 'c2',
      userId: '5',
      userName: 'Malika Yusupova',
      status: 'CLOSED',
      openingCash: 100000,
      countedCash: 900000,
      cashDiff: 0,
      forceClosed: false,
      startedAt: _now.subtract(const Duration(days: 2, hours: 8)),
      endedAt: _now.subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<List<HkTask>> getTasks({String? status, int limit = 200}) async => [
    _task('1', 'OPEN', priority: 'URGENT'),
    _task('2', 'OPEN', to: '2', name: 'Dilnoza Karimova'),
    _task('3', 'IN_PROGRESS', to: '1', name: 'Abdurahmon Abdurahmonov-Toshpoʻlatov', priority: 'HIGH'),
    _task('4', 'COMPLETED', to: '4', name: 'Sardor Rustamov'),
  ];

  @override
  Future<List<StaffProblem>> getProblems({String? status, int limit = 100}) async => [
    StaffProblem(
      id: 'p1',
      category: 'Santexnika va suv ta\'minoti',
      description: 'Vannaxonadagi kran oqyapti, pol ho\'l bo\'lib qolgan. '
          'Mehmon shikoyat qildi, zudlik bilan usta kerak.',
      status: 'OPEN',
      createdAt: _now.subtract(const Duration(hours: 3)),
      roomNumber: '1204A',
      reportedByName: 'Abdurahmon Abdurahmonov-Toshpoʻlatov',
    ),
    StaffProblem(
      id: 'p2',
      category: 'Elektr',
      description: 'Chiroq yonmayapti',
      status: 'IN_PROGRESS',
      createdAt: _now.subtract(const Duration(days: 1)),
    ),
    StaffProblem(
      id: 'p3',
      category: 'Mebel',
      description: 'Stul singan',
      status: 'RESOLVED',
      createdAt: _now.subtract(const Duration(days: 3)),
      roomNumber: '101',
    ),
  ];
}


/// Ixtiyoriy skrinshotlar: `GOHOTEL_SHOTS=<papka>` muhit o'zgaruvchisi va
/// `--update-goldens` bilan ishga tushirilsa, har bosqich PNG bo'lib
/// saqlanadi — dizaynni qurilmasiz ko'rib chiqish uchun. Oddiy test
/// yugurishida hech narsa qilmaydi.
Future<void> _shot(WidgetTester tester, String name) async {
  final dir = Platform.environment['GOHOTEL_SHOTS'];
  if (dir == null || dir.isEmpty) return;
  debugDisableShadows = false;
  await tester.pumpAndSettle();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile(Uri.file('$dir/$name.png')),
  );
  debugDisableShadows = true;
}

/// Skrinshotda belgilar kvadrat bo'lib chiqmasligi uchun ikonka shriftlari.
Future<void> _loadIconFonts() async {
  if ((Platform.environment['GOHOTEL_SHOTS'] ?? '').isEmpty) return;
  Future<void> load(String family, String path) async {
    final file = File(path);
    if (!file.existsSync()) return;
    final bytes = await file.readAsBytes();
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }

  final root = Platform.environment['FLUTTER_ROOT'] ?? '';
  await load(
    'MaterialIcons',
    '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  final cache =
      Platform.environment['PUB_CACHE'] ??
      '${Platform.environment['LOCALAPPDATA']}/Pub/Cache';
  final hosted = Directory('$cache/hosted/pub.dev');
  if (!hosted.existsSync()) return;
  for (final entry in hosted.listSync()) {
    final name = entry.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
    if (name.startsWith('cupertino_icons-')) {
      await load(
        'packages/cupertino_icons/CupertinoIcons',
        '${entry.path}/assets/CupertinoIcons.ttf',
      );
    }
  }
}

Future<void> _loadInter() async {
  final loader = FontLoader('Inter');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    final bytes = await File('assets/fonts/Inter-$weight.ttf').readAsBytes();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
  await _loadIconFonts();
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

  for (final locale in const [Locale('uz'), Locale('ru'), Locale('en')]) {
    group('til: ${locale.languageCode}', () {
      testWidgets('Xonalar xaritasi va xona oynasi sig\'adi', (tester) async {
        _phone(tester);
        final repo = _FakeRepo();
        final cubit = RoomMapCubit(repo);
        addTearDown(cubit.close);
        await cubit.load();

        await tester.pumpWidget(
          _host(
            BlocProvider.value(
              value: cubit,
              child: const RoomMapPage(access: _access),
            ),
            locale,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(RoomCell), findsNWidgets(8));
        // 26 soatdan beri tozalanayotgan xona — holat nomi o'rniga vaqt
        expect(find.textContaining('26'), findsWidgets);
        await _shot(tester, '01_rooms_${locale.languageCode}');

        // Filtr: plitka bosilganda faqat o'sha holat qoladi
        cubit.setFilter(RoomState.occupied);
        await tester.pumpAndSettle();
        expect(find.byType(RoomCell), findsNWidgets(2));
        await _shot(tester, '01b_rooms_filter_${locale.languageCode}');
        cubit.setFilter(null);
        await tester.pumpAndSettle();

        // Xona oynasi: mehmon, hamrohlar, amallar
        await tester.tap(find.byType(RoomCell).first);
        await tester.pumpAndSettle();
        expect(
          find.text('Abdurahmon Abdurahmonov-Toshpoʻlatov'),
          findsOneWidget,
        );
        expect(find.text('Dilnoza Karimova'), findsOneWidget);
        await _shot(tester, '02_room_sheet_${locale.languageCode}');
        await tester.tapAt(const Offset(20, 20)); // oynani yopish
        await tester.pumpAndSettle();

        // Band bo'lmagan xona: holatni qo'lda o'zgartirish tanlovlari
        await tester.tap(find.text('103'));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.block_rounded), findsWidgets);
        await _shot(tester, '02b_room_sheet_actions_${locale.languageCode}');
      });

      testWidgets('Jamoa: to\'rt bo\'lak va ularning oynalari sig\'adi', (
        tester,
      ) async {
        _phone(tester);
        final repo = _FakeRepo();
        final cubit = TeamCubit(repo);
        addTearDown(cubit.close);
        await cubit.load();

        await tester.pumpWidget(
          _host(
            BlocProvider.value(
              value: cubit,
              child: const TeamPage(access: _access),
            ),
            locale,
          ),
        );
        await tester.pumpAndSettle();
        // Xodimlar: uzun familiya ham sig'adi
        expect(
          find.text('Abdurahmon Abdurahmonov-Toshpoʻlatov'),
          findsWidgets,
        );
        await _shot(tester, '03_team_staff_${locale.languageCode}');
        await tester.tap(find.text('Dilnoza Karimova').first);
        await tester.pumpAndSettle();
        await _shot(tester, '04_staff_sheet_${locale.languageCode}');
        await tester.tapAt(const Offset(20, 20)); // oynani yopish
        await tester.pumpAndSettle();

        // Smenalar: ochiq (jonli vaqt) va yopilgan (tarix o'qi)
        cubit.selectSegment(TeamSegment.shifts);
        await tester.pumpAndSettle();
        expect(find.text('Dilnoza Karimova'), findsOneWidget);
        await _shot(tester, '05_shifts_${locale.languageCode}');
        // Tarix ochiq smenalar ostida — kichik ekranda aylantirib ko'riladi
        await tester.scrollUntilVisible(
          find.text('Malika Yusupova'),
          200,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.pumpAndSettle();
        expect(find.text('Sardor Rustamov'), findsOneWidget);
        await _shot(tester, '05b_shifts_history_${locale.languageCode}');

        // Vazifalar va vazifa oynasi
        cubit.selectSegment(TeamSegment.tasks);
        await tester.pumpAndSettle();
        await _shot(tester, '06_tasks_${locale.languageCode}');
        await tester.tap(find.text('103').first);
        await tester.pumpAndSettle();
        await _shot(tester, '07_task_sheet_${locale.languageCode}');
        await tester.tapAt(const Offset(20, 20));
        await tester.pumpAndSettle();

        // Muammolar
        cubit.selectSegment(TeamSegment.problems);
        await tester.pumpAndSettle();
        expect(find.textContaining('Vannaxonadagi'), findsOneWidget);
        await _shot(tester, '08_problems_${locale.languageCode}');
      });

      testWidgets('Oynalar: e\'lon, majburiy yopish, vazifa yaratish', (
        tester,
      ) async {
        _phone(tester);
        final repo = _FakeRepo();
        GetIt.instance.registerSingleton<ManagementRepository>(repo);
        addTearDown(() => GetIt.instance.unregister<ManagementRepository>());
        final cubit = TeamCubit(repo);
        addTearDown(cubit.close);
        await cubit.load();
        final shift = cubit.state.shifts.items.first;
        TaskDraft? created;

        await tester.pumpWidget(
          _host(
            BlocProvider.value(
              value: cubit,
              child: Builder(
                builder: (context) => Column(
                  children: [
                    TextButton(
                      onPressed: () =>
                          showBroadcastSheet(context, recipients: 12),
                      child: const Text('e'),
                    ),
                    TextButton(
                      onPressed: () => showForceCloseSheet(context, shift),
                      child: const Text('f'),
                    ),
                    TextButton(
                      onPressed: () => showTaskCreateSheet(
                        context,
                        room: repo.rooms.last,
                        onSubmit: (draft) async => created = draft,
                      ),
                      child: const Text('t'),
                    ),
                  ],
                ),
              ),
            ),
            locale,
          ),
        );

        // E'lon: yozilgan matn jonli ko'rinishda ham chiqadi
        await tester.tap(find.text('e'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).first, 'Yig\'ilish soat 15:00 da');
        await tester.pumpAndSettle();
        expect(find.text('Yig\'ilish soat 15:00 da'), findsNWidgets(2));
        await _shot(tester, '09_broadcast_${locale.languageCode}');
        await tester.tapAt(const Offset(20, 20));
        await tester.pumpAndSettle();

        // Majburiy yopish
        await tester.tap(find.text('f'));
        await tester.pumpAndSettle();
        await _shot(tester, '10_force_close_${locale.languageCode}');
        expect(
          find.text('Abdurahmon Abdurahmonov-Toshpoʻlatov'),
          findsOneWidget,
        );
        await tester.tapAt(const Offset(20, 20));
        await tester.pumpAndSettle();

        // Vazifa yaratish: standart tanlov bilan yuboriladi
        await tester.tap(find.text('t'));
        await tester.pumpAndSettle();
        await _shot(tester, '11_task_create_${locale.languageCode}');
        final createButton = find.byType(FilledButton).last;
        await tester.ensureVisible(createButton);
        await tester.tap(createButton);
        await tester.pumpAndSettle();
        expect(created?.taskType, 'CLEANING');
        expect(created?.priority, 'MEDIUM');
        expect(created?.assigneeId, isNull);
      });
    });
  }
}
