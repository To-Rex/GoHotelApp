import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/widgets/app_card.dart';
import '../cubit/profile_cubit.dart';

/// Ish statistikasi: bugun / hafta / oy / o'rtacha vaqt.
class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state.statsLoading) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final stats = state.stats;
        if (stats == null) return const SizedBox.shrink();

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.today_rounded,
                    iconBg: c.brandSoft,
                    iconFg: c.onBrandSoft,
                    value: '${stats.completedToday}',
                    label: '${l10n.statToday} · ${l10n.completedTasks}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.date_range_rounded,
                    iconBg: c.successSoft,
                    iconFg: c.success,
                    value: '${stats.completedThisWeek}',
                    label: '${l10n.statWeek} · ${l10n.completedTasks}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.calendar_month_rounded,
                    iconBg: c.violetSoft,
                    iconFg: c.violet,
                    value: '${stats.completedThisMonth}',
                    label: '${l10n.statMonth} · ${l10n.completedTasks}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.timer_outlined,
                    iconBg: c.warningSoft,
                    iconFg: c.warning,
                    value: stats.avgMinutes == 0
                        ? '—'
                        : l10n.statMinutes(stats.avgMinutes),
                    label: l10n.statAvg,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: iconFg),
          ),
          const SizedBox(height: 10),
          Text(value, style: context.textStyles.headlineSmall),
          const SizedBox(height: 2),
          Text(
            label,
            style: context.textStyles.labelMedium!.copyWith(color: c.textMuted),
          ),
        ],
      ),
    );
  }
}
