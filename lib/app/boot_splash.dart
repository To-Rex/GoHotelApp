import 'package:flutter/material.dart';

import '../features/auth/presentation/widgets/brand_mark.dart';

/// Ilova yuklanayotganda ko'rinadigan yagona ekran.
///
/// Ikki joyda ishlatiladi — bog'liqliklar tayyorlanayotganda va sessiya
/// tekshirilayotganda. Bitta ta'rif bo'lgani uchun foydalanuvchi bu ikki
/// bosqich orasida hech qanday sakrashni sezmaydi: u bitta uzluksiz ekran
/// ko'radi.
class BootSplash extends StatelessWidget {
  const BootSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandMark(size: 96),
            SizedBox(height: 32),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}
