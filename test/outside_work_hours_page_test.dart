import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gohotels/app/theme/app_theme.dart';
import 'package:gohotels/core/network/api_exception.dart';
import 'package:gohotels/core/services/biometric_service.dart';
import 'package:gohotels/core/storage/app_prefs.dart';
import 'package:gohotels/features/auth/data/auth_repository.dart';
import 'package:gohotels/features/auth/domain/staff_user.dart';
import 'package:gohotels/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gohotels/features/auth/presentation/pages/outside_work_hours_page.dart';
import 'package:gohotels/l10n/gen/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ish vaqti ekrani KICHIK telefonda (360×740) va uch tilda sig'adimi,
/// tugmalari ishlaydimi va daqiqada bir o'zi tekshiradimi.
///
/// Haqiqiy Inter shrifti yuklanadi (management_pages_test bilan bir xil):
/// sinov shrifti matnni ikki barobar keng chizib, toshish tekshiruvini
/// ma'nosiz qilardi.

StaffUser _user({
  bool blocked = true,
  String start = '09:00',
  String end = '18:00',
}) => StaffUser(
  id: 'u1',
  userType: 'EMPLOYEE',
  username: 'farrosh',
  firstName: 'Dilnoza',
  lastName: 'Karimova',
  permissions: const ['housekeeping.task.update'],
  workStart: start,
  workEnd: end,
  workHoursEnforced: true,
  workHoursBlocked: blocked,
);

class _FakeAuthRepo extends Fake implements AuthRepository {
  _FakeAuthRepo(this.restored);

  final StaffUser restored;

  /// Navbatdagi `me()` javoblari: [StaffUser] yoki tashlanadigan xato.
  final List<Object> meQueue = [];
  int meCalls = 0;
  bool loggedOut = false;

  @override
  Future<StaffUser?> restoreSession() async => restored;

  @override
  Future<StaffUser> me() async {
    meCalls++;
    final next = meQueue.removeAt(0);
    if (next is StaffUser) return next;
    throw next;
  }

  @override
  Future<void> logout() async => loggedOut = true;
}

class _NoBiometrics extends Fake implements BiometricService {
  @override
  Future<bool> get isAvailable async => false;
}

/// Ixtiyoriy skrinshotlar: `GOHOTEL_SHOTS=<papka>` va `--update-goldens`
/// bilan har holat PNG bo'lib saqlanadi. Oddiy yugurishda hech narsa
/// qilmaydi.
Future<void> _shot(WidgetTester tester, String name) async {
  final dir = Platform.environment['GOHOTEL_SHOTS'];
  if (dir == null || dir.isEmpty) return;
  debugDisableShadows = false;
  await tester.pump();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile(Uri.file('$dir/$name.png')),
  );
  debugDisableShadows = true;
}

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    var any = false;
    for (final path in paths) {
      final file = File(path);
      if (!file.existsSync()) continue;
      final bytes = await file.readAsBytes();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
      any = true;
    }
    if (any) await loader.load();
  }

  await load('Inter', [
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold'])
      'assets/fonts/Inter-$w.ttf',
  ]);
  // Ikonkalar faqat skrinshot uchun kerak (aks holda kvadrat bo'lib chiqadi)
  if ((Platform.environment['GOHOTEL_SHOTS'] ?? '').isEmpty) return;
  final root = Platform.environment['FLUTTER_ROOT'] ?? '';
  await load('MaterialIcons', [
    '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
}

Widget _host(AuthCubit cubit, Locale locale) => BlocProvider.value(
  value: cubit,
  child: MaterialApp(
    theme: AppTheme.light(),
    locale: locale,
    supportedLocales: S.supportedLocales,
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: const OutsideWorkHoursPage(),
  ),
);

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(360 * 3, 740 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Ilova ochilganda server "hozir ish vaqti emas" degan xodim.
Future<(AuthCubit, _FakeAuthRepo)> _blocked(
  WidgetTester tester, {
  StaffUser? user,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = AppPrefs(await SharedPreferences.getInstance());
  final repo = _FakeAuthRepo(user ?? _user());
  final cubit = AuthCubit(
    repository: repo,
    prefs: prefs,
    biometrics: _NoBiometrics(),
  );
  addTearDown(cubit.close);
  await cubit.appStarted();
  expect(cubit.state.status, AuthStatus.outsideWorkHours);
  return (cubit, repo);
}

void main() {
  setUpAll(_loadFonts);

  for (final locale in const [Locale('uz'), Locale('ru'), Locale('en')]) {
    group('til: ${locale.languageCode}', () {
      testWidgets('ekran sig\'adi: sarlavha, ish vaqti, tugmalar', (
        tester,
      ) async {
        _phone(tester);
        final (cubit, _) = await _blocked(tester);
        await tester.pumpWidget(_host(cubit, locale));
        await tester.pump();

        final l10n = await S.delegate.load(locale);
        expect(tester.takeException(), isNull); // toshish yo'q
        expect(find.text(l10n.outsideHoursTitle), findsOneWidget);
        expect(find.text(l10n.outsideHoursBody), findsOneWidget);
        expect(find.text(l10n.outsideHoursScheduleLabel), findsOneWidget);
        expect(find.text('09:00 – 18:00'), findsOneWidget);
        expect(find.text(l10n.outsideHoursRetry), findsOneWidget);
        expect(find.text(l10n.logout), findsOneWidget);
        // Tugmalar ekranda (aylantirmasdan) ko'rinadi
        final retry = tester.getRect(find.text(l10n.outsideHoursRetry));
        final logout = tester.getRect(find.text(l10n.logout));
        expect(retry.bottom, lessThan(740));
        expect(logout.bottom, lessThan(740));
        await _shot(tester, 'outside_hours_${locale.languageCode}');
      });

      testWidgets('tungi smena va soniyali soat ham to\'g\'ri chiqadi', (
        tester,
      ) async {
        _phone(tester);
        final (cubit, _) = await _blocked(
          tester,
          user: _user(start: '22:00:00', end: '06:00:00'),
        );
        await tester.pumpWidget(_host(cubit, locale));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('22:00 – 06:00'), findsOneWidget);
      });

      testWidgets('katta shriftda ham yiqilmaydi (sahifa aylanadi)', (
        tester,
      ) async {
        _phone(tester);
        tester.platformDispatcher.textScaleFactorTestValue = 1.6;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final (cubit, _) = await _blocked(tester);
        await tester.pumpWidget(_host(cubit, locale));
        await tester.pump();
        expect(tester.takeException(), isNull);
        final l10n = await S.delegate.load(locale);
        await tester.scrollUntilVisible(
          find.text(l10n.logout),
          120,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text(l10n.logout), findsOneWidget);
      });
    });
  }

  group('harakatlar', () {
    testWidgets(
      'qayta tekshirish: hali ish vaqti emas — xabar, ekranda qoladi',
      (tester) async {
        _phone(tester);
        final (cubit, repo) = await _blocked(tester);
        repo.meQueue.add(_user(blocked: true));
        await tester.pumpWidget(_host(cubit, const Locale('uz')));
        await tester.pump();

        await tester.tap(find.text('Qayta tekshirish'));
        await tester.pump();
        await tester.pump();
        expect(repo.meCalls, 1);
        expect(cubit.state.status, AuthStatus.outsideWorkHours);
        expect(find.text('Hozircha ish vaqtingiz emas'), findsOneWidget);
      },
    );

    testWidgets('qayta tekshirish: ish vaqti boshlangan — ish davom etadi', (
      tester,
    ) async {
      _phone(tester);
      final (cubit, repo) = await _blocked(tester);
      repo.meQueue.add(_user(blocked: false));
      await tester.pumpWidget(_host(cubit, const Locale('uz')));
      await tester.pump();

      await tester.tap(find.text('Qayta tekshirish'));
      await tester.pump();
      expect(cubit.state.status, AuthStatus.authenticated);
      expect(find.text('Hozircha ish vaqtingiz emas'), findsNothing);
    });

    testWidgets('qayta tekshirish: tarmoq xatosi — tushunarli xabar', (
      tester,
    ) async {
      _phone(tester);
      final (cubit, repo) = await _blocked(tester);
      repo.meQueue.add(const ApiException(message: 'x', isNetwork: true));
      await tester.pumpWidget(_host(cubit, const Locale('uz')));
      await tester.pump();

      await tester.tap(find.text('Qayta tekshirish'));
      await tester.pump();
      await tester.pump();
      final l10n = await S.delegate.load(const Locale('uz'));
      expect(find.text(l10n.networkError), findsOneWidget);
      expect(cubit.state.status, AuthStatus.outsideWorkHours);
    });

    testWidgets(
      'har daqiqada o\'zi tekshiradi va ish vaqti boshlanganda qaytadi',
      (tester) async {
        _phone(tester);
        final (cubit, repo) = await _blocked(tester);
        repo.meQueue
          ..add(_user(blocked: true))
          ..add(_user(blocked: false));
        await tester.pumpWidget(_host(cubit, const Locale('uz')));
        await tester.pump();
        expect(repo.meCalls, 0);

        await tester.pump(OutsideWorkHoursPage.recheckInterval);
        await tester.pump();
        expect(repo.meCalls, 1);
        expect(cubit.state.status, AuthStatus.outsideWorkHours);
        // Avtomatik tekshiruvda "hali emas" xabari chiqmaydi
        expect(find.text('Hozircha ish vaqtingiz emas'), findsNothing);

        await tester.pump(OutsideWorkHoursPage.recheckInterval);
        await tester.pump();
        expect(repo.meCalls, 2);
        expect(cubit.state.status, AuthStatus.authenticated);
      },
    );

    testWidgets('chiqish — haqiqatan hisobdan chiqadi', (tester) async {
      _phone(tester);
      final (cubit, repo) = await _blocked(tester);
      await tester.pumpWidget(_host(cubit, const Locale('uz')));
      await tester.pump();

      await tester.tap(find.text('Chiqish'));
      await tester.pump();
      expect(repo.loggedOut, isTrue);
      expect(cubit.state.status, AuthStatus.unauthenticated);
    });
  });
}
