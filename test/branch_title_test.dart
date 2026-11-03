import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gohotels/app/theme/app_theme.dart';
import 'package:gohotels/core/services/biometric_service.dart';
import 'package:gohotels/core/storage/app_prefs.dart';
import 'package:gohotels/core/widgets/glass.dart';
import 'package:gohotels/features/auth/data/auth_repository.dart';
import 'package:gohotels/features/auth/domain/staff_user.dart';
import 'package:gohotels/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gohotels/features/auth/presentation/widgets/branch_title.dart';
import 'package:gohotels/l10n/gen/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Administrator bosh sahifasi sarlavhasi: joriy filial — katta nom,
/// bosilsa almashtirish oynasi; salom va ism yuqori qatorda. Oddiy
/// (68) balandlikdagi app bar'ga sig'adi.

StaffUser _admin({String branchId = 'b1', String branchName = 'Markaz'}) => StaffUser(
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

  @override
  Future<StaffUser?> restoreSession() async => restored;

  @override
  Future<List<BranchOption>> branchOptions(String hotelId) async => _branches;

  @override
  Future<StaffUser> switchBranch({required String hotelId, required String branchId}) async {
    switched.add('$hotelId/$branchId');
    return _admin(branchId: branchId, branchName: _branches.firstWhere((b) => b.id == branchId).name);
  }
}

class _NoBiometrics extends Fake implements BiometricService {
  @override
  Future<bool> get isAvailable async => false;
}

Future<AuthCubit> _signedIn(_FakeAuthRepo repo, StaffUser user) async {
  SharedPreferences.setMockInitialValues({});
  repo.restored = user;
  final cubit = AuthCubit(
    repository: repo,
    prefs: AppPrefs(await SharedPreferences.getInstance()),
    biometrics: _NoBiometrics(),
  );
  addTearDown(cubit.close);
  await cubit.appStarted();
  return cubit;
}

Future<void> _pump(WidgetTester tester, AuthCubit cubit) async {
  tester.view.physicalSize = const Size(360 * 3, 740 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
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
        home: const Scaffold(
          extendBodyBehindAppBar: true,
          appBar: GlassAppBar(title: BranchTitle(greeting: 'Xayrli kun, Aziz')),
          body: SizedBox.expand(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('salom va ism yuqorida, filial — sarlavha, app bar oddiy balandlikda', (tester) async {
    final repo = _FakeAuthRepo();
    late AuthCubit cubit;
    await tester.runAsync(() async => cubit = await _signedIn(repo, _admin()));
    await _pump(tester, cubit);

    expect(find.text('Xayrli kun, Aziz'), findsOneWidget);
    expect(find.text('Markaz'), findsOneWidget);
    expect(tester.getSize(find.byType(BranchTitle)).height, lessThanOrEqualTo(68));
    // Sarlavha tugma sifatida e'lon qilinadi (ekran o'quvchi uchun nom + harakat)
    expect(find.bySemanticsLabel(RegExp('Markaz · Filialni almashtirish')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sarlavha bosilsa oyna ochiladi, tanlangach yangi filial sarlavhada', (tester) async {
    final repo = _FakeAuthRepo();
    late AuthCubit cubit;
    await tester.runAsync(() async => cubit = await _signedIn(repo, _admin()));
    await _pump(tester, cubit);

    await tester.tap(find.text('Markaz'));
    await tester.pumpAndSettle();
    expect(find.text('Filialni almashtirish'), findsOneWidget);
    expect(find.text('Chilonzor'), findsOneWidget);
    expect(find.text('MRK · Asosiy filial'), findsOneWidget);

    await tester.tap(find.text('Chilonzor'));
    await tester.pumpAndSettle();
    expect(repo.switched, ['h1/b2']);
    expect(find.text('Filialni almashtirish'), findsNothing);
    // Sarlavha yangi filialni ko'rsatadi
    expect(find.text('Chilonzor'), findsOneWidget);
    expect(find.text('Markaz'), findsNothing);
  });

  testWidgets('uzun filial nomi bir qatorda qisqaradi, belgi ko\'rinib turadi', (tester) async {
    final repo = _FakeAuthRepo();
    late AuthCubit cubit;
    await tester.runAsync(() async {
      cubit = await _signedIn(repo, _admin(branchName: 'Toshkent shahar Yunusobod tumani markaziy filiali'));
    });
    await _pump(tester, cubit);
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(BranchTitle)).height, lessThanOrEqualTo(68));
    expect(find.byIcon(Icons.abc), findsNothing);
  });
}
