import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../domain/finance_report.dart';
import '../../domain/format.dart';
import '../../domain/shift_handover.dart';
import 'finance_widgets.dart';

/// Gap ichidagi summa qatorga bo'linib ketmasin ("1 / 200 000").
String _nb(String money) => money.replaceAll(' ', '\u00A0');

/// Jamoa → Smenalar: kassada HOZIR qancha pul (ochiq smenalar kassasi) —
/// vebdagi "Smenalar" sahifasi bilan bir xil manba (`/shifts/cash-overview`,
/// smena topshirish bilan aynan bir hisob). Har kassa summasi ochiq smena
/// kartasida alohida ko'rsatiladi.
class TeamCashNowCard extends StatelessWidget {
  const TeamCashNowCard({super.key, required this.cash});

  final CashOverview cash;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: c.success.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CardIcon(
                icon: CupertinoIcons.money_dollar_circle_fill,
                color: c.success,
                background: c.successSoft,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(l10n.cashNowTitle, style: context.textStyles.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  formatMoney(cash.totalExpected),
                  style: context.textStyles.headlineMedium!.copyWith(
                    color: c.success,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  l10n.currencySuffix,
                  style: context.textStyles.bodyMedium!.copyWith(color: c.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            cash.drawers.isEmpty
                ? l10n.cashNoOpen
                : l10n.cashDrawersCount(cash.activeCount, cash.pendingCount),
            style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
          ),
          Text(
            l10n.cashNowHint,
            style: context.textStyles.labelSmall!.copyWith(color: c.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Smenadan smenaga o'tgan pullar: har topshirilgan kassa — kimdan kimga,
/// qancha (sanalgan), kutilgan va farq; kunlik kesimda yoki majburiy
/// yopishda kassadan chiqqan pul ham (`/shifts/handovers`).
class HandoversCard extends StatelessWidget {
  const HandoversCard({super.key, required this.report, this.limit = 10});

  final HandoverReport report;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final shown = report.items.take(limit).toList();
    String compact(double v) =>
        compactMoney(v, thousand: l10n.moneyThousand, million: l10n.moneyMillion);

    Widget pill(String label, double value, Color color, Color background) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.textStyles.labelSmall!.copyWith(color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              compact(value),
              style: context.textStyles.titleSmall!.copyWith(color: color),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.handoversHint,
            style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              pill(l10n.handoversPassed, report.handedOverTotal, c.brand, c.brandSoft),
              const SizedBox(width: 6),
              pill(l10n.handoversTakenOut, report.takenOutTotal, c.textMuted, c.surfaceAlt),
              const SizedBox(width: 6),
              pill(l10n.handoversPending, report.pendingTotal, c.warning, c.warningSoft),
            ],
          ),
          const SizedBox(height: 4),
          for (final h in shown) _HandoverRow(item: h),
          if (report.items.length > shown.length)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Text(
                l10n.handoversMore(report.items.length - shown.length),
                style: context.textStyles.labelMedium!.copyWith(color: c.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}

class _HandoverRow extends StatelessWidget {
  const _HandoverRow({required this.item});

  final ShiftHandover item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final now = DateTime.now();
    final diff = item.cashDiff ?? 0;
    final balanced = diff.abs() < 0.5;
    final diffColor = balanced ? c.success : (diff < 0 ? c.danger : c.warning);

    final (String target, Color targetColor) = switch (item.kind) {
      HandoverKind.handover => (item.toName ?? '—', c.text),
      HandoverKind.pending => (l10n.handoverKindPending, c.warning),
      HandoverKind.cashOut => (l10n.handoverKindCashOut, c.textMuted),
      HandoverKind.forceTaken => (l10n.handoverKindForceTaken, c.warning),
    };
    final mismatch = item.mismatch;

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              item.kind.passesOn
                  ? CupertinoIcons.arrow_right_circle_fill
                  : CupertinoIcons.arrow_up_right_square_fill,
              size: 18,
              color: item.kind.passesOn ? c.brand : c.textMuted,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: item.fromName ?? '—', style: context.textStyles.titleSmall),
                      TextSpan(
                        text: '  →  ',
                        style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
                      ),
                      TextSpan(
                        text: target,
                        style: context.textStyles.bodyMedium!.copyWith(
                          color: targetColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (item.endedAt != null) formatWhen(item.endedAt!, now),
                    if (item.kind == HandoverKind.handover && item.acceptedAt != null)
                      l10n.handoverAccepted(formatWhen(item.acceptedAt!, now)),
                    // Majburiy yopilganda pulni kim olgani
                    if (item.kind == HandoverKind.forceTaken) ?item.closedByName,
                    ?item.branchName,
                  ].join(' · '),
                  style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.expectedCash != null)
                  Text(
                    l10n.handoverExpected(_nb(formatMoney(item.expectedCash!))),
                    style: context.textStyles.labelSmall!.copyWith(color: c.textMuted),
                  ),
                if (item.forceClosed || item.corrected)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      [
                        if (item.forceClosed && item.kind != HandoverKind.forceTaken)
                          l10n.shiftForceClosed,
                        if (item.corrected) l10n.handoverCorrected,
                      ].join(' · '),
                      style: context.textStyles.labelSmall!.copyWith(
                        color: c.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (mismatch != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      l10n.handoverReceivedOpening(_nb(formatMoney(item.receivedOpeningCash ?? 0))),
                      style: context.textStyles.labelSmall!.copyWith(color: c.warning),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.countedCash == null ? '—' : formatMoney(item.countedCash!),
                style: context.textStyles.titleSmall,
              ),
              if (item.cashDiff != null)
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: diffColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    balanced ? '±0' : '${diff > 0 ? '+' : ''}${formatMoney(diff)}',
                    style: context.textStyles.labelSmall!.copyWith(
                      color: diffColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
