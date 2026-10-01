import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../domain/finance_summary.dart';
import '../../domain/format.dart';
import 'animated_counter.dart';

/// Moliya kartalarining umumiy bo'laklari — puls sahifasi va alohida
/// "Moliya" sahifasi bir xil ko'rinishda bo'lishi uchun bitta joyda.

class MiniStat extends StatelessWidget {
  const MiniStat({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.background,
  });

  final String label;
  final double value;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
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
          const SizedBox(height: 2),
          AnimatedCounter(
            value: value,
            format: (v) => compactMoney(
              v,
              thousand: l10n.moneyThousand,
              million: l10n.moneyMillion,
            ),
            style: context.textStyles.titleSmall!.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// To'lov usullari bo'yicha tushum — tanlangan davr uchun.
///
/// To'rt asosiy usul DOIM ko'rinadi (nol bo'lsa ham): admin "karta bilan
/// bugun hech narsa kelmadi" degan javobni ham ko'rishi kerak — bo'sh
/// joy savol tug'dirardi. "Boshqa" faqat unda harakat bo'lsa chiqadi.
/// Har qatorda summa, ulushi va shu usulda qilingan xarajat.
class MethodsBreakdown extends StatelessWidget {
  const MethodsBreakdown({
    super.key,required this.finance});

  final FinanceSummary finance;

  static const _main = ['cash', 'card', 'online', 'bank_transfer'];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final other = finance.method('other');
    final keys = [
      ..._main,
      if (other.total != 0 || other.expense != 0) 'other',
    ];
    final total = finance.methodsTotal;

    Color colorOf(String key) => switch (key) {
      'cash' => c.success,
      'card' => c.brand,
      'online' => c.warning,
      'bank_transfer' => c.violet,
      _ => c.textMuted,
    };
    Color softOf(String key) => switch (key) {
      'cash' => c.successSoft,
      'card' => c.brandSoft,
      'online' => c.warningSoft,
      'bank_transfer' => c.violetSoft,
      _ => c.surfaceAlt,
    };
    IconData iconOf(String key) => switch (key) {
      'cash' => CupertinoIcons.money_dollar_circle_fill,
      'card' => CupertinoIcons.creditcard_fill,
      'online' => CupertinoIcons.device_phone_portrait,
      'bank_transfer' => CupertinoIcons.building_2_fill,
      _ => CupertinoIcons.ellipsis_circle_fill,
    };
    String labelOf(String key) => switch (key) {
      'cash' => l10n.methodCash,
      'card' => l10n.methodCard,
      'online' => l10n.methodOnline,
      'bank_transfer' => l10n.methodBankTransfer,
      _ => l10n.methodOther,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reportByMethod,
          style: context.textStyles.labelMedium!.copyWith(color: c.textMuted),
        ),
        const SizedBox(height: 8),
        // Yig'ma chiziq: usullar ulushi bir qarashda. Tushum yo'q bo'lsa
        // bo'sh yo'lak qoladi.
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: SizedBox(
            height: 10,
            child: total <= 0
                ? ColoredBox(color: c.surfaceAlt)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final key in keys)
                        if (finance.method(key).total > 0)
                          Expanded(
                            flex: (finance.method(key).total / total * 1000)
                                .round()
                                .clamp(1, 1000),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: ColoredBox(color: colorOf(key)),
                            ),
                          ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 6),
        for (final key in keys)
          MethodRow(
            icon: iconOf(key),
            color: colorOf(key),
            background: softOf(key),
            label: labelOf(key),
            share: finance.method(key),
            ratio: total <= 0 ? 0 : finance.method(key).total / total,
          ),
      ],
    );
  }
}

class MethodRow extends StatelessWidget {
  const MethodRow({
    super.key,
    required this.icon,
    required this.color,
    required this.background,
    required this.label,
    required this.share,
    required this.ratio,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String label;
  final PaymentMethodShare share;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final empty = share.total == 0;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textStyles.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  [
                    formatPercent(ratio),
                    if (share.expense > 0)
                      '${l10n.financeExpenses}: −${formatMoney(share.expense)}',
                  ].join(' · '),
                  style: context.textStyles.labelSmall!.copyWith(
                    color: c.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AnimatedCounter(
            value: share.total,
            format: formatMoney,
            style: context.textStyles.titleSmall!.copyWith(
              color: empty ? c.textMuted : c.text,
            ),
          ),
        ],
      ),
    );
  }
}

class CardIcon extends StatelessWidget {
  const CardIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 18, color: color),
    );
  }
}
