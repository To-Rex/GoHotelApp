import 'package:flutter/material.dart';

/// Har 30 soniyada "hozir" ni qayta beradi — jonli davomiyliklar uchun
/// ("2 s 14 d dan beri"). Sekundlarni ko'rsatmaymiz, shuning uchun
/// daqiqa aniqligi kifoya; kichik jadval ekranni bezovta qilmaydi.
class MinuteTicker extends StatelessWidget {
  const MinuteTicker({super.key, required this.builder});

  final Widget Function(BuildContext context, DateTime now) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(
        const Duration(seconds: 30),
        (_) => DateTime.now(),
      ),
      initialData: DateTime.now(),
      builder: (context, snapshot) =>
          builder(context, snapshot.data ?? DateTime.now()),
    );
  }
}
