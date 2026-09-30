import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/context_x.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_state.dart';
import '../../../calls/presentation/call_permission_card.dart';
import '../../domain/booking.dart';
import '../cubit/bookings_cubit.dart';
import '../widgets/booking_card.dart';
import 'booking_detail_sheet.dart';

/// Qabulxona bronlari: kun tanlanadi, ro'yxat guruhlar bo'yicha filtrlanadi.
///
/// Resepsiya kunni uch savol bilan boshqaradi — kim keladi, kim turibdi,
/// kim chiqadi. Shuning uchun filtr chiplari shu uch guruh bo'yicha va
/// har birida soni ko'rinadi: xodim ro'yxatni ochmasdan turib kunning
/// og'irligini biladi.
class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final barPadding = MediaQuery.paddingOf(context);

    return BlocBuilder<BookingsCubit, BookingsState>(
      /* Qidiruv har harfda holat chiqaradi (so'rov 400 ms kutadi, matnning
         o'zi esa darhol saqlanadi) — o'sha harflarda butun sahifa va
         ko'rinib turgan kartalarni qayta chizish shart emas. `search`dan
         bu builder'da faqat bo'sh/bo'sh-emas farqi ko'rinadi (bo'sh
         ro'yxatdagi "topilmadi"/"bronlar yo'q" sarlavhasi) — faqat shu
         o'tish kuzatiladi. Ro'yxat o'zgarishi doim yangi list instance
         bilan keladi, qidiruv-harfi esa o'sha instance'ni qayta ishlatadi.
      */
      buildWhen: (a, b) =>
          a.loading != b.loading ||
          a.error != b.error ||
          !identical(a.bookings, b.bookings) ||
          a.filter != b.filter ||
          a.date != b.date ||
          a.search.isEmpty != b.search.isEmpty,
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, barPadding.top + 8, 20, 0),
              child: const _DateBar(),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: _SearchField(),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 4),
              child: _KindFilters(),
            ),
            // Qo'ng'iroq bo'yicha mehmonni aniqlash taklifi — ruxsat
            // berilgan bo'lsa yoki qurilma qo'llamasa umuman chizilmaydi
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: CallPermissionCard(),
            ),
            Expanded(child: _Body(state: state)),
          ],
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final BookingsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<BookingsCubit>();

    if (state.loading && state.bookings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: ListSkeleton(count: 4),
      );
    }
    if (state.error != null && state.bookings.isEmpty) {
      return ErrorState(error: state.error!, onRetry: cubit.load);
    }

    final items = state.visible;
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: cubit.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 40),
            EmptyState(
              icon: CupertinoIcons.calendar,
              title: state.search.isNotEmpty
                  ? l10n.bookingsNotFoundTitle
                  : l10n.bookingsEmptyTitle,
              body: state.search.isNotEmpty
                  ? l10n.bookingsNotFoundBody
                  : l10n.bookingsEmptyBody,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: cubit.load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final booking = items[index];
          return BookingCard(
            booking: booking,
            onTap: () => showBookingDetailSheet(context, booking),
          );
        },
      ),
    );
  }
}

/// Kun tanlash: chap/o'ng o'qlar va sana ustiga bosib taqvim.
class _DateBar extends StatelessWidget {
  const _DateBar();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final cubit = context.read<BookingsCubit>();
    final date = context.select((BookingsCubit b) => b.state.date);
    final isToday = _sameDay(date, DateTime.now());

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => cubit.shiftDay(-1),
            icon: const Icon(CupertinoIcons.chevron_left),
            tooltip: l10n.previousDay,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) cubit.selectDate(picked);
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatDate(date),
                    style: context.textStyles.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                  if (isToday)
                    Text(
                      l10n.today,
                      style: context.textStyles.bodySmall!.copyWith(
                        color: c.brand,
                      ),
                    ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => cubit.shiftDay(1),
            icon: const Icon(CupertinoIcons.chevron_right),
            tooltip: l10n.nextDay,
          ),
        ],
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.${date.year}';
}

class _SearchField extends StatefulWidget {
  const _SearchField();

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<BookingsCubit>().state.search,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;

    return TextField(
      controller: _controller,
      onChanged: (value) {
        context.read<BookingsCubit>().search(value);
        // Tozalash tugmasi matn paydo bo'lishi bilan chiqishi kerak —
        // faqat `controller` o'zgarishi qayta chizishga sabab bo'lmaydi
        setState(() {});
      },
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: l10n.bookingsSearchHint,
        prefixIcon: const Icon(CupertinoIcons.search, size: 20),
        filled: true,
        fillColor: c.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(CupertinoIcons.clear_circled_solid, size: 18),
                onPressed: () {
                  _controller.clear();
                  context.read<BookingsCubit>().search('');
                  setState(() {});
                },
              ),
      ),
    );
  }
}

/// Guruh filtrlari — har birida shu kundagi soni.
class _KindFilters extends StatelessWidget {
  const _KindFilters();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<BookingsCubit>().state;
    final cubit = context.read<BookingsCubit>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: l10n.bookingsAll,
            count: state.bookings.length,
            selected: state.filter == null,
            onTap: () => cubit.setFilter(null),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: l10n.bookingArrival,
            count: state.countOf(BookingKind.arrival),
            selected: state.filter == BookingKind.arrival,
            onTap: () => cubit.setFilter(BookingKind.arrival),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: l10n.bookingInhouse,
            count: state.countOf(BookingKind.inhouse),
            selected: state.filter == BookingKind.inhouse,
            onTap: () => cubit.setFilter(BookingKind.inhouse),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: l10n.bookingDeparture,
            count: state.countOf(BookingKind.departure),
            selected: state.filter == BookingKind.departure,
            onTap: () => cubit.setFilter(BookingKind.departure),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? c.brand : c.surfaceAlt,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          '$label · $count',
          style: context.textStyles.bodyMedium!.copyWith(
            color: selected ? Colors.white : c.textMuted,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
