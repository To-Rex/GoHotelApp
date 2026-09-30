import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gohotels/app/theme/app_theme.dart';
import 'package:gohotels/core/widgets/app_nav_bar.dart';
import 'package:gohotels/core/widgets/glass.dart';

/// Shisha qatlamlarining ish tartibi.
///
/// Bu yerda RANG emas, TUZILISH tekshiriladi: ekranda nechta blur va nechta
/// fon o'qishi bor. Har biri mobil GPU'da alohida render o'tishi — soni
/// oshib ketsa ilova qotib ishlaydi (avvalgi 6 pog'onali zina aynan shu
/// sababdan olib tashlandi). Regressiya aynan shu shaklda qaytadi.
void main() {
  Widget host(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: SizedBox(height: 120, child: child)),
  );

  testWidgets('ProgressiveGlass — bitta blur, bitta guruh', (tester) async {
    await tester.pumpWidget(
      host(const ProgressiveGlass(strongEdge: VerticalDirection.down)),
    );
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.byType(BackdropGroup), findsOneWidget);
  });

  testWidgets("blursiz rejim (maxSigma: 0) fonni umuman o'qimaydi", (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const ProgressiveGlass(strongEdge: VerticalDirection.down, maxSigma: 0),
      ),
    );
    // Faqat rang gradienti — GPU uchun deyarli bepul
    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.byType(BackdropGroup), findsNothing);
  });

  testWidgets("tepada guruh bo'lsa yangisi ochilmaydi", (tester) async {
    await tester.pumpWidget(
      host(
        BackdropGroup(
          child: const ProgressiveGlass(strongEdge: VerticalDirection.up),
        ),
      ),
    );
    expect(find.byType(BackdropGroup), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets("GlassIsland yolg'iz ham ishlaydi — guruhsiz oddiy filtr", (
    tester,
  ) async {
    await tester.pumpWidget(
      host(GlassIsland(child: const SizedBox(width: 120, height: 48))),
    );
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.byType(BackdropGroup), findsNothing);
  });

  testWidgets("GlassScope: appbar + pastki panel — 1 o'qish, 2 blur", (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: GlassScope(
          child: Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            appBar: const GlassAppBar(title: Text('Sarlavha')),
            body: const SizedBox.expand(),
            bottomNavigationBar: AppNavBar(
              selectedIndex: 0,
              onSelected: (_) {},
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home), label: 'A'),
                NavigationDestination(icon: Icon(Icons.chat), label: 'B'),
              ],
            ),
          ),
        ),
      ),
    );

    // Ilgari bu ekran har kadrda 13 blur va 3 fon o'qishi edi. Endi: appbar
    // blur'i + kapsula blur'i (pastki zona blursiz), hammasi bitta guruhda.
    expect(find.byType(BackdropGroup), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNWidgets(2));
  });

  testWidgets("GlassScope ichma-ich o'ralsa bitta guruh qoladi", (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const GlassScope(
          child: GlassScope(
            child: ProgressiveGlass(strongEdge: VerticalDirection.up),
          ),
        ),
      ),
    );
    expect(find.byType(BackdropGroup), findsOneWidget);
  });
}
