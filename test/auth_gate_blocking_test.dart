import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gohotels/app/app.dart';
import 'package:gohotels/app/di.dart';
import 'package:gohotels/app/theme/app_theme.dart';
import 'package:gohotels/core/network/api_client.dart';
import 'package:gohotels/core/services/biometric_service.dart';
import 'package:gohotels/core/services/push_service.dart';
import 'package:gohotels/core/storage/app_prefs.dart';
import 'package:gohotels/core/storage/token_store.dart';
import 'package:gohotels/features/auth/data/auth_repository.dart';
import 'package:gohotels/features/auth/domain/staff_user.dart';
import 'package:gohotels/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gohotels/features/auth/presentation/pages/outside_work_hours_page.dart';
import 'package:gohotels/l10n/gen/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AuthGate: to'siq ekraniga o'tishda ustidagi sahifa va oynalar yopiladi.
///
/// Muhim nozik holat: to'siqni qo'zg'atgan 403 so'rovining egasi (masalan,
/// skanerning "o'qilmoqda" oynasi) o'z oynasini xatodan keyin O'ZI yopadi.
/// Yopish ekran almashinuvidan oldin ishlab ketsa, uning `pop()` i
/// ildizdagi AuthGate sahifasini olib tashlab, ilovani qora ekranda
/// qoldirardi.

StaffUser _blockedUser() => const StaffUser(
  id: 'u1',
  userType: 'EMPLOYEE',
  username: 'farrosh',
  firstName: 'Dilnoza',
  lastName: 'Karimova',
  permissions: ['housekeeping.task.update'],
  workHoursEnforced: true,
  workHoursBlocked: true,
);

class _FakeAuthRepo extends Fake implements AuthRepository {
  final restore = Completer<StaffUser?>();
  final List<Object> meQueue = [];

  @override
  Future<StaffUser?> restoreSession() => restore.future;

  @override
  Future<StaffUser> me() async {
    if (meQueue.isEmpty) return _blockedUser();
    final next = meQueue.removeAt(0);
    if (next is StaffUser) return next;
    throw next;
  }
}

class _NoBiometrics extends Fake implements BiometricService {
  @override
  Future<bool> get isAvailable async => false;
}

class _FakePush extends Fake implements PushService {
  int connects = 0;

  @override
  Future<void> connect() async => connects++;

  @override
  Future<void> disconnect() async {}
}

void main() {
  late _FakeAuthRepo repo;
  late _FakePush push;
  late AuthCubit cubit;

  /* Test zonasi ICHIDA yaratiladi: setUp'dagi Completer va cubit oddiy
     zonaga bog'lanib, ularning mikrotopshiriqlari soxta vaqt bilan
     yurmay qolardi. */
  Future<void> boot() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = AppPrefs(await SharedPreferences.getInstance());
    push = _FakePush();
    getIt
      ..registerSingleton<ApiClient>(
        ApiClient(
          tokenStore: TokenStore(const FlutterSecureStorage()),
          prefs: prefs,
        ),
      )
      ..registerSingleton<PushService>(push);
    repo = _FakeAuthRepo();
    cubit = AuthCubit(
      repository: repo,
      prefs: prefs,
      biometrics: _NoBiometrics(),
    );
  }

  tearDown(() async {
    await cubit.close();
    await getIt.reset();
  });

  /// [rootGuard] — ilovadagidek ildiz sahifa [AuthGate.rootRoute] orqali
  /// (dasturiy `pop()` uni olib tashlay olmaydi). Usiz — oddiy `home`.
  Widget host({bool rootGuard = false}) => BlocProvider.value(
    value: cubit,
    child: MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('uz'),
      supportedLocales: S.supportedLocales,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: rootGuard ? null : const AuthGate(),
      onGenerateInitialRoutes: rootGuard ? (_) => [AuthGate.rootRoute()] : null,
      onGenerateRoute: rootGuard
          ? (settings) => MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const AuthGate(),
            )
          : null,
    ),
  );

  NavigatorState rootNavigator(WidgetTester tester) =>
      tester.state<NavigatorState>(find.byType(Navigator).first);

  /// Animatsiyalar tugashi uchun yetarli vaqt. `pumpAndSettle` ishlatilmaydi:
  /// yuklanish ekranidagi aylanma indikator hech qachon "tinchimaydi".
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Ekran daraxtini yopadi — to'siq sahifasining daqiqalik taymeri
  /// test oxirida osilib qolmasin.
  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
  }

  testWidgets('to\'siqqa o\'tganda ochiq sahifa va oyna yopiladi', (
    tester,
  ) async {
    await boot();
    unawaited(cubit.appStarted());
    await tester.pumpWidget(host());
    await tester.pump();

    final navigator = rootNavigator(tester);
    unawaited(
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('vazifa sahifasi')),
        ),
      ),
    );
    await settle(tester);
    unawaited(
      showDialog<void>(
        context: navigator.context,
        builder: (_) => const Dialog(child: Text('oyna')),
      ),
    );
    await settle(tester);
    expect(find.text('oyna'), findsOneWidget);

    repo.restore.complete(_blockedUser());
    await tester.pump();
    await settle(tester);

    expect(cubit.state.status, AuthStatus.outsideWorkHours);
    expect(find.byType(OutsideWorkHoursPage), findsOneWidget);
    expect(find.text('oyna'), findsNothing);
    expect(find.text('vazifa sahifasi'), findsNothing);
    expect(rootNavigator(tester).canPop(), isFalse);
    // Ish vaqtidan tashqarida ham push ulanadi (register-device ochiq)
    expect(push.connects, 1);
    await dispose(tester);
  });

  testWidgets(
    'oyna egasi uni xatodan keyin o\'zi yopsa ham ilova qora ekranda qolmaydi',
    (tester) async {
      await boot();
      unawaited(cubit.appStarted());
      await tester.pumpWidget(host());
      await tester.pump();

      final navigator = rootNavigator(tester);
      unawaited(
        showDialog<void>(
          context: navigator.context,
          barrierDismissible: false,
          builder: (_) => const Dialog(child: Text('o\'qilmoqda')),
        ),
      );
      await settle(tester);

      /* Skanerdagi kabi: so'rov 403 bilan qaytadi → holat to'siqqa
         o'tadi → xato bir necha mikrotopshiriqdan keyin chaqiruvchiga
         yetadi va u "o'qilmoqda" oynasini o'zi yopadi. */
      unawaited(
        repo.restore.future.then((_) async {
          await Future<void>.microtask(() {});
          await Future<void>.microtask(() {});
          navigator.pop();
        }),
      );
      repo.restore.complete(_blockedUser());
      await tester.pump();
      await settle(tester);

      expect(tester.takeException(), isNull);
      expect(cubit.state.status, AuthStatus.outsideWorkHours);
      expect(find.byType(OutsideWorkHoursPage), findsOneWidget);
      expect(find.text('o\'qilmoqda'), findsNothing);
      expect(rootNavigator(tester).canPop(), isFalse);
      await dispose(tester);
    },
  );

  testWidgets(
    'kech qolgan pop() (sahifa allaqachon yopilgan) ildizni olib tashlamaydi',
    (tester) async {
      await boot();
      unawaited(cubit.appStarted());
      await tester.pumpWidget(host(rootGuard: true));
      await tester.pump();

      final navigator = rootNavigator(tester);
      unawaited(
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('kamera')),
          ),
        ),
      );
      await settle(tester);

      repo.restore.complete(_blockedUser());
      await tester.pump();
      await tester.pump(); // keyingi kadrdan keyin sahifalar yopiladi
      expect(
        find.text('kamera'),
        findsOneWidget,
      ); // hali yopilish animatsiyasida

      /* Kamera sahifasi yopilish animatsiyasi paytida hali "mounted":
         surat tayyor bo'lgach u o'zini pop() qiladi — chaqiriq endi
         ildizga tushadi. */
      navigator.pop();
      await settle(tester);

      expect(tester.takeException(), isNull);
      expect(find.byType(OutsideWorkHoursPage), findsOneWidget);
      expect(find.text('kamera'), findsNothing);
      expect(rootNavigator(tester).canPop(), isFalse);
      await dispose(tester);
    },
  );

  testWidgets('ildiz himoyasi oddiy ishga tegmaydi: ustidagi sahifa yopiladi', (
    tester,
  ) async {
    await boot();
    unawaited(cubit.appStarted());
    await tester.pumpWidget(host(rootGuard: true));
    await tester.pump();

    final navigator = rootNavigator(tester);
    unawaited(
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('sahifa')),
        ),
      ),
    );
    await settle(tester);
    expect(navigator.canPop(), isTrue);
    navigator.pop();
    await settle(tester);
    expect(find.text('sahifa'), findsNothing);
    expect(navigator.canPop(), isFalse);
    // Tizimning "orqaga" tugmasi ildizda avvalgidek ilovadan chiqaradi
    expect(await navigator.maybePop(), isFalse);
    await dispose(tester);
  });
}
