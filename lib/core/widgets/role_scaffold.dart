import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/di.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/chat/presentation/cubit/chat_cubit.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/notifications/presentation/widgets/notification_bell.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../extensions/context_x.dart';
import 'app_nav_bar.dart';
import 'empty_state.dart';
import 'glass.dart';
import 'ticker_indexed_stack.dart';

/// Hali to'liq ishlab chiqilmagan rollar uchun umumiy skelet.
///
/// Har bir rol baribir ishlay oladigan uch bo'lim oladi: o'z bo'limi
/// (hozircha "tez orada" yoki rolga xos boshlang'ich sahifa), chat va profil.
/// Sarlavha, qo'ng'iroqcha va yangilash — barcha tablar uchun yagona appbar'da.
class RoleScaffold extends StatefulWidget {
  const RoleScaffold({
    super.key,
    required this.roleLabel,
    required this.roleIcon,
    this.body,
  });

  final String Function(BuildContext) roleLabel;
  final IconData roleIcon;

  /// Rolning o'z bosh sahifasi. null bo'lsa "tez orada" ko'rsatiladi.
  final Widget? body;

  @override
  State<RoleScaffold> createState() => _RoleScaffoldState();
}

class _RoleScaffoldState extends State<RoleScaffold> {
  int _index = 0;

  void _refreshCurrent(BuildContext context) {
    switch (_index) {
      case 1:
        context.read<ChatCubit>().load(silent: true);
      case 2:
        final user = context.read<AuthCubit>().state.user;
        if (user != null) context.read<ProfileCubit>().load(user.id);
    }
    context.read<NotificationsCubit>().load(silent: true);
  }

  Widget _title(BuildContext context, String label) {
    final l10n = context.l10n;
    final c = context.colors;
    switch (_index) {
      case 1:
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
      case 2:
        return Text(l10n.profileTitle, style: context.textStyles.headlineSmall);
      default:
        return Text(label, style: context.textStyles.headlineSmall);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = widget.roleLabel(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ChatCubit(getIt())
            ..load()
            ..startPolling(),
        ),
        BlocProvider(
          create: (_) => NotificationsCubit(getIt())
            ..load(silent: true)
            ..startPolling(),
        ),
        BlocProvider(create: (_) => ProfileCubit(getIt())),
      ],
      // Builder — appbar ichidan provider'lar ostidagi kontekst kerak.
      // GlassScope — appbar va tab-bar shishasi bitta fon o'qishidan.
      child: Builder(
        builder: (context) => GlassScope(
          child: Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            appBar: GlassAppBar(
              title: _title(context, label),
              actions: [
                IconButton(
                  onPressed: () => _refreshCurrent(context),
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
              children: [
                widget.body ??
                    SafeArea(
                      child: EmptyState(
                        icon: widget.roleIcon,
                        title: l10n.roleHomeSoonTitle(label),
                        body: l10n.roleHomeSoonBody,
                      ),
                    ),
                const ChatPage(),
                const ProfilePage(),
              ],
            ),
            bottomNavigationBar: AppNavBar(
              selectedIndex: _index,
              onSelected: (i) => setState(() => _index = i),
              destinations: [
                NavigationDestination(
                  icon: Icon(widget.roleIcon),
                  label: label,
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
      ),
    );
  }
}
