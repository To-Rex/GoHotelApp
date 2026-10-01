import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../domain/format.dart';
import '../../domain/guest_feedback.dart';
import '../../domain/hk_task.dart';
import '../../domain/management_access.dart';
import '../../domain/shift_session.dart';
import '../../domain/staff_member.dart';
import '../cubit/team_cubit.dart';
import '../widgets/animated_counter.dart';
import '../widgets/avatar_stack.dart';
import '../widgets/day_timeline.dart';
import '../widgets/force_close_sheet.dart';
import '../widgets/minute_ticker.dart';
import '../widgets/stagger_in.dart';
import '../widgets/stat_tabs.dart';
import '../widgets/state_palette.dart';
import '../widgets/team_sheets.dart';

/// Jamoa: xodimlar, kassa smenalari, xo'jalik vazifalari, muammolar.
///
/// Tepada "hozir kim ish vaqtida" kartasi — yuzlar bilan. Ostida to'rt
/// bo'lakli sonli tanlagich: xodimlar soni va e'tibor talab qiladigan
/// narsalar (ochiq smena, kutayotgan vazifa, ochiq muammo). Har bo'lak
/// o'z ko'rinishiga ega: xodimlarda 24 soatlik ish chizig'i, smenalarda
/// jonli vaqt va tarix o'qi, vazifalarda bajarilish halqasi.
class TeamPage extends StatelessWidget {
  const TeamPage({super.key, required this.access});

  final ManagementAccess access;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final barPadding = MediaQuery.paddingOf(context);

    return BlocBuilder<TeamCubit, TeamState>(
      builder: (context, state) {
        final cubit = context.read<TeamCubit>();
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, barPadding.top + 8, 20, 0),
              child: _OnDutyCard(staff: state.staff.items),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
              child: StatTabs(
                items: [
                  StatTab(
                    label: l10n.segmentStaff,
                    count: state.staff.items.length,
                  ),
                  StatTab(
                    label: l10n.segmentShifts,
                    count: state.openShifts.length,
                  ),
                  StatTab(
                    label: l10n.segmentTasks,
                    count: state.tasksWith('OPEN').length,
                  ),
                  StatTab(
                    label: l10n.segmentProblems,
                    count: state.openProblems.length,
                  ),
                ],
                selected: state.segment.index,
                onSelected: (i) => cubit.selectSegment(TeamSegment.values[i]),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.02),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(state.segment),
                  child: switch (state.segment) {
                    TeamSegment.staff => _StaffView(state: state),
                    TeamSegment.shifts => _ShiftsView(state: state, access: access),
                    TeamSegment.tasks => _TasksView(state: state, access: access),
                    TeamSegment.problems =>
                      _ProblemsView(state: state, access: access),
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// "Hozir ish vaqtida" — yuzlar to'plami va son. Ma'lumot hali kelmagan
/// bo'lsa joy egallamaydi (ro'yxat yuklangach paydo bo'ladi).
class _OnDutyCard extends StatelessWidget {
  const _OnDutyCard({required this.staff});

  final List<StaffMember> staff;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final now = DateTime.now();
    final team = staff.where((s) => s.isActive && !s.isAdmin).toList();
    final onDuty = team.where((s) => s.isOnDuty(now)).toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));

    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: team.isEmpty
          ? const SizedBox(width: double.infinity)
          : Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          onDuty.isEmpty
                              ? l10n.teamNobodyOnDuty
                              : l10n.teamOnDutyNow,
                          style: context.textStyles.labelMedium!.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AnimatedCounter(
                              value: onDuty.length.toDouble(),
                              format: (v) => '${v.round()}',
                              duration: const Duration(milliseconds: 600),
                              style: context.textStyles.displaySmall!.copyWith(
                                color: onDuty.isEmpty ? c.textMuted : c.success,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 4),
                              child: Text(
                                '/ ${team.length}',
                                style: context.textStyles.titleMedium!.copyWith(
                                  color: c.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onDuty.isNotEmpty)
                    AvatarStack(
                      names: [for (final s in onDuty) s.fullName],
                      size: 40,
                      max: 4,
                    ),
                ],
              ),
            ),
    );
  }
}

/// Bo'lakning umumiy holatlari: skelet, xato, bo'sh — bir joyda.
Widget? _sectionState<T>(
  BuildContext context,
  Section<T> section, {
  required VoidCallback onRetry,
  required Widget empty,
  bool isEmpty = false,
}) {
  if (section.loading && section.items.isEmpty) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: ListSkeleton(count: 4, itemHeight: 96),
    );
  }
  if (section.error != null && section.items.isEmpty) {
    return ErrorState(error: section.error!, onRetry: onRetry);
  }
  if (isEmpty) {
    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [const SizedBox(height: 24), empty],
      ),
    );
  }
  return null;
}

// ------------------------------------------------------------ XODIMLAR ----

class _StaffView extends StatelessWidget {
  const _StaffView({required this.state});

  final TeamState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<TeamCubit>();
    final staff = state.visibleStaff;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
          child: _SearchField(
            initial: state.query,
            hint: l10n.staffSearchHint,
            onChanged: cubit.search,
          ),
        ),
        Expanded(
          child:
              _sectionState(
                context,
                state.staff,
                onRetry: () => cubit.loadSegment(TeamSegment.staff),
                isEmpty: staff.isEmpty,
                empty: EmptyState(
                  icon: CupertinoIcons.person_2,
                  title: l10n.staffEmptyTitle,
                  body: l10n.staffEmptyBody,
                ),
              ) ??
              RefreshIndicator(
                onRefresh: () => cubit.loadSegment(TeamSegment.staff),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
                  itemCount: staff.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _StaffCard(
                    member: staff[index],
                    tasks: state.tasks.items,
                    onTap: () => showStaffSheet(
                      context,
                      staff[index],
                      tasks: state.tasks.items,
                    ),
                  ),
                ),
              ),
        ),
      ],
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.initial,
    required this.hint,
    required this.onChanged,
  });

  final String initial;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TextField(
      controller: _controller,
      onChanged: (v) {
        widget.onChanged(v);
        setState(() {});
      },
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(CupertinoIcons.search, size: 20),
        filled: true,
        fillColor: c.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(CupertinoIcons.clear_circled_solid, size: 18),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                  setState(() {});
                },
              ),
      ),
    );
  }
}

/// Xodim kartasi: avatar (ish vaqtida — yashil halqa), ism va 24 soatlik
/// ish chizig'i. Chiziqdagi nuqta — hozir; u rangli oraliq ichida bo'lsa
/// xodim ish vaqtida.
class _StaffCard extends StatelessWidget {
  const _StaffCard({
    required this.member,
    required this.tasks,
    required this.onTap,
  });

  final StaffMember member;
  final List<HkTask> tasks;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final now = DateTime.now();
    final onDuty = member.isActive && member.isOnDuty(now);
    final online = member.wasRecentlyOnline(now);
    final activeTasks = tasks
        .where((t) => t.assignedTo == member.id && !t.isDone && t.status != 'CANCELLED')
        .length;
    final statusText = !member.isActive
        ? (member.status == 'TERMINATED'
              ? l10n.staffStatusTerminated
              : l10n.staffStatusInactive)
        : (onDuty ? l10n.staffOnDutyBadge : l10n.staffOffDuty);

    return Opacity(
      opacity: member.isActive ? 1 : 0.6,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: onDuty ? c.success : c.outline,
                          width: 2,
                        ),
                      ),
                      child: AppAvatar(name: member.fullName, size: 46),
                    ),
                    if (online)
                      Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            color: c.brand,
                            shape: BoxShape.circle,
                            border: Border.all(color: c.surface, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.fullName,
                        style: context.textStyles.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        statusText,
                        style: context.textStyles.bodySmall!.copyWith(
                          color: onDuty ? c.success : c.textMuted,
                          fontWeight: onDuty ? FontWeight.w600 : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (activeTasks > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: c.brandSoft,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.sparkles, size: 13, color: c.onBrandSoft),
                        const SizedBox(width: 4),
                        Text(
                          '$activeTasks',
                          style: context.textStyles.labelMedium!.copyWith(
                            color: c.onBrandSoft,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Icon(CupertinoIcons.chevron_right, size: 18, color: c.textMuted),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  member.workStart,
                  style: context.textStyles.labelSmall!.copyWith(
                    color: c.textMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DayTimeline(
                    start: member.workStart,
                    end: member.workEnd,
                    now: now,
                    color: onDuty ? c.success : c.textMuted.withValues(alpha: 0.45),
                    trackColor: c.surfaceAlt,
                    markerColor: c.text,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  member.workEnd,
                  style: context.textStyles.labelSmall!.copyWith(
                    color: c.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ SMENALAR ----

class _ShiftsView extends StatelessWidget {
  const _ShiftsView({required this.state, required this.access});

  final TeamState state;
  final ManagementAccess access;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<TeamCubit>();

    if (state.shiftMode != null && !state.cashMode) {
      return EmptyState(
        icon: CupertinoIcons.money_dollar_circle,
        title: l10n.shiftsNotCashTitle,
        body: l10n.shiftsNotCashBody,
      );
    }
    final placeholder = _sectionState(
      context,
      state.shifts,
      onRetry: () => cubit.loadSegment(TeamSegment.shifts),
      isEmpty: state.shifts.items.isEmpty,
      empty: EmptyState(
        icon: CupertinoIcons.money_dollar_circle,
        title: l10n.shiftsEmpty,
        body: l10n.shiftsNotCashBody,
      ),
    );
    if (placeholder != null) return placeholder;

    final open = state.openShifts;
    final closed = state.closedShifts;

    return RefreshIndicator(
      onRefresh: () => cubit.loadSegment(TeamSegment.shifts),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
        children: [
          if (open.isNotEmpty) ...[
            _SectionTitle(text: l10n.shiftsOpenTitle, count: open.length),
            StaggerIn(
              children: [
                for (final s in open)
                  _OpenShiftCard(
                    session: s,
                    canForceClose: access.canForceClose,
                    onForceClose: () => showForceCloseSheet(context, s),
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          if (closed.isNotEmpty) ...[
            _SectionTitle(text: l10n.shiftsClosedTitle, count: closed.length),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 16, 16, 2),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < closed.length; i++)
                    _ClosedShiftRow(
                      session: closed[i],
                      isLast: i == closed.length - 1,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Ochiq smena: chap chetda holat tasmasi, o'rtada KATTA jonli vaqt.
class _OpenShiftCard extends StatelessWidget {
  const _OpenShiftCard({
    required this.session,
    required this.canForceClose,
    required this.onForceClose,
  });

  final ShiftSession session;
  final bool canForceClose;
  final VoidCallback onForceClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final pending = session.isPendingHandover;
    final accent = pending ? c.warning : c.success;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: ColoredBox(
        color: c.surface,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppAvatar(name: session.userName ?? '?', size: 42),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.userName ?? '—',
                                  style: context.textStyles.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                // Holat — ism ostida: uzun yozuv ismni siqmaydi
                                Row(
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: accent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        pending
                                            ? l10n.shiftPendingHandover
                                            : l10n.shiftActive,
                                        style: context.textStyles.bodySmall!
                                            .copyWith(
                                              color: accent,
                                              fontWeight: FontWeight.w600,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.shiftDurationLabel,
                                  style: context.textStyles.labelSmall!.copyWith(
                                    color: c.textMuted,
                                  ),
                                ),
                                MinuteTicker(
                                  builder: (context, now) => Text(
                                    formatDuration(
                                      session.elapsed(now),
                                      h: l10n.hourShort,
                                      m: l10n.minuteShort,
                                    ),
                                    style: context.textStyles.headlineMedium!
                                        .copyWith(
                                          color: accent,
                                          fontWeight: FontWeight.w800,
                                          height: 1.15,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (session.startedAt != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8, bottom: 5),
                              child: Text(
                                l10n.shiftStarted(
                                  formatWhen(session.startedAt!, DateTime.now()),
                                ),
                                style: context.textStyles.bodySmall!.copyWith(
                                  color: c.textMuted,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Kassa: ikki teng ustun — uzun yozuvlar ham sig'adi
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: c.surfaceAlt,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _KeyValue(
                                label: l10n.shiftOpeningCash,
                                value: formatMoney(session.openingCash),
                              ),
                            ),
                            if (session.countedCash != null) ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: _KeyValue(
                                  label: l10n.shiftCounted,
                                  value: formatMoney(session.countedCash!),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (canForceClose) ...[
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: onForceClose,
                            style: TextButton.styleFrom(
                              foregroundColor: c.danger,
                              backgroundColor: c.dangerSoft,
                              minimumSize: const Size.fromHeight(46),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(CupertinoIcons.lock_fill, size: 17),
                            label: Text(l10n.shiftForceClose),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Yopilgan smena — vaqt o'qi ustidagi nuqta: kim, qachon, kassa farqi.
class _ClosedShiftRow extends StatelessWidget {
  const _ClosedShiftRow({required this.session, required this.isLast});

  final ShiftSession session;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final diff = session.cashDiff;
    final delta = diff ?? 0;
    final balanced = delta.abs() < 0.5;
    // Kam chiqsa qizil, ortiqcha chiqsa sariq, teng bo'lsa yashil
    final diffColor = balanced
        ? c.success
        : (delta < 0 ? c.danger : c.warning);
    final now = DateTime.now();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Vaqt o'qi: nuqta va pastga tushuvchi chiziq
          SizedBox(
            width: 22,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: diffColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.surface, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: c.outline),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.userName ?? '—',
                          style: context.textStyles.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            if (session.startedAt != null)
                              formatWhen(session.startedAt!, now),
                            formatDuration(
                              session.elapsed(now),
                              h: l10n.hourShort,
                              m: l10n.minuteShort,
                            ),
                          ].join(' · '),
                          style: context.textStyles.bodySmall!.copyWith(
                            color: c.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (session.forceClosed)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              l10n.shiftForceClosed,
                              style: context.textStyles.labelSmall!.copyWith(
                                color: c.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        session.countedCash == null
                            ? '—'
                            : formatMoney(session.countedCash!),
                        style: context.textStyles.titleSmall,
                      ),
                      if (diff != null)
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: diffColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            balanced
                                ? '±0'
                                : '${delta > 0 ? '+' : ''}${formatMoney(delta)}',
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
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------- VAZIFALAR ----

class _TasksView extends StatelessWidget {
  const _TasksView({required this.state, required this.access});

  final TeamState state;
  final ManagementAccess access;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<TeamCubit>();
    final placeholder = _sectionState(
      context,
      state.tasks,
      onRetry: () => cubit.loadSegment(TeamSegment.tasks),
      isEmpty: state.tasks.items.isEmpty,
      empty: EmptyState(
        icon: CupertinoIcons.sparkles,
        title: l10n.tasksEmptyTitle,
        body: l10n.tasksEmptyBody,
      ),
    );
    if (placeholder != null) return placeholder;

    final open = state.tasksWith('OPEN');
    final inProgress = state.tasksWith('IN_PROGRESS');
    final done = state.tasksWith('COMPLETED').take(15).toList();

    return RefreshIndicator(
      onRefresh: () => cubit.loadSegment(TeamSegment.tasks),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
        children: [
          for (final (title, items) in [
            (l10n.taskOpen, open),
            (l10n.taskInProgress, inProgress),
            (l10n.taskCompleted, done),
          ])
            if (items.isNotEmpty) ...[
              _SectionTitle(text: title, count: items.length),
              StaggerIn(
                spacing: 8,
                children: [
                  for (final t in items)
                    _TaskRow(
                      task: t,
                      staff: state.staff.items,
                      onTap: () => showTaskSheet(context, t, access),
                    ),
                ],
              ),
              const SizedBox(height: 18),
            ],
        ],
      ),
    );
  }
}

/// Vazifa qatori: xona raqami atrofida bajarilish halqasi, o'ngda mas'ul.
class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.staff,
    required this.onTap,
  });

  final HkTask task;
  final List<StaffMember> staff;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final statusColor = TaskPalette.statusColor(c, task.status);
    final assignee = task.assigneeName ??
        staff
            .where((s) => s.id == task.assignedTo)
            .map((s) => s.fullName)
            .firstOrNull;
    final ratio = task.isDone
        ? 1.0
        : (task.checklistTotal > 0
              ? task.checklistDone / task.checklistTotal
              : 0.0);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Halqa — ish bandlari bo'yicha bajarilish; ichida xona raqami
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: ratio.clamp(0, 1)),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => CircularProgressIndicator(
                      value: v,
                      strokeWidth: 3.5,
                      color: statusColor,
                      backgroundColor: TaskPalette.statusSoft(c, task.status),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      task.roomNumber,
                      style: context.textStyles.titleSmall!.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TaskPalette.typeLabel(l10n, task.taskType),
                  style: context.textStyles.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                MinuteTicker(
                  builder: (context, now) {
                    final waiting = task.waiting(now);
                    // Bir soatdan ortiq kutayotgan ochiq vazifa — qizil
                    final late = task.isOpen && waiting.inMinutes >= 60;
                    final text = task.isDone
                        ? (task.autoCompleted
                              ? l10n.taskAutoCompleted
                              : (task.completedAt == null
                                    ? l10n.taskCompleted
                                    : formatWhen(task.completedAt!, now)))
                        : (task.isInProgress
                              ? l10n.taskWorking(
                                  formatDuration(
                                    waiting,
                                    h: l10n.hourShort,
                                    m: l10n.minuteShort,
                                  ),
                                )
                              : l10n.taskWaiting(
                                  formatDuration(
                                    waiting,
                                    h: l10n.hourShort,
                                    m: l10n.minuteShort,
                                  ),
                                ));
                    return Text(
                      text,
                      style: context.textStyles.bodySmall!.copyWith(
                        color: late ? c.danger : c.textMuted,
                        fontWeight: late ? FontWeight.w600 : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
                const SizedBox(height: 3),
                // Muhimlik belgisi sarlavhani siqmasin — mas'ul qatorida
                Row(
                  children: [
                    if (task.isUrgent && !task.isDone) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: TaskPalette.priorityColor(c, task.priority),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          TaskPalette.priorityLabel(l10n, task.priority),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        assignee ?? l10n.taskUnassigned,
                        style: context.textStyles.labelSmall!.copyWith(
                          color: assignee == null ? c.warning : c.textMuted,
                          fontWeight: assignee == null ? FontWeight.w700 : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (assignee != null)
            AppAvatar(name: assignee, size: 34)
          else
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: c.warningSoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                CupertinoIcons.person_badge_plus,
                size: 16,
                color: c.warning,
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------- MUAMMOLAR ----

class _ProblemsView extends StatelessWidget {
  const _ProblemsView({required this.state, required this.access});

  final TeamState state;
  final ManagementAccess access;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<TeamCubit>();
    final placeholder = _sectionState(
      context,
      state.problems,
      onRetry: () => cubit.loadSegment(TeamSegment.problems),
      isEmpty: state.problems.items.isEmpty,
      empty: EmptyState(
        icon: CupertinoIcons.wrench,
        title: l10n.problemsEmptyTitle,
        body: l10n.problemsEmptyBody,
      ),
    );
    if (placeholder != null) return placeholder;

    final open = state.openProblems;
    final resolved = state.resolvedProblems.take(10).toList();

    return RefreshIndicator(
      onRefresh: () => cubit.loadSegment(TeamSegment.problems),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
        children: [
          if (open.isNotEmpty) ...[
            _SectionTitle(text: l10n.problemOpen, count: open.length),
            StaggerIn(
              children: [
                for (final p in open)
                  _ProblemCard(problem: p, canResolve: access.canResolveProblems),
              ],
            ),
            const SizedBox(height: 18),
          ],
          if (resolved.isNotEmpty) ...[
            _SectionTitle(text: l10n.problemResolvedTitle, count: resolved.length),
            for (final p in resolved) ...[
              _ProblemCard(problem: p, canResolve: false),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

/// Muammo kartasi: kim, qayerda, qachon; tavsif iqtibos ko'rinishida.
class _ProblemCard extends StatefulWidget {
  const _ProblemCard({required this.problem, required this.canResolve});

  final StaffProblem problem;
  final bool canResolve;

  @override
  State<_ProblemCard> createState() => _ProblemCardState();
}

class _ProblemCardState extends State<_ProblemCard> {
  bool _busy = false;

  Future<void> _set(String status) async {
    setState(() => _busy = true);
    try {
      await context.read<TeamCubit>().setProblemStatus(widget.problem.id, status);
    } catch (e) {
      if (!mounted) return;
      context.showSnack(friendlyError(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final p = widget.problem;
    final (color, soft, label) = switch (p.status) {
      'RESOLVED' => (c.success, c.successSoft, l10n.problemResolved),
      'IN_PROGRESS' => (c.brand, c.brandSoft, l10n.taskInProgress),
      _ => (c.warning, c.warningSoft, l10n.problemOpen),
    };

    return Opacity(
      opacity: p.isOpen ? 1 : 0.75,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (p.roomNumber?.isNotEmpty == true) ...[
                  Container(
                    constraints: const BoxConstraints(minWidth: 46),
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: soft,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      p.roomNumber!,
                      style: context.textStyles.titleSmall!.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ] else
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: soft,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: Icon(CupertinoIcons.wrench_fill, size: 20, color: color),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Holat va vaqt — sarlavha ustida: nom va xabar
                      // bergan xodim uchun butun kenglik qoladi
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: label,
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '  ·  ${formatWhen(p.createdAt, DateTime.now())}',
                            ),
                          ],
                        ),
                        style: context.textStyles.labelSmall!.copyWith(
                          color: c.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.category.isEmpty ? l10n.segmentProblems : p.category,
                        style: context.textStyles.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (p.reportedByName?.isNotEmpty == true)
                        Text(
                          p.reportedByName!,
                          style: context.textStyles.bodySmall!.copyWith(
                            color: c.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(p.description, style: context.textStyles.bodyMedium),
                  ),
                ],
              ),
            ),
            if (widget.canResolve && p.isOpen) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  if (p.status == 'OPEN') ...[
                    Expanded(
                      child: TextButton(
                        onPressed: _busy ? null : () => _set('IN_PROGRESS'),
                        style: TextButton.styleFrom(
                          backgroundColor: c.brandSoft,
                          foregroundColor: c.onBrandSoft,
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(l10n.problemTake),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: FilledButton(
                      onPressed: _busy ? null : () => _set('RESOLVED'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        backgroundColor: c.success,
                      ),
                      child: Text(
                        l10n.problemResolved,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------- UMUMIY ----

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text, required this.count});

  final String text;
  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 10),
      child: Row(
        children: [
          Text(
            text.toUpperCase(),
            style: context.textStyles.labelSmall!.copyWith(
              color: c.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: context.textStyles.labelSmall!.copyWith(
              color: c.text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textStyles.labelSmall!.copyWith(color: c.textMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: context.textStyles.titleSmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
