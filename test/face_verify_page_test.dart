import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gohotels/app/theme/app_theme.dart';
import 'package:gohotels/core/services/biometric_service.dart';
import 'package:gohotels/core/storage/app_prefs.dart';
import 'package:gohotels/features/auth/data/auth_repository.dart';
import 'package:gohotels/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gohotels/features/auth/presentation/pages/face_verify_page.dart';
import 'package:gohotels/l10n/gen/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Yuz bosqichi: hisobga faqat biriktirilgan yuz bilan kiriladi —
/// "Kamerasiz kirish" faqat server yuzni tekshira olmaganda ko'rinadi.

class _Repo extends Fake implements AuthRepository {}

class _NoBiometrics extends Fake implements BiometricService {
  @override
  Future<bool> get isAvailable async => false;
}

class _TestCubit extends AuthCubit {
  _TestCubit({required super.repository, required super.prefs, required super.biometrics});

  void set(AuthState state) => emit(state);
}

Future<_TestCubit> _cubit() async {
  SharedPreferences.setMockInitialValues({});
  final cubit = _TestCubit(
    repository: _Repo(),
    prefs: AppPrefs(await SharedPreferences.getInstance()),
    biometrics: _NoBiometrics(),
  );
  addTearDown(cubit.close);
  return cubit;
}

/// Telefon ekrani (sinov muhitidagi 800×600 emas)
void _phoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Widget _host(AuthCubit cubit) => BlocProvider<AuthCubit>.value(
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
    home: const FaceVerifyPage(),
  ),
);

void main() {
  testWidgets('yuz bosqichida "Kamerasiz kirish" tugmasi yo\'q', (tester) async {
    _phoneScreen(tester);
    final cubit = await _cubit();
    cubit.set(const AuthState(status: AuthStatus.faceStep, faceToken: 't'));
    await tester.pumpWidget(_host(cubit));
    await tester.pumpAndSettle();
    expect(find.text('Kamerasiz kirish'), findsNothing);
    expect(find.textContaining('faqat biriktirilgan yuz'), findsOneWidget);
    expect(find.text('Kamerani ochish'), findsOneWidget);
  });

  testWidgets('server yuzni tekshira olmasa — tugma chiqadi', (tester) async {
    _phoneScreen(tester);
    final cubit = await _cubit();
    cubit.set(
      const AuthState(
        status: AuthStatus.faceStep,
        faceToken: 't',
        error: 'Bu serverda yuz tekshiruvi mavjud emas',
        errorCode: 'FACE_ENGINE_UNAVAILABLE',
      ),
    );
    await tester.pumpWidget(_host(cubit));
    await tester.pumpAndSettle();
    expect(find.text('Kamerasiz kirish'), findsOneWidget);
  });
}
