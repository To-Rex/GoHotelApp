import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/extensions/context_x.dart';
import '../../../../../core/widgets/glass.dart';
import '../../../../../core/widgets/status_chip.dart';
import '../../domain/booking.dart';

/// Bron tafsiloti: mehmon, muddat, mehmonlar soni va to'lov holati.
///
/// Bu oyna faqat KO'RSATADI — mobil qabulxona bronni tahrirlamaydi.
/// Bron ochish, ko'chirish va to'lov qabul qilish katta ekranda, hisob
/// va chek bilan birga bajariladi; telefonda ular xatoga yaqin.
///
/// Telefon raqami bosilsa nusxa olinadi: mehmonga qo'ng'iroq qilish
/// resepsiyaning eng tez-tez qiladigan ishi.
Future<void> showBookingDetailSheet(BuildContext context, Booking booking) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _BookingDetailSheet(booking: booking),
  );
}

class _BookingDetailSheet extends StatelessWidget {
  const _BookingDetailSheet({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;

    return GlassSheet(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: c.brandSoft,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      booking.roomNumber,
                      style: context.textStyles.titleMedium!.copyWith(
                        color: c.brand,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.guestName,
                          style: context.textStyles.titleMedium,
                        ),
                        Text(
                          booking.reservationNumber,
                          style: context.textStyles.bodySmall!.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _Row(
                icon: CupertinoIcons.calendar,
                label: l10n.bookingPeriod,
                value: booking.isHourly && booking.checkInTime != null
                    ? '${booking.checkInDate} · ${booking.checkInTime} – ${booking.checkOutTime ?? ''}'
                    : '${booking.checkInDate} → ${booking.checkOutDate}',
              ),
              _Row(
                icon: CupertinoIcons.person_2,
                label: l10n.bookingGuests,
                value: booking.children > 0
                    ? '${booking.adults} + ${booking.children}'
                    : '${booking.adults}',
              ),
              if (booking.guestPhone != null &&
                  booking.guestPhone!.trim().isNotEmpty)
                _Row(
                  icon: CupertinoIcons.phone,
                  label: l10n.bookingPhone,
                  value: booking.guestPhone!,
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: booking.guestPhone!),
                    );
                    if (context.mounted) context.showSnack(l10n.copied);
                  },
                ),
              if (booking.notes != null && booking.notes!.trim().isNotEmpty)
                _Row(
                  icon: CupertinoIcons.text_alignleft,
                  label: l10n.bookingNote,
                  value: booking.notes!,
                ),

              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: booking.hasDebt ? c.dangerSoft : c.successSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.bookingTotal,
                          style: context.textStyles.bodyMedium!.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                        Text(
                          _money(booking.totalAmount),
                          style: context.textStyles.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.bookingPaidAmount,
                          style: context.textStyles.bodyMedium!.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                        Text(
                          _money(booking.paidAmount),
                          style: context.textStyles.titleSmall,
                        ),
                      ],
                    ),
                    if (booking.hasDebt) ...[
                      const Divider(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.bookingRemaining,
                            style: context.textStyles.bodyMedium!.copyWith(
                              color: c.danger,
                            ),
                          ),
                          Text(
                            _money(booking.remaining),
                            style: context.textStyles.titleSmall!.copyWith(
                              color: c.danger,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  StatusChip(
                    label: booking.status,
                    background: c.surfaceAlt,
                    foreground: c.textMuted,
                  ),
                  StatusChip(
                    label: booking.paymentStatus,
                    background: booking.hasDebt ? c.dangerSoft : c.successSoft,
                    foreground: booking.hasDebt ? c.danger : c.success,
                  ),
                ],
              ),

              const SizedBox(height: 8),
              // Nima uchun bu yerda tugma yo'qligini aytib qo'yamiz —
              // xodim "ilova buzilgan" deb o'ylamasligi kerak
              Text(
                l10n.bookingReadOnlyHint,
                style: context.textStyles.bodySmall!.copyWith(
                  color: c.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _money(double value) => value
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]} ');
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: c.textMuted),
            const SizedBox(width: 10),
            Text(
              label,
              style: context.textStyles.bodyMedium!.copyWith(
                color: c.textMuted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: context.textStyles.bodyMedium!.copyWith(
                  decoration: onTap == null ? null : TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
