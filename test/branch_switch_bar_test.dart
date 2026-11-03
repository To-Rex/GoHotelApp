import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gohotels/app/theme/app_theme.dart';
import 'package:gohotels/core/network/api_exception.dart';
import 'package:gohotels/core/services/biometric_service.dart';
import 'package:gohotels/core/storage/app_prefs.dart';
import 'package:gohotels/core/widgets/glass.dart';
import 'package:gohotels/features/auth/data/auth_repository.dart';
import 'package:gohotels/features/auth/domain/staff_user.dart';
import 'package:gohotels/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gohotels/features/auth/presentation/widgets/branch_switch_bar.dart';
import 'package:gohotels/l10n/gen/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Administrator bosh sahifasidagi filiallar qatori: joriy filial
/// to'ldirilgan, boshqasi bir bosishda almashadi, joriy filial bosilsa
/// batafsil oyna ochiladi; ro'yxat kelmasa ham joriy filial turadi.

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
  BranchOption(id: 'b3', name: 'Yunusobod', code: 'YUN'),
];

class _FakeAuthRepo extends Fake implements AuthRepository {
  _FakeAuthRepo({this.optionsFail = false, this.switchFail});
  StaffUser? restored;
  final bool optionsFail;
  final ApiException? switchFail;
  final List<String> switched = [];
  int optionCalls = 0;

  @override
  Future<StaffUser?> restoreSession() async => restored;

  @override
  Future<List<BranchOption>> branchOptions(String hotelId) async {
    optionCalls++;
    if (optionsFail) throw const ApiException(message: 'Server xatosi', statusCode: 500);
    return _branches;
  }

  @override
  Future<StaffUser> switchBranch({required String hotelId, required String branchId}) async {
    final error = switchFail;
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
        home: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: const GlassAppBar(title: Text('Bosh sahifa'), bottom: BranchSwitchBar()),
          body: const SizedBox.expand(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(BranchSwitchBar.clearCache);

  testWidgets('barcha filiallar qatorda, joriysi belgilangan', (tester) async {
    final repo = _FakeAuthRepo();
    late AuthCubit cubit;
    await tester.runAsync(() async => cubit = await _signedIn(repo, _admin()));
    await _pump(tester, cubit);

    for (final b in _branches) {
      expect(find.text(b.name), findsOneWidget);
    }
    expect(tester.getSemantics(find.bySemanticsLabel(RegExp('^Markaz'))), isSemantics(isSelected: true));
    expect(tester.getSemantics(find.bySemanticsLabel('Chilonzor')), isSemantics(isSelected: false));
  });

  testWidgets('boshqa filial bosilsa darhol almashadi', (tester) async {
    final repo = _FakeAuthRepo();
    late AuthCubit cubit;
    await tester.runAsync(() async => cubit = await _signedIn(repo, _admin()));
    await _pump(tester, cubit);

    await tester.tap(find.text('Chilonzor'));
    await tester.pumpAndSettle();
    expect(repo.switched, ['h1/b2']);
    expect(cubit.state.user!.branchId, 'b2');
    expect(tester.getSemantics(find.bySemanticsLabel(RegExp('^Chilonzor'))), isSemantics(isSelected: true));
    // Oyna ochilmaydi — bir bosishda almashdi
    expect(find.text('Filialni almashtirish'), findsNothing);
  });

  testWidgets('joriy filial bosilsa batafsil oyna ochiladi', (tester) async {
    final repo = _FakeAuthRepo();
    late AuthCubit cubit;
    await tester.runAsync(() async => cubit = await _signedIn(repo, _admin()));
    await _pump(tester, cubit);

    await tester.tap(find.text('Markaz'));
    await tester.pumpAndSettle();
    expect(find.text('Filialni almashtirish'), findsOneWidget);
    expect(find.text('MRK · Asosiy filial'), findsOneWidget);
    expect(repo.switched, isEmpty);
  });

  testWidgets('server rad etsa — xato matni, filial o\'zgarmaydi', (tester) async {
    final repo = _FakeAuthRepo(
      switchFail: const ApiException(message: 'Faqat o\'z mehmonxonangiz filialini tanlay olasiz', statusCode: 403),
    );
    late AuthCubit cubit;
    await tester.runAsync(() async => cubit = await _signedIn(repo, _admin()));
    await _pump(tester, cubit);

    await tester.tap(find.text('Chilonzor'));
    await tester.pumpAndSettle();
    expect(cubit.state.user!.branchId, 'b1');
    expect(find.textContaining('filialini'), findsOneWidget);
    // Qator yana bosiladigan holatda
    expect(tester.getSemantics(find.bySemanticsLabel(RegExp('^Markaz'))), isSemantics(isSelected: true));
  });

  testWidgets('ro\'yxat kelmasa — faqat joriy filial, bosilsa oyna', (tester) async {
    final repo = _FakeAuthRepo(optionsFail: true);
    late AuthCubit cubit;
    await tester.runAsync(() async => cubit = await _signedIn(repo, _admin()));
    await _pump(tester, cubit);

    expect(find.text('Markaz'), findsOneWidget);
    expect(find.text('Chilonzor'), findsNothing);
    await tester.tap(find.text('Markaz'));
    await tester.pumpAndSettle();
    expect(find.text('Filialni almashtirish'), findsOneWidget);
  });

  testWidgets('ro\'yxat sessiya davomida bir marta so\'raladi', (tester) async {
    final repo = _FakeAuthRepo();
    late AuthCubit cubit;
    await tester.runAsync(() async => cubit = await _signedIn(repo, _admin()));
    await _pump(tester, cubit);
    expect(repo.optionCalls, 1);
    await tester.pumpWidget(const SizedBox());
    await _pump(tester, cubit);
    expect(repo.optionCalls, 1);
    expect(find.text('Yunusobod'), findsOneWidget);
  });
}
