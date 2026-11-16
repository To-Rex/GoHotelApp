import 'package:flutter/widgets.dart';

/// Bo'sh joyga bosilganda klaviaturani yopadi (iOS uchun).
///
/// Androidda klaviatura tizimning "orqaga" tugmasi bilan yopiladi. iPhone'da
/// esa bunday tugma yo'q: raqam klaviaturasida "Tayyor" tugmasi yo'q, ko'p
/// qatorli maydonda (chat, izoh) "Enter" yangi qator ochadi. Shu sababli
/// klaviaturani yopishning yo'li qolmaydi.
///
/// Bosish faqat hech kim olmagan joyda ishlaydi. Tugma, maydon yoki ro'yxat
/// qatori bosilsa, bosishni o'sha element oladi va klaviatura ochiq
/// qoladi. Masalan, chatda "Yuborish" bosilganda yozish davom etadi.
class KeyboardDismissOnTap extends StatelessWidget {
  const KeyboardDismissOnTap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );
  }
}
