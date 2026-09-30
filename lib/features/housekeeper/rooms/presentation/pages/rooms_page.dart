import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/context_x.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_state.dart';
import '../../../../chat/presentation/cubit/chat_cubit.dart';
import '../../domain/occupied_room.dart';
import '../cubit/rooms_cubit.dart';
import '../widgets/occupied_room_card.dart';
import '../widgets/room_detail_sheet.dart';

/// Xonalar: "Band xonalar" va "Yaqin tozalash" tablari.
///
/// Ikkalasi bitta ma'lumot manbaidan: band (CHECKED_IN) va kutilayotgan
/// (CONFIRMED) bronlar. "Yaqin tozalash" — chiqish vaqtiga saralangan
/// ko'rinish: farrosh navbatdagi ishini oldindan biladi.
class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final barPadding = MediaQuery.paddingOf(context);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // iOS segmented control: kulrang trek ichida oq tanlangan segment.
          // Sarlavha va yangilash tugmasi shell'dagi umumiy appbar'da;
          // segment shisha appbar tagidan boshlanadi.
          Padding(
            padding: EdgeInsets.fromLTRB(20, barPadding.top + 8, 20, 4),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: context.colors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: context.isDark
                      ? const Color(0xFF636366)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: context.colors.text,
                unselectedLabelColor: context.colors.textMuted,
                labelStyle: context.textStyles.titleSmall,
                splashBorderRadius: BorderRadius.circular(9),
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                tabs: [
                  Tab(height: 42, text: l10n.tabOccupied),
                  Tab(height: 42, text: l10n.tabUpcoming),
                ],
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<RoomsCubit, RoomsState>(
              builder: (context, state) {
                // Bo'sh/xato holatlar pastki shisha panel ostida qolmasin.
                Widget clearBottom(Widget child) => Padding(
                  padding: EdgeInsets.only(bottom: barPadding.bottom),
                  child: child,
                );
                if (state.loading) {
                  return clearBottom(const ListSkeleton(count: 4));
                }
                if (state.error != null && state.rooms.isEmpty) {
                  return clearBottom(
                    ErrorState(
                      error: state.error!,
                      onRetry: () => context.read<RoomsCubit>().load(),
                    ),
                  );
                }
                return TabBarView(
                  children: [
                    _RoomsList(
                      rooms: state.rooms,
                      emptyTitle: l10n.noOccupiedTitle,
                      emptyBody: l10n.noOccupiedBody,
                    ),
                    _UpcomingList(rooms: state.upcoming),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomsList extends StatelessWidget {
  const _RoomsList({
    required this.rooms,
    required this.emptyTitle,
    required this.emptyBody,
  });

  final List<OccupiedRoom> rooms;
  final String emptyTitle;
  final String emptyBody;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    if (rooms.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(bottom: bottomPad),
        child: EmptyState(
          icon: Icons.meeting_room_rounded,
          title: emptyTitle,
          body: emptyBody,
        ),
      );
    }
    // Ochiq chat so'rovlarini xona raqamiga bog'laymiz — "mehmon talablari".
    final openByRoom = _openRequestsByRoom(context);

    return RefreshIndicator(
      onRefresh: () => context.read<RoomsCubit>().load(silent: true),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 20),
        itemCount: rooms.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final room = rooms[index];
          return OccupiedRoomCard(
            room: room,
            openRequests: openByRoom[room.roomNumber] ?? 0,
            onTap: () => showRoomDetailSheet(context, room),
          );
        },
      ),
    );
  }
}

/// "Yaqin tozalash": tepada tushuntirish, ro'yxat chiqish vaqtiga saralangan.
class _UpcomingList extends StatelessWidget {
  const _UpcomingList({required this.rooms});

  final List<OccupiedRoom> rooms;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    if (rooms.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(bottom: bottomPad),
        child: EmptyState(
          icon: Icons.schedule_rounded,
          title: l10n.upcomingEmptyTitle,
          body: l10n.upcomingEmptyBody,
        ),
      );
    }
    final openByRoom = _openRequestsByRoom(context);

    return RefreshIndicator(
      onRefresh: () => context.read<RoomsCubit>().load(silent: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.infoSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: c.info, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.upcomingHint,
                    style: context.textStyles.bodyMedium!.copyWith(
                      color: c.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final room in rooms) ...[
            OccupiedRoomCard(
              room: room,
              openRequests: openByRoom[room.roomNumber] ?? 0,
              onTap: () => showRoomDetailSheet(context, room),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

Map<String, int> _openRequestsByRoom(BuildContext context) {
  // Faqat xabarlar ro'yxati kuzatiladi: to'liq watch chatning 10 soniyalik
  // so'rovi va har yuborishdagi sending holatlarida ham xonalar ro'yxatini
  // (hatto boshqa tabda turganda ham) qayta chizardi — hisoblagichlarga
  // esa faqat xabarlarning o'zi ta'sir qiladi.
  final messages = context.select((ChatCubit cubit) => cubit.state.messages);
  final result = <String, int>{};
  for (final message in messages) {
    final room = message.roomNumber;
    if (room == null || !message.isOpen) continue;
    result[room] = (result[room] ?? 0) + 1;
  }
  return result;
}
