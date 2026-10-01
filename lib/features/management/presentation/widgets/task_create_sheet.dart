import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../../app/di.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/glass.dart';
import '../../data/management_repository.dart';
import '../../domain/room_tile.dart';
import '../../domain/staff_member.dart';
import 'pressable.dart';
import 'state_palette.dart';

/// Yangi vazifa ma'lumotlari — oynadan chaqiruvchiga qaytadi.
class TaskDraft {
  const TaskDraft({
    required this.taskType,
    required this.priority,
    this.assigneeId,
    this.notes,
  });

  final String taskType;
  final String priority;
  final String? assigneeId;
  final String? notes;
}

/// Xona uchun vazifa yaratish: tur, muhimlik, mas'ul (ixtiyoriy), izoh.
///
/// Mas'ul tanlanmasa server o'zi navbat bo'yicha biriktiradi (yoki
/// "kim birinchi olsa" rejimida umumiy ro'yxatga qo'yadi) — sozlamaga qarab.
Future<void> showTaskCreateSheet(
  BuildContext context, {
  required RoomTile room,
  required Future<void> Function(TaskDraft draft) onSubmit,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _TaskCreateSheet(room: room, onSubmit: onSubmit),
  );
}

class _TaskCreateSheet extends StatefulWidget {
  const _TaskCreateSheet({required this.room, required this.onSubmit});

  final RoomTile room;
  final Future<void> Function(TaskDraft draft) onSubmit;

  @override
  State<_TaskCreateSheet> createState() => _TaskCreateSheetState();
}

class _TaskCreateSheetState extends State<_TaskCreateSheet> {
  static const _types = [
    ('CLEANING', Icons.cleaning_services_rounded),
    ('DEEP_CLEANING', Icons.auto_awesome_rounded),
    ('MAINTENANCE', Icons.build_rounded),
    ('INSPECTION', Icons.fact_check_rounded),
    ('TURN_DOWN', Icons.nightlight_round),
  ];
  static const _priorities = ['LOW', 'MEDIUM', 'HIGH', 'URGENT'];

  String _type = 'CLEANING';
  String _priority = 'MEDIUM';
  String? _assigneeId;
  final _notes = TextEditingController();
  bool _submitting = false;
  late final Future<List<StaffMember>> _staff = getIt<ManagementRepository>()
      .getStaff()
      .then((list) {
        final now = DateTime.now();
        return list.where((s) => s.isActive && !s.isAdmin).toList()
          // Ish vaqtidagilar oldinda — vazifani hozir ola oladiganlar
          ..sort((a, b) {
            final ad = a.isOnDuty(now), bd = b.isOnDuty(now);
            if (ad != bd) return ad ? -1 : 1;
            return a.fullName.compareTo(b.fullName);
          });
      });

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final l10n = context.l10n;
    try {
      await widget.onSubmit(
        TaskDraft(
          taskType: _type,
          priority: _priority,
          assigneeId: _assigneeId,
          notes: _notes.text,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      context.showSnack(l10n.taskCreated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      context.showSnack(friendlyError(context, e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return GlassSheet(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            10,
            20,
            bottom + MediaQuery.paddingOf(context).bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Sarlavha: xona nishoni bilan ---------------------------
              Row(
                children: [
                  Container(
                    constraints: const BoxConstraints(minWidth: 56),
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: c.brand,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.room.number,
                      style: context.textStyles.titleLarge!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.roomCreateTask,
                          style: context.textStyles.titleLarge,
                        ),
                        Text(
                          RoomStatePalette.label(l10n, widget.room.state),
                          style: context.textStyles.bodySmall!.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // --- Tur: belgili plitkalar -----------------------------------
              _Label(text: l10n.taskTypeLabel),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.2,
                children: [
                  for (final (type, icon) in _types)
                    _TypeTile(
                      icon: icon,
                      label: TaskPalette.typeLabel(l10n, type),
                      selected: _type == type,
                      onTap: () => setState(() => _type = type),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // --- Muhimlik: to'rt pog'ona ----------------------------------
              _Label(text: l10n.priorityLabel),
              Row(
                children: [
                  for (var i = 0; i < _priorities.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: _PriorityTile(
                        level: i + 1,
                        label: TaskPalette.priorityLabel(l10n, _priorities[i]),
                        color: TaskPalette.priorityColor(c, _priorities[i]),
                        selected: _priority == _priorities[i],
                        onTap: () => setState(() => _priority = _priorities[i]),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),

              // --- Mas'ul: avatarlar qatori ---------------------------------
              _Label(text: l10n.assigneeLabel),
              SizedBox(
                height: 86,
                child: FutureBuilder<List<StaffMember>>(
                  future: _staff,
                  builder: (context, snapshot) {
                    final staff = snapshot.data ?? const <StaffMember>[];
                    final now = DateTime.now();
                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _AssigneeTile(
                          // Tanlanmasa server o'zi biriktiradi (navbat yoki
                          // "kim birinchi olsa" — sozlamaga qarab)
                          label: l10n.assigneeAuto,
                          selected: _assigneeId == null,
                          onTap: () => setState(() => _assigneeId = null),
                          avatar: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: c.brandSoft,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              CupertinoIcons.shuffle,
                              size: 20,
                              color: c.onBrandSoft,
                            ),
                          ),
                        ),
                        for (final s in staff)
                          _AssigneeTile(
                            label: s.firstName.isNotEmpty
                                ? s.firstName
                                : s.fullName,
                            selected: _assigneeId == s.id,
                            onDuty: s.isOnDuty(now),
                            onTap: () => setState(() => _assigneeId = s.id),
                            avatar: AppAvatar(name: s.fullName, size: 48),
                          ),
                        if (snapshot.connectionState != ConnectionState.done)
                          const Padding(
                            padding: EdgeInsets.fromLTRB(14, 14, 0, 0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _notes,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(hintText: l10n.notesLabel),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(CupertinoIcons.add),
                label: Text(l10n.create),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

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

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? c.brand : c.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: selected ? Colors.white : c.brand),
            const SizedBox(height: 6),
            // Ikki qatorgacha: "Chuqur tozalash" kabi nomlar qisqarmaydi
            Text(
              label,
              style: context.textStyles.labelSmall!.copyWith(
                color: selected ? Colors.white : c.text,
                fontWeight: FontWeight.w600,
                height: 1.15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Muhimlik plitkasi: pog'onani ko'rsatuvchi ustunchalar va nom.
class _PriorityTile extends StatelessWidget {
  const _PriorityTile({
    required this.level,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  /// 1..4 — nechta ustuncha to'ldirilgan.
  final int level;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final barOn = selected ? Colors.white : color;
    final barOff = selected
        ? Colors.white.withValues(alpha: 0.3)
        : c.surfaceAlt;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? color : c.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 1; i <= 4; i++)
                  Container(
                    width: 4,
                    height: 5.0 + i * 3,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      color: i <= level ? barOn : barOff,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: context.textStyles.labelSmall!.copyWith(
                color: selected ? Colors.white : c.text,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _AssigneeTile extends StatelessWidget {
  const _AssigneeTile({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.avatar,
    this.onDuty = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget avatar;
  final bool onDuty;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: onTap,
      child: SizedBox(
        width: 74,
        child: Column(
          children: [
            Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? c.brand : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: avatar,
                ),
                if (onDuty)
                  Positioned(
                    right: 3,
                    bottom: 3,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: c.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.textStyles.labelSmall!.copyWith(
                color: selected ? c.brand : c.text,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
