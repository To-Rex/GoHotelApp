import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/widgets/app_avatar.dart';

/// Ustma-ust avatarlar: "hozir kimlar ish vaqtida" degan savolga yuzlar
/// bilan javob. Sig'maganlari "+N" doirasiga yig'iladi.
class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.names,
    this.size = 36,
    this.max = 5,
    this.ringColor,
  });

  final List<String> names;
  final double size;
  final int max;

  /// Avatarlar orasidagi hoshiya — ostidagi karta rangi bilan bir xil
  /// bo'lsa avatarlar bir-biridan "kesilib" ko'rinadi.
  final Color? ringColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ring = ringColor ?? c.surface;
    final shown = names.take(max).toList();
    final extra = names.length - shown.length;
    // Qadam bosh harflarni yopmaydigan darajada: keyingi avatar faqat
    // chetini bosadi
    final step = size * 0.82;
    final count = shown.length + (extra > 0 ? 1 : 0);
    if (count == 0) return const SizedBox.shrink();

    Widget ringed(Widget child) => Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: ring, shape: BoxShape.circle),
      child: child,
    );

    return SizedBox(
      width: size + step * (count - 1),
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: step * i,
              child: ringed(AppAvatar(name: shown[i], size: size - 4)),
            ),
          if (extra > 0)
            Positioned(
              left: step * shown.length,
              child: ringed(
                Container(
                  decoration: BoxDecoration(
                    color: c.surfaceAlt,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '+$extra',
                    style: TextStyle(
                      fontSize: size * 0.3,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                      color: c.textMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
