import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gohotels/core/widgets/ticker_indexed_stack.dart';

/// Ko'rinmas tabning animatsiyasi ekranni qayta chizdirmasligi kerak.
///
/// Oddiy IndexedStack yashirin bolalarning tiker'larini ishlatib qo'yadi:
/// ilova ochilganda 2–3 ta ko'rinmas skelet 60 fps'da "ishlab", shisha
/// panellar bilan birga butun ilovani qotirib turardi.
void main() {
  // Stack yo'nalishni talab qiladi — ilovada uni MaterialApp beradi
  Widget host(Widget child) =>
      Directionality(textDirection: TextDirection.ltr, child: child);

  Widget probe(Map<int, bool> modes, int i) => Builder(
    builder: (context) {
      modes[i] = TickerMode.valuesOf(context).enabled;
      return const SizedBox();
    },
  );

  testWidgets("faqat ko'rinayotgan tab tiker'lari ishlaydi", (tester) async {
    final modes = <int, bool>{};
    await tester.pumpWidget(
      host(
        TickerIndexedStack(
          index: 1,
          children: [probe(modes, 0), probe(modes, 1), probe(modes, 2)],
        ),
      ),
    );
    expect(modes, {0: false, 1: true, 2: false});

    // Tab almashdi — eskisi uxlaydi, yangisi uyg'onadi
    await tester.pumpWidget(
      host(
        TickerIndexedStack(
          index: 2,
          children: [probe(modes, 0), probe(modes, 1), probe(modes, 2)],
        ),
      ),
    );
    expect(modes, {0: false, 1: false, 2: true});
  });

  testWidgets('yashirin bolaning holati saqlanadi', (tester) async {
    Widget stack(int index) => host(
      TickerIndexedStack(
        index: index,
        children: const [
          _Counter(key: ValueKey('a')),
          SizedBox(),
        ],
      ),
    );

    await tester.pumpWidget(stack(0));
    await tester.tap(find.byKey(const ValueKey('a')));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    // Boshqa tabga o'tib qaytganda hisob yo'qolmaydi — IndexedStack'ning
    // holat saqlash xatti-harakati o'zgarmagan (aks holda '0' ko'rinardi)
    await tester.pumpWidget(stack(1));
    await tester.pumpWidget(stack(0));
    expect(find.text('1'), findsOneWidget);
  });
}

class _Counter extends StatefulWidget {
  const _Counter({super.key});

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => setState(() => _count++),
    child: SizedBox(width: 50, height: 50, child: Text('$_count')),
  );
}
