import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gohotels/app/theme/app_theme.dart';
import 'package:gohotels/core/network/api_client.dart';
import 'package:gohotels/core/network/api_exception.dart';
import 'package:gohotels/core/services/biometric_service.dart';
import 'package:gohotels/core/storage/app_prefs.dart';
import 'package:gohotels/core/storage/token_store.dart';
import 'package:gohotels/features/auth/data/auth_repository.dart';
import 'package:gohotels/features/auth/domain/staff_user.dart';
import 'package:gohotels/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gohotels/features/auth/presentation/widgets/branch_switch_sheet.dart';
import 'package:gohotels/l10n/gen/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Filiallar to'liq ajratilgan: administrator o'z mehmonxonasining filiallari
/// orasida o'tadi (`POST /auth/context` → yangi tokenlar → `/auth/me`),
/// xodim esa faqat o'z filialida ishlaydi.

StaffUser _admin({String branchId = 'b1', String branchName = 'Markaz'}) =>
    StaffUser(
      id: 'u1',
      userType: 'ADMIN',
      username: 'admin',
      firstName: 'Aziz',
      lastName: 'Karimov',
      permissions: const [],
      hotelId: 'h1',
      hotelName: 'Grand Hotel',
      branchId: branchId,
      branchName: branchName,
    );

const _branches = [
  BranchOption(id: 'b1', name: 'Markaz', code: 'MRK', isMain: true),
  BranchOption(id: 'b2', name: 'Chilonzor', code: 'CHL'),
];

class _FakeAuthRepo extends Fake implements AuthRepository {
  StaffUser? restored;
  final List<String> switched = [];
  ApiException? failWith;

  @override
  Future<StaffUser?> restoreSession() async => restored;

  @override
  Future<List<BranchOption>> branchOptions(String hotelId) async => _branches;

  @override
  Future<StaffUser> switchBranch({
    required String hotelId,
    required String branchId,
  }) async {
    final error = failWith;
    if (error != null) throw error;
    switched.add('$hotelId/$branchId');
    final name = _branches.firstWhere((b) => b.id == branchId).name;
    return _admin(branchId: branchId, branchName: name);
  }
}

class _NoBiometrics extends Fake implements BiometricService {
  @override
  Future<bool> get isAvailable async => false;
}

Future<AppPrefs> _prefs() async {
  SharedPreferences.setMockInitialValues({});
  return AppPrefs(await SharedPreferences.getInstance());
}

Future<AuthCubit> _signedIn(_FakeAuthRepo repo, StaffUser user) async {
  repo.restored = user;
  final cubit = AuthCubit(
    repository: repo,
    prefs: await _prefs(),
    biometrics: _NoBiometrics(),
  );
  addTearDown(cubit.close);
  await cubit.appStarted();
  return cubit;
}

/// So'rovlarni yozib, yo'lga qarab javob beradigan adapter.
class _RouteAdapter implements HttpClientAdapter {
  final List<String> calls = [];
  final List<dynamic> bodies = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add('${options.method} ${options.path}');
    bodies.add(options.data);
    final body = switch (options.path) {
      '/auth/context' => {'access_token': 'new-access', 'refresh_token': 'new-refresh'},
      '/auth/me' => {
        'id': 'u1',
        'user_type': 'ADMIN',
        'username': 'admin',
        'hotel_id': 'h1',
        'hotel_name': 'Grand Hotel',
        'branch_id': 'b2',
        'branch_name': 'Chilonzor',
      },
      '/auth/context/options' => {
        'hotels': [
          {
            'id': 'h1',
            'name': 'Grand Hotel',
            'branches': [
              {'id': 'b1', 'name': 'Markaz', 'code': 'MRK', 'is_main': true},
              {'id': 'b2', 'name': 'Chilonzor', 'code': 'CHL', 'is_main': false},
            ],
          },
        ],
      },
      _ => <String, dynamic>{},
    };
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StaffUser — filial', () {
    test('branch_name o\'qiladi, administrator filial tanlay oladi', () {
      final user = StaffUser.fromJson({
        'id': 'u1',
        'user_type': 'ADMIN',
        'hotel_id': 'h1',
        'branch_id': 'b1',
        'branch_name': 'Markaz',
      });
      expect(user.branchName, 'Markaz');
      expect(user.canSwitchBranch, isTrue);
    });

    test('xodim va mehmonxonasiz hisob filial tanlamaydi', () {
      final employee = StaffUser.fromJson({
        'id': 'u2',
        'user_type': 'EMPLOYEE',
        'hotel_id': 'h1',
        'branch_id': 'b1',
      });
      expect(employee.canSwitchBranch, isFalse);
      final configurator = StaffUser.fromJson({'id': 'u3', 'user_type': 'CONFIGURATOR'});
      expect(configurator.canSwitchBranch, isFalse);
    });

    test('filial tenglikka kiradi — almashganda ekran yangilanadi', () {
      expect(_admin(), equals(_admin()));
      expect(_admin(branchId: 'b2'), isNot(equals(_admin())));
    });
  });

  group('AuthCubit.switchBranch', () {
    test('yangi filial holatga yoziladi, ustidagi sahifalar yopilishi belgilanadi', () async {
      final repo = _FakeAuthRepo();
      final cubit = await _signedIn(repo, _admin());
      final error = await cubit.switchBranch('b2');
      expect(error, isNull);
      expect(repo.switched, ['h1/b2']);
      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.user!.branchId, 'b2');
      expect(cubit.state.user!.branchName, 'Chilonzor');
      expect(cubit.branchJustSwitched, isTrue);
    });

    test('o\'sha filial — so\'rov ketmaydi', () async {
      final repo = _FakeAuthRepo();
      final cubit = await _signedIn(repo, _admin());
      expect(await cubit.switchBranch('b1'), isNull);
      expect(repo.switched, isEmpty);
      expect(cubit.branchJustSwitched, isFalse);
    });

    test('xodim filial almashtira olmaydi', () async {
      final repo = _FakeAuthRepo();
      final employee = StaffUser(
        id: 'u2',
        userType: 'EMPLOYEE',
        username: 'farrosh',
        firstName: 'D',
        lastName: 'K',
        permissions: const [],
        hotelId: 'h1',
        branchId: 'b1',
      );
      final cubit = await _signedIn(repo, employee);
      expect(await cubit.switchBranch('b2'), isNull);
      expect(repo.switched, isEmpty);
      expect(cubit.state.user!.branchId, 'b1');
    });

    test('server rad etsa — xato matni, holat o\'zgarmaydi', () async {
      final repo = _FakeAuthRepo()
        ..failWith = const ApiException(
          message: 'Faqat o\'z mehmonxonangiz filialini tanlay olasiz',
          statusCode: 403,
          code: 'CONTEXT_FORBIDDEN',
        );
      final cubit = await _signedIn(repo, _admin());
      final error = await cubit.switchBranch('b2');
      expect(error, contains('filialini'));
      expect(cubit.state.user!.branchId, 'b1');
    });
  });

  group('AuthRepository — /auth/context', () {
    test('tokenlar avval saqlanadi, keyin /auth/me yangi filialni qaytaradi', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final tokens = TokenStore(const FlutterSecureStorage());
      final api = ApiClient(tokenStore: tokens, prefs: await _prefs());
      final adapter = _RouteAdapter();
      api.raw.httpClientAdapter = adapter;
      final repo = AuthRepository(api: api, tokens: tokens);

      final options = await repo.branchOptions('h1');
      expect(options.map((b) => b.name), ['Markaz', 'Chilonzor']);
      expect(options.first.isMain, isTrue);

      final user = await repo.switchBranch(hotelId: 'h1', branchId: 'b2');
      expect(adapter.calls, ['GET /auth/context/options', 'POST /auth/context', 'GET /auth/me']);
      expect(adapter.bodies[1], {'hotel_id': 'h1', 'branch_id': 'b2'});
      expect(tokens.accessToken, 'new-access');
      expect(user.branchId, 'b2');
      expect(user.branchName, 'Chilonzor');
    });
  });

  testWidgets('oyna filiallarni ko\'rsatadi va tanlangani almashtiriladi', (tester) async {
    final repo = _FakeAuthRepo();
    late AuthCubit cubit;
    await tester.runAsync(() async {
      cubit = await _signedIn(repo, _admin());
    });
    await tester.pumpWidget(
      BlocProvider.value(
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
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showBranchSwitchSheet(context),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Filialni almashtirish'), findsOneWidget);
    expect(find.text('Markaz'), findsOneWidget);
    expect(find.text('Chilonzor'), findsOneWidget);
    expect(find.text('MRK · Asosiy filial'), findsOneWidget);

    await tester.tap(find.text('Chilonzor'));
    await tester.pumpAndSettle();
    expect(repo.switched, ['h1/b2']);
    expect(cubit.state.user!.branchId, 'b2');
    // Oyna yopildi
    expect(find.text('Filialni almashtirish'), findsNothing);
  });
}
