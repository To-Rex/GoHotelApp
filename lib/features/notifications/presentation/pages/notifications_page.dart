import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/datetime_x.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/glass.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../domain/staff_notification.dart';
import '../cubit/notifications_cubit.dart';

/// Bildirishnomalar ro'yxati.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static Future<void> open(BuildContext context) {
    final cubit = context.read<NotificationsCubit>()..load(silent: true);
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: cubit, child: const NotificationsPage()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) => state.unreadCount == 0
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextButton(
                      onPressed: () =>
                          context.read<NotificationsCubit>().markAllRead(),
                      child: Text(l10n.markAllRead),
                    ),
                  ),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final topPad = MediaQuery.paddingOf(context).top;
          return BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state.loading && state.items.isEmpty) {
                return Padding(
                  padding: EdgeInsets.only(top: topPad),
                  child: const ListSkeleton(itemHeight: 88),
                );
              }
              if (state.error != null && state.items.isEmpty) {
                return Padding(
                  padding: EdgeInsets.only(top: topPad),
                  child: ErrorState(
                    error: state.error!,
                    onRetry: () => context.read<NotificationsCubit>().load(),
                  ),
                );
              }
              if (state.items.isEmpty) {
                return Padding(
                  padding: EdgeInsets.only(top: topPad),
                  child: EmptyState(
                    icon: Icons.notifications_none_rounded,
                    title: l10n.noNotifsTitle,
                    body: l10n.noNotifsBody,
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<NotificationsCubit>().load(silent: true),
                edgeOffset: topPad,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20, topPad + 8, 20, 24),
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _NotificationTile(notification: state.items[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final StaffNotification notification;

  (IconData, Color, Color) _style(BuildContext context) {
    final c = context.colors;
    return switch (notification.type) {
      'critical' => (Icons.priority_high_rounded, c.dangerSoft, c.danger),
      'newTask' => (
        Icons.cleaning_services_rounded,
        c.brandSoft,
        c.onBrandSoft,
      ),
      'problemAccepted' => (Icons.task_alt_rounded, c.successSoft, c.success),
      'inventory' => (Icons.inventory_2_outlined, c.warningSoft, c.warning),
      _ => (Icons.info_outline_rounded, c.infoSoft, c.info),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final (icon, bg, fg) = _style(context);

    return AppCard(
      onTap: notification.isRead
          ? null
          : () => context.read<NotificationsCubit>().markRead(notification.id),
      padding: const EdgeInsets.all(14),
      borderColor: notification.isRead ? null : c.brand.withValues(alpha: 0.4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: fg, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: context.textStyles.titleSmall!.copyWith(
                          fontWeight: notification.isRead
                              ? FontWeight.w600
                              : FontWeight.w800,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: c.brand,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  notification.message,
                  style: context.textStyles.bodyMedium!.copyWith(
                    color: c.textMuted,
                  ),
                ),
                if (notification.timestamp != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    notification.timestamp!.shortWhen(todayLabel: l10n.today),
                    style: context.textStyles.labelSmall!.copyWith(
                      color: c.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
