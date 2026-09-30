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
import '../bookings/presentation/cubit/bookings_cubit.dart';
import '../bookings/presentation/pages/bookings_page.dart';
import '../report/presentation/cubit/report_cubit.dart';
import '../calls/call_watcher_service.dart';
import '../report/presentation/pages/report_page.dart';
import '../scan/presentation/scan_flow.dart';

/// Qabulxona bosh oynasi: Bronlar, Hisobot, Xabarlar, Profil.
///
/// Farrosh oynasidan ATAYLAB alohida: resepsiyada vazifa va xona
/// bo'limlari yo'q, farroshda esa bron va hisobot yo'q. Ikkalasi bitta
/// shellga tiqilsa, har rol o'ziga keraksiz tugmalarni ko'rib turardi
/// va ruxsati yo'q bo'limga bosib xato olardi.
///
/// Cubitlar shu yerda yaratiladi: ilova fonga o'tganda pollinglar
/// to'xtaydi, qaytganda hammasi jim yangilanadi.
class ReceptionShell extends StatefulWidget {
  const ReceptionShell({super.key});

  @override
  State<ReceptionShell> createState() => _ReceptionShellState();
}

class _ReceptionShellState extends State<ReceptionShell>
    with WidgetsBindingObserver {
  int _index = 0;

  late final BookingsCubit _bookings;
  late final ReportCubit _report;
  late final ChatCubit _chat;
  late final NotificationsCubit _notifications;
  late final ProfileCubit _profile;
  late final CallWatcherService _calls;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bookings = BookingsCubit(getIt())
      ..load()
      ..startPolling();
    _report = ReportCubit(getIt())..load();
    _chat = ChatCubit(getIt())
      ..load()
      ..startPolling();
    _notifications = NotificationsCubit(getIt())
      ..load(silent: true)
      ..startPolling();
    _profile = ProfileCubit(getIt());

    /* Kiruvchi qo'ng'iroq kuzatuvchisi FAQAT shu rolda ishga tushadi:
       farrosh ilovasida u umuman yoqilmaydi. Ruxsat berilmagan bo'lsa
       xizmat jim qoladi — taklif kartasi bronlar sahifasida chiqadi. */
    _calls = getIt<CallWatcherService>();
    _calls.start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Xizmat DI'da yagona nusxa — uni yopmaymiz, faqat tinglashni
    // to'xtatamiz: rol almashsa qayta ishga tushirilishi kerak
    _calls.stop();
    _bookings.close();
    _report.close();
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
        _bookings.startPolling();
        _chat.startPolling();
        _notifications.startPolling();
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _bookings.stopPolling();
        _chat.stopPolling();
        _notifications.stopPolling();
      default:
        break;
    }
  }

  void _refreshAll() {
    _bookings.load(silent: true);
    _report.load(silent: true);
    _chat.load(silent: true);
    _notifications.load(silent: true);
  }

  void _onTabSelected(int index) {
    setState(() => _index = index);
    _refreshCurrent();
  }

  /// Joriy bo'lim ma'lumotini jim yangilaydi (tab almashganda va
  /// appbar'dagi "yangilash" tugmasida).
  void _refreshCurrent() {
    switch (_index) {
      case 0:
        _bookings.load(silent: true);
      case 1:
        _report.load(silent: true);
      case 2:
        _chat.load(silent: true);
      case 3:
        final user = context.read<AuthCubit>().state.user;
        if (user != null) _profile.load(user.id);
    }
    _notifications.load(silent: true);
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
              style: context.textStyles.bodyMedium!.copyWith(
                color: c.textMuted,
              ),
            ),
            Text(
              user?.firstName.isNotEmpty == true
                  ? user!.firstName
                  : l10n.bookingsTitle,
              style: context.textStyles.headlineSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      case 1:
        return Text(l10n.tabReport, style: context.textStyles.headlineSmall);
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
        BlocProvider.value(value: _bookings),
        BlocProvider.value(value: _report),
        BlocProvider.value(value: _chat),
        BlocProvider.value(value: _notifications),
        BlocProvider.value(value: _profile),
      ],
      // Appbar va tab-bar shishasi bitta fon o'qishidan foydalanadi
      child: GlassScope(
        child: Scaffold(
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
              BookingsPage(),
              ReportPage(),
              ChatPage(),
              ProfilePage(),
            ],
          ),
          bottomNavigationBar: AppNavBar(
            selectedIndex: _index,
            onSelected: _onTabSelected,
            /* Hujjat skaneri — tab emas, amal: mehmonning pasporti
             suratga olinadi va natija qabulxona kompyuteridagi bandlov
             oynasini ochadi. Farrosh qobig'ida bu tugma yo'q. */
            centerAction: NavBarAction(
              icon: Icons.document_scanner_outlined,
              label: l10n.scanTitle,
              onTap: () => startDocumentScan(context),
            ),
            destinations: [
              NavigationDestination(
                icon: const Icon(CupertinoIcons.calendar),
                label: l10n.tabBookings,
              ),
              NavigationDestination(
                icon: const Icon(CupertinoIcons.chart_bar),
                selectedIcon: const Icon(CupertinoIcons.chart_bar_fill),
                label: l10n.tabReport,
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
