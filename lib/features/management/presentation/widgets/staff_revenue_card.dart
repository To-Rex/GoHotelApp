import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/glass.dart';
import '../../domain/format.dart';
import '../../domain/staff_revenue.dart';
import 'finance_widgets.dart';
import 'pressable.dart';

/// Jami tushum xodimlar (resepshnlar) kesimida: kim qancha bron to'lovi va
/// do'kon savdosi qabul qilgan, jami tushumdagi ulushi. Qator bosilsa —
/// batafsil: usullar, qaytarim, xarajat, xodim kassasidagi naqd.
///
/// Raqamlar serverda (`/finance/by-staff`), "Jami tushum" bilan bir xil
/// sana ta'rifida — xodimlar yig'indisi jami tushumga teng.
class StaffRevenueCard extends StatefulWidget {
  const StaffRevenueCard({super.key, required this.report});

  /// `null` — hali yuklanmoqda.
  final StaffRevenueReport? report;

  @override
  State<StaffRevenueCard> createState() => _StaffRevenueCardState();
}

class _StaffRevenueCardState extends State<StaffRevenueCard> {
  static const _visible = 5;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final data = widget.report;
    final items = data?.items ?? const <StaffRevenue>[];
    final shown = _expanded ? items : items.take(_visible).toList();

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CardIcon(
                icon: CupertinoIcons.person_2_fill,
                color: c.brand,
                background: c.brandSoft,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(l10n.staffRevenueTitle, style: context.textStyles.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.staffRevenueHint,
            style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
          ),
          if (data == null)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: LinearProgressIndicator(minHeight: 2),
            )
          else if (data.earners.isEmpty && items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.staffRevenueNone,
                style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
              ),
            )
          else ...[
            for (final item in shown)
              _StaffRow(
                item: item,
                share: data.shareOf(item),
                onTap: () => showStaffRevenueSheet(context, item, data.shareOf(item)),
              ),
            if (items.length > _visible)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    _expanded
                        ? l10n.staffRevenueShowLess
                        : l10n.staffRevenueShowAll(items.length),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

String _nameOf(BuildContext context, StaffRevenue item) =>
    item.name ?? context.l10n.staffUnknown;

class _StaffRow extends StatelessWidget {
  const _StaffRow({required this.item, required this.share, required this.onTap});

  final StaffRevenue item;
  final double share;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final name = _nameOf(context, item);
    String compact(double v) =>
        compactMoney(v, thousand: l10n.moneyThousand, million: l10n.moneyMillion);
    // Lavozim ham shu qatorda — ism yonida belgi ismni qisqartirib yuborardi
    final parts = <String>[
      if (item.isAdmin) l10n.roleAdmin,
      if (item.income != 0 || item.paymentCount > 0) l10n.financePayments(item.paymentCount),
      if (item.shop != 0) l10n.staffShopShort(compact(item.shop)),
      if (item.revenue == 0 && item.expense > 0)
        '${l10n.financeExpenses}: −${compact(item.expense)}',
    ];

    return Pressable(
      scale: 0.98,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AppAvatar(name: name, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: context.textStyles.titleSmall!.copyWith(
                          color: item.active ? null : c.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (parts.isNotEmpty)
                        Text(
                          parts.join(' · '),
                          style: context.textStyles.labelSmall!.copyWith(color: c.textMuted),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatMoney(item.revenue),
                      style: context.textStyles.titleSmall!.copyWith(
                        color: item.revenue < 0 ? c.danger : null,
                      ),
                    ),
                    Text(
                      formatPercent(share),
                      style: context.textStyles.labelSmall!.copyWith(color: c.textMuted),
                    ),
                  ],
                ),
                const SizedBox(width: 2),
                Icon(CupertinoIcons.chevron_right, size: 14, color: c.textMuted),
              ],
            ),
            const SizedBox(height: 6),
            // Ulush chizig'i — kim ko'p ishlagani bir qarashda
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: share,
                minHeight: 4,
                color: c.brand,
                backgroundColor: c.surfaceAlt,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CashLine extends StatelessWidget {
  const _CashLine({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold ? context.textStyles.titleSmall : context.textStyles.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 8),
          Text(value, style: style),
        ],
      ),
    );
  }
}

/// Bitta xodimning davrdagi pul harakati — batafsil.
Future<void> showStaffRevenueSheet(BuildContext context, StaffRevenue item, double share) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => GlassSheet(child: _StaffSheet(item: item, share: share)),
  );
}

class _StaffSheet extends StatelessWidget {
  const _StaffSheet({required this.item, required this.share});

  final StaffRevenue item;
  final double share;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final name = _nameOf(context, item);

    Widget pair(Widget a, Widget b) => Row(
      children: [
        Expanded(child: a),
        const SizedBox(width: 8),
        Expanded(child: b),
      ],
    );

    String methodLabel(String key) => switch (key) {
      'cash' => l10n.methodCash,
      'card' => l10n.methodCard,
      'online' => l10n.methodOnline,
      'bank_transfer' => l10n.methodBankTransfer,
      _ => l10n.methodOther,
    };

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AppAvatar(name: name, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: context.textStyles.titleMedium, maxLines: 2),
                      Text(
                        [
                          item.isAdmin ? l10n.roleAdmin : l10n.roleStaff,
                          if (!item.active) l10n.staffInactive,
                        ].join(' · '),
                        style: context.textStyles.labelSmall!.copyWith(color: c.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              l10n.financeRevenue,
              style: context.textStyles.labelMedium!.copyWith(color: c.textMuted),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(formatMoney(item.revenue), style: context.textStyles.headlineSmall),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    l10n.currencySuffix,
                    style: context.textStyles.bodyMedium!.copyWith(color: c.textMuted),
                  ),
                ),
              ],
            ),
            Text(
              l10n.staffRevenueShare(formatPercent(share)),
              style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
            ),
            const SizedBox(height: 12),
            pair(
              MiniStat(
                label: l10n.staffBookings,
                value: item.income,
                color: c.success,
                background: c.successSoft,
              ),
              MiniStat(
                label: l10n.reportShop,
                value: item.shop,
                color: c.violet,
                background: c.violetSoft,
              ),
            ),
            const SizedBox(height: 8),
            pair(
              MiniStat(
                label: l10n.reportRefunds,
                value: item.refunds,
                color: item.refunds > 0 ? c.warning : c.textMuted,
                background: item.refunds > 0 ? c.warningSoft : c.surfaceAlt,
              ),
              MiniStat(
                label: l10n.financeExpenses,
                value: item.expense,
                color: item.expense > 0 ? c.danger : c.textMuted,
                background: item.expense > 0 ? c.dangerSoft : c.surfaceAlt,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.staffCounts(item.paymentCount, item.shopCount, item.expenseCount),
              style: context.textStyles.labelSmall!.copyWith(color: c.textMuted),
            ),
            if (item.methods.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                l10n.reportByMethod,
                style: context.textStyles.labelMedium!.copyWith(color: c.textMuted),
              ),
              for (final m in item.methods)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(methodLabel(m.key), style: context.textStyles.bodyMedium),
                      ),
                      Text(
                        formatMoney(m.total),
                        style: context.textStyles.titleSmall!.copyWith(
                          color: m.total < 0 ? c.danger : null,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            if (item.cash != 0 || item.cashExpense != 0) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: c.successSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.staffCashTitle,
                      style: context.textStyles.labelMedium!.copyWith(color: c.success),
                    ),
                    const SizedBox(height: 4),
                    _CashLine(label: l10n.staffCashIn, value: formatMoney(item.cash)),
                    _CashLine(
                      label: l10n.staffCashOut,
                      value: item.cashExpense > 0 ? '−${formatMoney(item.cashExpense)}' : '0',
                    ),
                    const Divider(height: 12),
                    _CashLine(label: l10n.staffCashNet, value: formatMoney(item.cashNet), bold: true),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
