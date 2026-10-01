import 'package:flutter_bloc/flutter_bloc.dart';

/// Yopilgan cubit'ga kech kelgan javobni jim tashlab yuboradi.
///
/// Ilova holati almashganda (xizmat to'xtatildi, ish vaqti tugadi) bo'lim
/// qobig'i yopiladi va o'z cubit'larini yopadi, yo'lda qolgan so'rovlar
/// esa keyinroq qaytadi. Oddiy `emit` bunda `StateError` tashlardi —
/// ekranga ta'siri yo'q, faqat jurnalni xatolar bilan to'ldirardi.
/// Ochiq cubit uchun hech narsa o'zgarmaydi.
mixin SafeEmit<S> on Cubit<S> {
  @override
  void emit(S state) {
    if (isClosed) return;
    super.emit(state);
  }
}
