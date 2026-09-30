import 'dart:async' show unawaited;

import 'package:flutter/material.dart';

import '../../../../app/di.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/glass.dart';
import '../data/scan_repository.dart';
import '../domain/scanned_document.dart';
import 'pages/document_camera_page.dart';

/// Hujjat skanerlash oqimi: tur tanlash → kamera → serverga yuborish →
/// natija.
///
/// Oqim CUBIT'siz: u boshidan oxirigacha bitta harakat va hech qanday
/// holat ekranlar orasida saqlanmaydi. Cubit qo'shilsa, shell'da doim
/// yashab turadigan yana bitta obyekt paydo bo'lardi va u hech narsani
/// soddalashtirmasdi.
///
/// Natija qabulxona KOMPYUTERIGA boradi: veb ekrani yangi skanni ko'rib
/// bandlov oynasini o'zi ochadi. Telefonda esa qisqa tasdiq ko'rsatiladi.
Future<void> startDocumentScan(BuildContext context) async {
  /* Kamera hujjat turiga bog'liq emas — tanlov oynasi ochilgan zahoti
     fonda qizdiriladi. Foydalanuvchi turini tanlaguncha (odatda 1-2
     soniya) kamera tayyor bo'ladi va sahifa kutdirmasdan ochiladi.
     Skaner rejimi ham xuddi shu paytda so'raladi. */
  final warmup = DocumentCameraPage.warmUp();
  final modeFuture = _scanMode();

  final type = await _pickDocumentType(context);
  if (type == null || !context.mounted) {
    // Tanlov bekor qilindi — qizdirilgan kamera bo'shatiladi, aks holda
    // u band bo'lib, keyingi ochilishlar ishlamay qolardi
    unawaited(warmup.then((controller) => controller?.dispose()));
    return;
  }

  /* MRZ rejimida ID kartaning faqat orqa tomoni olinadi. Rejim so'rovi
     sekin tarmoqda kamerani ushlab turmasin: tur tanlangach 2 soniyada
     javob kelmasa, oxirgi ma'lum rejim bilan davom etiladi — bu xatodagi
     zaxira yo'lning o'zi, faqat 20 soniyalik jim kutishsiz. */
  final mrzOnly =
      await modeFuture.timeout(
        const Duration(seconds: 2),
        onTimeout: _lastKnownMode,
      ) ==
      'mrz';
  if (!context.mounted) {
    // Kutish payti sahifa yo'q bo'lib ketdi (sessiya tugashi, rol
    // almashishi) — qizdirilgan kamera bo'shatiladi, aks holda u umrbod
    // band qolib, keyingi ochilishlar ishlamay qolardi
    unawaited(warmup.then((controller) => controller?.dispose()));
    return;
  }

  final shots = await DocumentCameraPage.open(
    context,
    documentType: type,
    mrzOnly: mrzOnly,
    warmup: warmup,
  );
  if (shots == null || shots.isEmpty || !context.mounted) return;

  await _sendAndShow(context, type: type, shots: shots, mrzOnly: mrzOnly);
}

/// Skaner rejimi — har qanday muammoda xavfsiz "auto".
///
/// DI hali sozlanmagan bo'lsa ham (masalan testlarda) oqim yiqilmaydi.
Future<String> _scanMode() async {
  try {
    return await getIt<ScanRepository>().scanMode();
  } catch (_) {
    return 'auto';
  }
}

/// Sekin javobda ishlatiladigan zaxira rejim — xuddi xatodagidek xavfsiz.
String _lastKnownMode() {
  try {
    return getIt<ScanRepository>().lastKnownMode;
  } catch (_) {
    return 'auto';
  }
}

/// ID karta yoki passport.
Future<String?> _pickDocumentType(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    builder: (sheetContext) {
      final l10n = sheetContext.l10n;
      final c = sheetContext.colors;
      return GlassSheet(
        child: SafeArea(
          // Kichik ekranda (yoki katta shriftda) oyna toshib ketmasin —
          // tarkib sig'masa ohista aylanadi
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.scanPickType,
                  style: sheetContext.textStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.scanPickTypeBody,
                  style: sheetContext.textStyles.bodyMedium!.copyWith(
                    color: c.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _TypeTile(
                  icon: Icons.badge_outlined,
                  title: l10n.scanIdCard,
                  body: l10n.scanIdCardBody,
                  // ID-1 nisbati — plitka ham hujjatga o'xshab tursin
                  aspect: 85.6 / 54,
                  onTap: () => Navigator.of(sheetContext).pop('ID_CARD'),
                ),
                const SizedBox(height: 12),
                _TypeTile(
                  icon: Icons.menu_book_outlined,
                  title: l10n.scanPassport,
                  body: l10n.scanPassportBody,
                  aspect: 125 / 88,
                  onTap: () => Navigator.of(sheetContext).pop('PASSPORT'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(l10n.cancel),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Yuborish: davomida modal "o'qilmoqda" oynasi turadi.
Future<void> _sendAndShow(
  BuildContext context, {
  required String type,
  required List<String> shots,
  bool mrzOnly = false,
}) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _SendingDialog(),
  );

  ScannedDocument? result;
  String? error;
  try {
    // MRZ rejimidagi ID kartada yagona kadr ORQA tomon — serverga ham
    // aynan `back` sifatida ketadi, aks holda server uni old tomon deb
    // bilib MRZ'ni izlamasdi
    final backOnly = mrzOnly && type == 'ID_CARD';
    result = await getIt<ScanRepository>().submit(
      documentType: type,
      frontPath: backOnly ? null : shots.first,
      backPath: backOnly
          ? shots.first
          : (shots.length > 1 ? shots[1] : null),
    );
  } on ApiException catch (e) {
    // Serverning matni aniqroq: "hujjatni ramkaga to'liq joylang" kabi
    error = e.isNetwork ? null : e.message;
  }

  navigator.pop(); // "o'qilmoqda" oynasini yopamiz
  if (!context.mounted) return;

  if (result == null) {
    await _showResultSheet(context, error: error ?? context.l10n.networkError);
    return;
  }
  await _showResultSheet(context, document: result);
}

Future<void> _showResultSheet(
  BuildContext context, {
  ScannedDocument? document,
  String? error,
}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      final l10n = sheetContext.l10n;
      final c = sheetContext.colors;
      final failed = document == null;
      final matched = document?.matched ?? false;
      final accent = failed
          ? c.danger
          : matched
          ? c.success
          : c.brand;
      final accentSoft = failed
          ? c.dangerSoft
          : matched
          ? c.successSoft
          : c.brandSoft;

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
                  child: Icon(
                    failed
                        ? Icons.error_outline_rounded
                        : matched
                        ? Icons.person_search_rounded
                        : Icons.person_add_alt_1_rounded,
                    size: 34,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  failed
                      ? l10n.scanFailedTitle
                      : matched
                      ? l10n.scanMatchedTitle
                      : l10n.scanNewGuestTitle,
                  style: sheetContext.textStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
                if (!failed && document.displayName.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    document.displayName,
                    style: sheetContext.textStyles.titleMedium!.copyWith(
                      color: accent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  failed ? error! : l10n.scanSentBody,
                  style: sheetContext.textStyles.bodyLarge!.copyWith(
                    color: c.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!failed && document.documentNumber != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: c.surfaceAlt,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (document.verified) ...[
                          Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: c.success,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          document.documentNumber!,
                          style: sheetContext.textStyles.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(l10n.done),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    // Sifat past chiqqan bo'lsa darhol qayta urinish
                    startDocumentScan(context);
                  },
                  child: Text(l10n.scanAgain),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.aspect,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final double aspect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surfaceAlt,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Hujjat nisbatidagi kichik chizma — tanlov ko'z bilan
              // tanilsin, matn o'qilmasdan ham. O'lcham ANIQ beriladi:
              // Row ichidagi AspectRatio ikkala tomondan ham cheksiz
              // o'lcham olib, butun oynani yiqitib qo'ygan edi.
              Container(
                width: 44 * aspect,
                height: 44,
                decoration: BoxDecoration(
                  color: c.brandSoft,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: c.brand.withValues(alpha: 0.35)),
                ),
                child: Icon(icon, color: c.brand, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.textStyles.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: context.textStyles.bodySmall!.copyWith(
                        color: c.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendingDialog extends StatelessWidget {
  const _SendingDialog();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PopScope(
      // Yuborish o'rtasida orqaga bosilsa, natija ko'rsatiladigan oyna
      // egasiz qolardi
      canPop: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.scanReading,
                style: context.textStyles.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
