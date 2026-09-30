import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../extensions/context_x.dart';

/// iOS uslubidagi karta: soyasiz tekis sirt — kunduzgi rejimda kulrang fon
/// (#F2F2F7) ustidagi oq guruh, tungi rejimda qora fon ustidagi #1C1C1E.
/// Apple'ning "inset grouped" ro'yxatlari xuddi shunday ko'rinadi.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;

  /// Berilsa (masalan, o'qilmagan bildirishnoma urg'usi) hairline ko'rinadi.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.2)
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
