import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gohotels/core/network/api_client.dart';
import 'package:gohotels/core/network/api_exception.dart';
import 'package:gohotels/core/services/biometric_service.dart';
import 'package:gohotels/core/storage/app_prefs.dart';
import 'package:gohotels/core/storage/token_store.dart';
import 'package:gohotels/features/auth/data/auth_repository.dart';
import 'package:gohotels/features/auth/domain/staff_user.dart';
import 'package:gohotels/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ish vaqtidan tashqari ishlashni cheklash — ilova tomoni.
///
/// Qaror serverniki (`/auth/me` → `work_hours_blocked`, so'rovlarda
/// `403 OUTSIDE_WORK_HOURS`); ilova faqat to'g'ri ekranga o'tishi va
/// ish vaqti boshlanganda (server tasdig'i bilan) qaytishi kerak.

Map<String, dynamic> _meJson({
  Object? allow,
  Object? enforced,
  Object? blocked,
}) => {
  'id': 'u1',
  'user_type': 'EMPLOYEE',
  'username': 'farrosh',
  'first_name': 'Dilnoza',
  'last_name': 'Karimova',
  'permissions': ['housekeeping.task.update'],
  'hotel_id': 'h1',
  'work_start': '09:00',
  'work_end': '18:00',
  'allow_outside_work_hours': ?allow,
  'work_hours_enforced': ?enforced,
  'work_hours_blocked': ?blocked,
};

StaffUser _user({
  bool blocked = false,
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
  StaffUser? restored;

  /// Navbatdagi `me()` javoblari: [StaffUser] yoki tashlanadigan xato.
  final List<Object> meQueue = [];
  int meCalls = 0;
  bool loggedOut = false;

  /// Berilsa `me()` shu ochilguncha javob bermaydi (parallel so'rovlar).
  Completer<void>? meGate;

  @override
  Future<StaffUser?> restoreSession() async => restored;

  @override
  Future<LoginOutcome> login({
    required String username,
    required String password,
    String? fcmToken,
  }) async => const LoginSuccess();

  @override
  Future<StaffUser> me() async {
    meCalls++;
    final gate = meGate;
    if (gate != null) await gate.future;
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

Future<AppPrefs> _prefs() async {
  SharedPreferences.setMockInitialValues({});
  return AppPrefs(await SharedPreferences.getInstance());
}

Future<AuthCubit> _cubit(_FakeAuthRepo repo) async {
  final cubit = AuthCubit(
    repository: repo,
    prefs: await _prefs(),
    biometrics: _NoBiometrics(),
  );
  addTearDown(cubit.close);
  return cubit;
}

/// Ishlayotgan xodimni to'siq ekraniga olib keladi (403 orqali).
Future<AuthCubit> _blockedCubit(_FakeAuthRepo repo) async {
  repo.restored = _user();
  final cubit = await _cubit(repo);
  await cubit.appStarted();
  // Kirishdagi jim yangilash uchun javob
  repo.meQueue.add(_user(blocked: true));
  cubit.outsideWorkHours('Ish vaqtingiz emas (09:00–18:00).');
  await pumpEventQueue();
  return cubit;
}

/// Dio'ga tarmoqsiz javob beradigan adapter.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.status, this.body);

  final int status;
  final Map<String, dynamic> body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StaffUser.fromJson — ish vaqti maydonlari', () {
    test('eski server (maydonlarsiz): hech kim to\'silmaydi', () {
      final user = StaffUser.fromJson(_meJson());
      expect(user.allowOutsideWorkHours, isFalse);
      expect(user.workHoursEnforced, isFalse);
      expect(user.workHoursBlocked, isFalse);
      expect(user.workStart, '09:00');
      expect(user.workEnd, '18:00');
    });

    test('yangi maydonlar o\'qiladi', () {
      final user = StaffUser.fromJson(
        _meJson(allow: true, enforced: true, blocked: true),
      );
      expect(user.allowOutsideWorkHours, isTrue);
      expect(user.workHoursEnforced, isTrue);
      expect(user.workHoursBlocked, isTrue);
    });

    test('null yoki noto\'g\'ri turdagi qiymat — xavfsiz false', () {
      final user = StaffUser.fromJson({
        ..._meJson(),
        'allow_outside_work_hours': null,
        'work_hours_enforced': 'true',
        'work_hours_blocked': 1,
      });
      expect(user.allowOutsideWorkHours, isFalse);
      expect(user.workHoursEnforced, isFalse);
      expect(user.workHoursBlocked, isFalse);
    });

    test('tenglik ish vaqti va bayroqlarni ham hisobga oladi', () {
      expect(_user(), equals(_user()));
      expect(_user(), isNot(equals(_user(blocked: true))));
      expect(_user(), isNot(equals(_user(end: '20:00'))));
      expect(
        StaffUser.fromJson(_meJson()),
        isNot(equals(StaffUser.fromJson(_meJson(allow: true)))),
      );
    });
  });

  group('AuthCubit — ish vaqti', () {
    test(
      'ilova ochilganda to\'silgan xodim ish vaqti ekraniga tushadi',
      () async {
        final repo = _FakeAuthRepo()..restored = _user(blocked: true);
        final cubit = await _cubit(repo);
        await cubit.appStarted();
        expect(cubit.state.status, AuthStatus.outsideWorkHours);
        expect(cubit.state.user?.workHoursBlocked, isTrue);
      },
    );

    test('to\'silmagan xodim odatdagidek kiradi', () async {
      final repo = _FakeAuthRepo()..restored = _user();
      final cubit = await _cubit(repo);
      await cubit.appStarted();
      expect(cubit.state.status, AuthStatus.authenticated);
    });

    test(
      'login: server "hozir ish vaqti emas" desa — ish vaqti ekrani',
      () async {
        final repo = _FakeAuthRepo()..meQueue.add(_user(blocked: true));
        final cubit = await _cubit(repo);
        await cubit.appStarted(); // sessiya yo'q → login sahifasi
        expect(cubit.state.status, AuthStatus.unauthenticated);
        await cubit.login('farrosh', 'parol');
        expect(cubit.state.status, AuthStatus.outsideWorkHours);
        expect(cubit.state.submitting, isFalse);
      },
    );

    test('login: to\'silmagan bo\'lsa odatdagidek', () async {
      final repo = _FakeAuthRepo()..meQueue.add(_user());
      final cubit = await _cubit(repo);
      await cubit.appStarted();
      await cubit.login('farrosh', 'parol');
      expect(cubit.state.status, AuthStatus.authenticated);
    });

    test(
      '403: ishlayotgan xodim to\'siq ekraniga o\'tadi, sabab saqlanadi',
      () async {
        final repo = _FakeAuthRepo();
        final cubit = await _blockedCubit(repo);
        expect(cubit.state.status, AuthStatus.outsideWorkHours);
        expect(cubit.state.error, 'Ish vaqtingiz emas (09:00–18:00).');
        expect(cubit.state.errorCode, ApiException.outsideWorkHoursCode);
        expect(cubit.state.user, isNotNull);
      },
    );

    test('parallel 403\'lar bitta o\'tish beradi', () async {
      final repo = _FakeAuthRepo();
      final cubit = await _blockedCubit(repo);
      final calls = repo.meCalls;
      final before = cubit.state;
      cubit.outsideWorkHours('boshqa');
      cubit.outsideWorkHours('yana');
      await pumpEventQueue();
      expect(cubit.state, before);
      expect(repo.meCalls, calls);
    });

    test('kirmagan yoki xizmati to\'xtagan holatda 403 e\'tiborsiz', () async {
      final repo = _FakeAuthRepo();
      final cubit = await _cubit(repo);
      await cubit.appStarted();
      cubit.outsideWorkHours('x');
      expect(cubit.state.status, AuthStatus.unauthenticated);

      final repo2 = _FakeAuthRepo()..restored = _user();
      final cubit2 = await _cubit(repo2);
      await cubit2.appStarted();
      cubit2.serviceStopped('HOTEL_SUSPENDED', 'to\'xtatildi');
      cubit2.outsideWorkHours('x');
      expect(cubit2.state.status, AuthStatus.serviceStopped);
    });

    test(
      'kirishdagi jim yangilash soatni yangilaydi, lekin ekrandan chiqarmaydi',
      () async {
        final repo = _FakeAuthRepo()..restored = _user();
        final cubit = await _cubit(repo);
        await cubit.appStarted();
        // Administrator soatni o'zgartirgan; server allaqachon "to'siq yo'q"
        // desa ham chiqish faqat qayta tekshiruv orqali (miltillash yo'q).
        repo.meQueue.add(_user(start: '10:00', end: '19:00'));
        cubit.outsideWorkHours('x');
        await pumpEventQueue();
        expect(cubit.state.status, AuthStatus.outsideWorkHours);
        expect(cubit.state.user?.workStart, '10:00');
        expect(cubit.state.user?.workEnd, '19:00');
      },
    );

    test('qayta tekshirish: hali ish vaqti emas — ekranda qoladi', () async {
      final repo = _FakeAuthRepo();
      final cubit = await _blockedCubit(repo);
      repo.meQueue.add(_user(blocked: true, end: '17:00'));
      final resumed = await cubit.recheckWorkHours();
      expect(resumed, isFalse);
      expect(cubit.state.status, AuthStatus.outsideWorkHours);
      expect(cubit.state.submitting, isFalse);
      expect(cubit.state.user?.workEnd, '17:00');
    });

    test('qayta tekshirish: ish vaqti boshlandi — ish davom etadi', () async {
      final repo = _FakeAuthRepo();
      final cubit = await _blockedCubit(repo);
      repo.meQueue.add(_user());
      final resumed = await cubit.recheckWorkHours();
      expect(resumed, isTrue);
      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.user?.workHoursBlocked, isFalse);
      expect(cubit.state.error, isNull);
      expect(cubit.state.errorCode, isNull);
      expect(cubit.state.submitting, isFalse);
    });

    test(
      'qayta tekshirish: tarmoq xatosi — holat o\'zgarmaydi, xato qaytadi',
      () async {
        final repo = _FakeAuthRepo();
        final cubit = await _blockedCubit(repo);
        repo.meQueue.add(const ApiException(message: 'net', isNetwork: true));
        await expectLater(
          cubit.recheckWorkHours(),
          throwsA(isA<ApiException>()),
        );
        expect(cubit.state.status, AuthStatus.outsideWorkHours);
        expect(cubit.state.submitting, isFalse);
      },
    );

    test(
      'avtomatik tekshiruv jim, tugma bilan bir vaqtda — bitta so\'rov',
      () async {
        final repo = _FakeAuthRepo();
        final cubit = await _blockedCubit(repo);
        final calls = repo.meCalls;
        repo
          ..meGate = Completer<void>()
          ..meQueue.add(_user());

        final auto = cubit.recheckWorkHours(silent: true);
        await pumpEventQueue();
        expect(cubit.state.submitting, isFalse); // tugma miltillamaydi

        final manual = cubit.recheckWorkHours();
        expect(cubit.state.submitting, isTrue); // tugma kutish holatida

        repo.meGate!.complete();
        expect(await auto, isTrue);
        expect(await manual, isTrue);
        expect(repo.meCalls, calls + 1);
        expect(cubit.state.status, AuthStatus.authenticated);
      },
    );

    test(
      'to\'siq ekranidan boshqa holatda qayta tekshirish hech narsa qilmaydi',
      () async {
        final repo = _FakeAuthRepo()..restored = _user();
        final cubit = await _cubit(repo);
        await cubit.appStarted();
        expect(await cubit.recheckWorkHours(), isFalse);
        expect(repo.meCalls, 0);
        expect(cubit.state.status, AuthStatus.authenticated);
      },
    );

    test('sessiya tugasa (refresh o\'tmadi) — login sahifasi', () async {
      final repo = _FakeAuthRepo();
      final cubit = await _blockedCubit(repo);
      cubit.sessionExpired();
      expect(cubit.state.status, AuthStatus.unauthenticated);
    });

    test('chiqish — tokenlar tozalanadi, login sahifasi', () async {
      final repo = _FakeAuthRepo();
      final cubit = await _blockedCubit(repo);
      await cubit.logout();
      expect(repo.loggedOut, isTrue);
      expect(cubit.state.status, AuthStatus.unauthenticated);
    });
  });

  group('ApiClient — 403 OUTSIDE_WORK_HOURS', () {
    late ApiClient api;
    late List<String> outside;
    late List<String> stopped;

    setUp(() async {
      api = ApiClient(
        tokenStore: TokenStore(const FlutterSecureStorage()),
        prefs: await _prefs(),
      );
      outside = [];
      stopped = [];
      api
        ..onOutsideWorkHours = outside.add
        ..onServiceStopped = (code, _) => stopped.add(code);
    });

    void respond(int status, Map<String, dynamic> body) =>
        api.raw.httpClientAdapter = _StubAdapter(status, body);

    test(
      'kod tanilsa ekran almashadi, chaqiruvchi baribir xato oladi',
      () async {
        respond(403, {
          'detail': 'Ish vaqtingiz emas (09:00–18:00).',
          'error_code': 'OUTSIDE_WORK_HOURS',
        });
        await expectLater(
          api.get<dynamic>('/tasks'),
          throwsA(
            isA<ApiException>()
                .having((e) => e.isOutsideWorkHours, 'isOutsideWorkHours', true)
                .having((e) => e.isForbidden, 'isForbidden', true),
          ),
        );
        expect(outside, ['Ish vaqtingiz emas (09:00–18:00).']);
        expect(stopped, isEmpty);
      },
    );

    test('HOTEL_ kodi avvalgidek "xizmat to\'xtatildi"', () async {
      respond(403, {'detail': 'x', 'error_code': 'HOTEL_SUSPENDED'});
      await expectLater(
        api.get<dynamic>('/tasks'),
        throwsA(isA<ApiException>()),
      );
      expect(stopped, ['HOTEL_SUSPENDED']);
      expect(outside, isEmpty);
    });

    test('oddiy 403 hech qaysi ekranni ochmaydi', () async {
      respond(403, {'detail': 'Ruxsat yo\'q', 'error_code': 'FORBIDDEN'});
      await expectLater(
        api.get<dynamic>('/tasks'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.isOutsideWorkHours,
            'isOutsideWorkHours',
            false,
          ),
        ),
      );
      expect(outside, isEmpty);
      expect(stopped, isEmpty);
    });

    test('kirish yo\'llarida ekran almashmaydi', () async {
      respond(403, {'detail': 'x', 'error_code': 'OUTSIDE_WORK_HOURS'});
      await expectLater(
        api.post<dynamic>('/auth/login', data: {}),
        throwsA(isA<ApiException>()),
      );
      expect(outside, isEmpty);
    });
  });
}
