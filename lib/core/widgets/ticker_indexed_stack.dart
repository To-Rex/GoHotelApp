import 'package:flutter/widgets.dart';

/// [IndexedStack] — faqat KO'RINAYOTGAN bola animatsiya qiladi.
///
/// Oddiy [IndexedStack] yashirin bolalarni chizmaydi, lekin ularning
/// animatsiyalari (skelet pulsatsiyasi, spinner) ishlashda davom etadi:
/// har tik butun ekranni qayta chizdiradi, shisha panellar bilan bu har
/// kadrda o'nlab blur o'tishi degani — foydalanuvchi esa hech narsa
/// ko'rmaydi. Ilova ochilganda hamma tab bir vaqtda yuklanadi: aynan shu
/// paytda ko'rinmas 2–3 skelet 60 fps'da "ishlab" turar, ilova birinchi
/// soniyalarda qotib ishlardi.
///
/// [TickerMode] yashirin bolaning tiker'larini uxlatadi. Holat, skroll o'rni,
/// kubitlar va polling (Timer — tiker emas) o'z holicha qoladi; tab
/// ochilganda animatsiya joyidan davom etadi.
class TickerIndexedStack extends StatelessWidget {
  const TickerIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: index,
      children: [
        for (var i = 0; i < children.length; i++)
          TickerMode(enabled: i == index, child: children[i]),
      ],
    );
  }
}
