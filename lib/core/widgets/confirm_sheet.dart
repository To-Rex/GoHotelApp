import 'package:flutter/material.dart';

import '../extensions/context_x.dart';
import 'glass.dart';

/// Katta, tushunarli tasdiqlash oynasi (pastdan chiqadi).
///
/// Yoshi katta foydalanuvchilar uchun dialog o'rniga bottom sheet — tugmalar
/// katta va barmoq ostida.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  IconData icon = Icons.help_outline_rounded,
  bool destructive = false,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    builder: (sheetContext) {
      final c = sheetContext.colors;
      final accent = destructive ? c.danger : c.brand;
      final accentSoft = destructive ? c.dangerSoft : c.brandSoft;
      return GlassSheet(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: accentSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 34, color: accent),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: sheetContext.textStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: sheetContext.textStyles.bodyLarge!.copyWith(
                    color: c.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  style: destructive
                      ? FilledButton.styleFrom(backgroundColor: c.danger)
                      : null,
                  child: Text(confirmLabel),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  child: Text(sheetContext.l10n.cancel),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  return result ?? false;
}
