import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_x.dart';
import '../../../../../core/extensions/datetime_x.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/status_chip.dart';
import '../../domain/occupied_room.dart';

/// Band xona kartasi.
///
/// Urg'u — xona raqami va "qancha vaqt qoldi" belgisi. Mehmon ismi va chiqish
/// vaqti tinch, ikkinchi darajali qatorlarda.
class OccupiedRoomCard extends StatelessWidget {
  const OccupiedRoomCard({
    super.key,
    required this.room,
    required this.openRequests,
    required this.onTap,
  });

  final OccupiedRoom room;

  /// Shu xona bo'yicha ochiq so'rovlar (chatdan) soni.
  final int openRequests;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _badge(context),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.roomTitle(room.roomNumber),
                        style: context.textStyles.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _timeChip(context),
                  ],
                ),
                const SizedBox(height: 6),
                _mutedRow(
                  context,
                  Icons.person_outline_rounded,
                  room.guestName,
                ),
                if (room.expectedCheckout != null) ...[
                  const SizedBox(height: 4),
                  _mutedRow(
                    context,
                    Icons.logout_rounded,
                    '${room.expectedCheckout!.shortWhen(todayLabel: l10n.today)}'
                    ' · ${room.bookingType == 'HOURLY' ? l10n.bookingHourly : l10n.bookingDaily}',
                  ),
                ],
                if (openRequests > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.record_voice_over_outlined,
                        size: 16,
                        color: c.warning,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${l10n.guestRequests}: $openRequests',
                        style: context.textStyles.labelMedium!.copyWith(
                          color: c.warning,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(BuildContext context) {
    final c = context.colors;
    final bg = room.isOverdue
        ? c.dangerSoft
        : (room.isCheckedIn ? c.violetSoft : c.infoSoft);
    final fg = room.isOverdue
        ? c.danger
        : (room.isCheckedIn ? c.violet : c.info);
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
            room.roomNumber,
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

  Widget _mutedRow(BuildContext context, IconData icon, String text) {
    final c = context.colors;
    return Row(
      children: [
        Icon(icon, size: 16, color: c.textMuted),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: context.textStyles.labelMedium!.copyWith(color: c.textMuted),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _timeChip(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    if (!room.isCheckedIn) {
      return StatusChip(
        label: l10n.reservedBadge,
        background: c.infoSoft,
        foreground: c.info,
        icon: Icons.event_available_rounded,
      );
    }
    if (room.isOverdue) {
      return StatusChip(
        label: l10n.overdueBadge,
        background: c.dangerSoft,
        foreground: c.danger,
        icon: Icons.alarm_rounded,
      );
    }
    final minutes = room.minutesUntilCheckout;
    final String label;
    if (minutes < 60) {
      label = l10n.leftMinutes(minutes);
    } else {
      label = l10n.leftHours(minutes ~/ 60, minutes % 60);
    }
    final isSoon = minutes < 90;
    return StatusChip(
      label: label,
      background: isSoon ? c.warningSoft : c.surfaceAlt,
      foreground: isSoon ? c.warning : c.textMuted,
      icon: Icons.schedule_rounded,
    );
  }
}
