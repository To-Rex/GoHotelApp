import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/context_x.dart';
import '../../../../../core/widgets/glass.dart';
import '../../../../../core/extensions/datetime_x.dart';
import '../../../../../core/widgets/status_chip.dart';
import '../../../../chat/presentation/cubit/chat_cubit.dart';
import '../../domain/occupied_room.dart';

/// Xona tafsiloti: holat, mehmon, chiqish vaqti, shu xona bo'yicha ochiq
/// so'rovlar va "Resepshnga yozish" (xabar xona bilan bog'lanadi).
Future<void> showRoomDetailSheet(BuildContext context, OccupiedRoom room) {
  final chatCubit = context.read<ChatCubit>();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: chatCubit,
      child: _RoomDetailSheet(room: room),
    ),
  );
}

class _RoomDetailSheet extends StatefulWidget {
  const _RoomDetailSheet({required this.room});

  final OccupiedRoom room;

  @override
  State<_RoomDetailSheet> createState() => _RoomDetailSheetState();
}

class _RoomDetailSheetState extends State<_RoomDetailSheet> {
  final _message = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _message.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    final ok = await context.read<ChatCubit>().send(
      text,
      roomId: widget.room.roomId,
    );
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) {
      Navigator.of(context).pop();
      context.showSnack(context.l10n.done);
    }
  }

  String _roomStatusLabel(BuildContext context, String status) {
    final l10n = context.l10n;
    return switch (status) {
      'AVAILABLE' => l10n.roomStatusAvailable,
      'RESERVED' => l10n.roomStatusReserved,
      'OCCUPIED' => l10n.roomStatusOccupied,
      'CLEANING' => l10n.roomStatusCleaning,
      'MAINTENANCE' => l10n.roomStatusMaintenance,
      'INSPECTION' => l10n.roomStatusInspection,
      'OUT_OF_SERVICE' => l10n.roomStatusOutOfService,
      _ => status,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final room = widget.room;

    final openRequests = context
        .watch<ChatCubit>()
        .state
        .messages
        .where((m) => m.isOpen && m.roomNumber == room.roomNumber)
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassSheet(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: c.brandSoft,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            room.roomNumber,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: c.onBrandSoft,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.roomTitle(room.roomNumber),
                            style: context.textStyles.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              StatusChip(
                                label: _roomStatusLabel(
                                  context,
                                  room.roomStatus,
                                ),
                                background: c.surfaceAlt,
                                foreground: c.textMuted,
                              ),
                              if (room.isOverdue)
                                StatusChip(
                                  label: l10n.overdueBadge,
                                  background: c.dangerSoft,
                                  foreground: c.danger,
                                  icon: Icons.alarm_rounded,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _row(
                  context,
                  Icons.person_outline_rounded,
                  l10n.guestLabel,
                  room.guestName,
                ),
                if (room.expectedCheckout != null) ...[
                  const SizedBox(height: 10),
                  _row(
                    context,
                    Icons.logout_rounded,
                    l10n.checkoutLabel,
                    room.expectedCheckout!.shortWhen(todayLabel: l10n.today),
                  ),
                ],
                if (openRequests.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    l10n.guestRequests,
                    style: context.textStyles.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  for (final request in openRequests)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: c.warningSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.record_voice_over_outlined,
                            size: 20,
                            color: c.warning,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${request.body}\n— ${request.createdByName}',
                              style: context.textStyles.bodyMedium!.copyWith(
                                color: c.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 18),
                Text(
                  l10n.writeToReception,
                  style: context.textStyles.titleSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _message,
                        minLines: 1,
                        maxLines: 3,
                        decoration: InputDecoration(hintText: l10n.messageHint),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 58,
                      height: 58,
                      // Har harfdagi setState o'rniga faqat tugma
                      // controller'ni tinglaydi — oyna qayta chizilmaydi.
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _message,
                        builder: (context, value, _) => FilledButton(
                          onPressed: value.text.trim().isEmpty || _sending
                              ? null
                              : _send,
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(58, 58),
                          ),
                          child: _sending
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String label, String value) {
    final c = context.colors;
    return Row(
      children: [
        Icon(icon, size: 22, color: c.textMuted),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: context.textStyles.bodyLarge!.copyWith(color: c.textMuted),
        ),
        Expanded(child: Text(value, style: context.textStyles.bodyLarge)),
      ],
    );
  }
}
