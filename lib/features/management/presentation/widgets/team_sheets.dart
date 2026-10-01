import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/confirm_sheet.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/glass.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/format.dart';
import '../../domain/hk_task.dart';
import '../../domain/management_access.dart';
import '../../domain/staff_member.dart';
import '../cubit/team_cubit.dart';
import 'day_timeline.dart';
import 'pressable.dart';
import 'state_palette.dart';

// ------------------------------------------------------------- XODIM ----

/// Xodim tafsiloti: banner, 24 soatlik ish chizig'i, bugungi natija,
/// aloqa ma'lumotlari va faol vazifalari.
Future<void> showStaffSheet(
  BuildContext context,
  StaffMember member, {
  required List<HkTask> tasks,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final l10n = sheetContext.l10n;
      final c = sheetContext.colors;
      final now = DateTime.now();
      final onDuty = member.isActive && member.isOnDuty(now);
      final mine = tasks.where((t) => t.assignedTo == member.id).toList();
      final active = mine
          .where((t) => !t.isDone && t.status != 'CANCELLED')
          .toList();
      final doneToday = mine.where((t) {
        final d = t.completedAt;
        return t.isDone &&
            d != null &&
            d.year == now.year &&
            d.month == now.month &&
            d.day == now.day;
      }).length;
      final accent = onDuty ? c.success : c.textMuted;

      return GlassSheet(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.88,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              10,
              20,
              MediaQuery.paddingOf(sheetContext).bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Banner -----------------------------------------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: accent, width: 2.5),
                        ),
                        child: AppAvatar(name: member.fullName, size: 76),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        member.fullName,
                        style: sheetContext.textStyles.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '@${member.username}',
                        style: sheetContext.textStyles.bodySmall!.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          StatusChip(
                            label: !member.isActive
                                ? (member.status == 'TERMINATED'
                                      ? l10n.staffStatusTerminated
                                      : l10n.staffStatusInactive)
                                : (onDuty
                                      ? l10n.staffOnDutyBadge
                                      : l10n.staffOffDuty),
                            background: onDuty ? c.successSoft : c.surfaceAlt,
                            foreground: accent,
                            icon: onDuty
                                ? CupertinoIcons.clock_fill
                                : CupertinoIcons.moon_fill,
                          ),
                          if (member.wasRecentlyOnline(now))
                            StatusChip(
                              label: l10n.staffOnline,
                              background: c.brandSoft,
                              foreground: c.onBrandSoft,
                              icon: CupertinoIcons.dot_radiowaves_left_right,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 24 soatlik ish chizig'i
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.scheduleLabel,
                            style: sheetContext.textStyles.labelMedium!.copyWith(
                              color: c.textMuted,
                            ),
                          ),
                          Text(
                            '${member.workStart} – ${member.workEnd}',
                            style: sheetContext.textStyles.labelLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DayTimeline(
                        start: member.workStart,
                        end: member.workEnd,
                        now: now,
                        color: onDuty ? c.success : c.textMuted.withValues(alpha: 0.5),
                        trackColor: c.surfaceAlt,
                        markerColor: c.text,
                        height: 8,
                        labelStyle: sheetContext.textStyles.labelSmall!.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // --- Bugungi natija ---------------------------------------
                Row(
                  children: [
                    Expanded(
                      child: _Stat(
                        value: '${active.length}',
                        label: l10n.segmentTasks,
                        color: c.brand,
                        background: c.brandSoft,
                        icon: CupertinoIcons.sparkles,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Stat(
                        value: '$doneToday',
                        label: l10n.hkDoneToday,
                        color: c.success,
                        background: c.successSoft,
                        icon: CupertinoIcons.checkmark_seal_fill,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // --- Aloqa -------------------------------------------------
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      if (member.phone?.isNotEmpty == true)
                        _Row(
                          icon: CupertinoIcons.phone_fill,
                          label: l10n.phoneLabel,
                          value: member.phone!,
                        ),
                      _Row(
                        icon: CupertinoIcons.arrow_right_circle_fill,
                        label: l10n.staffLastLoginLabel,
                        value: member.lastLoginAt == null
                            ? l10n.staffNeverLoggedIn
                            : formatWhen(member.lastLoginAt!, now),
                      ),
                    ],
                  ),
                ),

                // --- Faol vazifalar ----------------------------------------
                if (active.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _Caption(text: l10n.segmentTasks),
                  for (final t in active)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            constraints: const BoxConstraints(minWidth: 40),
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: TaskPalette.statusSoft(c, t.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              t.roomNumber,
                              style: sheetContext.textStyles.labelLarge!.copyWith(
                                color: TaskPalette.statusColor(c, t.status),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              TaskPalette.typeLabel(l10n, t.taskType),
                              style: sheetContext.textStyles.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          StatusChip(
                            label: TaskPalette.statusLabel(l10n, t.status),
                            background: TaskPalette.statusSoft(c, t.status),
                            foreground: TaskPalette.statusColor(c, t.status),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}

// ------------------------------------------------------------ VAZIFA ----

/// Vazifa tafsiloti va amallar: biriktirish, yakunlash, bekor qilish.
Future<void> showTaskSheet(
  BuildContext context,
  HkTask task,
  ManagementAccess access,
) {
  final cubit = context.read<TeamCubit>();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _TaskSheet(taskId: task.id, access: access),
    ),
  );
}

class _TaskSheet extends StatefulWidget {
  const _TaskSheet({required this.taskId, required this.access});

  final String taskId;
  final ManagementAccess access;

  @override
  State<_TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends State<_TaskSheet> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action, {String? done}) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      if (done != null) context.showSnack(done);
    } catch (e) {
      if (!mounted) return;
      context.showSnack(friendlyError(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _assign(HkTask task) async {
    final cubit = context.read<TeamCubit>();
    final staff = cubit.state.staff.items
        .where((s) => s.isActive && !s.isAdmin)
        .toList();
    final picked = await pickStaff(
      context,
      staff,
      current: task.assignedTo,
      tasks: cubit.state.tasks.items,
    );
    if (picked == null || !mounted) return;
    await _run(
      () => cubit.assignTask(task.id, picked.id),
      done: context.l10n.taskAssigned,
    );
  }

  Future<void> _setStatus(HkTask task, String status) async {
    final l10n = context.l10n;
    final completing = status == 'COMPLETED';
    final ok = await showConfirmSheet(
      context,
      title: completing ? l10n.taskComplete : l10n.taskCancelAction,
      body: completing ? l10n.taskCompleteConfirm : l10n.taskCancelConfirm,
      confirmLabel: l10n.confirm,
      icon: completing ? CupertinoIcons.checkmark_seal_fill : CupertinoIcons.xmark_circle,
      destructive: !completing,
    );
    if (!ok || !mounted) return;
    await _run(() => context.read<TeamCubit>().setTaskStatus(task.id, status));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final task = context.select(
      (TeamCubit cubit) => cubit.state.tasks.items.firstWhere(
        (t) => t.id == widget.taskId,
        orElse: () => cubit.state.tasks.items.first,
      ),
    );
    final color = TaskPalette.statusColor(c, task.status);
    final soft = TaskPalette.statusSoft(c, task.status);
    final now = DateTime.now();
    final priorityColor = TaskPalette.priorityColor(c, task.priority);
    final closed = task.isDone || task.status == 'CANCELLED';

    return GlassSheet(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            10,
            20,
            MediaQuery.paddingOf(context).bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Banner: xona, tur, holat --------------------------------
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
                decoration: BoxDecoration(
                  color: soft,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.roomNumber,
                            style: context.textStyles.displaySmall!.copyWith(
                              color: color,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            TaskPalette.typeLabel(l10n, task.taskType),
                            style: context.textStyles.titleMedium!.copyWith(
                              color: color,
                            ),
                          ),
                          Text(
                            TaskPalette.statusLabel(l10n, task.status),
                            style: context.textStyles.bodySmall!.copyWith(
                              color: color.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        TaskPalette.priorityLabel(l10n, task.priority),
                        style: context.textStyles.labelMedium!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // --- Mas'ul ---------------------------------------------------
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (task.assigneeName != null)
                          AppAvatar(name: task.assigneeName!, size: 44)
                        else
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: c.warningSoft,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              CupertinoIcons.person_badge_plus,
                              size: 20,
                              color: c.warning,
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.assigneeLabel,
                                style: context.textStyles.labelSmall!.copyWith(
                                  color: c.textMuted,
                                ),
                              ),
                              Text(
                                task.assigneeName ?? l10n.taskUnassigned,
                                style: context.textStyles.titleSmall!.copyWith(
                                  color: task.assigneeName == null
                                      ? c.warning
                                      : c.text,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Tugma alohida qatorda — uzun ism ham to'liq ko'rinadi
                    if (!closed && widget.access.canAssignTask) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: _busy ? null : () => _assign(task),
                          style: TextButton.styleFrom(
                            backgroundColor: c.brandSoft,
                            foregroundColor: c.onBrandSoft,
                            minimumSize: const Size.fromHeight(42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: Icon(
                            task.assignedTo == null
                                ? CupertinoIcons.person_badge_plus
                                : CupertinoIcons.arrow_right_arrow_left,
                            size: 16,
                          ),
                          label: Text(
                            task.assignedTo == null
                                ? l10n.taskAssign
                                : l10n.taskReassign,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // --- Jarayon o'qi ---------------------------------------------
              _Caption(text: l10n.taskTimelineTitle),
              _Step(
                done: true,
                color: c.success,
                title: l10n.taskCreatedAt,
                value: formatWhen(task.createdAt, now),
              ),
              _Step(
                done: task.assignedTo != null,
                color: c.success,
                title: l10n.taskStepAssigned,
                value: task.assigneeName ?? l10n.taskUnassigned,
              ),
              _Step(
                done: task.startedAt != null,
                color: c.success,
                title: l10n.taskStartedAt,
                value: task.startedAt == null
                    ? l10n.taskNotStarted
                    : formatWhen(task.startedAt!, now),
              ),
              _Step(
                done: task.isDone,
                color: task.status == 'CANCELLED' ? c.danger : c.success,
                isLast: true,
                title: task.status == 'CANCELLED'
                    ? l10n.taskCancelled
                    : l10n.taskCompleted,
                value: task.completedAt != null
                    ? (task.autoCompleted
                          ? '${formatWhen(task.completedAt!, now)} · ${l10n.taskAutoCompleted}'
                          : formatWhen(task.completedAt!, now))
                    : '—',
              ),

              // --- Ish bandlari ---------------------------------------------
              if (task.checklistTotal > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.taskChecklistLabel,
                      style: context.textStyles.labelMedium!.copyWith(
                        color: c.textMuted,
                      ),
                    ),
                    Text(
                      l10n.taskChecklist(task.checklistDone, task.checklistTotal),
                      style: context.textStyles.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: task.checklistDone / task.checklistTotal,
                    ),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: 8,
                      color: color,
                      backgroundColor: c.surfaceAlt,
                    ),
                  ),
                ),
              ],
              if (task.notes?.isNotEmpty == true) ...[
                const SizedBox(height: 14),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 3,
                        decoration: BoxDecoration(
                          color: c.textMuted.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          task.notes!,
                          style: context.textStyles.bodyMedium!.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // --- Amallar --------------------------------------------------
              if (!closed && widget.access.canUpdateTask) ...[
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _busy ? null : () => _setStatus(task, 'COMPLETED'),
                  style: FilledButton.styleFrom(backgroundColor: c.success),
                  icon: const Icon(CupertinoIcons.checkmark_seal_fill, size: 18),
                  label: Text(l10n.taskComplete),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _busy ? null : () => _setStatus(task, 'CANCELLED'),
                  style: TextButton.styleFrom(
                    foregroundColor: c.danger,
                    minimumSize: const Size.fromHeight(46),
                  ),
                  child: Text(l10n.taskCancelAction),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Jarayon o'qidagi bitta qadam: doira (bajarilgan — to'la, kutilayotgan —
/// bo'sh), pastga chiziq, o'ngda nom va vaqt.
class _Step extends StatelessWidget {
  const _Step({
    required this.done,
    required this.color,
    required this.title,
    required this.value,
    this.isLast = false,
  });

  final bool done;
  final Color color;
  final String title;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Kutilayotgan qadam: shisha oyna fonida ham ko'rinadigan kulrang halqa
    final pending = c.textMuted.withValues(alpha: 0.4);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: done ? color : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: done ? color : pending,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: done
                      ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: done ? color.withValues(alpha: 0.35) : pending,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 4 : 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textStyles.titleSmall!.copyWith(
                      color: done ? c.text : c.textMuted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Qiymat doim o'ng chetga tekislanadi — qisqa vaqt ham,
                  // uzun ism ham bir chiziqda turadi
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 1.5),
                      child: Text(
                        value,
                        style: context.textStyles.bodySmall!.copyWith(
                          color: c.textMuted,
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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

// ---------------------------------------------------------- TANLAGICH ----

/// Xodim tanlash: qidiruv, ish vaqtidagilar tepada, har birida hozirgi
/// yuklamasi (faol vazifalar soni) — ish teng taqsimlansin.
Future<StaffMember?> pickStaff(
  BuildContext context,
  List<StaffMember> staff, {
  String? current,
  List<HkTask> tasks = const [],
}) {
  return showModalBottomSheet<StaffMember>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) =>
        _StaffPicker(staff: staff, current: current, tasks: tasks),
  );
}

class _StaffPicker extends StatefulWidget {
  const _StaffPicker({
    required this.staff,
    required this.current,
    required this.tasks,
  });

  final List<StaffMember> staff;
  final String? current;
  final List<HkTask> tasks;

  @override
  State<_StaffPicker> createState() => _StaffPickerState();
}

class _StaffPickerState extends State<_StaffPicker> {
  String _query = '';

  int _load(String userId) => widget.tasks
      .where(
        (t) => t.assignedTo == userId && !t.isDone && t.status != 'CANCELLED',
      )
      .length;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final now = DateTime.now();
    final q = _query.trim().toLowerCase();
    final visible = widget.staff
        .where((s) => q.isEmpty || s.fullName.toLowerCase().contains(q))
        .toList()
      // Ish vaqtidagilar tepada, ular ichida — yuklamasi kami birinchi
      ..sort((a, b) {
        final ad = a.isOnDuty(now), bd = b.isOnDuty(now);
        if (ad != bd) return ad ? -1 : 1;
        final byLoad = _load(a.id).compareTo(_load(b.id));
        if (byLoad != 0) return byLoad;
        return a.fullName.compareTo(b.fullName);
      });

    return GlassSheet(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.74,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.assignSheetTitle, style: context.textStyles.titleLarge),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: l10n.staffSearchHint,
                      prefixIcon: const Icon(CupertinoIcons.search, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  MediaQuery.paddingOf(context).bottom + 20,
                ),
                itemCount: visible.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final s = visible[index];
                  final onDuty = s.isOnDuty(now);
                  final load = _load(s.id);
                  final selected = s.id == widget.current;
                  return Pressable(
                    scale: 0.98,
                    onTap: () => Navigator.of(context).pop(s),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected ? c.brandSoft : c.surface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
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
                            child: AppAvatar(name: s.fullName, size: 40),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.fullName,
                                  style: context.textStyles.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${onDuty ? l10n.staffOnDutyBadge : l10n.staffOffDuty}'
                                  ' · ${s.workStart}–${s.workEnd}',
                                  style: context.textStyles.bodySmall!.copyWith(
                                    color: onDuty ? c.success : c.textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (selected)
                            Icon(
                              CupertinoIcons.checkmark_circle_fill,
                              color: c.brand,
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: load == 0 ? c.successSoft : c.surfaceAlt,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                load == 0
                                    ? l10n.staffNoTasks
                                    : l10n.staffActiveTasks(load),
                                style: context.textStyles.labelSmall!.copyWith(
                                  color: load == 0 ? c.success : c.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------- UMUMIY ----

class _Caption extends StatelessWidget {
  const _Caption({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: context.textStyles.labelSmall!.copyWith(
          color: context.colors.textMuted,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: c.textMuted),
          const SizedBox(width: 12),
          Text(
            label,
            style: context.textStyles.bodyMedium!.copyWith(color: c.textMuted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: context.textStyles.titleSmall,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    required this.color,
    required this.background,
    required this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final Color background;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: context.textStyles.headlineMedium!.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                Text(
                  label,
                  style: context.textStyles.labelSmall!.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(icon, size: 22, color: color.withValues(alpha: 0.7)),
        ],
      ),
    );
  }
}
