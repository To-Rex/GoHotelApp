import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di.dart';
import '../../../core/extensions/context_x.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_nav_bar.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/ticker_indexed_stack.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../auth/domain/staff_user.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../chat/presentation/cubit/chat_cubit.dart';
import '../../chat/presentation/pages/chat_page.dart';
import '../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../notifications/presentation/widgets/notification_bell.dart';
import '../../profile/presentation/cubit/profile_cubit.dart';
import '../../profile/presentation/pages/profile_page.dart';
import '../domain/management_access.dart';
import '../presentation/cubit/pulse_cubit.dart';
import '../presentation/cubit/room_map_cubit.dart';
import '../presentation/cubit/team_cubit.dart';
import '../presentation/pages/feedback_page.dart';
import '../presentation/pages/pulse_page.dart';
import '../presentation/pages/room_map_page.dart';
import '../presentation/pages/team_page.dart';
import '../presentation/widgets/broadcast_sheet.dart';

/// Boshqaruv qobig'i — admin va menejer uchun bitta shell, ruxsatlar farqli.
///
/// Tablar: Asosiy (puls), Xonalar (xarita), Jamoa, Chat. Profil appbar'dagi
/// avatar orqali ochiladi — to'rt tab va (admin uchun) markaziy "E'lon"
/// tugmasi bilan pastki panel toza qoladi. Farrosh va qabulxona
/// qobiqlariga TEGILMAGAN: ular avvalgidek ishlaydi.
///
/// Cubitlar shu yerda yaratiladi: ilova fonga o'tganda pollinglar
/// to'xtaydi, qaytganda hammasi jim yangilanadi.
class ManagementShell extends StatefulWidget {
  const ManagementShell({super.key, required this.user});

  final StaffUser user;

  @override
  State<ManagementShell> createState() => _ManagementShellState();
}

class _ManagementShellState extends State<ManagementShell>
    with WidgetsBindingObserver {
  int _index = 0;

  late final ManagementAccess _access = ManagementAccess.of(widget.user);
  late final PulseCubit _pulse;
  late final RoomMapCubit _rooms;
  late final TeamCubit _team;
  late final ChatCubit _chat;
  late final NotificationsCubit _notifications;
  late final ProfileCubit _profile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulse = PulseCubit(getIt(), getIt(), access: _access)
      ..load()
      ..startPolling();
    _rooms = RoomMapCubit(getIt())
      ..load()
      ..startPolling();
    _team = TeamCubit(getIt())
      ..load()
      ..startPolling();
    _chat = ChatCubit(getIt())
      ..load()
      ..startPolling();
    _notifications = NotificationsCubit(getIt())
      ..load(silent: true)
      ..startPolling();
    // Avatar appbar'da turadi — surat darhol kerak
    _profile = ProfileCubit(getIt())..load(widget.user.id);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulse.close();
    _rooms.close();
    _team.close();
    _chat.close();
    _notifications.close();
    _profile.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _refreshAll();
        _pulse.startPolling();
        _rooms.startPolling();
        _team.startPolling();
        _chat.startPolling();
        _notifications.startPolling();
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _pulse.stopPolling();
        _rooms.stopPolling();
        _team.stopPolling();
        _chat.stopPolling();
        _notifications.stopPolling();
      default:
        break;
    }
  }

  void _refreshAll() {
    _pulse.load(silent: true);
    _rooms.load(silent: true);
    _team.load(silent: true);
    _chat.load(silent: true);
    _notifications.load(silent: true);
  }

  void _onTabSelected(int index) {
    setState(() => _index = index);
    switch (index) {
      case 0:
        _pulse.load(silent: true);
      case 1:
        _rooms.load(silent: true);
      case 2:
        _team.load(silent: true);
      case 3:
        _chat.load(silent: true);
    }
    _notifications.load(silent: true);
  }

  void _openTeam(TeamSegment segment) {
    _team.selectSegment(segment);
    _onTabSelected(2);
  }

  Future<void> _openProfile(BuildContext context) {
    final l10n = context.l10n;
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _profile,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: GlassAppBar(title: Text(l10n.profileTitle)),
            body: const ProfilePage(),
          ),
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    switch (_index) {
      case 0:
        final user = context.select((AuthCubit cubit) => cubit.state.user);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${_greeting(l10n)},',
              style: context.textStyles.bodyMedium!.copyWith(color: c.textMuted),
            ),
            Text(
              user?.firstName.isNotEmpty == true
                  ? user!.firstName
                  : l10n.pulseTitle,
              style: context.textStyles.headlineSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      case 1:
        return Text(l10n.roomMapTitle, style: context.textStyles.headlineSmall);
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.tabTeam, style: context.textStyles.headlineSmall),
            if (widget.user.hotelName?.isNotEmpty == true)
              Text(
                // Jamoa — joriy filialniki (filiallar ajratilgan)
                [widget.user.hotelName!, ?widget.user.branchName].join(' · '),
                style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.chatTitle, style: context.textStyles.headlineSmall),
            Text(
              l10n.chatSubtitle,
              style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
            ),
          ],
        );
    }
  }

  String _greeting(S l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 18) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _pulse),
        BlocProvider.value(value: _rooms),
        BlocProvider.value(value: _team),
        BlocProvider.value(value: _chat),
        BlocProvider.value(value: _notifications),
        BlocProvider.value(value: _profile),
      ],
      child: ManagementAccessScope(
        access: _access,
        // Appbar va tab-bar shishasi bitta fon o'qishidan foydalanadi
        child: GlassScope(
          child: Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            appBar: GlassAppBar(
              title: Builder(builder: _title),
              actions: [
                const NotificationBell(),
                Builder(
                  builder: (context) => Padding(
                    padding: const EdgeInsets.only(left: 4, right: 14),
                    child: BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (context, _) {
                        final cubit = context.read<ProfileCubit>();
                        return Tooltip(
                          message: l10n.tabProfile,
                          child: GestureDetector(
                            onTap: () => _openProfile(context),
                            child: AppAvatar(
                              name: widget.user.fullName,
                              imageUrl: cubit.photoUrl(),
                              headers: cubit.photoHeaders(),
                              size: 36,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            // Ko'rinmas tablardagi animatsiya uxlaydi
            body: TickerIndexedStack(
              index: _index,
              children: [
                PulsePage(
                  access: _access,
                  onOpenRooms: () => _onTabSelected(1),
                  onOpenTeam: _openTeam,
                ),
                RoomMapPage(access: _access),
                TeamPage(access: _access),
                const ChatPage(),
              ],
            ),
            bottomNavigationBar: AppNavBar(
              selectedIndex: _index,
              onSelected: _onTabSelected,
              // E'lon — tab emas, amal: barcha xodimlarga push. Faqat admin.
              centerAction: _access.canBroadcast
                  ? NavBarAction(
                      icon: CupertinoIcons.speaker_2_fill,
                      label: l10n.broadcastAction,
                      // E'lon mehmonxonaning barcha faol foydalanuvchilariga
                      // boradi — soni jamoa ro'yxatidan (yuklangan bo'lsa)
                      onTap: () => showBroadcastSheet(
                        context,
                        recipients: _team.state.staff.items
                            .where((s) => s.isActive)
                            .length,
                      ),
                    )
                  : null,
              destinations: [
                NavigationDestination(
                  icon: const Icon(CupertinoIcons.chart_pie),
                  selectedIcon: const Icon(CupertinoIcons.chart_pie_fill),
                  label: l10n.tabHome,
                ),
                NavigationDestination(
                  icon: const Icon(CupertinoIcons.square_grid_2x2),
                  selectedIcon: const Icon(CupertinoIcons.square_grid_2x2_fill),
                  label: l10n.tabRooms,
                ),
                NavigationDestination(
                  icon: const Icon(CupertinoIcons.person_2),
                  selectedIcon: const Icon(CupertinoIcons.person_2_fill),
                  label: l10n.tabTeam,
                ),
                NavigationDestination(
                  icon: const Icon(CupertinoIcons.chat_bubble),
                  selectedIcon: const Icon(CupertinoIcons.chat_bubble_fill),
                  label: l10n.tabChat,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
