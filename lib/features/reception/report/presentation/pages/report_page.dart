import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/context_x.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_state.dart';
import '../../../../../l10n/gen/app_localizations.dart';
import '../../domain/my_report.dart';
import '../cubit/report_cubit.dart';

/// "Mening hisobotim" — xodim o'z smenasining natijasini ko'radi.
///
/// Barcha raqamlar serverdan keladi va bu yerda qayta hisoblanmaydi:
/// "tushum" va "sof natija" ta'rifi bitta joyda turishi kerak, aks holda
/// veb va mobil bir kunga ikki xil raqam ko'rsatib qo'yardi.
class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final barPadding = MediaQuery.paddingOf(context);
    final cubit = context.read<ReportCubit>();

    return BlocBuilder<ReportCubit, ReportState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, barPadding.top + 8, 20, 8),
              child: const _PeriodBar(),
            ),
            Expanded(
              child: switch (state) {
                ReportState(report: null, loading: true) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ListSkeleton(count: 4),
                ),
                ReportState(report: null, error: final e?) => ErrorState(
                  error: e,
                  onRetry: cubit.load,
                ),
                ReportState(report: final report?) => _Body(report: report),
                _ => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ListSkeleton(count: 4),
                ),
              },
            ),
          ],
        );
      },
    );
  }
}

class _PeriodBar extends StatelessWidget {
  const _PeriodBar();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final cubit = context.read<ReportCubit>();
    final selected = context.select((ReportCubit b) => b.state.period);

    String label(ReportPeriod period) => switch (period) {
      ReportPeriod.today => l10n.periodToday,
      ReportPeriod.yesterday => l10n.periodYesterday,
      ReportPeriod.last7 => l10n.periodLast7,
      ReportPeriod.thisMonth => l10n.periodThisMonth,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final period in ReportPeriod.values) ...[
            GestureDetector(
              onTap: () => cubit.selectPeriod(period),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected == period ? c.brand : c.surfaceAlt,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  label(period),
                  style: context.textStyles.bodyMedium!.copyWith(
                    color: selected == period ? Colors.white : c.textMuted,
                    fontWeight: selected == period
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.report});

  final MyReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;

    return RefreshIndicator(
      onRefresh: context.read<ReportCubit>().load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
        children: [
          // SOF NATIJA — qolgan kartalardan ataylab boshqacha: bu
          // ularning xulosasi, ular bilan bir qatorda turadigan yana
          // bitta raqam emas
          _NetCard(report: report),
          const SizedBox(height: 12),

          _StatRow(
            icon: CupertinoIcons.money_dollar_circle,
            iconColor: c.success,
            iconBackground: c.successSoft,
            label: l10n.reportCollected,
            value: _money(report.paymentsTotal),
            hint: l10n.reportCash(_money(report.paymentsCash)),
          ),
          _StatRow(
            icon: CupertinoIcons.calendar_badge_plus,
            iconColor: c.brand,
            iconBackground: c.brandSoft,
            label: l10n.reportBookings,
            value: '${report.reservationCount}',
            hint: report.cancelledCount > 0
                ? l10n.reportCancelled(report.cancelledCount)
                : _money(report.reservationTotal),
          ),
          _StatRow(
            icon: CupertinoIcons.bag,
            iconColor: c.violet,
            iconBackground: c.violetSoft,
            label: l10n.reportShop,
            value: _money(report.shopTotal),
            hint: l10n.reportShopCount(report.shopCount),
          ),
          _StatRow(
            icon: CupertinoIcons.arrow_down_circle,
            iconColor: c.danger,
            iconBackground: c.dangerSoft,
            label: l10n.reportExpenses,
            value: _money(report.expenseTotal),
            hint: l10n.reportExpenseCount(report.expenseCount),
          ),
          if (report.refunds > 0)
            _StatRow(
              icon: CupertinoIcons.arrow_uturn_left_circle,
              iconColor: c.warning,
              iconBackground: c.warningSoft,
              label: l10n.reportRefunds,
              value: _money(report.refunds),
              hint: l10n.reportRefundsHint,
            ),
          if (report.shopUnpaidTotal > 0)
            _StatRow(
              icon: CupertinoIcons.exclamationmark_circle,
              iconColor: c.warning,
              iconBackground: c.warningSoft,
              label: l10n.reportShopUnpaid,
              value: _money(report.shopUnpaidTotal),
              hint: l10n.reportShopUnpaidHint,
            ),

          if (report.incomeByMethod.isNotEmpty) ...[
            const SizedBox(height: 8),
            _MethodsCard(report: report),
          ],
        ],
      ),
    );
  }
}

class _NetCard extends StatelessWidget {
  const _NetCard({required this.report});

  final MyReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final positive = report.netPositive;

    return AppCard(
      color: positive ? c.successSoft : c.dangerSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                positive
                    ? CupertinoIcons.arrow_up_right
                    : CupertinoIcons.arrow_down_right,
                color: positive ? c.success : c.danger,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.reportNet,
                style: context.textStyles.bodyMedium!.copyWith(
                  color: c.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _money(report.netTotal),
            style: context.textStyles.headlineMedium!.copyWith(
              color: positive ? c.success : c.danger,
            ),
          ),
          const SizedBox(height: 4),
          // Raqam qayerdan chiqqani yonida yozilgan: xodim kartalarni
          // qo'shib chiqmasdan ko'radi
          Text(
            l10n.reportNetBreakdown(
              _money(report.incomeTotal),
              _money(report.expenseTotal),
            ),
            style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
          ),
        ],
      ),
    );
  }
}

class _MethodsCard extends StatelessWidget {
  const _MethodsCard({required this.report});

  final MyReport report;

  /// Usul kodlari — backenddagi `METHODS` bilan bir xil tartibda.
  static const _order = ['cash', 'card', 'online', 'bank_transfer', 'other'];

  static String _label(S l10n, String method) => switch (method) {
    'cash' => l10n.methodCash,
    'card' => l10n.methodCard,
    'online' => l10n.methodOnline,
    'bank_transfer' => l10n.methodBankTransfer,
    _ => l10n.methodOther,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    // Nol bo'lgan usullar ko'rsatilmaydi — ro'yxatni shovqin bosmasin
    final rows = _order
        .where((m) => (report.incomeByMethod[m] ?? 0) != 0)
        .toList();
    if (rows.isEmpty) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.reportByMethod, style: context.textStyles.titleSmall),
          const SizedBox(height: 10),
          for (final method in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _label(l10n, method),
                    style: context.textStyles.bodyMedium!.copyWith(
                      color: c.textMuted,
                    ),
                  ),
                  Text(
                    _money(report.incomeByMethod[method] ?? 0),
                    style: context.textStyles.bodyMedium,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.value,
    this.hint,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String value;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.textStyles.bodyMedium!.copyWith(
                      color: c.textMuted,
                    ),
                  ),
                  Text(value, style: context.textStyles.titleSmall),
                ],
              ),
            ),
            if (hint != null)
              Flexible(
                child: Text(
                  hint!,
                  textAlign: TextAlign.right,
                  style: context.textStyles.bodySmall!.copyWith(
                    color: c.textMuted,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Ming ajratgichi bilan — telefon ekranida uzun raqamni o'qish qiyin.
String _money(double value) {
  final negative = value < 0;
  final text = value
      .abs()
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]} ');
  return negative ? '-$text' : text;
}
