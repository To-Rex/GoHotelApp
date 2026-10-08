import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../debt/debt_reason.dart';
import '../extensions/context_x.dart';
import '../../l10n/gen/app_localizations.dart';

export '../debt/debt_reason.dart';

/// Sababning o'qiladigan sarlavhasi (summasiz).
String debtReasonTitle(S l10n, DebtReason reason) {
  switch (reason.kind) {
    case 'room':
      return reason.roomNumber != null
          ? l10n.debtReasonRoom(reason.roomNumber!)
          : l10n.debtReasonRoomPlain;
    case 'extension':
      return l10n.debtReasonExtension;
    case 'service':
      return l10n.debtReasonService(reason.name ?? '');
    case 'penalty':
      final kind = switch (reason.penaltyKind) {
        'LATE_CHECKOUT' => l10n.debtPenaltyLate,
        'DAMAGE' => l10n.debtPenaltyDamage,
        'OTHER' => l10n.debtPenaltyOther,
        _ => '',
      };
      final note = (reason.note ?? '').trim();
      final details = [kind, note].where((p) => p.isNotEmpty).join(', ');
      return details.isEmpty
          ? l10n.debtReasonPenalty
          : l10n.debtReasonPenaltyWith(details);
    case 'shop':
      final products = (reason.products ?? '').trim();
      return products.isEmpty
          ? l10n.debtReasonShopPlain
          : l10n.debtReasonShop(products);
    default:
      return reason.kind;
  }
}

/// Bo'linmaydigan bo'shliq bilan — summa satr oxirida ikkiga ajralmasin.
String _money(num value) => value
    .abs()
    .round()
    .toString()
    .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}\u00A0');

/// Sabablar — har biri rangli belgi: nima va qancha.
class DebtReasonChips extends StatelessWidget {
  const DebtReasonChips({super.key, required this.reasons});

  final List<DebtReason> reasons;

  @override
  Widget build(BuildContext context) {
    if (reasons.isEmpty) return const SizedBox.shrink();
    final c = context.colors;
    final l10n = context.l10n;

    (IconData, Color, Color) style(String kind) => switch (kind) {
      'room' => (CupertinoIcons.bed_double_fill, c.warningSoft, c.warning),
      'extension' => (CupertinoIcons.calendar_badge_plus, c.violetSoft, c.violet),
      'service' => (CupertinoIcons.sparkles, c.infoSoft, c.info),
      'penalty' => (CupertinoIcons.exclamationmark_shield_fill, c.dangerSoft, c.danger),
      'shop' => (CupertinoIcons.bag_fill, c.successSoft, c.success),
      _ => (CupertinoIcons.info_circle_fill, c.surfaceAlt, c.textMuted),
    };

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final reason in reasons)
          Builder(
            builder: (context) {
              final (icon, background, foreground) = style(reason.kind);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 13, color: foreground),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${debtReasonTitle(l10n, reason)}\u00A0\u00A0${_money(reason.amount)}',
                        style: context.textStyles.labelSmall!.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
