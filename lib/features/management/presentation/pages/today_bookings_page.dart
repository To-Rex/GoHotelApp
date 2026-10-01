import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/glass.dart';
import '../../../reception/bookings/domain/booking.dart';
import '../../../reception/bookings/presentation/pages/booking_detail_sheet.dart';
import '../../../reception/bookings/presentation/widgets/booking_card.dart';
import '../cubit/pulse_cubit.dart';

/// Bugungi bronlar — puls kartasidan ochiladi.
///
/// Ro'yxat pulsdagi ma'lumotdan (qayta so'rov yo'q); qabulxona kartasi va
/// tafsilot oynasi QAYTA ISHLATILADI — admin bilan resepsiya bir xil
/// bronni bir xil ko'radi.
class TodayBookingsPage extends StatefulWidget {
  const TodayBookingsPage({super.key});

  static Future<void> open(BuildContext context) {
    final cubit = context.read<PulseCubit>();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: cubit, child: const TodayBookingsPage()),
      ),
    );
  }

  @override
  State<TodayBookingsPage> createState() => _TodayBookingsPageState();
}

class _TodayBookingsPageState extends State<TodayBookingsPage> {
  BookingKind? _filter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(title: Text(l10n.todayBookingsTitle)),
      body: Builder(
        builder: (context) {
          final topPad = MediaQuery.paddingOf(context).top;
          final bookings = context.select(
            (PulseCubit cubit) => cubit.state.pulse.bookings ?? const <Booking>[],
          );
          final active = bookings.where((b) => b.status != 'CANCELLED').toList();
          final visible = _filter == null
              ? active
              : active.where((b) => b.kind == _filter).toList();
          int count(BookingKind kind) => active.where((b) => b.kind == kind).length;

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, topPad + 8, 20, 6),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _Chip(
                        label: '${l10n.bookingsAll} · ${active.length}',
                        selected: _filter == null,
                        onTap: () => setState(() => _filter = null),
                      ),
                      const SizedBox(width: 8),
                      _Chip(
                        label:
                            '${l10n.bookingArrival} · ${count(BookingKind.arrival)}',
                        selected: _filter == BookingKind.arrival,
                        onTap: () =>
                            setState(() => _filter = BookingKind.arrival),
                      ),
                      const SizedBox(width: 8),
                      _Chip(
                        label:
                            '${l10n.bookingInhouse} · ${count(BookingKind.inhouse)}',
                        selected: _filter == BookingKind.inhouse,
                        onTap: () =>
                            setState(() => _filter = BookingKind.inhouse),
                      ),
                      const SizedBox(width: 8),
                      _Chip(
                        label:
                            '${l10n.bookingDeparture} · ${count(BookingKind.departure)}',
                        selected: _filter == BookingKind.departure,
                        onTap: () =>
                            setState(() => _filter = BookingKind.departure),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: visible.isEmpty
                    ? EmptyState(
                        icon: CupertinoIcons.calendar,
                        title: l10n.bookingsEmptyTitle,
                        body: l10n.bookingsEmptyBody,
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          8,
                          20,
                          MediaQuery.paddingOf(context).bottom + 24,
                        ),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final booking = visible[index];
                          return BookingCard(
                            booking: booking,
                            onTap: () => showBookingDetailSheet(context, booking),
                          );
                        },
                      ),
              ),
              // Qarzdorlar soni pastda eslatma sifatida
              if (active.any((b) => b.hasDebt))
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    MediaQuery.paddingOf(context).bottom + 12,
                  ),
                  child: Text(
                    l10n.attentionDebtors(
                      active.where((b) => b.hasDebt).length,
                      _money(
                        active.fold<double>(0, (s, b) => s + b.remaining),
                      ),
                    ),
                    style: context.textStyles.bodySmall!.copyWith(
                      color: c.danger,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  static String _money(double value) =>
      value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]} ',
      );
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? c.brand : c.surfaceAlt,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: context.textStyles.bodyMedium!.copyWith(
            color: selected ? Colors.white : c.textMuted,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
