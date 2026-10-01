import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/glass.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../data/management_repository.dart';
import '../../domain/finance_report.dart';
import '../../domain/finance_summary.dart';
import '../../domain/format.dart';
import '../cubit/finance_cubit.dart';
import '../widgets/animated_counter.dart';
import '../widgets/finance_bar_chart.dart';
import '../widgets/finance_widgets.dart';

/// Moliya — admin/menejer uchun alohida sahifa (puls kartasidan ochiladi).
///
/// Davr: bugun, kecha, 7 kun, shu oy yoki istalgan oraliq. Ko'rsatiladi:
/// jami tushum va oldingi davrga nisbatan o'zgarish, xarajat, sof natija,
/// qarzdorlik, qaytarimlar; HOZIR kassalarda qancha pul borligi (ochiq
/// smenalar bo'yicha) va davrdagi naqd pul harakati; kunlik grafik; to'lov
/// usullari; xarajat toifalari; qarzdorlar; smenalardagi kamomad/ortiqcha.
///
/// Barcha raqamlar serverda hisoblanadi (veb bilan bir xil formulalar).
class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  static Future<void> open(
    BuildContext context, {
    FinanceRangeKind initial = FinanceRangeKind.today,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              FinanceCubit(getIt<ManagementRepository>(), initial: initial)..load(),
          child: const FinancePage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(title: Text(l10n.financeTitle)),
      body: BlocBuilder<FinanceCubit, FinanceState>(
        builder: (context, state) {
          final cubit = context.read<FinanceCubit>();
          final topPad = MediaQuery.paddingOf(context).top;
          final bottomPad = MediaQuery.paddingOf(context).bottom;

          final header = [
            const _PeriodBar(),
            const SizedBox(height: 8),
            _RangeLabel(state: state),
            const SizedBox(height: 12),
          ];

          if (!state.hasData && state.error != null) {
            return ListView(
              padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 24),
              children: [
                ...header,
                SizedBox(
                  height: 360,
                  child: ErrorState(error: state.error!, onRetry: cubit.load),
                ),
              ],
            );
          }

          return RefreshIndicator(
            edgeOffset: topPad,
            onRefresh: () => cubit.load(silent: true),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, bottomPad + 32),
              children: [
                ...header,
                if (!state.hasData)
                  // ListSkeleton o'zi ro'yxat — tashqi ro'yxat ichida balandligi beriladi
                  const SizedBox(
                    height: 4 * 152,
                    child: ListSkeleton(count: 4, itemHeight: 140),
                  )
                else
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    opacity: state.periodLoading ? 0.5 : 1,
                    child: _Cards(state: state),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------- DAVR ----

class _PeriodBar extends StatelessWidget {
  const _PeriodBar();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<FinanceCubit>();
    final range = context.select((FinanceCubit b) => b.state.range);

    String label(FinanceRangeKind kind) => switch (kind) {
      FinanceRangeKind.today => l10n.periodToday,
      FinanceRangeKind.yesterday => l10n.periodYesterday,
      FinanceRangeKind.week => l10n.periodLast7,
      FinanceRangeKind.month => l10n.periodThisMonth,
      FinanceRangeKind.custom => l10n.periodCustom,
    };

    Future<void> pickCustom() async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: today,
        initialDateRange: DateTimeRange(
          start: range.from.isAfter(today) ? today : range.from,
          end: range.to.isAfter(today) ? today : range.to,
        ),
        helpText: l10n.financePickRange,
      );
      if (picked != null) await cubit.selectCustom(picked.start, picked.end);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final kind in FinanceRangeKind.values) ...[
            _Chip(
              label: label(kind),
              icon: kind == FinanceRangeKind.custom ? CupertinoIcons.calendar : null,
              selected: range.kind == kind,
              onTap: () => kind == FinanceRangeKind.custom
                  ? pickCustom()
                  : cubit.selectKind(kind),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = selected ? Colors.white : c.textMuted;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? c.brand : c.surfaceAlt,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: context.textStyles.bodyMedium!.copyWith(
                color: fg,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _fullDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year}';
}

class _RangeLabel extends StatelessWidget {
  const _RangeLabel({required this.state});

  final FinanceState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final range = state.range;
    final text = range.isSingleDay
        ? _fullDate(range.from)
        : '${_fullDate(range.from)} — ${_fullDate(range.to)}';
    final updated = state.updatedAt;

    return Row(
      children: [
        Icon(CupertinoIcons.calendar, size: 15, color: c.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: context.textStyles.labelLarge!.copyWith(color: c.text),
          ),
        ),
        if (state.periodLoading)
          SizedBox.square(
            dimension: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: c.brand),
          )
        else if (updated != null)
          Text(
            l10n.pulseUpdatedAt(formatWhen(updated, DateTime.now())),
            style: context.textStyles.labelSmall!.copyWith(color: c.textMuted),
          ),
      ],
    );
  }
}

// ------------------------------------------------------------ KARTALAR ----

class _Cards extends StatelessWidget {
  const _Cards({required this.state});

  final FinanceState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final summary = state.summary!;
    final days = state.days;
    final cash = state.cash;
    const gap = SizedBox(height: 12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.failedSections > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: c.warningSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n.pulsePartialWarning(state.failedSections),
              style: context.textStyles.bodySmall!.copyWith(color: c.warning),
            ),
          ),
          gap,
        ],
        _RevenueCard(summary: summary, previous: state.previous),
        gap,
        _KpiGrid(summary: summary),
        gap,
        // Kassa nazorati ruxsati bo'lmasa — faqat davrdagi naqd pul harakati
        _CashCard(
          cash: state.cashForbidden ? null : cash,
          showLive: !state.cashForbidden,
          summary: summary,
        ),
        if (days != null && days.length > 1) ...[
          gap,
          _ChartCard(days: days, range: state.range, summary: summary),
        ],
        gap,
        AppCard(child: MethodsBreakdown(finance: summary)),
        gap,
        _ExpensesCard(summary: summary),
        gap,
        _DebtorsCard(report: state.debtors),
        if (cash != null && cash.isCashMode && state.shifts != null) ...[
          gap,
          _ShiftsCard(shifts: state.shifts!),
        ],
      ],
    );
  }
}

/// Jami tushum + oldingi davrga nisbatan o'zgarish.
class _RevenueCard extends StatelessWidget {
  const _RevenueCard({required this.summary, required this.previous});

  final FinanceSummary summary;
  final FinanceSummary? previous;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final prev = previous;
    final ratio = prev == null ? null : changeRatio(summary.revenue, prev.revenue);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
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
                child: Text(l10n.financeRevenue, style: context.textStyles.titleMedium),
              ),
              if (ratio != null) _DeltaChip(ratio: ratio),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: AnimatedCounter(
                  value: summary.revenue,
                  format: formatMoney,
                  style: context.textStyles.displaySmall,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  l10n.currencySuffix,
                  style: context.textStyles.bodyMedium!.copyWith(color: c.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            l10n.financeRevenueParts(
              formatMoney(summary.income),
              formatMoney(summary.shopTotal),
            ),
            style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
          ),
          Text(
            [
              l10n.financePayments(summary.paymentCount),
              if (summary.paymentCount > 0)
                l10n.financeAvgPayment(formatMoney(summary.averagePayment)),
            ].join(' · '),
            style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
          ),
          if (ratio != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.financeVsPrevious,
                style: context.textStyles.labelSmall!.copyWith(color: c.textMuted),
              ),
            )
          else if (prev != null && prev.revenue == 0 && summary.revenue > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.financeNoPrevious,
                style: context.textStyles.labelSmall!.copyWith(color: c.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.ratio});

  final double ratio;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final up = ratio >= 0;
    final color = up ? c.success : c.danger;
    final percent = (ratio.abs() * 100);
    final text = percent >= 1000 ? '999+%' : '${percent.round()}%';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: up ? c.successSoft : c.dangerSoft,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            up ? CupertinoIcons.arrow_up_right : CupertinoIcons.arrow_down_right,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: context.textStyles.labelMedium!.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Asosiy ko'rsatkichlar: xarajat, sof natija, qarzdorlik, qaytarimlar,
/// do'kon qarzi, chegirmalar; ostida hisob-fakturalar.
class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.summary});

  final FinanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final netPositive = summary.net >= 0;

    Widget pair(Widget a, Widget b) => Row(
      children: [
        Expanded(child: a),
        const SizedBox(width: 8),
        Expanded(child: b),
      ],
    );

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          pair(
            MiniStat(
              label: l10n.financeExpenses,
              value: summary.expenseTotal,
              color: c.danger,
              background: c.dangerSoft,
            ),
            MiniStat(
              label: l10n.financeNet,
              value: summary.net,
              color: netPositive ? c.success : c.danger,
              background: netPositive ? c.successSoft : c.dangerSoft,
            ),
          ),
          const SizedBox(height: 8),
          pair(
            MiniStat(
              label: l10n.financeDebt,
              value: summary.debt,
              color: summary.debt > 0 ? c.warning : c.textMuted,
              background: summary.debt > 0 ? c.warningSoft : c.surfaceAlt,
            ),
            MiniStat(
              label: l10n.reportRefunds,
              value: summary.refunds,
              color: summary.refunds > 0 ? c.violet : c.textMuted,
              background: summary.refunds > 0 ? c.violetSoft : c.surfaceAlt,
            ),
          ),
          const SizedBox(height: 8),
          pair(
            MiniStat(
              label: l10n.reportShopUnpaid,
              value: summary.shopDebt,
              color: summary.shopDebt > 0 ? c.warning : c.textMuted,
              background: summary.shopDebt > 0 ? c.warningSoft : c.surfaceAlt,
            ),
            MiniStat(
              label: l10n.financeDiscounts,
              value: summary.invoiceDiscount,
              color: c.info,
              background: c.infoSoft,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(CupertinoIcons.doc_text, size: 16, color: c.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.financeInvoices,
                  style: context.textStyles.bodyMedium!.copyWith(color: c.textMuted),
                ),
              ),
              Text(
                l10n.financeInvoicesValue(
                  summary.invoiceCount,
                  formatMoney(summary.invoiceTotal),
                ),
                style: context.textStyles.titleSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Kassada hozir (ochiq smenalar) va davrdagi naqd pul harakati.
class _CashCard extends StatelessWidget {
  const _CashCard({
    required this.cash,
    required this.showLive,
    required this.summary,
  });

  final CashOverview? cash;
  final bool showLive;
  final FinanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final overview = cash;
    final cashMethod = summary.method('cash');
    final cashIn = cashMethod.total;
    final cashOut = cashMethod.expense;
    // Kassa smenalari yuritilsa — "Kassada hozir"; aks holda karta faqat
    // davrdagi naqd pul harakati
    final live = showLive && overview != null && overview.isCashMode;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CardIcon(
                icon: CupertinoIcons.tray_full_fill,
                color: c.brand,
                background: c.brandSoft,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  live ? l10n.cashNowTitle : l10n.cashFlowTitle,
                  style: context.textStyles.titleMedium,
                ),
              ),
            ],
          ),
          if (live) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: AnimatedCounter(
                    value: overview.totalExpected,
                    format: formatMoney,
                    style: context.textStyles.headlineMedium,
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
            Text(
              l10n.cashNowHint,
              style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
            ),
            const SizedBox(height: 4),
            Text(
              overview.drawers.isEmpty
                  ? l10n.cashNoOpen
                  : l10n.cashDrawersCount(overview.activeCount, overview.pendingCount),
              style: context.textStyles.labelMedium!.copyWith(color: c.textMuted),
            ),
            for (final drawer in overview.drawers) _DrawerRow(drawer: drawer),
          ] else if (showLive && overview != null) ...[
            const SizedBox(height: 8),
            Text(
              l10n.cashSimpleMode,
              style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
            ),
          ],
          SizedBox(height: live ? 14 : 12),
          if (live) ...[
            Text(
              l10n.cashFlowTitle,
              style: context.textStyles.labelMedium!.copyWith(color: c.textMuted),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: MiniStat(
                  label: l10n.cashIn,
                  value: cashIn,
                  color: c.success,
                  background: c.successSoft,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MiniStat(
                  label: l10n.cashOut,
                  value: cashOut,
                  color: c.danger,
                  background: c.dangerSoft,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MiniStat(
                  label: l10n.cashBalance,
                  value: cashIn - cashOut,
                  color: cashIn - cashOut >= 0 ? c.brand : c.danger,
                  background: cashIn - cashOut >= 0 ? c.brandSoft : c.dangerSoft,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrawerRow extends StatelessWidget {
  const _DrawerRow({required this.drawer});

  final CashDrawer drawer;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final started = drawer.startedAt;
    final diff = drawer.diff;
    final meta = [
      if (drawer.branchName != null && drawer.branchName!.isNotEmpty) drawer.branchName!,
      if (started != null) l10n.shiftStarted(formatWhen(started, DateTime.now())),
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surfaceAlt.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  drawer.userName ?? '—',
                  style: context.textStyles.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatMoney(drawer.expectedCash),
                style: context.textStyles.titleMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (meta.isNotEmpty)
            Text(
              meta,
              style: context.textStyles.labelSmall!.copyWith(color: c.textMuted),
            ),
          if (drawer.isPendingHandover)
            Container(
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: c.warningSoft,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                l10n.shiftPendingHandover,
                style: context.textStyles.labelSmall!.copyWith(color: c.warning),
              ),
            ),
          const SizedBox(height: 6),
          Text(
            l10n.cashBreakdown(
              formatMoney(drawer.openingCash),
              formatMoney(drawer.paymentsCash),
              formatMoney(drawer.shopCash),
              formatMoney(drawer.expensesCash),
            ),
            style: context.textStyles.labelSmall!.copyWith(color: c.textMuted),
          ),
          if (drawer.countedCash != null) ...[
            const SizedBox(height: 4),
            Text(
              [
                l10n.cashCounted(formatMoney(drawer.countedCash!)),
                if (diff != null && diff.abs() >= 1)
                  '${l10n.shiftDiff}: ${diff > 0 ? '+' : ''}${formatMoney(diff)}',
              ].join(' · '),
              style: context.textStyles.labelSmall!.copyWith(
                color: diff != null && diff.abs() >= 1
                    ? (diff < 0 ? c.danger : c.success)
                    : c.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Kunlik (uzun davrda haftalik) tushum va xarajat grafigi.
class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.days,
    required this.range,
    required this.summary,
  });

  final List<FinanceDay> days;
  final FinanceRange range;
  final FinanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final buckets = chartBuckets(days);
    final weekly = buckets.isNotEmpty && !buckets.first.isSingleDay;
    ChartBucket? best;
    for (final b in buckets) {
      if (b.revenue > 0 && (best == null || b.revenue > best.revenue)) best = b;
    }
    String bucketLabel(ChartBucket b) =>
        b.isSingleDay ? shortDay(b.start) : '${shortDay(b.start)}–${shortDay(b.end)}';
    final average = range.days == 0 ? 0.0 : summary.revenue / range.days;

    Widget legend(Color color, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 5),
        Text(text, style: context.textStyles.labelSmall!.copyWith(color: c.textMuted)),
      ],
    );

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CardIcon(
                icon: CupertinoIcons.chart_bar_alt_fill,
                color: c.violet,
                background: c.violetSoft,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  weekly ? l10n.chartWeekly : l10n.chartDaily,
                  style: context.textStyles.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              legend(c.success, l10n.financeIncome),
              const SizedBox(width: 14),
              legend(c.danger, l10n.financeExpenses),
            ],
          ),
          const SizedBox(height: 12),
          FinanceBarChart(
            revenue: [for (final b in buckets) b.revenue],
            expense: [for (final b in buckets) b.expense],
            labels: [for (final b in buckets) shortDay(b.start)],
            revenueColor: c.success,
            expenseColor: c.danger,
            gridColor: c.outline,
            labelStyle: context.textStyles.labelSmall!.copyWith(color: c.textMuted, fontSize: 10),
          ),
          const SizedBox(height: 10),
          if (best != null)
            Text(
              l10n.chartBest(bucketLabel(best), formatMoney(best.revenue)),
              style: context.textStyles.bodySmall,
            ),
          Text(
            l10n.chartAverage(formatMoney(average)),
            style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Xarajat toifalari — eng kattasi birinchi, ulush chizig'i bilan.
class _ExpensesCard extends StatelessWidget {
  const _ExpensesCard({required this.summary});

  final FinanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final categories = summary.expenseCategories;
    final total = summary.expenseTotal;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CardIcon(
                icon: CupertinoIcons.cart_fill,
                color: c.danger,
                background: c.dangerSoft,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.expenseCategoriesTitle,
                  style: context.textStyles.titleMedium,
                ),
              ),
              Text(
                formatMoney(total),
                style: context.textStyles.titleSmall!.copyWith(color: c.danger),
              ),
            ],
          ),
          if (categories.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                l10n.expensesNone,
                style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
              ),
            ),
          for (final cat in categories)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.name,
                              style: context.textStyles.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              l10n.reportExpenseCount(cat.count),
                              style: context.textStyles.labelSmall!.copyWith(color: c.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(formatMoney(cat.total), style: context.textStyles.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: total <= 0 ? 0 : (cat.total / total).clamp(0, 1),
                      minHeight: 6,
                      backgroundColor: c.surfaceAlt,
                      color: c.danger.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Qarzdorlar — joriy holat (davrga bog'liq emas), eng katta qarz birinchi.
class _DebtorsCard extends StatelessWidget {
  const _DebtorsCard({required this.report});

  final DebtorsReport? report;

  static const _visible = 5;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final data = report;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CardIcon(
                icon: CupertinoIcons.person_crop_circle_badge_exclam,
                color: c.warning,
                background: c.warningSoft,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(l10n.debtorsTitle, style: context.textStyles.titleMedium),
              ),
              if (data != null && data.count > 0)
                Text(
                  formatMoney(data.totalDebt),
                  style: context.textStyles.titleSmall!.copyWith(color: c.warning),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (data == null)
            const LinearProgressIndicator(minHeight: 2)
          else if (data.count == 0)
            Text(
              l10n.debtorsNone,
              style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
            )
          else ...[
            Text(
              l10n.debtorsSummary(data.count, formatMoney(data.totalDebt)),
              style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
            ),
            for (final item in data.items.take(_visible))
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.guestName ?? l10n.financeGuestUnknown,
                            style: context.textStyles.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            [
                              if (item.roomNumber != null) l10n.debtorRoom(item.roomNumber!),
                              if (item.checkOut != null) l10n.debtorCheckOut(_fullDate(item.checkOut!)),
                            ].join(' · '),
                            style: context.textStyles.labelSmall!.copyWith(color: c.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatMoney(item.debt),
                      style: context.textStyles.titleSmall!.copyWith(color: c.warning),
                    ),
                  ],
                ),
              ),
            if (data.items.length > _visible)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  l10n.debtorsMore(data.items.length - _visible),
                  style: context.textStyles.labelMedium!.copyWith(color: c.textMuted),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Davrda yopilgan smenalar: kamomad va ortiqcha (kassa rejimida).
class _ShiftsCard extends StatelessWidget {
  const _ShiftsCard({required this.shifts});

  final ShiftDiffSummary shifts;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final now = DateTime.now();

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CardIcon(
                icon: CupertinoIcons.clock_fill,
                color: c.info,
                background: c.infoSoft,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(l10n.shiftsCashTitle, style: context.textStyles.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            shifts.closed.isEmpty
                ? l10n.shiftsNoneClosed
                : l10n.shiftsClosedCount(shifts.closed.length),
            style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
          ),
          if (shifts.closed.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: MiniStat(
                    label: l10n.shiftsShortage,
                    value: shifts.shortage,
                    color: shifts.shortage > 0 ? c.danger : c.textMuted,
                    background: shifts.shortage > 0 ? c.dangerSoft : c.surfaceAlt,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: MiniStat(
                    label: l10n.shiftsSurplus,
                    value: shifts.surplus,
                    color: shifts.surplus > 0 ? c.success : c.textMuted,
                    background: shifts.surplus > 0 ? c.successSoft : c.surfaceAlt,
                  ),
                ),
              ],
            ),
            for (final s in shifts.closed.take(5))
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.userName ?? '—',
                            style: context.textStyles.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (s.endedAt != null)
                            Text(
                              formatWhen(s.endedAt!, now),
                              style: context.textStyles.labelSmall!.copyWith(color: c.textMuted),
                            ),
                        ],
                      ),
                    ),
                    if (s.countedCash != null)
                      Text(
                        formatMoney(s.countedCash!),
                        style: context.textStyles.bodyMedium,
                      ),
                    const SizedBox(width: 8),
                    _DiffBadge(diff: s.cashDiff ?? 0),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _DiffBadge extends StatelessWidget {
  const _DiffBadge({required this.diff});

  final double diff;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final zero = diff.abs() < 1;
    final color = zero ? c.textMuted : (diff < 0 ? c.danger : c.success);
    final bg = zero ? c.surfaceAlt : (diff < 0 ? c.dangerSoft : c.successSoft);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Text(
        zero ? '0' : '${diff > 0 ? '+' : ''}${formatMoney(diff)}',
        style: context.textStyles.labelSmall!.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
