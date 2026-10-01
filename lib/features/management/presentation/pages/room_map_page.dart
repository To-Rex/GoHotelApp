import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../domain/format.dart';
import '../../domain/management_access.dart';
import '../../domain/room_tile.dart';
import '../cubit/room_map_cubit.dart';
import '../widgets/animated_counter.dart';
import '../widgets/distribution_bar.dart';
import '../widgets/pressable.dart';
import '../widgets/room_sheet.dart';
import '../widgets/state_palette.dart';

/// Xonalar xaritasi: qavatlar bo'yicha kataklar, rang — holat.
///
/// Tepada umumiy karta: hozir nechta xona bo'sh, bandlik foizi va butun
/// mehmonxonaning taqsimot chizig'i. Ostida holat filtrlari — aylantirganda
/// ham tepada qoladi. Har qavat "lift tugmasi" ko'rinishidagi raqami,
/// nomi va o'z kichik chizig'i bilan. Bo'sh xona — oq katak, qolganlari
/// holat rangida: band qavat o'qimasdan ko'rinadi. Katak bosilganda
/// tafsilot va amallar ochiladi. Har daqiqada jim yangilanadi; holat
/// o'zgarsa katak rangi silliq almashadi.
class RoomMapPage extends StatelessWidget {
  const RoomMapPage({super.key, required this.access});

  final ManagementAccess access;

  /// Filtr va chiziqdagi holatlar tartibi — hamma joyda bir xil.
  static const stateOrder = [
    RoomState.occupied,
    RoomState.reserved,
    RoomState.cleaning,
    RoomState.available,
    RoomState.maintenance,
    RoomState.inspection,
    RoomState.outOfService,
  ];

  static List<DistributionSegment> segmentsOf(
    AppColors c,
    Iterable<RoomTile> rooms,
  ) => [
    for (final s in stateOrder)
      DistributionSegment(
        value: rooms.where((r) => r.state == s).length,
        color: RoomStatePalette.color(c, s),
      ),
  ];

  @override
  Widget build(BuildContext context) {
    final barPadding = MediaQuery.paddingOf(context);
    return BlocBuilder<RoomMapCubit, RoomMapState>(
      builder: (context, state) => Column(
        children: [
          SizedBox(height: barPadding.top + 8),
          Expanded(child: _Body(state: state, access: access)),
        ],
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({required this.state, required this.access});

  final RoomMapState state;
  final ManagementAccess access;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with SingleTickerProviderStateMixin {
  /// Kirish animatsiyasi: qavatlar va kataklar birin-ketin paydo bo'ladi.
  /// Bitta kontroller — faqat ma'lumot birinchi kelganda va filtr
  /// almashganda o'ynaydi; aylantirganda yoki jim yangilanishda emas.
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.state.rooms.isNotEmpty) _intro.forward();
  }

  @override
  void didUpdateWidget(_Body oldWidget) {
    super.didUpdateWidget(oldWidget);
    final arrived =
        oldWidget.state.rooms.isEmpty && widget.state.rooms.isNotEmpty;
    if (arrived || oldWidget.state.filter != widget.state.filter) {
      _intro.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<RoomMapCubit>();
    final state = widget.state;
    final hasRooms = state.rooms.isNotEmpty;
    final groups = state.groups;

    return RefreshIndicator(
      onRefresh: cubit.load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (hasRooms) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _OverviewCard(state: state),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _FilterBarDelegate(
                state: state,
                onSelect: cubit.setFilter,
              ),
            ),
          ],
          if (state.loading && !hasRooms)
            const SliverFillRemaining(
              child: ListSkeleton(count: 3, itemHeight: 170),
            )
          else if (state.error != null && !hasRooms)
            SliverFillRemaining(
              hasScrollBody: false,
              child: ErrorState(error: state.error!, onRetry: cubit.load),
            )
          else if (groups.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: CupertinoIcons.bed_double,
                title: l10n.roomsEmptyTitle,
                body: l10n.roomsEmptyBody,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
              sliver: SliverList.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) => _FloorSection(
                  group: groups[index],
                  // Qavat sarlavhasi filtrdan qat'i nazar butun qavatni
                  // ko'rsatadi
                  allRooms: state.rooms,
                  access: widget.access,
                  intro: _intro,
                  order: index * 3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Umumiy karta: hozir bo'sh xonalar, bandlik va taqsimot chizig'i.
class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.state});

  final RoomMapState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final total = state.rooms.length;
    final free = state.countOf(RoomState.available);
    final occupied = state.countOf(RoomState.occupied);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.roomsFreeNow,
                      style: context.textStyles.labelMedium!.copyWith(
                        color: c.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AnimatedCounter(
                          value: free.toDouble(),
                          format: (v) => '${v.round()}',
                          duration: const Duration(milliseconds: 600),
                          style: context.textStyles.displaySmall!.copyWith(
                            color: free == 0 ? c.textMuted : c.success,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 4),
                          child: Text(
                            '/ $total',
                            style: context.textStyles.titleMedium!.copyWith(
                              color: c.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.occupancyTitle,
                    style: context.textStyles.labelMedium!.copyWith(
                      color: c.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedCounter(
                    value: total == 0 ? 0 : occupied / total,
                    format: formatPercent,
                    duration: const Duration(milliseconds: 600),
                    style: context.textStyles.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          DistributionBar(
            height: 10,
            segments: RoomMapPage.segmentsOf(c, state.rooms),
            trackColor: c.surfaceAlt,
          ),
        ],
      ),
    );
  }
}

/// Holat filtrlari: aylantirganda ham tepada qoladigan chiplar qatori.
class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  const _FilterBarDelegate({required this.state, required this.onSelect});

  final RoomMapState state;
  final ValueChanged<RoomState?> onSelect;

  static const _height = 60.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  bool shouldRebuild(_FilterBarDelegate oldDelegate) =>
      oldDelegate.state != state;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final l10n = context.l10n;
    final c = context.colors;
    return ColoredBox(
      // Xira fon: ostidan o'tayotgan kataklar chiplar orasidan ko'rinmaydi
      color: c.background,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
        children: [
          _FilterChip(
            label: l10n.all,
            count: state.rooms.length,
            color: c.brand,
            selected: state.filter == null,
            onTap: () => onSelect(null),
          ),
          for (final s in RoomMapPage.stateOrder)
            if (state.countOf(s) > 0) ...[
              const SizedBox(width: 8),
              _FilterChip(
                label: RoomStatePalette.label(l10n, s),
                count: state.countOf(s),
                color: RoomStatePalette.color(c, s),
                dot: true,
                selected: state.filter == s,
                onTap: () => onSelect(state.filter == s ? null : s),
              ),
            ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.color,
    required this.selected,
    required this.onTap,
    this.dot = false,
  });

  final String label;
  final int count;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  /// Holat chipida rangli nuqta; "Barchasi"da — to'r belgisi.
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: selected ? color : c.surface,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot)
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : color,
                  shape: BoxShape.circle,
                ),
              )
            else
              Icon(
                CupertinoIcons.square_grid_2x2_fill,
                size: 13,
                color: selected ? Colors.white : color,
              ),
            const SizedBox(width: 7),
            Text(
              label,
              style: context.textStyles.labelLarge!.copyWith(
                color: selected ? Colors.white : c.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 7),
            AnimatedCounter(
              value: count.toDouble(),
              format: (v) => '${v.round()}',
              duration: const Duration(milliseconds: 500),
              style: context.textStyles.labelLarge!.copyWith(
                color: selected
                    ? Colors.white.withValues(alpha: 0.85)
                    : c.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloorSection extends StatelessWidget {
  const _FloorSection({
    required this.group,
    required this.allRooms,
    required this.access,
    required this.intro,
    required this.order,
  });

  final FloorGroup group;
  final List<RoomTile> allRooms;
  final ManagementAccess access;
  final Animation<double> intro;
  final int order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final floor = group.floor;
    final title = floor == null
        ? l10n.floorOther
        : (floor.name?.isNotEmpty == true
              ? floor.name!
              : l10n.floorLabel(floor.number));
    final floorRooms = floor == null
        ? group.rooms
        : allRooms.where((r) => r.floorId == floor.id).toList();
    final busy = floorRooms.where((r) => r.state.isBusy).length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Intro(
            animation: intro,
            order: order,
            child: Row(
              children: [
                // Qavat raqami — lift tugmasi kabi
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: floor == null
                      ? Icon(
                          CupertinoIcons.ellipsis,
                          size: 16,
                          color: c.textMuted,
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '${floor.number}',
                              style: context.textStyles.titleMedium!.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: context.textStyles.titleMedium!.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                // Qavat tarkibi: kichik chiziq va "band / jami"
                SizedBox(
                  width: 46,
                  child: DistributionBar(
                    height: 6,
                    segments: RoomMapPage.segmentsOf(c, floorRooms),
                    trackColor: c.surfaceAlt,
                  ),
                ),
                const SizedBox(width: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$busy',
                        style: context.textStyles.titleSmall!.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${floorRooms.length}',
                        style: context.textStyles.bodySmall!.copyWith(
                          color: c.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            // Telefonda 4 ustun, keng ekranda ko'proq
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 96,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.86,
            ),
            itemCount: group.rooms.length,
            itemBuilder: (context, index) => _Intro(
              animation: intro,
              order: order + 1 + index,
              pop: true,
              child: RoomCell(
                room: group.rooms[index],
                onTap: () => showRoomSheet(context, group.rooms[index], access),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kirish animatsiyasidagi bitta element: umumiy kontrollerdan o'z
/// oralig'ini oladi. Tugagach o'ram olib tashlanadi — bola to'g'ridan-
/// to'g'ri chiziladi (qatlam yo'q).
class _Intro extends StatelessWidget {
  const _Intro({
    required this.animation,
    required this.order,
    required this.child,
    this.pop = false,
  });

  final Animation<double> animation;

  /// Navbatdagi o'rni — kattaroq bo'lsa kechroq paydo bo'ladi.
  final int order;
  final Widget child;

  /// true — joyida kattalashib chiqadi (katak); false — pastdan ko'tariladi.
  final bool pop;

  @override
  Widget build(BuildContext context) {
    final start = (order * 0.03).clamp(0.0, 0.55);
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(
          ((animation.value - start) / 0.45).clamp(0.0, 1.0),
        );
        if (t >= 1) return child!;
        return Opacity(
          opacity: t,
          child: pop
              ? Transform.scale(scale: 0.86 + 0.14 * t, child: child)
              : Transform.translate(
                  offset: Offset(0, 10 * (1 - t)),
                  child: child,
                ),
        );
      },
    );
  }
}

/// Bitta xona katagi: chap tepada holat belgisi, pastda katta raqam va
/// yozuv. Bo'sh xona — oq, xizmatdan tashqari — kulrang, qolganlari holat
/// rangining och tusida. Texnik holatlarda (tozalash, ta'mir...) holat
/// nomi o'rniga QANCHADAN BERI shundaligi yoziladi — bir kun turib qolgan
/// xona darhol ko'zga tashlanadi. Rang o'zgarishi animatsiyali.
class RoomCell extends StatelessWidget {
  const RoomCell({super.key, required this.room, required this.onTap});

  final RoomTile room;
  final VoidCallback onTap;

  static String _caption(S l10n, RoomTile room) {
    final since = room.statusChangedAt;
    final timed =
        room.state == RoomState.cleaning ||
        room.state == RoomState.maintenance ||
        room.state == RoomState.inspection;
    if (timed && since != null) {
      final elapsed = DateTime.now().difference(since);
      if (!elapsed.isNegative && elapsed.inMinutes >= 1) {
        return formatDuration(elapsed, h: l10n.hourShort, m: l10n.minuteShort);
      }
    }
    return RoomStatePalette.label(l10n, room.state);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final color = RoomStatePalette.color(c, room.state);
    final inactive =
        room.state == RoomState.outOfService || room.state == RoomState.other;
    // Bo'sh xona — toza oq sirt: xaritada rang faqat e'tibor talab
    // qiladigan xonalarda qoladi
    final background = room.state == RoomState.available
        ? c.surface
        : RoomStatePalette.soft(c, room.state);

    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.fromLTRB(9, 9, 8, 8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 380),
              width: 21,
              height: 21,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(
                RoomStatePalette.icon(room.state),
                size: 13,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                room.number,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.1,
                  color: inactive ? c.textMuted : c.text,
                ),
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 1),
            _CellCaption(text: _caption(l10n, room), color: color),
          ],
        ),
      ),
    );
  }
}

/// Katak ostidagi yozuv: sig'sa bir qatorda; sig'masa so'z o'rtasidan
/// sindirilmaydi — bo'shliqdan ikki qatorga bo'linadi va kerak bo'lsa
/// biroz kichrayadi ("Xizmatdan tashqari", "Не обслуживается").
class _CellCaption extends StatelessWidget {
  const _CellCaption({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 9.5,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: -0.1,
      height: 1.15,
    );
    return LayoutBuilder(
      builder: (context, box) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();
        final fits = painter.width <= box.maxWidth;
        painter.dispose();
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            fits ? text : text.replaceFirst(' ', '\n'),
            style: style,
            maxLines: 2,
          ),
        );
      },
    );
  }
}
