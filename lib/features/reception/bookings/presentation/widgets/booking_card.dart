import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/extensions/context_x.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/status_chip.dart';
import '../../../../../l10n/gen/app_localizations.dart';
import '../../domain/booking.dart';

/// Bitta bron kartasi: xona, mehmon, muddat va to'lov holati.
///
/// Resepsiya kartaga bir qarab uchta savolga javob olishi kerak: kim,
/// qaysi xonada, puli to'langanmi. Shuning uchun xona raqami eng katta
/// element, qarz esa alohida qizil belgi bilan ajratiladi.
class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.booking, this.onTap});

  final Booking booking;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Xona raqami — kartaning tayanch nuqtasi
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _kindSoft(c, booking.kind),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  booking.roomNumber,
                  style: context.textStyles.titleMedium!.copyWith(
                    color: _kindColor(c, booking.kind),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.guestName,
                      style: context.textStyles.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.reservationNumber,
                      style: context.textStyles.bodySmall!.copyWith(
                        color: c.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          size: 14,
                          color: c.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _period(booking),
                            style: context.textStyles.bodySmall!.copyWith(
                              color: c.textMuted,
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
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              StatusChip(
                label: _kindLabel(l10n, booking.kind),
                background: _kindSoft(c, booking.kind),
                foreground: _kindColor(c, booking.kind),
                icon: _kindIcon(booking.kind),
              ),
              if (booking.hasDebt)
                StatusChip(
                  // Qarz — resepsiya uchun eng muhim belgi: mehmon
                  // chiqib ketishidan oldin ko'rinishi kerak
                  label: l10n.bookingDebt(_money(booking.remaining)),
                  background: c.dangerSoft,
                  foreground: c.danger,
                  icon: CupertinoIcons.exclamationmark_circle,
                )
              else
                StatusChip(
                  label: l10n.bookingPaid,
                  background: c.successSoft,
                  foreground: c.success,
                  icon: CupertinoIcons.checkmark_seal,
                ),
              if (booking.status == 'CANCELLED')
                StatusChip(
                  label: l10n.bookingCancelled,
                  background: c.surfaceAlt,
                  foreground: c.textMuted,
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _money(double value) =>
      value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]} ',
      );

  static String _period(Booking booking) {
    if (booking.isHourly && booking.checkInTime != null) {
      return '${booking.checkInDate} · '
          '${booking.checkInTime} – ${booking.checkOutTime ?? ''}';
    }
    return '${booking.checkInDate} → ${booking.checkOutDate}';
  }

  static Color _kindColor(AppColors c, BookingKind kind) => switch (kind) {
    BookingKind.arrival => c.brand,
    BookingKind.departure => c.warning,
    BookingKind.inhouse => c.success,
  };

  static Color _kindSoft(AppColors c, BookingKind kind) => switch (kind) {
    BookingKind.arrival => c.brandSoft,
    BookingKind.departure => c.warningSoft,
    BookingKind.inhouse => c.successSoft,
  };

  static IconData _kindIcon(BookingKind kind) => switch (kind) {
    BookingKind.arrival => CupertinoIcons.arrow_down_left_circle,
    BookingKind.departure => CupertinoIcons.arrow_up_right_circle,
    BookingKind.inhouse => CupertinoIcons.bed_double,
  };

  static String _kindLabel(S l10n, BookingKind kind) => switch (kind) {
    BookingKind.arrival => l10n.bookingArrival,
    BookingKind.departure => l10n.bookingDeparture,
    BookingKind.inhouse => l10n.bookingInhouse,
  };
}
