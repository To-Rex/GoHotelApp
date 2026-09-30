import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/context_x.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_state.dart';
import '../cubit/tasks_cubit.dart';
import '../widgets/task_card.dart';
import 'task_detail_page.dart';

/// "Tozalash kerak bo'lgan xonalar" — farroshning bosh sahifasi.
/// Sarlavha va qo'ng'iroqcha shell'dagi umumiy appbar'da.
class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Shisha panellar balandligi — kontent ular ostidan skroll bo'lib o'tadi.
    final barPadding = MediaQuery.paddingOf(context);

    return RefreshIndicator(
      onRefresh: () => context.read<TasksCubit>().load(silent: true),
      edgeOffset: barPadding.top,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20, barPadding.top + 8, 20, 8),
            sliver: SliverToBoxAdapter(
              child: BlocBuilder<TasksCubit, TasksState>(
                builder: (context, state) => _SummaryBar(state: state),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: BlocBuilder<TasksCubit, TasksState>(
              buildWhen: (a, b) => a.filter != b.filter,
              builder: (context, state) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    for (final filter in TaskFilter.values) ...[
                      _FilterChip(
                        filter: filter,
                        selected: state.filter == filter,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
            ),
          ),
          BlocBuilder<TasksCubit, TasksState>(
            builder: (context, state) {
              // Bo'sh/xato holatlar pastki shisha panel ostida qolmasin.
              Widget fill(Widget child) => SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: barPadding.bottom),
                  child: child,
                ),
              );
              if (state.loading) {
                return fill(const ListSkeleton(count: 4));
              }
              if (state.error != null && state.tasks.isEmpty) {
                return fill(
                  ErrorState(
                    error: state.error!,
                    onRetry: () => context.read<TasksCubit>().load(),
                  ),
                );
              }
              final tasks = state.visible;
              if (tasks.isEmpty) {
                return fill(
                  EmptyState(
                    icon: Icons.cleaning_services_rounded,
                    title: l10n.noTasksTitle,
                    body: l10n.noTasksBody,
                  ),
                );
              }
              return SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, barPadding.bottom + 24),
                sliver: SliverList.separated(
                  itemCount: tasks.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskCard(
                      task: task,
                      onTap: () => TaskDetailPage.open(context, task),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Bugungi holat: nechta vazifadan nechtasi bajarildi.
class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.state});

  final TasksState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final total = state.tasks.length;
    if (state.loading || total == 0) return const SizedBox.shrink();
    final done = state.doneCount;
    final ratio = total == 0 ? 0.0 : done / total;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: c.brand.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.tasksTitle,
                  style: context.textStyles.labelMedium!.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.tasksSummary(done, total),
                  style: context.textStyles.titleLarge!.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${(ratio * 100).round()}%',
              style: context.textStyles.titleSmall!.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.filter, required this.selected});

  final TaskFilter filter;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final label = switch (filter) {
      TaskFilter.all => l10n.filterAll,
      TaskFilter.pending => l10n.filterNew,
      TaskFilter.inProgress => l10n.filterInProgress,
      TaskFilter.completed => l10n.filterDone,
    };
    // iOS filtr "pill"lari: tanlanmagani kulrang to'ldirilgan, tanlangani ko'k.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? c.brand : c.surfaceAlt,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () => context.read<TasksCubit>().setFilter(filter),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            child: Text(
              label,
              style: context.textStyles.labelLarge!.copyWith(
                color: selected ? Colors.white : c.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
