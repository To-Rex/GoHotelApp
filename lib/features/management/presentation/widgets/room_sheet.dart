import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/confirm_sheet.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/glass.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../data/management_repository.dart';
import '../../domain/format.dart';
import '../../domain/management_access.dart';
import '../../domain/room_tile.dart';
import '../cubit/room_map_cubit.dart';
import 'minute_ticker.dart';
import 'pressable.dart';
import 'state_palette.dart';
import 'task_create_sheet.dart';

/// Xona tafsiloti: holat va qanchadan beri, xonadagi mehmon, amallar.
Future<void> showRoomSheet(
  BuildContext context,
  RoomTile room,
  ManagementAccess access,
) {
  final cubit = context.read<RoomMapCubit>();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _RoomSheet(roomId: room.id, access: access),
    ),
  );
}

class _RoomSheet extends StatefulWidget {
  const _RoomSheet({required this.roomId, required this.access});

  final String roomId;
  final ManagementAccess access;

  @override
  State<_RoomSheet> createState() => _RoomSheetState();
}

class _RoomSheetState extends State<_RoomSheet> {
  late final Future<List<RoomStay>> _stays = context
      .read<RoomMapCubit>()
      .getStays(widget.roomId);
  bool _busy = false;

  Future<void> _changeState(RoomTile room, RoomState target) async {
    final l10n = context.l10n;
    final ok = await showConfirmSheet(
      context,
      title: l10n.roomChangeStatus,
      body: '${room.number}: ${RoomStatePalette.label(l10n, room.state)} → '
          '${RoomStatePalette.label(l10n, target)}',
      confirmLabel: l10n.confirm,
      icon: RoomStatePalette.icon(target),
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await context.read<RoomMapCubit>().setRoomStatus(room.id, target);
      if (!mounted) return;
      context.showSnack(l10n.roomStatusChanged);
    } catch (e) {
      if (!mounted) return;
      context.showSnack(friendlyError(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createTask(RoomTile room) async {
    final cubit = context.read<RoomMapCubit>();
    await showTaskCreateSheet(
      context,
      room: room,
      onSubmit: (draft) async {
        await getIt<ManagementRepository>().createTask(
          branchId: room.branchId,
          roomId: room.id,
          taskType: draft.taskType,
          priority: draft.priority,
          assignedTo: draft.assigneeId,
          notes: draft.notes,
        );
        cubit.load(silent: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final room = context.select(
      (RoomMapCubit cubit) => cubit.state.rooms.firstWhere(
        (r) => r.id == widget.roomId,
        orElse: () => cubit.state.rooms.first,
      ),
    );
    final color = RoomStatePalette.color(c, room.state);
    final soft = RoomStatePalette.soft(c, room.state);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return GlassSheet(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
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
              // --- Banner: raqam, holat, qanchadan beri -------------------
              AnimatedContainer(
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutCubic,
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
                            room.number,
                            style: context.textStyles.displayMedium!.copyWith(
                              color: color,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            RoomStatePalette.label(l10n, room.state),
                            style: context.textStyles.titleMedium!.copyWith(
                              color: color,
                            ),
                          ),
                          if (room.statusChangedAt != null)
                            MinuteTicker(
                              builder: (context, now) => Text(
                                l10n.roomSinceLabel(
                                  formatDuration(
                                    now.difference(room.statusChangedAt!),
                                    h: l10n.hourShort,
                                    m: l10n.minuteShort,
                                  ),
                                ),
                                style: context.textStyles.bodySmall!.copyWith(
                                  color: color.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 380),
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        RoomStatePalette.icon(room.state),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // --- Faktlar --------------------------------------------------
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (room.capacity != null)
                    _Fact(
                      icon: CupertinoIcons.person_2_fill,
                      text: l10n.roomCapacity(room.capacity!),
                    ),
                  if (room.basePrice > 0)
                    _Fact(
                      icon: CupertinoIcons.tag_fill,
                      text: '${formatMoney(room.basePrice)} ${l10n.currencySuffix}',
                    ),
                ],
              ),
              if (room.notes?.isNotEmpty == true) ...[
                const SizedBox(height: 10),
                _Quote(text: room.notes!, color: c.textMuted),
              ],
              const SizedBox(height: 20),

              // --- Mehmon ---------------------------------------------------
              _SectionLabel(text: l10n.roomGuestTitle),
              FutureBuilder<List<RoomStay>>(
                future: _stays,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ),
                    );
                  }
                  final stays = (snapshot.data ?? const <RoomStay>[])
                      .where((s) => s.isActive)
                      .toList();
                  if (snapshot.hasError || stays.isEmpty) {
                    return _EmptyLine(
                      icon: snapshot.hasError
                          ? CupertinoIcons.lock
                          : CupertinoIcons.bed_double,
                      text: snapshot.hasError
                          ? friendlyError(context, snapshot.error!)
                          : l10n.roomNoStay,
                    );
                  }
                  return Column(
                    children: [for (final stay in stays) _StayCard(stay: stay)],
                  );
                },
              ),

              // --- Amallar --------------------------------------------------
              if (widget.access.canSetRoomStatus) ...[
                const SizedBox(height: 20),
                _SectionLabel(text: l10n.roomChangeStatus),
                if (room.state.isBusy)
                  _EmptyLine(
                    icon: CupertinoIcons.info_circle,
                    text: l10n.roomStatusBusyHint,
                  )
                else
                  // Teng balandlikdagi plitkalar: ikki qatorli nom ham
                  // qatorni qiyshaytirmaydi
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (i, s)
                            in RoomState.manual
                                .where((s) => s != room.state)
                                .indexed) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: _StateChoice(
                              state: s,
                              enabled: !_busy,
                              onTap: () => _changeState(room, s),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
              if (widget.access.canCreateTask) ...[
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _busy ? null : () => _createTask(room),
                  icon: const Icon(CupertinoIcons.sparkles),
                  label: Text(l10n.roomCreateTask),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

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

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c.textMuted),
          const SizedBox(width: 6),
          Text(
            text,
            style: context.textStyles.labelMedium!.copyWith(
              color: c.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Izoh — chapida ingichka chiziq bilan (iqtibos ko'rinishi).
class _Quote extends StatelessWidget {
  const _Quote({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 3,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: context.textStyles.bodyMedium!.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLine extends StatelessWidget {
  const _EmptyLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surfaceAlt.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: c.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: context.textStyles.bodyMedium!.copyWith(color: c.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bron kartasi: mehmon, sanalar va turish jarayoni (necha kecha o'tdi).
class _StayCard extends StatelessWidget {
  const _StayCard({required this.stay});

  final RoomStay stay;

  /// (o'tgan kechalar, jami kechalar) — sanalar o'qilmasa null.
  (int, int)? get _nights {
    final from = DateTime.tryParse(stay.checkIn);
    final to = DateTime.tryParse(stay.checkOut);
    if (from == null || to == null) return null;
    final total = to.difference(from).inDays;
    if (total <= 0) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final done = today.difference(from).inDays.clamp(0, total);
    return (done, total);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final checkedIn = stay.status == 'CHECKED_IN';
    final accent = checkedIn ? c.danger : c.brand;
    final nights = _nights;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: stay.guestName, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stay.guestName,
                      style: context.textStyles.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    // Holat va bron raqami — ism ostida: ism uchun butun
                    // kenglik qoladi
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: checkedIn
                                ? l10n.roomStateOccupied
                                : l10n.roomStateReserved,
                            style: TextStyle(
                              color: accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(text: '  ·  ${stay.number}'),
                        ],
                      ),
                      style: context.textStyles.bodySmall!.copyWith(
                        color: c.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (stay.guestPhone?.isNotEmpty == true)
                      Text(
                        stay.guestPhone!,
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
          const SizedBox(height: 14),
          // Sanalar va ular orasidagi jarayon chizig'i
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StayDate(label: l10n.stayCheckIn, iso: stay.checkIn),
              Expanded(
                child: nights != null && checkedIn
                    ? Text(
                        l10n.roomStayNights(nights.$1, nights.$2),
                        style: context.textStyles.labelSmall!.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : const SizedBox.shrink(),
              ),
              _StayDate(
                label: l10n.stayCheckOut,
                iso: stay.checkOut,
                alignEnd: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: SizedBox(
              height: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: c.surfaceAlt),
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: nights == null || !checkedIn
                          ? 0
                          : (nights.$1 / nights.$2).clamp(0.03, 1),
                    ),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, t, _) => FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: t,
                      child: ColoredBox(color: accent),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (stay.companions.isNotEmpty || stay.debt > 0) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final name in stay.companions)
                  StatusChip(
                    label: name,
                    background: c.surfaceAlt,
                    foreground: c.text,
                    icon: CupertinoIcons.person,
                  ),
                if (stay.debt > 0)
                  StatusChip(
                    label: l10n.bookingDebt(formatMoney(stay.debt)),
                    background: c.dangerSoft,
                    foreground: c.danger,
                    icon: CupertinoIcons.exclamationmark_circle,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Bron sanasi: ustida kichik yozuv, ostida `kk.oo.yyyy` ko'rinishidagi
/// sana (server `yyyy-MM-dd` yuboradi; o'qilmasa o'zi ko'rsatiladi).
class _StayDate extends StatelessWidget {
  const _StayDate({
    required this.label,
    required this.iso,
    this.alignEnd = false,
  });

  final String label;
  final String iso;
  final bool alignEnd;

  static String _format(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textStyles.labelSmall!.copyWith(color: c.textMuted),
        ),
        const SizedBox(height: 1),
        Text(
          _format(iso),
          style: context.textStyles.labelLarge!.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Holat tanlovi: oq plitka, tepada xarita katagidagi kabi holat belgisi,
/// ostida nomi. Plitkalar teng kenglik va balandlikda.
class _StateChoice extends StatelessWidget {
  const _StateChoice({
    required this.state,
    required this.enabled,
    required this.onTap,
  });

  final RoomState state;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final label = RoomStatePalette.label(context.l10n, state);
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Pressable(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 12, 6, 10),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: RoomStatePalette.color(c, state),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  RoomStatePalette.icon(state),
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // Uzun nom so'z o'rtasidan sinmaydi: bo'shliqdan ikki qatorga
              // bo'linadi, sig'masa biroz kichrayadi
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label.replaceFirst(' ', '\n'),
                      style: context.textStyles.labelSmall!.copyWith(
                        color: c.text,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
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
