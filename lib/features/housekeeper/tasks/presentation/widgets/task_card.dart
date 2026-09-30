import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_x.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/status_chip.dart';
import '../../domain/cleaning_task.dart';

/// Ro'yxatdagi bitta vazifa kartasi.
///
/// Dizayn qoidasi: bitta karta — bitta urg'u. Katta xona raqami + holat,
/// qolgan hamma narsa (qavat, muddat, shoshilinchlik) tinch ikkinchi qatorda.
class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, required this.onTap});

  final CleaningTask task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final isDone = task.status == TaskStatus.completed;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _RoomBadge(task: task),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.roomTitle(task.roomNumber),
                            style: context.textStyles.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _statusChip(context),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        task.floor,
                        task.roomType,
                      ].where((s) => s.isNotEmpty).join(' · '),
                      style: context.textStyles.bodyMedium!.copyWith(
                        color: c.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.isUrgent || task.deadline?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (task.isUrgent) ...[
                            Icon(
                              Icons.error_rounded,
                              size: 16,
                              color: c.danger,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.urgentBadge,
                              style: context.textStyles.labelMedium!.copyWith(
                                color: c.danger,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 14),
                          ],
                          if (task.deadline?.isNotEmpty == true) ...[
                            Icon(
                              Icons.schedule_rounded,
                              size: 16,
                              color: c.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.deadlineAt(task.deadline!),
                              style: context.textStyles.labelMedium!.copyWith(
                                color: c.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (task.status == TaskStatus.inProgress) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: task.progress / 100,
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${task.progress}%',
                  style: context.textStyles.labelLarge!.copyWith(
                    color: c.brand,
                  ),
                ),
              ],
            ),
          ],
          if (isDone && task.checklist.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.check_circle_rounded, size: 16, color: c.success),
                const SizedBox(width: 5),
                Text(
                  '${task.completedCount}/${task.checklist.length}',
                  style: context.textStyles.labelMedium!.copyWith(
                    color: c.success,
                  ),
                ),
              ],
            ),
          ],
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

class _RoomBadge extends StatelessWidget {
  const _RoomBadge({required this.task});

  final CleaningTask task;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDone = task.status == TaskStatus.completed;
    final bg = isDone
        ? c.successSoft
        : (task.isUrgent ? c.dangerSoft : c.brandSoft);
    final fg = isDone ? c.success : (task.isUrgent ? c.danger : c.onBrandSoft);

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            task.roomNumber,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
