import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gohotels/app/theme/app_theme.dart';
import 'package:gohotels/features/management/presentation/widgets/animated_counter.dart';
import 'package:gohotels/features/management/presentation/widgets/distribution_bar.dart';
import 'package:gohotels/features/management/presentation/widgets/income_sparkline.dart';
import 'package:gohotels/features/management/presentation/widgets/occupancy_ring.dart';
import 'package:gohotels/features/management/presentation/widgets/segmented_tabs.dart';
import 'package:gohotels/features/management/presentation/widgets/stagger_in.dart';
import 'package:gohotels/features/management/presentation/widgets/stat_tabs.dart';

/// Boshqaruv vidjetlari chiziladimi va animatsiyasi tugaydimi.
///
/// CustomPainter'lar (halqa, chiziq) chekka qiymatlarda — bo'sh ro'yxat,
/// nol jami, bitta nuqta — yiqilmasligi kerak: ma'lumot hali kelmagan
/// paytda ham ekran turadi.
void main() {
  Widget host(Widget child) => MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(body: Center(child: SizedBox(width: 320, child: child))),
  );

  testWidgets('OccupancyRing nol jami va bo\'sh bo\'laklar bilan chiziladi', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const OccupancyRing(
          segments: [],
          total: 0,
          trackColor: Colors.grey,
          child: Text('0%'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('0%'), findsOneWidget);

    await tester.pumpWidget(
      host(
        const OccupancyRing(
          segments: [
            RingSegment(value: 3, color: Colors.red),
            RingSegment(value: 1, color: Colors.blue),
          ],
          total: 8,
          trackColor: Colors.grey,
          child: Text('38%'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('38%'), findsOneWidget);
  });

  testWidgets('IncomeSparkline: hamma nol, bitta nuqta va oddiy qator', (
    tester,
  ) async {
    const style = TextStyle(fontSize: 10);
    for (final values in [
      <double>[0, 0, 0],
      <double>[120],
      <double>[10, 40, 25, 80, 60, 0, 30],
    ]) {
      await tester.pumpWidget(
        host(
          IncomeSparkline(
            values: values,
            labels: [for (var i = 0; i < values.length; i++) 'd$i'],
            color: Colors.blue,
            labelStyle: style,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('d0'), findsOneWidget);
    }
  });

  testWidgets('SegmentedTabs bosilganda indeks qaytadi, belgi ko\'rinadi', (
    tester,
  ) async {
    int? picked;
    await tester.pumpWidget(
      host(
        SegmentedTabs(
          items: const [
            SegmentItem(label: 'A'),
            SegmentItem(label: 'B', badge: 3),
            SegmentItem(label: 'C', badge: 0),
          ],
          selected: 0,
          onSelected: (i) => picked = i,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('3'), findsOneWidget); // B belgisi
    expect(find.text('0'), findsNothing); // nol belgi chizilmaydi
    await tester.tap(find.text('B'));
    expect(picked, 1);
  });

  testWidgets('StatTabs: sonlar va nomlar ko\'rinadi, bosilganda indeks', (
    tester,
  ) async {
    int? picked;
    await tester.pumpWidget(
      host(
        StatTabs(
          items: const [
            StatTab(label: 'Xodimlar', count: 6),
            StatTab(label: 'Smenalar', count: 0),
            StatTab(label: 'Muammolar', count: 12),
          ],
          selected: 0,
          onSelected: (i) => picked = i,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('6'), findsOneWidget);
    expect(find.text('0'), findsOneWidget); // nol ham ko'rsatiladi
    await tester.tap(find.text('Muammolar'));
    expect(picked, 2);
  });

  testWidgets('DistributionBar bo\'laklari ko\'rinadi (balandligi nol emas)', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const DistributionBar(
          height: 8,
          trackColor: Colors.grey,
          segments: [
            DistributionSegment(value: 3, color: Colors.red),
            DistributionSegment(value: 0, color: Colors.green),
            DistributionSegment(value: 1, color: Colors.blue),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Yo'lak + ikki bo'lak; nol qiymatli bo'lak chizilmaydi
    final boxes = find.byType(ColoredBox);
    expect(boxes, findsNWidgets(3));
    final red = tester.getSize(boxes.at(1));
    final blue = tester.getSize(boxes.at(2));
    // Bolasi yo'q ColoredBox Row ichida cho'zilmasa 0 balandlik olardi
    expect(red.height, 8);
    expect(blue.height, 8);
    expect(red.width, greaterThan(blue.width * 2.5));
  });

  testWidgets('StaggerIn hamma bolani chiqaradi va animatsiya tugaydi', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const StaggerIn(children: [Text('bir'), Text('ikki'), Text('uch')]),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('bir'), findsOneWidget);
    expect(find.text('uch'), findsOneWidget);
    // Tugagach Opacity o'rami olib tashlanadi — bola to'g'ridan-to'g'ri
    expect(find.byType(Opacity), findsNothing);
  });

  testWidgets('AnimatedCounter yakuniy qiymatga yetadi', (tester) async {
    await tester.pumpWidget(
      host(AnimatedCounter(value: 1250, format: (v) => v.round().toString())),
    );
    await tester.pumpAndSettle();
    expect(find.text('1250'), findsOneWidget);
  });
}
