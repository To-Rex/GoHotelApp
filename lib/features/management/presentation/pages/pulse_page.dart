import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../domain/finance_summary.dart';
import '../../domain/format.dart';
import '../../domain/hotel_pulse.dart';
import '../../domain/management_access.dart';
import '../cubit/pulse_cubit.dart';
import '../cubit/team_cubit.dart';
import '../widgets/animated_counter.dart';
import '../widgets/finance_widgets.dart';
import '../widgets/income_sparkline.dart';
import '../widgets/live_dot.dart';
import '../widgets/occupancy_ring.dart';
import '../widgets/segmented_tabs.dart';
import '../widgets/stagger_in.dart';
import '../../domain/finance_report.dart';
import 'feedback_page.dart';
import 'finance_page.dart';
import 'today_bookings_page.dart';

/// Mehmonxona pulsi — admin/menejer bosh ekrani.
///
/// Bir qarashda: bandlik halqasi, bugungi kelish/chiqish, tushum chizig'i,
/// xo'jalik holati va e'tibor talab qiladigan ro'yxat. Har karta o'z
/// bo'lagini ko'rsatadi — biri yuklanmasa qolganlari turadi.
class PulsePage extends StatelessWidget {
  const PulsePage({
    super.key,
    required this.access,
    required this.onOpenRooms,
    required this.onOpenTeam,
  });

  final ManagementAccess access;
  final VoidCallback onOpenRooms;
  final void Function(TeamSegment segment) onOpenTeam;

  @override
  Widget build(BuildContext context) {
    final barPadding = MediaQuery.paddingOf(context);
    final cubit = context.read<PulseCubit>();

    return BlocBuilder<PulseCubit, PulseState>(
      builder: (context, state) {
        if (state.loading && !state.hasData) {
          return Padding(
            padding: EdgeInsets.only(top: barPadding.top + 8),
            child: const ListSkeleton(count: 4, itemHeight: 150),
          );
        }
        if (state.error != null && !state.hasData) {
          return ErrorState(error: state.error!, onRetry: cubit.load);
        }
        final pulse = state.pulse;
        return RefreshIndicator(
          onRefresh: cubit.load,
          edgeOffset: barPadding.top,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, barPadding.top + 8, 20, 130),
            children: [
              if (state.failedSections > 0) ...[
                _WarningStrip(count: state.failedSections),
                const SizedBox(height: 12),
              ],
              StaggerIn(
                children: [
                  _HeroCard(state: state, onOpenRooms: onOpenRooms),
                  _FinanceCard(state: state),
                  _HousekeepingCard(
                    pulse: pulse,
                    onOpen: () => onOpenTeam(TeamSegment.tasks),
                  ),
                  _AttentionCard(
                    pulse: pulse,
                    access: access,
                    onOpenRooms: onOpenRooms,
                    onOpenTeam: onOpenTeam,
                  ),
                  _TeamCard(
                    pulse: pulse,
                    onOpen: () => onOpenTeam(TeamSegment.staff),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WarningStrip extends StatelessWidget {
  const _WarningStrip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: c.warningSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(CupertinoIcons.exclamationmark_triangle, size: 18, color: c.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.pulsePartialWarning(count),
              style: context.textStyles.bodySmall!.copyWith(color: c.warning),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- HERO ----

/// Bandlik halqasi va bugungi harakat — brend rangidagi TEKIS karta ustida
/// oq raqamlar (gradient yo'q). Boshqa kartalardan ataylab farqli: bu
/// ekranning "yuzi".
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.state, required this.onOpenRooms});

  final PulseState state;
  final VoidCallback onOpenRooms;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pulse = state.pulse;
    final total = pulse.roomCount;
    final busy = pulse.occupiedRooms;
    final white = Colors.white;

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: ColoredBox(
        // Ikkala mavzuda ham bir xil brend ko'ki — oq matn bilan kontrast
        color: AppPalette.brand,
        // Butunlay tekis sirt: gradient ham, yarim shaffof bezak ham yo'q
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      LiveDot(
                        label: l10n.pulseLive,
                        color: const Color(0xFF6EE7B7),
                        textStyle: context.textStyles.labelMedium!.copyWith(
                          color: white.withValues(alpha: 0.9),
                        ),
                      ),
                      const Spacer(),
                      if (state.updatedAt != null)
                        Text(
                          l10n.pulseUpdatedAt(
                            formatWhen(state.updatedAt!, DateTime.now()),
                          ),
                          style: context.textStyles.labelSmall!.copyWith(
                            color: white.withValues(alpha: 0.7),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onOpenRooms,
                        child: OccupancyRing(
                          total: total,
                          trackColor: white.withValues(alpha: 0.16),
                          segments: [
                            RingSegment(value: busy, color: white),
                            RingSegment(
                              value: pulse.reservedRooms,
                              color: white.withValues(alpha: 0.62),
                            ),
                            RingSegment(
                              value: pulse.cleaningRooms,
                              color: white.withValues(alpha: 0.38),
                            ),
                          ],
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedCounter(
                                value: pulse.occupancy * 100,
                                format: (v) => '${v.round()}%',
                                style: context.textStyles.headlineMedium!
                                    .copyWith(color: white),
                              ),
                              Text(
                                l10n.occupancyTitle,
                                style: context.textStyles.labelSmall!.copyWith(
                                  color: white.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HeroMetric(
                              icon: CupertinoIcons.arrow_down_left_circle_fill,
                              label: l10n.heroArrivals,
                              value: pulse.arrivals,
                              onTap: () => TodayBookingsPage.open(context),
                            ),
                            const SizedBox(height: 10),
                            _HeroMetric(
                              icon: CupertinoIcons.arrow_up_right_circle_fill,
                              label: l10n.heroDepartures,
                              value: pulse.departures,
                              onTap: () => TodayBookingsPage.open(context),
                            ),
                            const SizedBox(height: 10),
                            _HeroMetric(
                              icon: CupertinoIcons.bed_double_fill,
                              label: l10n.heroInHouse,
                              value: pulse.inHouse,
                              onTap: () => TodayBookingsPage.open(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _HeroChip(text: l10n.roomsOf(busy, total)),
                      if (pulse.availableRooms > 0)
                        _HeroChip(
                          text:
                              '${pulse.availableRooms} · ${l10n.roomStateAvailable}',
                        ),
                      if (pulse.overdueRooms > 0)
                        _HeroChip(
                          text: l10n.heroOverdue(pulse.overdueRooms),
                          accent: const Color(0xFFFFB4AB),
                          icon: CupertinoIcons.clock_fill,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white.withValues(alpha: 0.85)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: context.textStyles.bodyMedium!.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          AnimatedCounter(
            value: value.toDouble(),
            format: (v) => '${v.round()}',
            style: context.textStyles.titleLarge!.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.text, this.accent, this.icon});

  final String text;
  final Color? accent;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: context.textStyles.labelMedium!.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------- MOLIYA ----

class _FinanceCard extends StatelessWidget {
  const _FinanceCard({required this.state});

  final PulseState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final cubit = context.read<PulseCubit>();
    final finance = state.pulse.finance;
    final days = state.pulse.incomeDays;

    // Karta bosilsa — alohida "Moliya" sahifasi (shu davr bilan ochiladi)
    void openFinance() => FinancePage.open(
      context,
      initial: switch (state.period) {
        PulsePeriod.today => FinanceRangeKind.today,
        PulsePeriod.week => FinanceRangeKind.week,
        PulsePeriod.month => FinanceRangeKind.month,
      },
    );

    return AppCard(
      onTap: openFinance,
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
                child: Text(l10n.financeTitle, style: context.textStyles.titleMedium),
              ),
              Text(
                l10n.financeDetails,
                style: context.textStyles.labelLarge!.copyWith(color: c.brand),
              ),
              Icon(CupertinoIcons.chevron_right, size: 15, color: c.brand),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedTabs(
            items: [
              SegmentItem(label: l10n.periodToday),
              SegmentItem(label: l10n.periodLast7),
              SegmentItem(label: l10n.periodThisMonth),
            ],
            selected: state.period.index,
            onSelected: (i) => cubit.selectPeriod(PulsePeriod.values[i]),
          ),
          const SizedBox(height: 16),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: state.financeLoading ? 0.45 : 1,
            child: finance == null
                ? _FinanceSkeleton()
                : _FinanceBody(finance: finance),
          ),
          if (days != null && days.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              l10n.financeLast7,
              style: context.textStyles.labelMedium!.copyWith(
                color: c.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            IncomeSparkline(
              values: [for (final d in days) d.income],
              labels: [for (final d in days) shortDay(d.date)],
              color: c.brand,
              labelStyle: context.textStyles.labelSmall!.copyWith(
                color: c.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FinanceSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget block(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(8),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        block(180, 30),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: block(double.infinity, 44)),
            const SizedBox(width: 10),
            Expanded(child: block(double.infinity, 44)),
            const SizedBox(width: 10),
            Expanded(child: block(double.infinity, 44)),
          ],
        ),
      ],
    );
  }
}

class _FinanceBody extends StatelessWidget {
  const _FinanceBody({required this.finance});

  final FinanceSummary finance;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final netPositive = finance.net >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.financeIncome,
          style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: AnimatedCounter(
                value: finance.income,
                format: formatMoney,
                style: context.textStyles.displaySmall,
              ),
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                l10n.currencySuffix,
                style: context.textStyles.bodyMedium!.copyWith(
                  color: c.textMuted,
                ),
              ),
            ),
          ],
        ),
        Text(
          l10n.financePayments(finance.paymentCount),
          style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: MiniStat(
                label: l10n.financeExpenses,
                value: finance.expenseTotal,
                color: c.danger,
                background: c.dangerSoft,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: MiniStat(
                label: l10n.financeNet,
                value: finance.net,
                color: netPositive ? c.success : c.danger,
                background: netPositive ? c.successSoft : c.dangerSoft,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: MiniStat(
                label: l10n.financeDebt,
                value: finance.debt,
                color: finance.debt > 0 ? c.warning : c.textMuted,
                background: finance.debt > 0 ? c.warningSoft : c.surfaceAlt,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        MethodsBreakdown(finance: finance),
      ],
    );
  }
}

// ------------------------------------------------------------ XO'JALIK ----

class _HousekeepingCard extends StatelessWidget {
  const _HousekeepingCard({required this.pulse, required this.onOpen});

  final HotelPulse pulse;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final open = pulse.openTasks;
    final progress = pulse.tasksInProgress;
    final done = pulse.completedTasksOn(DateTime.now());
    final total = open + progress + done;

    return AppCard(
      onTap: onOpen,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CardIcon(
                icon: CupertinoIcons.sparkles,
                color: c.info,
                background: c.infoSoft,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(l10n.hkTitle, style: context.textStyles.titleMedium),
              ),
              Icon(CupertinoIcons.chevron_right, size: 18, color: c.textMuted),
            ],
          ),
          const SizedBox(height: 14),
          // Uch bo'lakli progress: kutmoqda / jarayonda / bajarildi
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: SizedBox(
              height: 10,
              child: total == 0
                  ? ColoredBox(color: c.surfaceAlt)
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Bar(flex: open, color: c.warning),
                        _Bar(flex: progress, color: c.brand),
                        _Bar(flex: done, color: c.success),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Legend(
                  color: c.warning,
                  value: open,
                  label: l10n.taskOpen,
                ),
              ),
              Expanded(
                child: _Legend(
                  color: c.brand,
                  value: progress,
                  label: l10n.taskInProgress,
                ),
              ),
              Expanded(
                child: _Legend(
                  color: c.success,
                  value: done,
                  label: l10n.hkDoneToday,
                ),
              ),
            ],
          ),
          if (pulse.cleaningRooms > 0) ...[
            const SizedBox(height: 10),
            Text(
              l10n.hkCleaningRooms(pulse.cleaningRooms),
              style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.flex, required this.color});

  final int flex;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (flex <= 0) return const SizedBox.shrink();
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.only(right: 2),
        child: ColoredBox(color: color),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.value, required this.label});

  final Color color;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedCounter(
                value: value.toDouble(),
                format: (v) => '${v.round()}',
                style: context.textStyles.titleMedium,
              ),
              Text(
                label,
                style: context.textStyles.labelSmall!.copyWith(
                  color: c.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------- DIQQAT ----

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({
    required this.pulse,
    required this.access,
    required this.onOpenRooms,
    required this.onOpenTeam,
  });

  final HotelPulse pulse;
  final ManagementAccess access;
  final VoidCallback onOpenRooms;
  final void Function(TeamSegment) onOpenTeam;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;

    final rows = <_AttentionRow>[
      if (pulse.newComplaints > 0)
        _AttentionRow(
          icon: CupertinoIcons.exclamationmark_bubble_fill,
          color: c.danger,
          background: c.dangerSoft,
          text: l10n.attentionComplaints(pulse.newComplaints),
          onTap: access.canViewFeedback
              ? () => FeedbackPage.open(context)
              : null,
        )
      else if (pulse.openFeedback > 0)
        _AttentionRow(
          icon: CupertinoIcons.text_bubble_fill,
          color: c.brand,
          background: c.brandSoft,
          text: l10n.attentionFeedbackOpen(pulse.openFeedback),
          onTap: access.canViewFeedback
              ? () => FeedbackPage.open(context)
              : null,
        ),
      if (pulse.overdueRooms > 0)
        _AttentionRow(
          icon: CupertinoIcons.clock_fill,
          color: c.warning,
          background: c.warningSoft,
          text: l10n.heroOverdue(pulse.overdueRooms),
          onTap: onOpenRooms,
        ),
      if (pulse.unassignedTasks > 0)
        _AttentionRow(
          icon: CupertinoIcons.person_crop_circle_badge_exclam,
          color: c.warning,
          background: c.warningSoft,
          text: l10n.attentionOpenTasks(pulse.unassignedTasks),
          onTap: () => onOpenTeam(TeamSegment.tasks),
        ),
      if (pulse.openProblems > 0)
        _AttentionRow(
          icon: CupertinoIcons.wrench_fill,
          color: c.violet,
          background: c.violetSoft,
          text: l10n.attentionProblems(pulse.openProblems),
          onTap: () => onOpenTeam(TeamSegment.problems),
        ),
      if (pulse.pendingHandovers > 0)
        _AttentionRow(
          icon: CupertinoIcons.arrow_right_arrow_left_circle_fill,
          color: c.info,
          background: c.infoSoft,
          text: l10n.attentionHandover(pulse.pendingHandovers),
          onTap: () => onOpenTeam(TeamSegment.shifts),
        ),
      if (pulse.debtorCount > 0)
        _AttentionRow(
          icon: CupertinoIcons.creditcard_fill,
          color: c.danger,
          background: c.dangerSoft,
          text: l10n.attentionDebtors(
            pulse.debtorCount,
            formatMoney(pulse.debtTotal),
          ),
          onTap: () => TodayBookingsPage.open(context),
        ),
    ];

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CardIcon(
                icon: CupertinoIcons.bell_fill,
                color: rows.isEmpty ? c.success : c.warning,
                background: rows.isEmpty ? c.successSoft : c.warningSoft,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.attentionTitle,
                  style: context.textStyles.titleMedium,
                ),
              ),
              if (rows.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: c.warning,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '${rows.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 6, 0, 8),
              child: Row(
                children: [
                  Icon(CupertinoIcons.checkmark_seal_fill, size: 18, color: c.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.attentionNone,
                      style: context.textStyles.bodyMedium!.copyWith(
                        color: c.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...rows,
        ],
      ),
    );
  }
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow({
    required this.icon,
    required this.color,
    required this.background,
    required this.text,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: context.textStyles.bodyMedium),
            ),
            if (onTap != null)
              Icon(CupertinoIcons.chevron_right, size: 16, color: c.textMuted),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------- JAMOA ----

class _TeamCard extends StatelessWidget {
  const _TeamCard({required this.pulse, required this.onOpen});

  final HotelPulse pulse;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final ratio = pulse.staffTotal == 0
        ? 0.0
        : pulse.staffOnDuty / pulse.staffTotal;

    return AppCard(
      onTap: onOpen,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: OccupancyRing(
              size: 56,
              thickness: 6,
              total: pulse.staffTotal == 0 ? 1 : pulse.staffTotal,
              trackColor: c.surfaceAlt,
              segments: [RingSegment(value: pulse.staffOnDuty, color: c.brand)],
              child: Text(
                formatPercent(ratio),
                style: context.textStyles.labelMedium!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.tabTeam, style: context.textStyles.titleMedium),
                const SizedBox(height: 2),
                Text(
                  l10n.teamOnDuty(pulse.staffOnDuty, pulse.staffTotal),
                  style: context.textStyles.bodySmall!.copyWith(
                    color: c.textMuted,
                  ),
                ),
                if (pulse.openShifts > 0)
                  Text(
                    l10n.shiftsOpen(pulse.openShifts),
                    style: context.textStyles.bodySmall!.copyWith(
                      color: c.brand,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          Icon(CupertinoIcons.chevron_right, size: 18, color: c.textMuted),
        ],
      ),
    );
  }
}
