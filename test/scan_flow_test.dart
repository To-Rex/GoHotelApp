import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gohotels/app/theme/app_theme.dart';
import 'package:gohotels/features/reception/scan/presentation/scan_flow.dart';
import 'package:gohotels/l10n/gen/app_localizations.dart';

/// Skaner oqimining birinchi oynasi — hujjat turini tanlash.
///
/// Bu oyna bir marta umuman chizilmay qolgan edi: ichidagi cheksiz
/// o'lchamli element layout'ni yiqitgan, ekranda esa faqat qorong'i
/// parda qolgan. Test aynan shu regressiyani ushlaydi: oyna XATOSIZ
/// ochilishi va ikkala tanlov ko'rinishi shart.
void main() {
  Widget host() => MaterialApp(
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
          child: FilledButton(
            onPressed: () => startDocumentScan(context),
            child: const Text('boshlash'),
          ),
        ),
      ),
    ),
  );

  testWidgets('tur tanlash oynasi xatosiz ochiladi', (tester) async {
    await tester.pumpWidget(host());
    await tester.tap(find.text('boshlash'));
    await tester.pumpAndSettle();

    // Layout yiqilgan bo'lsa shu yerda xato chiqadi
    expect(tester.takeException(), isNull);
    expect(find.text('ID karta'), findsOneWidget);
    expect(find.text('Passport'), findsOneWidget);
    expect(find.text('Hujjat turi'), findsOneWidget);
  });

  testWidgets('bekor qilish oynani yopadi', (tester) async {
    await tester.pumpWidget(host());
    await tester.tap(find.text('boshlash'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bekor qilish'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('ID karta'), findsNothing);
  });
}
