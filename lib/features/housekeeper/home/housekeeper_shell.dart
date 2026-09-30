import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/di.dart';
import '../../../core/extensions/context_x.dart';
import '../../../core/widgets/app_nav_bar.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/ticker_indexed_stack.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../chat/presentation/cubit/chat_cubit.dart';
import '../../chat/presentation/pages/chat_page.dart';
import '../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../notifications/presentation/widgets/notification_bell.dart';
import '../../profile/presentation/cubit/profile_cubit.dart';
import '../../profile/presentation/pages/profile_page.dart';
import '../rooms/presentation/cubit/rooms_cubit.dart';
import '../rooms/presentation/pages/rooms_page.dart';
import '../tasks/presentation/cubit/tasks_cubit.dart';
import '../tasks/presentation/pages/tasks_page.dart';

/// Farrosh bosh oynasi: 4 ta katta tab — Vazifalar, Xonalar, Chat, Profil.
///
/// Cubitlar shu yerda yaratiladi: ilova fonga o'tganda pollinglar to'xtaydi,
/// qaytganda hammasi jim yangilanadi; tab almashganda tegishli bo'lim ham
/// yangilanadi — xodim doim dolzarb ma'lumot ko'radi.
class HousekeeperShell extends StatefulWidget {
  const HousekeeperShell({super.key});

  @override
  State<HousekeeperShell> createState() => _HousekeeperShellState();
}

class _HousekeeperShellState extends State<HousekeeperShell>
    with WidgetsBindingObserver {
  int _index = 0;

  late final TasksCubit _tasks;
  late final RoomsCubit _rooms;
  late final ChatCubit _chat;
  late final NotificationsCubit _notifications;
  late final ProfileCubit _profile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tasks = TasksCubit(getIt())..load();
    _rooms = RoomsCubit(getIt())
      ..load()
      ..startPolling();
    _chat = ChatCubit(getIt())
      ..load()
      ..startPolling();
    _notifications = NotificationsCubit(getIt())
      ..load(silent: true)
      ..startPolling();
    _profile = ProfileCubit(getIt());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tasks.close();
    _rooms.close();
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
        _rooms.startPolling();
        _chat.startPolling();
        _notifications.startPolling();
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _rooms.stopPolling();
        _chat.stopPolling();
        _notifications.stopPolling();
      default:
        break;
    }
  }

  void _refreshAll() {
    _tasks.load(silent: true);
    _rooms.load(silent: true);
    _chat.load(silent: true);
    _notifications.load(silent: true);
  }

  void _onTabSelected(int index) {
    setState(() => _index = index);
    _refreshCurrent();
  }

  /// Joriy bo'lim ma'lumotini jim yangilaydi (tab almashganda va
  /// appbar'dagi "yangilash" tugmasida ishlatiladi).
  void _refreshCurrent() {
    switch (_index) {
      case 0:
        _tasks.load(silent: true);
      case 1:
        _rooms.load(silent: true);
      case 2:
        _chat.load(silent: true);
      case 3:
        final user = context.read<AuthCubit>().state.user;
        if (user != null) _profile.load(user.id);
    }
    _notifications.load(silent: true);
  }

  /// Yagona appbar sarlavhasi — tab'ga qarab o'zgaradi.
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
              style: context.textStyles.bodyMedium!.copyWith(
                color: c.textMuted,
              ),
            ),
            Text(
              user?.firstName.isNotEmpty == true
                  ? user!.firstName
                  : l10n.tabTasks,
              style: context.textStyles.headlineSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      case 1:
        return Text(l10n.roomsTitle, style: context.textStyles.headlineSmall);
      case 2:
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
      default:
        return Text(l10n.profileTitle, style: context.textStyles.headlineSmall);
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
        BlocProvider.value(value: _tasks),
        BlocProvider.value(value: _rooms),
        BlocProvider.value(value: _chat),
        BlocProvider.value(value: _notifications),
        BlocProvider.value(value: _profile),
      ],
      // Appbar va tab-bar shishasi bitta fon o'qishidan foydalanadi
      child: GlassScope(
        child: Scaffold(
          // iOS 26 shisha panellar: kontent appbar va tab-bar ostidan
          // skroll bo'lib o'tadi, blur orqali ko'rinadi.
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: GlassAppBar(
            title: Builder(builder: _title),
            actions: [
              IconButton(
                onPressed: _refreshCurrent,
                icon: const Icon(CupertinoIcons.arrow_clockwise, size: 24),
                tooltip: l10n.refresh,
              ),
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: NotificationBell(),
              ),
            ],
          ),
          // Ko'rinmas tablardagi animatsiya uxlaydi — ekranni bekorga
          // qayta chizdirmaydi
          body: TickerIndexedStack(
            index: _index,
            children: const [
              TasksPage(),
              RoomsPage(),
              ChatPage(),
              ProfilePage(),
            ],
          ),
          bottomNavigationBar: AppNavBar(
            selectedIndex: _index,
            onSelected: _onTabSelected,
            destinations: [
              NavigationDestination(
                icon: const Icon(CupertinoIcons.sparkles),
                label: l10n.tabTasks,
              ),
              NavigationDestination(
                icon: const Icon(CupertinoIcons.bed_double),
                selectedIcon: const Icon(CupertinoIcons.bed_double_fill),
                label: l10n.tabRooms,
              ),
              NavigationDestination(
                icon: const Icon(CupertinoIcons.chat_bubble),
                selectedIcon: const Icon(CupertinoIcons.chat_bubble_fill),
                label: l10n.tabChat,
              ),
              NavigationDestination(
                icon: const Icon(CupertinoIcons.person),
                selectedIcon: const Icon(CupertinoIcons.person_fill),
                label: l10n.tabProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
