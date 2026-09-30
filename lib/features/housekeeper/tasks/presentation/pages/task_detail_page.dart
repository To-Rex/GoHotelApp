import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app/di.dart';
import '../../../../../core/extensions/context_x.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/confirm_sheet.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/glass.dart';
import '../../../../../core/widgets/image_viewer_page.dart';
import '../../../../../core/widgets/status_chip.dart';
import '../../domain/cleaning_task.dart';
import '../cubit/task_detail_cubit.dart';
import '../cubit/tasks_cubit.dart';
import '../widgets/photo_report_sheet.dart';
import '../widgets/report_problem_sheet.dart';

/// Bitta tozalash vazifasi: boshlash → checklist → yakunlash.
class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key});

  /// Ro'yxatdan ochish: detal yopilganda yangilangan vazifa ro'yxatga qaytadi.
  static Future<void> open(BuildContext context, CleaningTask task) async {
    final tasksCubit = context.read<TasksCubit>();
    final updated = await Navigator.of(context).push<CleaningTask>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => TaskDetailCubit(getIt(), task)..refresh(),
          child: const TaskDetailPage(),
        ),
      ),
    );
    if (updated != null) tasksCubit.applyUpdated(updated);
    // Ro'yxatni fon rejimida ham yangilab qo'yamiz (server holati aniq bo'lsin).
    tasksCubit.load(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<TaskDetailCubit, TaskDetailState>(
      listener: (context, state) {
        if (state.justCompleted) {
          context.showSnack(l10n.cleaningDone);
        } else if (state.error != null) {
          context.showSnack(
            friendlyError(context, state.error!),
            isError: true,
          );
        }
      },
      builder: (context, state) {
        final task = state.task;
        return PopScope<CleaningTask>(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) Navigator.of(context).pop(task);
          },
          // Appbar va pastki tugma shishasi bitta fon o'qishidan foydalanadi
          child: GlassScope(
            child: Scaffold(
              // Shisha panellar: kontent appbar va pastki tugma ostidan
              // skroll bo'lib, blur orqali ko'rinadi.
              extendBody: true,
              extendBodyBehindAppBar: true,
              appBar: GlassAppBar(
                title: Text(l10n.roomTitle(task.roomNumber)),
                leading: IconButton(
                  icon: const Icon(CupertinoIcons.back, size: 26),
                  onPressed: () => Navigator.of(context).pop(task),
                ),
              ),
              body: Builder(
                builder: (context) {
                  final barPadding = MediaQuery.paddingOf(context);
                  return RefreshIndicator(
                    onRefresh: () => context.read<TaskDetailCubit>().refresh(),
                    edgeOffset: barPadding.top,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        20,
                        barPadding.top + 8,
                        20,
                        barPadding.bottom + 20,
                      ),
                      children: [
                        _HeaderCard(task: task),
                        const SizedBox(height: 14),
                        if (task.checklist.isNotEmpty)
                          _ChecklistCard(task: task, busy: state.busy),
                        const SizedBox(height: 14),
                        _ActionsCard(task: task),
                        if (state.photoIds.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _SentPhotosCard(photoIds: state.photoIds),
                        ],
                      ],
                    ),
                  );
                },
              ),
              bottomNavigationBar: _BottomAction(state: state),
            ),
          ),
        );
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.task});

  final CleaningTask task;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: task.status == TaskStatus.completed
                      ? c.successSoft
                      : c.brandSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      task.roomNumber,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: task.status == TaskStatus.completed
                            ? c.success
                            : c.onBrandSoft,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      [
                        task.floor,
                        task.roomType,
                      ].where((s) => s.isNotEmpty).join(' · '),
                      style: context.textStyles.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _statusChip(context),
                        if (task.isUrgent)
                          StatusChip(
                            label: l10n.urgentBadge,
                            background: c.dangerSoft,
                            foreground: c.danger,
                            icon: Icons.priority_high_rounded,
                          ),
                        if (task.deadline != null && task.deadline!.isNotEmpty)
                          StatusChip(
                            label: l10n.deadlineAt(task.deadline!),
                            background: c.surfaceAlt,
                            foreground: c.textMuted,
                            icon: Icons.schedule_rounded,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (task.guest != null && task.guest!.isNotEmpty) ...[
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.person_outline_rounded,
              label: l10n.guestLabel,
              value: [
                task.guest!,
                if (task.guestStatus?.isNotEmpty == true) task.guestStatus!,
              ].join(' — '),
            ),
          ],
          if (task.note != null && task.note!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.sticky_note_2_outlined,
              label: l10n.noteLabel,
              value: task.note!,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                l10n.progressLabel,
                style: context.textStyles.labelMedium!.copyWith(
                  color: c.textMuted,
                ),
              ),
              const Spacer(),
              Text(
                '${task.progress}%',
                style: context.textStyles.titleSmall!.copyWith(color: c.brand),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: task.progress / 100,
              minHeight: 12,
              valueColor: AlwaysStoppedAnimation<Color>(
                task.status == TaskStatus.completed ? c.success : c.brand,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return switch (task.status) {
      TaskStatus.pending => StatusChip(
        label: l10n.statusNew,
        background: c.brandSoft,
        foreground: c.onBrandSoft,
      ),
      TaskStatus.inProgress => StatusChip(
        label: l10n.statusInProgress,
        background: c.warningSoft,
        foreground: c.warning,
      ),
      TaskStatus.completed => StatusChip(
        label: l10n.statusDone,
        background: c.successSoft,
        foreground: c.success,
        icon: Icons.check_rounded,
      ),
    };
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: c.textMuted),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: context.textStyles.bodyMedium!.copyWith(color: c.textMuted),
        ),
        Expanded(child: Text(value, style: context.textStyles.bodyMedium)),
      ],
    );
  }
}

/// Checklist — har bir band katta, barmoq bilan oson belgilanadi.
class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.task, required this.busy});

  final CleaningTask task;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    // Yakunlangan vazifada belgilar qotadi: ish tugagach uni orqaga
    // o'zgartirish hisobotni chalkashtirardi
    final canToggle = task.status == TaskStatus.inProgress && !busy;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.checklistTitle, style: context.textStyles.titleMedium),
              const Spacer(),
              Text(
                '${task.completedCount}/${task.checklist.length}',
                style: context.textStyles.titleSmall!.copyWith(
                  color: c.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final item in task.checklist)
            _ChecklistTile(
              item: item,
              enabled: canToggle,
              onTap: () => context.read<TaskDetailCubit>().toggleItem(item.id),
            ),
          if (task.status == TaskStatus.pending)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Text(
                l10n.startCleaning,
                style: context.textStyles.bodySmall!.copyWith(
                  color: c.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({
    required this.item,
    required this.enabled,
    required this.onTap,
  });

  final ChecklistItem item;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: item.isCompleted ? c.success : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: item.isCompleted ? c.success : c.outline,
                  width: 2,
                ),
              ),
              child: item.isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      size: 20,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.title,
                style: context.textStyles.bodyLarge!.copyWith(
                  decoration: item.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: item.isCompleted ? c.textMuted : c.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Qo'shimcha amallar: foto hisobot va muammo xabari.
class _ActionsCard extends StatelessWidget {
  const _ActionsCard({required this.task});

  final CleaningTask task;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c.brandSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.photo_camera_outlined, color: c.onBrandSoft),
            ),
            title: Text(l10n.photoReportTitle),
            trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
            onTap: () => showPhotoReportSheet(context),
          ),
          Divider(height: 1, indent: 72, color: c.outline),
          ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c.warningSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.report_problem_outlined, color: c.warning),
            ),
            title: Text(l10n.reportProblem),
            trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
            onTap: () => showReportProblemSheet(
              context,
              taskId: task.id,
              roomNumber: task.roomNumber,
            ),
          ),
        ],
      ),
    );
  }
}

/// Avval yuborilgan foto hisobot rasmlari (bosilganda kattalashadi).
class _SentPhotosCard extends StatelessWidget {
  const _SentPhotosCard({required this.photoIds});

  final List<String> photoIds;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final cubit = context.read<TaskDetailCubit>();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.photo_library_outlined, size: 20, color: c.textMuted),
              const SizedBox(width: 8),
              Text(
                l10n.photoReportTitle,
                style: context.textStyles.titleMedium,
              ),
              const Spacer(),
              Text(
                '${photoIds.length}',
                style: context.textStyles.titleSmall!.copyWith(
                  color: c.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photoIds.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final url = cubit.photoUrl(photoIds[index]);
                final headers = cubit.photoHeaders();
                return GestureDetector(
                  onTap: () => ImageViewerPage.open(
                    context,
                    imageUrl: url,
                    headers: headers,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      httpHeaders: headers,
                      width: 88,
                      height: 88,
                      // 88px katakka to'liq surat dekodlanmasin
                      memCacheWidth:
                          (88 * MediaQuery.devicePixelRatioOf(context))
                              .round(),
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          Container(width: 88, height: 88, color: c.surfaceAlt),
                      errorWidget: (_, _, _) => Container(
                        width: 88,
                        height: 88,
                        color: c.surfaceAlt,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: c.textMuted,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Pastki asosiy tugma — vazifa holatiga qarab o'zgaradi.
class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.state});

  final TaskDetailState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final task = state.task;

    Widget child;
    switch (task.status) {
      case TaskStatus.pending:
        child = FilledButton.icon(
          onPressed: state.busy
              ? null
              : () => context.read<TaskDetailCubit>().start(),
          icon: const Icon(Icons.play_arrow_rounded, size: 28),
          label: Text(l10n.startCleaning),
        );
      case TaskStatus.inProgress:
        /* Vazifani YAKUNLAYDIGAN yagona joy shu tugma.

           Bandni belgilash vazifani yopmaydi — ilgari oxirgi band
           belgilanishi bilan ish o'zi tugab qolardi va farrosh tugmani
           bosishga ulgurmasdi. Endi belgilash faqat progressni suradi,
           yakunlash esa ongli bosish bilan bo'ladi.

           Belgilanmagan ish qolgan bo'lsa yakunlash TAQIQLANMAYDI —
           ba'zi ish o'rinsiz bo'lishi mumkin — lekin nechtasi qolgani
           tugmada ham, tasdiq oynasida ham aytiladi. */
        final remaining = task.checklist.length - task.completedCount;
        final allDone = task.checklist.isEmpty || remaining == 0;

        child = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.checklist.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      allDone
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 16,
                      color: allDone ? c.success : c.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      allDone
                          ? l10n.checklistAllDone
                          : l10n.checklistRemaining(remaining),
                      style: context.textStyles.bodySmall!.copyWith(
                        color: allDone ? c.success : c.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: state.busy
                    ? null
                    : () async {
                        final cubit = context.read<TaskDetailCubit>();
                        final ok = await showConfirmSheet(
                          context,
                          title: l10n.confirmFinishTitle,
                          body: allDone
                              ? l10n.confirmFinishBody
                              : l10n.confirmFinishBodyRemaining(remaining),
                          confirmLabel: l10n.finishCleaning,
                          icon: Icons.task_alt_rounded,
                        );
                        if (ok) await cubit.finish();
                      },
                style: FilledButton.styleFrom(
                  // Hamma ish belgilanmaguncha tugma "tayyor" ko'rinishida
                  // turmaydi — bosish mumkin, lekin e'tibor tortmaydi
                  backgroundColor: allDone ? c.success : null,
                ),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 26),
                label: Text(l10n.finishCleaning),
              ),
            ),
          ],
        );
      case TaskStatus.completed:
        child = Container(
          height: 58,
          decoration: BoxDecoration(
            color: c.successSoft,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, color: c.success),
              const SizedBox(width: 8),
              Text(
                l10n.statusDone,
                style: context.textStyles.titleMedium!.copyWith(
                  color: c.success,
                ),
              ),
            ],
          ),
        );
    }

    // Progressiv shisha: tepasi shaffof, pastga qarab blur kuchayadi —
    // checklist tugma ostiga "erib" kiradi.
    return ProgressiveGlass(
      strongEdge: VerticalDirection.down,
      maxSigma: 16,
      maxTintAlpha: 0.48,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
          child: child,
        ),
      ),
    );
  }
}
