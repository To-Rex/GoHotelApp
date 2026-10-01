import 'package:flutter/material.dart';

import '../extensions/context_x.dart';
import '../network/api_exception.dart';

/// Xato holati: tushunarli matn + "Qayta urinish" tugmasi.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final message = friendlyError(context, error);
    // Ikonka xato turiga mos bo'lsin: ruxsat muammosi tarmoq muammosi emas.
    final icon = switch (error) {
      ApiException(isOutsideWorkHours: true) => Icons.schedule_rounded,
      ApiException(isForbidden: true) => Icons.lock_outline_rounded,
      ApiException(isNetwork: true) => Icons.wifi_off_rounded,
      _ => Icons.error_outline_rounded,
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: c.warningSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: c.warning),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: context.textStyles.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
              style: FilledButton.styleFrom(minimumSize: const Size(180, 54)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Har qanday xatoni foydalanuvchiga tushunarli matnga aylantiradi.
String friendlyError(BuildContext context, Object error) {
  final l10n = context.l10n;
  if (error is ApiException) {
    if (error.isNetwork) return l10n.networkError;
    // Ish vaqti tugagani "ruxsat yo'q" emas: ilova baribir ish vaqti
    // ekraniga o'tadi, bu matn faqat o'sha o'tish bilan poyga qilgan
    // snack/xato holatida ko'rinadi.
    if (error.isOutsideWorkHours) return l10n.outsideHoursError;
    if (error.isForbidden) return l10n.permissionDenied;
    if (error.statusCode != null && error.statusCode! >= 500) {
      return l10n.serverError;
    }
    return error.message;
  }
  return l10n.serverError;
}
